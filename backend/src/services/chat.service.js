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
  deleteMessage,
  addMessageReaction,
  removeMessageReaction,
  getMessageReactions,
  pinMessage as pinMessageDb,
  unpinMessage as unpinMessageDb,
  getPinnedMessages,
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
    metadata: row.metadata ?? {},
    last_message_at: row.last_message_at,
    created_at: row.created_at,
    unread_count: row.unread_count ?? 0,
    last_message: row.last_message ?? null,
    members: members.map(serializeMember),
    my_role: row.role ?? null,
    last_read_at: row.last_read_at ?? null,
  };
}

function serializeMessage(row, receipts = [], reactions = []) {
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
    reactions: reactions,
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

export async function createGroupConversation(userId, { title, memberIds = [], kind = 'group', privacy = 'public' }) {
  if (!title?.trim()) throw new AppError('Group title is required', 400);

  const uniqueMembers = [...new Set([userId, ...memberIds])];
  if (uniqueMembers.length < 1) {
    throw new AppError('Group requires at least 1 member', 400);
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
    metadata: {
      kind: kind === 'channel' ? 'channel' : 'group',
      privacy: privacy ?? 'public',
    },
  });

  for (const memberId of uniqueMembers) {
    await invalidateUserConversations(memberId);
  }

  return getConversation(userId, conversation.id);
}

export async function getConversationMessages(userId, conversationId, { limit = 50, before = null }) {
  await assertMember(conversationId, userId);

  const rows = await listMessages(conversationId, { limit, before });
  
  // Batch fetch receipts for all messages to avoid N+1 queries
  const messageIds = rows.map(row => row.id);
  const { getMessageReceiptsBatch, getMessageReactionsBatch } = await import('../models/message.model.js');
  const [receiptsMap, reactionsMap] = await Promise.all([
    getMessageReceiptsBatch(messageIds),
    getMessageReactionsBatch(messageIds),
  ]);
  
  const messages = rows.map(row => {
    const receipts = receiptsMap.get(row.id) || [];
    const reactions = reactionsMap.get(row.id) || [];
    return serializeMessage(row, receipts, reactions);
  });

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
  const reactions = await getMessageReactions(message.id);
  const payload = serializeMessage(message, receipts, reactions);

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
      const conversation = await getConversationById(conversationId, userId);
      const isGroup = conversation?.type === 'group';
      
      for (const recipientId of recipientIds) {
        let notificationType = 'message';
        let notificationBody = payload.message_type === 'text' ? payload.body : `Sent a ${payload.message_type}`;
        
        // Determine notification type based on message type
        if (payload.message_type === 'voice') {
          notificationType = 'message_voice';
          notificationBody = 'Sent you a voice message';
        } else if (payload.message_type === 'image') {
          notificationType = 'message_photo';
          notificationBody = 'Sent you a photo';
        } else if (payload.message_type === 'video') {
          notificationType = 'message_video';
          notificationBody = 'Sent you a video';
        } else if (payload.message_type === 'reel') {
          notificationType = 'message_reel';
          notificationBody = 'Sent you a reel';
        }
        
        // Check for mentions in message body
        if (payload.body && payload.message_type === 'text') {
          const mentionRegex = /@(\w+)/g;
          const mentions = payload.body.match(mentionRegex);
          if (mentions && mentions.includes(`@${sender.username}`)) {
            notificationType = 'message_mention';
            notificationBody = 'Mentioned you in a message';
          }
        }
        
        // Check if this is a reply (metadata would contain reply_to info)
        if (payload.metadata?.reply_to) {
          notificationType = 'message_reply';
          notificationBody = 'Replied to your message';
        }
        
        const title = isGroup 
          ? `${conversation.title || 'Group'} — ${sender.username}`
          : sender.username;
        
        await sendPushNotification(recipientId, {
          title,
          body: notificationBody,
          data: {
            type: isGroup ? 'group_message' : notificationType,
            conversation_id: conversationId,
            message_id: payload.id,
            sender_id: userId,
            message_type: payload.message_type,
          },
        });
      }
    }
  } catch (err) {
    console.error('Failed to send FCM notifications for chat message', err);
  }

  return payload;
}

