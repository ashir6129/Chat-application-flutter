import { query } from '../config/db.js';

export async function createNotification({ recipientId, senderId, type, message, metadata = {} }) {
  const result = await query(
    `INSERT INTO notifications (recipient_id, sender_id, type, message, metadata)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, recipient_id, sender_id, type, message, is_read, metadata, created_at`,
    [recipientId, senderId || null, type, message, JSON.stringify(metadata)]
  );
  return result.rows[0];
}

export async function getUserNotificationPreferences(userId) {
  const result = await query(
    `SELECT push_enabled, likes, comments, comment_likes, mentions, new_followers,
            follow_requests, tags, direct_messages, group_messages, message_requests,
            story_replies, story_reactions, story_mentions, voice_calls, video_calls,
            post_shares, tips, new_post_from_following
     FROM notification_preferences
     WHERE user_id = $1`,
    [userId]
  );
  if (result.rows.length === 0) {
    // Return default preferences if none exist
    return {
      push_enabled: true,
      likes: true,
      comments: true,
      comment_likes: false,
      mentions: true,
      new_followers: true,
      follow_requests: true,
      tags: true,
      direct_messages: true,
      group_messages: true,
      message_requests: true,
      story_replies: true,
      story_reactions: true,
      story_mentions: true,
      voice_calls: true,
      video_calls: true,
      post_shares: false,
      tips: true,
      new_post_from_following: false,
    };
  }
  return result.rows[0];
}

export async function updateUserNotificationPreferences(userId, preferences) {
  const {
    push_enabled, likes, comments, comment_likes, mentions, new_followers,
    follow_requests, tags, direct_messages, group_messages, message_requests,
    story_replies, story_reactions, story_mentions, voice_calls, video_calls,
    post_shares, tips, new_post_from_following
  } = preferences;

  const result = await query(
    `INSERT INTO notification_preferences (
      user_id, push_enabled, likes, comments, comment_likes, mentions, new_followers,
      follow_requests, tags, direct_messages, group_messages, message_requests,
      story_replies, story_reactions, story_mentions, voice_calls, video_calls,
      post_shares, tips, new_post_from_following
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
    ON CONFLICT (user_id)
    DO UPDATE SET
      push_enabled = EXCLUDED.push_enabled,
      likes = EXCLUDED.likes,
      comments = EXCLUDED.comments,
      comment_likes = EXCLUDED.comment_likes,
      mentions = EXCLUDED.mentions,
      new_followers = EXCLUDED.new_followers,
      follow_requests = EXCLUDED.follow_requests,
      tags = EXCLUDED.tags,
      direct_messages = EXCLUDED.direct_messages,
      group_messages = EXCLUDED.group_messages,
      message_requests = EXCLUDED.message_requests,
      story_replies = EXCLUDED.story_replies,
      story_reactions = EXCLUDED.story_reactions,
      story_mentions = EXCLUDED.story_mentions,
      voice_calls = EXCLUDED.voice_calls,
      video_calls = EXCLUDED.video_calls,
      post_shares = EXCLUDED.post_shares,
      tips = EXCLUDED.tips,
      new_post_from_following = EXCLUDED.new_post_from_following,
      updated_at = NOW()
    RETURNING *`,
    [
      userId, push_enabled, likes, comments, comment_likes, mentions, new_followers,
      follow_requests, tags, direct_messages, group_messages, message_requests,
      story_replies, story_reactions, story_mentions, voice_calls, video_calls,
      post_shares, tips, new_post_from_following
    ]
  );
  return result.rows[0];
}

export async function shouldSendNotification(userId, notificationType) {
  const prefs = await getUserNotificationPreferences(userId);
  
  if (!prefs.push_enabled) return false;
  
  // Map notification types to preference keys
  const typeToKey = {
    'like': 'likes',
    'comment': 'comments',
    'comment_like': 'comment_likes',
    'mention': 'mentions',
    'follow': 'new_followers',
    'follow_request': 'follow_requests',
    'tag': 'tags',
    'message': 'direct_messages',
    'group_message': 'group_messages',
    'message_request': 'message_requests',
    'story_reply': 'story_replies',
    'story_reaction': 'story_reactions',
    'story_mention': 'story_mentions',
    'voice_call': 'voice_calls',
    'video_call': 'video_calls',
    'post_share': 'post_shares',
    'tip': 'tips',
    'new_post_from_following': 'new_post_from_following',
  };
  
  const key = typeToKey[notificationType];
  if (!key) return true; // Default to true for unknown types
  
  return prefs[key] === true;
}

export async function listNotificationsForUser(recipientId, { limit = 20, offset = 0 } = {}) {
  const result = await query(
    `SELECT n.id, n.recipient_id, n.sender_id, n.type, n.message, n.is_read, n.metadata, n.created_at,
            u.username AS actor_username, u.avatar_url AS actor_avatar, u.is_verified AS actor_is_verified
     FROM notifications n
     LEFT JOIN users u ON u.id = n.sender_id
     WHERE n.recipient_id = $1 AND n.type != 'chat_message'
     ORDER BY n.created_at DESC
     LIMIT $2 OFFSET $3`,
    [recipientId, limit, offset]
  );
  return result.rows;
}

export async function countUnreadNotifications(recipientId) {
  const result = await query(
    `SELECT COUNT(*)::INTEGER AS count FROM notifications WHERE recipient_id = $1 AND is_read = FALSE AND type != 'chat_message'`,
    [recipientId]
  );
  return result.rows[0]?.count ?? 0;
}

export async function markNotificationAsRead(id, recipientId) {
  const result = await query(
    `UPDATE notifications SET is_read = TRUE, updated_at = NOW()
     WHERE id = $1 AND recipient_id = $2
     RETURNING id, is_read`,
    [id, recipientId]
  );
  return result.rows[0] ?? null;
}

export async function markAllNotificationsAsRead(recipientId) {
  await query(
    `UPDATE notifications SET is_read = TRUE, updated_at = NOW()
     WHERE recipient_id = $1 AND is_read = FALSE`,
    [recipientId]
  );
}

export async function deleteNotification(id, recipientId) {
  const result = await query(
    `DELETE FROM notifications WHERE id = $1 AND recipient_id = $2 RETURNING id`,
    [id, recipientId]
  );
  return result.rows[0] ?? null;
}
