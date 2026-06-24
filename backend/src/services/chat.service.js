import { AppError } from '../utils/AppError.js';
import {
  findDirectConversation,
  createConversation,
  isConversationMember,
  getConversationById,
  listUserConversations,
  listConversationMembers,
  addConversationMember,
  removeConversationMember,
  updateLastRead,
  touchConversation,
} from '../models/conversation.model.js';
import {
  createMessage,
  listMessages,
  createReceipts,
  markConversationDelivered,
  markAllDeliveredForUser,
  markConversationRead,
  getMessageReceipts,
  getMemberIds,
  updateReceiptStatus,
} from '../models/message.model.js';
import { findUserById } from '../models/user.model.js';
import env from '../config/env.js';
import { getIO } from '../socket/index.js';
import { isUserOnline } from '../socket/presence.js';
import {
  cacheRemember,
  invalidateUserConversations,
} from '../utils/cache.js';

function serializeMember(row) {
  return {
    user_id: row.user_id,
    username: row.username,
    avatar_url: row.avatar_url,
    is_verified: row.is_verified,
    role: row.role,
    joined_at: row.joined_at,
    last_read_at: row.last_read_at,
    is_online: isUserOnline(row.user_id),
    last_seen_at: row.last_seen_at,
  };
}

function serializeConversation(row, members = []) {
  return {
    id: row.id,
    type: row.type,
    title: row.title,
    avatar_url: row.avatar_url,
    last_message_at: row.last_message_at,
    created_at: row.created_at,
    unread_count: row.unread_count ?? 0,
    last_message: row.last_message ?? null,
    members: members.map(serializeMember),
    my_role: row.role ?? null,
    last_read_at: row.last_read_at ?? null,
  };
}

function serializeMessage(row, receipts = []) {
  return {
    id: row.id,
    conversation_id: row.conversation_id,
    sender_id: row.sender_id,
    sender_username: row.sender_username,
    sender_avatar: row.sender_avatar,
    body: row.body,
    message_type: row.message_type,
    metadata: row.metadata ?? {},
    created_at: row.created_at,
    receipts: receipts.map((r) => ({
      user_id: r.user_id,
      username: r.username,
      status: r.status,
      updated_at: r.updated_at,
    })),
  };
}

export async function getConversations(userId, { page = 1, limit = 30 }) {
  return cacheRemember(
    `conversations:${userId}:${page}:${limit}`,
    env.redis.conversationsTtlSeconds,
    async () => {
      const offset = (page - 1) * limit;
      const rows = await listUserConversations(userId, { limit, offset });

      const conversations = await Promise.all(
        rows.map(async (row) => {
          const members = await listConversationMembers(row.id);
          return serializeConversation(row, members);
        }),
      );

      return { conversations, page, limit };
    },
  );
}

export async function getConversation(userId, conversationId) {
  await assertMember(conversationId, userId);

  const row = await getConversationById(conversationId, userId);
  if (!row) throw new AppError('Conversation not found', 404);

  const members = await listConversationMembers(conversationId);
  return serializeConversation(row, members);
}

export async function startDirectConversation(userId, targetUserId) {
  if (userId === targetUserId) {
    throw new AppError('Cannot start a conversation with yourself', 400);
  }

  const target = await findUserById(targetUserId);
  if (!target) throw new AppError('User not found', 404);

  // Enforce ZyntraPlus rules: require accepted Box request OR mutual follow
  const { findBoxRequestBetween } = await import('../models/box.model.js');
  const box = await findBoxRequestBetween(userId, targetUserId);
  const isBoxAccepted = box && box.status === 'accepted';

  if (!isBoxAccepted) {
    const { isFollowing } = await import('../models/follow.model.js');
    const followingTarget = await isFollowing(userId, targetUserId);
    const targetFollowingUs = await isFollowing(targetUserId, userId);
    const isMutualFollow = followingTarget && targetFollowingUs;

    if (!isMutualFollow) {
      throw new AppError('Unlock connection via Box request or mutual follow to start chat', 403);
    }
  }

  const existing = await findDirectConversation(userId, targetUserId);
  if (existing) {
    return getConversation(userId, existing.id);
  }

  const conversation = await createConversation({
    type: 'direct',
    createdBy: userId,
    memberIds: [userId, targetUserId],
    roles: { [userId]: 'member', [targetUserId]: 'member' },
  });

  await invalidateUserConversations(userId);
  await invalidateUserConversations(targetUserId);

  return getConversation(userId, conversation.id);
}