export async function unsendMessage(userId, conversationId, messageId) {
  await assertMember(conversationId, userId);

  const deleted = await deleteMessage(messageId, userId);
  if (!deleted) throw new AppError('Message not found or not authorized', 404);

  await touchConversation(conversationId);

  const memberIds = await getMemberIds(conversationId);
  const io = getIO();
  
  io?.to(`conversation:${conversationId}`).emit('message:deleted', {
    message_id: messageId,
    conversation_id: conversationId,
    deleted_by: userId,
    deleted_at: new Date().toISOString(),
  });

  for (const memberId of memberIds) {
    await invalidateUserConversations(memberId);
  }

  return { success: true, message_id: messageId };
}

export async function addReaction(userId, conversationId, messageId, emoji) {
  await assertMember(conversationId, userId);

  const reaction = await addMessageReaction(messageId, userId, emoji);
  if (!reaction) throw new AppError('Failed to add reaction', 500);

  const reactions = await getMessageReactions(messageId);
  const io = getIO();
  
  io?.to(`conversation:${conversationId}`).emit('message:reaction', {
    message_id: messageId,
    conversation_id: conversationId,
    user_id: userId,
    emoji: emoji,
    reactions: reactions,
  });

  // Send push notification to message author if someone else reacted
  const { getMessageById } = await import('../models/message.model.js');
  const message = await getMessageById(messageId);
  if (message && message.sender_id !== userId) {
    const { sendPushNotification } = await import('./notification.service.js');
    const reactor = await findUserById(userId);
    if (reactor) {
      const reactorName = reactor.username || 'Someone';
      sendPushNotification(message.sender_id, {
        title: 'Reaction on Message',
        body: `${reactorName} reacted to your message`,
        data: {
          type: 'message_reaction',
          conversation_id: conversationId,
          message_id: messageId,
          reactor_id: userId,
          emoji: emoji,
        },
      });
    }
  }

  return { success: true, reaction, reactions };
}

export async function removeReaction(userId, conversationId, messageId) {
  await assertMember(conversationId, userId);

  const removed = await removeMessageReaction(messageId, userId);
  if (!removed) throw new AppError('Reaction not found', 404);

  const reactions = await getMessageReactions(messageId);
  const io = getIO();
  
  io?.to(`conversation:${conversationId}`).emit('message:reaction_removed', {
    message_id: messageId,
    conversation_id: conversationId,
    user_id: userId,
    reactions: reactions,
  });

  return { success: true, reactions };
}

export async function pinMessage(userId, conversationId, messageId) {
  await assertMember(conversationId, userId);

  const pinned = await pinMessageDb(conversationId, messageId, userId);
  if (!pinned) throw new AppError('Failed to pin message', 500);

  const pinnedMessages = await getPinnedMessages(conversationId, userId);
  const io = getIO();
  
  io?.to(`conversation:${conversationId}`).emit('message:pinned', {
    conversation_id: conversationId,
    message_id: messageId,
    user_id: userId,
    pinned_messages: pinnedMessages,
  });

  return { success: true, pinned, pinned_messages };
}

export async function unpinMessage(userId, conversationId) {
  await assertMember(conversationId, userId);

  const unpinned = await unpinMessageDb(conversationId, userId);
  if (!unpinned) throw new AppError('No pinned message found', 404);

  const pinnedMessages = await getPinnedMessages(conversationId, userId);
  const io = getIO();
  
  io?.to(`conversation:${conversationId}`).emit('message:unpinned', {
    conversation_id: conversationId,
    user_id: userId,
    pinned_messages: pinnedMessages,
  });

  return { success: true, pinned_messages };
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

export async function leaveConversation(userId, conversationId) {
  await assertMember(conversationId, userId);
  const removed = await removeConversationMember(conversationId, userId);
  if (!removed) throw new AppError('Could not leave conversation', 404);

  const io = getIO();
  io?.to(`conversation:${conversationId}`).emit('conversation:member_removed', {
    conversation_id: conversationId,
    user_id: userId,
  });
  io?.to(`user:${userId}`).emit('conversation:left', { conversation_id: conversationId });

  await invalidateUserConversations(userId);
  return { success: true, conversation_id: conversationId };
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
