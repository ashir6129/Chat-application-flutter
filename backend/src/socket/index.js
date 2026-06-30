import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import env from '../config/env.js';
import { getRedis, isRedisEnabled } from '../config/redis.js';
import { socketAuth } from './auth.js';
import { setUserOnline, setUserOffline, isUserOnline } from './presence.js';
import { updateLastSeen } from '../models/user.model.js';
import { findUserById } from '../models/user.model.js';
import {
  listUserConversationIds,
  listConversationPartnerIds,
} from '../models/conversation.model.js';
import * as chatService from '../services/chat.service.js';
import { isConversationMember } from '../models/conversation.model.js';
import { sendPushNotification } from '../services/notification.service.js';

let ioInstance = null;

export async function initSocket(httpServer) {
  ioInstance = new Server(httpServer, {
    path: env.socket.path,
    cors: {
      origin: env.cors.origin,
      credentials: env.cors.credentials,
    },
  });

  if (isRedisEnabled()) {
    const redis = getRedis();
    const pubClient = redis.duplicate();
    const subClient = redis.duplicate();
    ioInstance.adapter(createAdapter(pubClient, subClient));
    console.log('Socket.IO using Redis adapter');
  }

  ioInstance.use(socketAuth);

  ioInstance.on('connection', async (socket) => {
    const userId = socket.userId;
    setUserOnline(userId, socket.id);
    socket.join(`user:${userId}`);

    socket.emit('connected', { user_id: userId });

    try {
      const conversationIds = await listUserConversationIds(userId);
      for (const conversationId of conversationIds) {
        socket.join(`conversation:${conversationId}`);
      }
      await chatService.deliverAllPendingForUser(userId);

      const partnerIds = await listConversationPartnerIds(userId);
      const onlinePayload = { user_id: userId, is_online: true };
      for (const partnerId of partnerIds) {
        ioInstance.to(`user:${partnerId}`).emit('presence:changed', onlinePayload);
        if (isUserOnline(partnerId)) {
          socket.emit('presence:changed', {
            user_id: partnerId,
            is_online: true,
          });
        }
      }
    } catch (err) {
      console.error('Socket connect setup failed:', err.message);
    }

    socket.on('conversation:join', async (payload, ack) => {
      try {
        const conversationId = payload?.conversation_id;
        if (!conversationId) throw new Error('conversation_id is required');

        const allowed = await isConversationMember(conversationId, userId);
        if (!allowed) throw new Error('Not a member of this conversation');

        socket.join(`conversation:${conversationId}`);
        await chatService.deliverPendingMessages(userId, conversationId);

        ack?.({ success: true, conversation_id: conversationId });
      } catch (err) {
        ack?.({ success: false, message: err.message });
      }
    });

    socket.on('conversation:leave', (payload) => {
      const conversationId = payload?.conversation_id;
      if (conversationId) {
        socket.leave(`conversation:${conversationId}`);
      }
    });

    socket.on('message:send', async (payload, ack) => {
      try {
        const conversationId = payload?.conversation_id;
        const body = payload?.body ?? '';
        const messageType = payload?.message_type ?? 'text';
        const metadata = payload?.metadata ?? {};

        const message = await chatService.sendMessage(userId, conversationId, body, {
          messageType,
          metadata,
        });

        ack?.({ success: true, message });
      } catch (err) {
        ack?.({ success: false, message: err.message });
      }
    });

    socket.on('message:read', async (payload, ack) => {
      try {
        const conversationId = payload?.conversation_id;
        const result = await chatService.markRead(userId, conversationId);
        ack?.({ success: true, ...result });
      } catch (err) {
        ack?.({ success: false, message: err.message });
      }
    });

    socket.on('typing:start', (payload) => {
      const conversationId = payload?.conversation_id;
      if (!conversationId) return;
      socket.to(`conversation:${conversationId}`).emit('typing:start', {
        conversation_id: conversationId,
        user_id: userId,
        username: socket.username,
      });
    });

    socket.on('typing:stop', (payload) => {
      const conversationId = payload?.conversation_id;
      if (!conversationId) return;
      socket.to(`conversation:${conversationId}`).emit('typing:stop', {
        conversation_id: conversationId,
        user_id: userId,
      });
    });

    // --- WebRTC Call Signaling ---
    socket.on('call:offer', async (payload) => {
      const peerId = payload?.peer_id;
      if (!peerId) return;
      
      // Check if peer is online before attempting call
      if (!isUserOnline(peerId)) {
        socket.emit('call:error', {
          error: 'User is offline',
          peer_id: peerId,
        });
        return;
      }
      
      // Check if users can call each other (mutual follow or accepted conversation)
      try {
        const { isFollowing } = await import('./models/follow.model.js');
        const { findBoxRequestBetween } = await import('./models/box.model.js');
        const { findDirectConversation } = await import('./models/conversation.model.js');
        const { query } = await import('./config/db.js');
        
        const followingTarget = await isFollowing(userId, peerId);
        const targetFollowingUs = await isFollowing(peerId, userId);
        const isMutualFollow = followingTarget && targetFollowingUs;
        
        const box = await findBoxRequestBetween(userId, peerId);
        const isBoxAccepted = box && box.status === 'accepted';
        
        // Check conversation status if it exists
        const conversation = await findDirectConversation(userId, peerId);
        let isConversationAccepted = false;
        if (conversation) {
          const memberStatus = await query(
            `SELECT status FROM conversation_members 
             WHERE conversation_id = $1 AND user_id = $2`,
            [conversation.id, peerId]
          );
          isConversationAccepted = memberStatus.rows[0]?.status === 'accepted';
        }
        
        const canCall = isMutualFollow || isBoxAccepted || isConversationAccepted;
        
        if (!canCall) {
          socket.emit('call:error', {
            error: 'You can call once your message request is accepted or you mutually follow each other',
            peer_id: peerId,
          });
          return;
        }
      } catch (err) {
        console.error('Error checking call permissions:', err.message);
        // Allow call if check fails (fail open for better UX)
      }
      
      let callerAvatar = null;
      let callerUsername = socket.username;
      try {
        const caller = await findUserById(userId);
        callerAvatar = caller?.avatar_url ?? null;
        callerUsername = caller?.username ?? socket.username;
      } catch (_) {
        /* ignore */
      }
      
      // Send push notification for incoming call
      const callType = payload?.call_type === 'video' ? 'video' : 'voice';
      sendPushNotification(peerId, {
        title: callType === 'video' ? 'Video Call' : 'Voice Call',
        body: `${callerUsername} is calling you`,
        data: {
          type: callType === 'video' ? 'video_call' : 'voice_call',
          caller_id: userId,
          caller_username: callerUsername,
          caller_avatar: callerAvatar,
        },
      }).catch(err => console.error('Failed to send call notification:', err.message));
      
      socket.to(`user:${peerId}`).emit('call:offer', {
        ...payload,
        caller_id: userId,
        caller_username: callerUsername,
        caller_avatar: callerAvatar,
      });
    });

    socket.on('call:answer', (payload) => {
      const callerId = payload?.caller_id;
      if (!callerId) return;
      socket.to(`user:${callerId}`).emit('call:answer', {
        ...payload,
        answerer_id: userId,
      });
    });

    socket.on('call:ice-candidate', (payload) => {
      const toId = payload?.to_id;
      if (!toId) return;
      socket.to(`user:${toId}`).emit('call:ice-candidate', {
        ...payload,
        from_id: userId,
      });
    });

    socket.on('call:end', (payload) => {
      const toId = payload?.to_id;
      if (!toId) return;
      
      // Send missed call notification if call ended without being answered
      // This would typically be tracked on the client side, but we can send a notification here
      sendPushNotification(toId, {
        title: 'Missed Call',
        body: `${socket.username} called you`,
        data: {
          type: 'missed_call',
          caller_id: userId,
          caller_username: socket.username,
        },
      }).catch(err => console.error('Failed to send missed call notification:', err.message));
      
      socket.to(`user:${toId}`).emit('call:end', {
        from_id: userId,
      });
    });

    socket.on('call:reject', (payload) => {
      const callerId = payload?.caller_id;
      if (!callerId) return;
      
      // Send missed call notification to caller
      sendPushNotification(callerId, {
        title: 'Missed Call',
        body: `${socket.username} declined your call`,
        data: {
          type: 'missed_call',
          caller_id: userId,
          caller_username: socket.username,
        },
      }).catch(err => console.error('Failed to send missed call notification:', err.message));
      
      socket.to(`user:${callerId}`).emit('call:reject', {
        rejecter_id: userId,
      });
    });

    socket.on('disconnect', async () => {
      setUserOffline(userId, socket.id);
      try {
        // Only update last_seen when user is truly offline (no more active sockets)
        if (!isUserOnline(userId)) {
          await updateLastSeen(userId);
          // Fetch the updated last_seen from database to ensure accuracy
          const user = await findUserById(userId);
          const partnerIds = await listConversationPartnerIds(userId);
          const offlinePayload = {
            user_id: userId,
            is_online: false,
            last_seen_at: user?.last_seen_at?.toISOString() || new Date().toISOString(),
          };
          for (const partnerId of partnerIds) {
            ioInstance.to(`user:${partnerId}`).emit('presence:changed', offlinePayload);
          }
        }
      } catch (_) {
        /* ignore */
      }
    });
  });

  return ioInstance;
}

export function getIO() {
  return ioInstance;
}
