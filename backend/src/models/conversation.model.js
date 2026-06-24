import pool, { query } from '../config/db.js';

const memberSelect = `
  u.id AS user_id,
  u.username,
  u.avatar_url,
  u.is_verified,
  u.last_seen_at,
  cm.role,
  cm.joined_at,
  cm.last_read_at
`;

export async function findDirectConversation(userIdA, userIdB) {
  const result = await query(
    `SELECT c.id, c.type, c.title, c.avatar_url, c.created_by, c.last_message_at, c.created_at
     FROM conversations c
     JOIN conversation_members cm1 ON cm1.conversation_id = c.id AND cm1.user_id = $1
     JOIN conversation_members cm2 ON cm2.conversation_id = c.id AND cm2.user_id = $2
     WHERE c.type = 'direct'
     LIMIT 1`,
    [userIdA, userIdB],
  );
  return result.rows[0] ?? null;
}

export async function createConversation({ type, title, avatarUrl, createdBy, memberIds, roles = {} }) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const convResult = await client.query(
      `INSERT INTO conversations (type, title, avatar_url, created_by)
       VALUES ($1, $2, $3, $4)
       RETURNING id, type, title, avatar_url, created_by, last_message_at, created_at`,
      [type, title ?? null, avatarUrl ?? null, createdBy ?? null],
    );

    const conversation = convResult.rows[0];

    for (const memberId of memberIds) {
      const role = roles[memberId] ?? (memberId === createdBy ? 'admin' : 'member');
      await client.query(
        `INSERT INTO conversation_members (conversation_id, user_id, role)
         VALUES ($1, $2, $3)`,
        [conversation.id, memberId, role],
      );
    }

    await client.query('COMMIT');
    return conversation;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function isConversationMember(conversationId, userId) {
  const result = await query(
    `SELECT 1 FROM conversation_members
     WHERE conversation_id = $1 AND user_id = $2
     LIMIT 1`,
    [conversationId, userId],
  );
  return result.rowCount > 0;
}

export async function getConversationById(conversationId, userId) {
  const result = await query(
    `SELECT c.id, c.type, c.title, c.avatar_url, c.created_by, c.last_message_at, c.created_at,
            cm.role, cm.last_read_at
     FROM conversations c
     JOIN conversation_members cm ON cm.conversation_id = c.id AND cm.user_id = $2
     WHERE c.id = $1
     LIMIT 1`,
    [conversationId, userId],
  );
  return result.rows[0] ?? null;
}

export async function listUserConversations(userId, { limit = 30, offset = 0 }) {
  const result = await query(
    `SELECT c.id, c.type, c.title, c.avatar_url, c.last_message_at, c.created_at,
            cm.last_read_at,
            (
              SELECT COUNT(*)::int
              FROM messages m
              WHERE m.conversation_id = c.id
                AND m.sender_id <> $1
                AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01'::timestamptz)
            ) AS unread_count,
            (
              SELECT row_to_json(last_msg)
              FROM (
                SELECT m.id, m.body, m.message_type, m.sender_id, m.created_at,
                       u.username AS sender_username
                FROM messages m
                JOIN users u ON u.id = m.sender_id
                WHERE m.conversation_id = c.id
                ORDER BY m.created_at DESC
                LIMIT 1
              ) last_msg
            ) AS last_message
     FROM conversations c
     JOIN conversation_members cm ON cm.conversation_id = c.id AND cm.user_id = $1
     ORDER BY COALESCE(c.last_message_at, c.created_at) DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset],
  );

  return result.rows;
}

export async function listConversationMembers(conversationId) {
  const result = await query(
    `SELECT ${memberSelect}
     FROM conversation_members cm
     JOIN users u ON u.id = cm.user_id
     WHERE cm.conversation_id = $1
     ORDER BY cm.joined_at ASC`,
    [conversationId],
  );
  return result.rows;
}

export async function addConversationMember(conversationId, userId, role = 'member') {
  const result = await query(
    `INSERT INTO conversation_members (conversation_id, user_id, role)
     VALUES ($1, $2, $3)
     ON CONFLICT (conversation_id, user_id) DO NOTHING
     RETURNING conversation_id, user_id, role`,
    [conversationId, userId, role],
  );
  return result.rows[0] ?? null;
}

export async function removeConversationMember(conversationId, userId) {
  const result = await query(
    `DELETE FROM conversation_members
     WHERE conversation_id = $1 AND user_id = $2
     RETURNING conversation_id, user_id`,
    [conversationId, userId],
  );
  return result.rows[0] ?? null;
}

export async function updateLastRead(conversationId, userId, readAt = new Date()) {
  await query(
    `UPDATE conversation_members
     SET last_read_at = $3
     WHERE conversation_id = $1 AND user_id = $2`,
    [conversationId, userId, readAt],
  );
}

export async function touchConversation(conversationId) {
  await query(
    `UPDATE conversations SET last_message_at = NOW(), updated_at = NOW() WHERE id = $1`,
    [conversationId],
  );
}

export async function listUserConversationIds(userId) {
  const result = await query(
    `SELECT conversation_id FROM conversation_members WHERE user_id = $1`,
    [userId],
  );
  return result.rows.map((r) => r.conversation_id);
}

export async function listConversationPartnerIds(userId) {
  const result = await query(
    `SELECT DISTINCT cm2.user_id
     FROM conversation_members cm1
     JOIN conversation_members cm2
       ON cm2.conversation_id = cm1.conversation_id AND cm2.user_id <> $1
     WHERE cm1.user_id = $1`,
    [userId],
  );
  return result.rows.map((r) => r.user_id);
}
