import { query } from '../config/db.js';

export async function createMessage({
  conversationId,
  senderId,
  body,
  messageType = 'text',
  metadata = {},
}) {
  const result = await query(
    `INSERT INTO messages (conversation_id, sender_id, body, message_type, metadata)
     VALUES ($1, $2, $3, $4, $5::jsonb)
     RETURNING id, conversation_id, sender_id, body, message_type, metadata, created_at`,
    [conversationId, senderId, body ?? '', messageType, JSON.stringify(metadata ?? {})],
  );
  return result.rows[0];
}

export async function listMessages(conversationId, { limit = 50, before = null }) {
  const params = [conversationId, limit];
  let cursorClause = '';

  if (before) {
    params.push(before);
    cursorClause = `AND m.created_at < (SELECT created_at FROM messages WHERE id = $3)`;
  }

  const result = await query(
    `SELECT m.id, m.conversation_id, m.sender_id, m.body, m.message_type, m.metadata,
            m.created_at, u.username AS sender_username, u.avatar_url AS sender_avatar
     FROM messages m
     JOIN users u ON u.id = m.sender_id
     WHERE m.conversation_id = $1 ${cursorClause}
     ORDER BY m.created_at DESC
     LIMIT $2`,
    params,
  );

  return result.rows.reverse();
}

export async function findMessageById(messageId) {
  const result = await query(
    `SELECT m.id, m.conversation_id, m.sender_id, m.body, m.message_type, m.metadata, m.created_at,
            u.username AS sender_username, u.avatar_url AS sender_avatar
     FROM messages m
     JOIN users u ON u.id = m.sender_id
     WHERE m.id = $1
     LIMIT 1`,
    [messageId],
  );
  return result.rows[0] ?? null;
}

export async function createReceipts(messageId, userIds, status = 'sent') {
  for (const userId of userIds) {
    await query(
      `INSERT INTO message_receipts (message_id, user_id, status)
       VALUES ($1, $2, $3)
       ON CONFLICT (message_id, user_id) DO NOTHING`,
      [messageId, userId, status],
    );
  }
}

export async function updateReceiptStatus(messageId, userId, status) {
  const result = await query(
    `UPDATE message_receipts
     SET status = $3, updated_at = NOW()
     WHERE message_id = $1 AND user_id = $2
     RETURNING message_id, user_id, status, updated_at`,
    [messageId, userId, status],
  );
  return result.rows[0] ?? null;
}

export async function markConversationDelivered(conversationId, userId) {
  const result = await query(
    `UPDATE message_receipts mr
     SET status = 'delivered', updated_at = NOW()
     FROM messages m
     WHERE mr.message_id = m.id
       AND m.conversation_id = $1
       AND mr.user_id = $2
       AND mr.status = 'sent'
     RETURNING mr.message_id, m.conversation_id, m.sender_id`,
    [conversationId, userId],
  );
  return result.rows;
}

export async function markAllDeliveredForUser(userId) {
  const result = await query(
    `UPDATE message_receipts mr
     SET status = 'delivered', updated_at = NOW()
     FROM messages m
     WHERE mr.message_id = m.id
       AND mr.user_id = $1
       AND mr.status = 'sent'
     RETURNING mr.message_id, m.conversation_id, m.sender_id`,
    [userId],
  );
  return result.rows;
}

export async function markConversationRead(conversationId, userId) {
  await query(
    `UPDATE message_receipts mr
     SET status = 'read', updated_at = NOW()
     FROM messages m
     WHERE mr.message_id = m.id
       AND m.conversation_id = $1
       AND mr.user_id = $2
       AND mr.status <> 'read'`,
    [conversationId, userId],
  );
}

export async function getMessageReceipts(messageId) {
  const result = await query(
    `SELECT mr.user_id, mr.status, mr.updated_at, u.username
     FROM message_receipts mr
     JOIN users u ON u.id = mr.user_id
     WHERE mr.message_id = $1`,
    [messageId],
  );
  return result.rows;
}

export async function getMemberIds(conversationId) {
  const result = await query(
    `SELECT user_id FROM conversation_members WHERE conversation_id = $1`,
    [conversationId],
  );
  return result.rows.map((r) => r.user_id);
}
