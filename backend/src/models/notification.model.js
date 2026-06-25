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
