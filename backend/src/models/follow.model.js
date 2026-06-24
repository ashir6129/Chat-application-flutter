import { query } from '../config/db.js';

export async function followUser({ followerId, followingId }) {
  if (followerId === followingId) return null;

  const result = await query(
    `INSERT INTO user_follows (follower_id, following_id)
     VALUES ($1, $2)
     ON CONFLICT DO NOTHING
     RETURNING follower_id, following_id, created_at`,
    [followerId, followingId],
  );
  return result.rows[0] ?? { follower_id: followerId, following_id: followingId, already: true };
}

export async function unfollowUser({ followerId, followingId }) {
  const result = await query(
    `DELETE FROM user_follows WHERE follower_id = $1 AND following_id = $2 RETURNING follower_id`,
    [followerId, followingId],
  );
  return result.rows[0] ?? null;
}

export async function isFollowing(followerId, followingId) {
  const result = await query(
    `SELECT 1 FROM user_follows WHERE follower_id = $1 AND following_id = $2 LIMIT 1`,
    [followerId, followingId],
  );
  return result.rowCount > 0;
}

export async function countFollowers(userId) {
  const result = await query(
    `SELECT COUNT(*)::int AS total FROM user_follows WHERE following_id = $1`,
    [userId],
  );
  return result.rows[0]?.total ?? 0;
}

export async function countFollowing(userId) {
  const result = await query(
    `SELECT COUNT(*)::int AS total FROM user_follows WHERE follower_id = $1`,
    [userId],
  );
  return result.rows[0]?.total ?? 0;
}

export async function listFollowers(userId, { limit = 50, offset = 0, viewerId = null } = {}) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, uf.created_at AS followed_at,
            CASE WHEN $4::uuid IS NULL THEN false
                 ELSE EXISTS(
                   SELECT 1 FROM user_follows vf
                   WHERE vf.follower_id = $4 AND vf.following_id = u.id
                 )
            END AS is_following,
            CASE WHEN $4::uuid IS NULL THEN false
                 ELSE EXISTS(
                   SELECT 1 FROM user_follows vf
                   WHERE vf.follower_id = u.id AND vf.following_id = $4
                 )
            END AS follows_viewer
     FROM user_follows uf
     JOIN users u ON u.id = uf.follower_id
     WHERE uf.following_id = $1
     ORDER BY uf.created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset, viewerId],
  );
  return result.rows;
}

export async function listFollowing(userId, { limit = 50, offset = 0, viewerId = null } = {}) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, uf.created_at AS followed_at,
            CASE WHEN $4::uuid IS NULL THEN false
                 ELSE EXISTS(
                   SELECT 1 FROM user_follows vf
                   WHERE vf.follower_id = $4 AND vf.following_id = u.id
                 )
            END AS is_following,
            CASE WHEN $4::uuid IS NULL THEN false
                 ELSE EXISTS(
                   SELECT 1 FROM user_follows vf
                   WHERE vf.follower_id = u.id AND vf.following_id = $4
                 )
            END AS follows_viewer
     FROM user_follows uf
     JOIN users u ON u.id = uf.following_id
     WHERE uf.follower_id = $1
     ORDER BY uf.created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset, viewerId],
  );
  return result.rows;
}
