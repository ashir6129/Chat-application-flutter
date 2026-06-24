import { query } from '../config/db.js';

export async function listCommentsForPost(postId) {
  const result = await query(
    `SELECT c.id, c.post_id, c.user_id, c.parent_id, c.body, c.created_at,
            u.username, u.avatar_url, u.is_verified
     FROM post_comments c
     JOIN users u ON u.id = c.user_id
     WHERE c.post_id = $1
     ORDER BY c.created_at ASC`,
    [postId],
  );
  return result.rows;
}

export async function listReactionsForPost(postId) {
  const result = await query(
    `SELECT cr.comment_id, cr.emoji, cr.user_id
     FROM comment_reactions cr
     JOIN post_comments c ON c.id = cr.comment_id
     WHERE c.post_id = $1`,
    [postId],
  );
  return result.rows;
}

export async function createComment({ postId, userId, body, parentId = null }) {
  const result = await query(
    `INSERT INTO post_comments (post_id, user_id, body, parent_id)
     VALUES ($1, $2, $3, $4)
     RETURNING id, post_id, user_id, parent_id, body, created_at`,
    [postId, userId, body, parentId],
  );

  await query(
    `UPDATE posts SET comment_count = comment_count + 1, updated_at = NOW() WHERE id = $1`,
    [postId],
  );

  const row = result.rows[0];
  const author = await query(
    `SELECT username, avatar_url, is_verified FROM users WHERE id = $1`,
    [userId],
  );

  return { ...row, ...author.rows[0] };
}

export async function getCommentById(commentId) {
  const result = await query(
    `SELECT c.id, c.post_id, c.user_id, c.parent_id, c.body, c.created_at,
            u.username, u.avatar_url, u.is_verified
     FROM post_comments c
     JOIN users u ON u.id = c.user_id
     WHERE c.id = $1`,
    [commentId],
  );
  return result.rows[0] ?? null;
}

export async function updateCommentBody(commentId, userId, body) {
  const result = await query(
    `UPDATE post_comments
     SET body = $1
     WHERE id = $2 AND user_id = $3
     RETURNING id, post_id, user_id, parent_id, body, created_at`,
    [body, commentId, userId],
  );
  if (!result.rows[0]) return null;

  const author = await query(
    `SELECT username, avatar_url, is_verified FROM users WHERE id = $1`,
    [userId],
  );

  return { ...result.rows[0], ...author.rows[0] };
}

export async function deleteComment(commentId, userId) {
  const existing = await query(
    `SELECT id, post_id FROM post_comments WHERE id = $1 AND user_id = $2`,
    [commentId, userId],
  );
  if (!existing.rows[0]) return null;

  const postId = existing.rows[0].post_id;

  await query(`DELETE FROM post_comments WHERE id = $1`, [commentId]);

  await query(
    `UPDATE posts
     SET comment_count = GREATEST(comment_count - 1, 0), updated_at = NOW()
     WHERE id = $1`,
    [postId],
  );

  const countResult = await query(`SELECT comment_count FROM posts WHERE id = $1`, [postId]);
  return {
    post_id: postId,
    comment_count: countResult.rows[0]?.comment_count ?? 0,
  };
}

export async function toggleReaction(commentId, userId, emoji) {
  const existing = await query(
    `SELECT id, emoji FROM comment_reactions WHERE comment_id = $1 AND user_id = $2`,
    [commentId, userId],
  );

  if (existing.rows[0]) {
    if (existing.rows[0].emoji === emoji) {
      await query(`DELETE FROM comment_reactions WHERE id = $1`, [existing.rows[0].id]);
      return null;
    }
    await query(`UPDATE comment_reactions SET emoji = $1 WHERE id = $2`, [
      emoji,
      existing.rows[0].id,
    ]);
    return emoji;
  }

  await query(
    `INSERT INTO comment_reactions (comment_id, user_id, emoji) VALUES ($1, $2, $3)`,
    [commentId, userId, emoji],
  );
  return emoji;
}

export async function reportComment(commentId, reporterId, reason = null) {
  await query(
    `INSERT INTO comment_reports (comment_id, reporter_id, reason)
     VALUES ($1, $2, $3)
     ON CONFLICT (comment_id, reporter_id) DO UPDATE SET reason = EXCLUDED.reason`,
    [commentId, reporterId, reason],
  );
}

export async function getCommentCount(postId) {
  const result = await query(`SELECT comment_count FROM posts WHERE id = $1`, [postId]);
  return result.rows[0]?.comment_count ?? 0;
}

export async function postExists(postId) {
  const result = await query(`SELECT id FROM posts WHERE id = $1`, [postId]);
  return Boolean(result.rows[0]);
}