export async function createGroupConversation(userId, { title, memberIds = [] }) {
  if (!title?.trim()) throw new AppError('Group title is required', 400);

  const uniqueMembers = [...new Set([userId, ...memberIds])];
  if (uniqueMembers.length < 2) {
    throw new AppError('Group requires at least 2 members', 400);
  }

  for (const memberId of uniqueMembers) {
    const user = await findUserById(memberId);
    if (!user) throw new AppError(`User not found: ${memberId}`, 404);
  }

  const conversation = await createConversation({
    type: 'group',
    title: title.trim(),
    createdBy: userId,
    memberIds: uniqueMembers,
    roles: { [userId]: 'admin' },
  });

  for (const memberId of uniqueMembers) {
    await invalidateUserConversations(memberId);
  }

  return getConversation(userId, conversation.id);
}

export async function getConversationMessages(userId, conversationId, { limit = 50, before = null }) {
  await assertMember(conversationId, userId);

  const rows = await listMessages(conversationId, { limit, before });
  const messages = await Promise.all(
    rows.map(async (row) => {
      const receipts = await getMessageReceipts(row.id);
      return serializeMessage(row, receipts);
    }),
  );

  return { messages, limit, before };
}

export async function sendMessage(userId, conversationId, body, options = {}) {
  await assertMember(conversationId, userId);

  const trimmed = body?.trim();
  if (!trimmed && !['image', 'voice'].includes(options.messageType)) {
    throw new AppError('Message body is required', 400);
  }

  const message = await createMessage({
    conversationId,
    senderId: userId,
    body: trimmed ?? '',
    messageType: options.messageType ?? 'text',
    metadata: options.metadata ?? {},
  });

  await touchConversation(conversationId);

  const memberIds = await getMemberIds(conversationId);
  const recipientIds = memberIds.filter((id) => id !== userId);

  await createReceipts(message.id, recipientIds, 'sent');

  const deliveredRows = [];
  for (const recipientId of recipientIds) {
    if (isUserOnline(recipientId)) {
      const updated = await updateReceiptStatus(message.id, recipientId, 'delivered');
      if (updated) {
        deliveredRows.push({
          message_id: message.id,
          conversation_id: conversationId,
          sender_id: userId,
        });
      }
    }
  }
  if (deliveredRows.length) {
    emitReceiptUpdates(deliveredRows, 'delivered');
  }

  const receipts = await getMessageReceipts(message.id);
  const payload = serializeMessage(message, receipts);

  const io = getIO();
  io?.to(`conversation:${conversationId}`).emit('message:new', payload);
  for (const memberId of memberIds) {
    io?.to(`user:${memberId}`).emit('conversation:updated', {
      conversation_id: conversationId,
      last_message: payload,
    });
    await invalidateUserConversations(memberId);
  }

  // FCM Push Notifications for recipients
  try {
    const sender = await findUserById(userId);
    const { sendPushNotification } = await import('./notification.service.js');
    if (sender) {
      for (const recipientId of recipientIds) {
        await sendPushNotification(recipientId, {
          title: sender.username,
          body: payload.message_type === 'text' ? payload.body : `Sent a ${payload.message_type}`,
          data: {
            type: 'chat_message',
            conversation_id: conversationId,
            message_id: payload.id,
            sender_id: userId,
          },
        });
      }
    }
  } catch (err) {
    console.error('Failed to send FCM notifications for chat message', err);
  }

  return payload;
}

export async function markRead(userId, conversationId) {
  await assertMember(conversationId, userId);
  await updateLastRead(conversationId, userId);
  await markConversationRead(conversationId, userId);

  const io = getIO();
  const readPayload = {
    conversation_id: conversationId,
    user_id: userId,
    read_at: new Date().toISOString(),
    status: 'read',
  };
  io?.to(`conversation:${conversationId}`).emit('message:read', readPayload);
  io?.to(`conversation:${conversationId}`).emit('message:receipts', {
    ...readPayload,
    message_ids: [],
  });

  const memberIds = await getMemberIds(conversationId);
  for (const memberId of memberIds) {
    if (memberId !== userId) {
      io?.to(`user:${memberId}`).emit('message:read', readPayload);
      io?.to(`user:${memberId}`).emit('message:receipts', {
        ...readPayload,
        message_ids: [],
      });
    }
  }

  return { success: true, conversation_id: conversationId };
}

export async function addGroupMember(userId, conversationId, memberId) {
  const conversation = await getConversationById(conversationId, userId);
  if (!conversation) throw new AppError('Conversation not found', 404);
  if (conversation.type !== 'group') throw new AppError('Not a group conversation', 400);
  if (conversation.role !== 'admin') throw new AppError('Only admins can add members', 403);

  const user = await findUserById(memberId);
  if (!user) throw new AppError('User not found', 404);

  await addConversationMember(conversationId, memberId);

  const io = getIO();
  io?.to(`conversation:${conversationId}`).emit('conversation:member_added', {
    conversation_id: conversationId,
    user_id: memberId,
    username: user.username,
  });

  return getConversation(userId, conversationId);
}

export async function removeGroupMember(userId, conversationId, memberId) {
  const conversation = await getConversationById(conversationId, userId);
  if (!conversation) throw new AppError('Conversation not found', 404);
  if (conversation.type !== 'group') throw new AppError('Not a group conversation', 400);

  const isSelfLeave = userId === memberId;
  if (!isSelfLeave && conversation.role !== 'admin') {
    throw new AppError('Only admins can remove members', 403);
  }

  const removed = await removeConversationMember(conversationId, memberId);
  if (!removed) throw new AppError('Member not found in conversation', 404);

  const io = getIO();
  io?.to(`conversation:${conversationId}`).emit('conversation:member_removed', {
    conversation_id: conversationId,
    user_id: memberId,
  });
  io?.to(`user:${memberId}`).emit('conversation:left', { conversation_id: conversationId });

  return { success: true, conversation_id: conversationId, user_id: memberId };
}

async function assertMember(conversationId, userId) {
  const member = await isConversationMember(conversationId, userId);
  if (!member) throw new AppError('Conversation not found', 404);
}

function emitReceiptUpdates(rows, status) {
  const io = getIO();
  if (!io || !rows?.length) return;

  const byConversation = new Map();
  for (const row of rows) {
    if (!byConversation.has(row.conversation_id)) {
      byConversation.set(row.conversation_id, []);
    }
    byConversation.get(row.conversation_id).push(row);
  }

  for (const [conversationId, updates] of byConversation) {
    const senderIds = [...new Set(updates.map((r) => r.sender_id))];
    const payload = {
      conversation_id: conversationId,
      status,
      message_ids: updates.map((r) => r.message_id),
    };
    io.to(`conversation:${conversationId}`).emit('message:receipts', payload);
    for (const senderId of senderIds) {
      io.to(`user:${senderId}`).emit('message:receipts', payload);
    }
  }
}

export async function deliverPendingMessages(userId, conversationId) {
  await assertMember(conversationId, userId);
  const rows = await markConversationDelivered(conversationId, userId);
  emitReceiptUpdates(rows, 'delivered');
}

export async function deliverAllPendingForUser(userId) {
  const rows = await markAllDeliveredForUser(userId);
  emitReceiptUpdates(rows, 'delivered');
}
