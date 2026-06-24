import { query } from '../config/db.js';

const authorSelect = `
  u.id AS author_id,
  u.username,
  u.email,
  u.avatar_url,
  u.is_verified,
  u.is_spotlight
`;

function mapMediaUrls(rows, baseUrl) {
  return rows.map((row) => ({
    ...row,
    media_urls: Array.isArray(row.media_urls)
      ? row.media_urls.map((url) =>
          url.startsWith('http') ? url : `${baseUrl}${url.startsWith('/') ? '' : '/'}${url}`,
        )
      : [],
  }));
}

export async function createPost({
  userId,
  caption,
  postType,
  mediaUrls,
  location,
  mediaMeta = [],
  postMeta = {},
}) {
  const result = await query(
    `INSERT INTO posts (user_id, caption, post_type, media_urls, location, media_meta, post_meta)
     VALUES ($1, $2, $3, $4::jsonb, $5, $6::jsonb, $7::jsonb)
     RETURNING id, user_id, caption, post_type, media_urls, media_meta, post_meta, is_archived,
               like_count, comment_count, share_count, location, created_at, updated_at`,
    [
      userId,
      caption ?? '',
      postType,
      JSON.stringify(mediaUrls ?? []),
      location ?? null,
      JSON.stringify(mediaMeta ?? []),
      JSON.stringify(postMeta ?? {}),
    ],
  );

  return result.rows[0];
}

export async function findPostById(postId, viewerId, baseUrl) {
  const result = await query(
    `SELECT p.id, p.user_id, p.caption, p.post_type, p.media_urls, p.media_meta, p.post_meta,
            p.is_archived, p.like_count,
            p.comment_count, p.share_count, p.location, p.created_at,
            ${authorSelect},
            EXISTS(
              SELECT 1 FROM post_likes pl
              WHERE pl.post_id = p.id AND pl.user_id = $2
            ) AS liked
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.id = $1
     LIMIT 1`,
    [postId, viewerId ?? null],
  );

  const row = result.rows[0];
  if (!row) return null;

  return mapMediaUrls([row], baseUrl)[0];
}

export async function listFeedPosts({ viewerId, page, limit, postTypes, baseUrl, followingOnly = false }) {
  const offset = (page - 1) * limit;
  const types = postTypes?.length ? postTypes : ['text', 'image', 'video'];

  const followingFilter = followingOnly && viewerId
    ? `AND (
         p.user_id = $4
         OR EXISTS (
           SELECT 1 FROM user_follows uf
           WHERE uf.follower_id = $4 AND uf.following_id = p.user_id
         )
       )`
    : '';

  const result = await query(
    `SELECT p.id, p.user_id, p.caption, p.post_type, p.media_urls, p.media_meta, p.post_meta,
            p.is_archived, p.like_count,
            p.comment_count, p.share_count, p.location, p.created_at,
            ${authorSelect},
            EXISTS(
              SELECT 1 FROM post_likes pl
              WHERE pl.post_id = p.id AND pl.user_id = $4
            ) AS liked
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.post_type = ANY($1::text[])
       AND COALESCE(p.is_archived, FALSE) = FALSE
       ${followingFilter}
     ORDER BY p.created_at DESC
     LIMIT $2 OFFSET $3`,
    [types, limit, offset, viewerId ?? null],
  );

  const countFollowingFilter = followingOnly && viewerId
    ? `AND (
         p.user_id = $2
         OR EXISTS (
           SELECT 1 FROM user_follows uf
           WHERE uf.follower_id = $2 AND uf.following_id = p.user_id
         )
       )`
    : '';

  const countResult = await query(
    `SELECT COUNT(*)::int AS total FROM posts p
     WHERE p.post_type = ANY($1::text[])
       AND COALESCE(p.is_archived, FALSE) = FALSE
       ${countFollowingFilter}`,
    followingOnly && viewerId ? [types, viewerId] : [types],
  );

  const total = countResult.rows[0]?.total ?? 0;

  return {
    posts: mapMediaUrls(result.rows, baseUrl),
    total,
    hasMore: offset + result.rows.length < total,
  };
}

export async function listReels({ viewerId, page, limit, baseUrl, followingOnly = false }) {
  return listFeedPosts({
    viewerId,
    page,
    limit,
    postTypes: ['reel', 'video'],
    baseUrl,
    followingOnly,
  });
}

export async function countPostsByUser(userId, { archiveFilter = 'active' } = {}) {
  const result = await query(
    `SELECT COUNT(*)::int AS total FROM posts
     WHERE user_id = $1
       AND (
         $2::text = 'all'
         OR ($2::text = 'archived' AND COALESCE(is_archived, FALSE) = TRUE)
         OR ($2::text = 'active' AND COALESCE(is_archived, FALSE) = FALSE)
       )`,
    [userId, archiveFilter],
  );
  return result.rows[0]?.total ?? 0;
}

export async function listPostsByUser({
  userId,
  viewerId,
  page = 1,
  limit = 20,
  postTypes,
  baseUrl,
  archiveFilter = 'active',
}) {
  const offset = (page - 1) * limit;
  const types = postTypes?.length ? postTypes : null;

  const result = await query(
    `SELECT p.id, p.user_id, p.caption, p.post_type, p.media_urls, p.media_meta, p.post_meta,
            p.is_archived, p.like_count,
            p.comment_count, p.share_count, p.location, p.created_at,
            ${authorSelect},
            EXISTS(
              SELECT 1 FROM post_likes pl
              WHERE pl.post_id = p.id AND pl.user_id = $4
            ) AS liked
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.user_id = $1
       AND (
         $6::text = 'all'
         OR ($6::text = 'archived' AND COALESCE(p.is_archived, FALSE) = TRUE)
         OR ($6::text = 'active' AND COALESCE(p.is_archived, FALSE) = FALSE)
       )
       AND ($5::text[] IS NULL OR p.post_type = ANY($5::text[]))
     ORDER BY p.created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset, viewerId ?? null, types, archiveFilter],
  );

  const countResult = await query(
    `SELECT COUNT(*)::int AS total FROM posts p
     WHERE p.user_id = $1
       AND (
         $3::text = 'all'
         OR ($3::text = 'archived' AND COALESCE(p.is_archived, FALSE) = TRUE)
         OR ($3::text = 'active' AND COALESCE(p.is_archived, FALSE) = FALSE)
       )
       AND ($2::text[] IS NULL OR p.post_type = ANY($2::text[]))`,
    [userId, types, archiveFilter],
  );

  const total = countResult.rows[0]?.total ?? 0;

  return {
    posts: mapMediaUrls(result.rows, baseUrl),
    total,
    hasMore: offset + result.rows.length < total,
  };
}

export async function toggleLike({ postId, userId }) {
  const existing = await query(
    `SELECT 1 FROM post_likes WHERE post_id = $1 AND user_id = $2`,
    [postId, userId],
  );

  if (existing.rowCount > 0) {
    await query(`DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2`, [postId, userId]);
    await query(
      `UPDATE posts SET like_count = GREATEST(like_count - 1, 0), updated_at = NOW() WHERE id = $1`,
      [postId],
    );

    const result = await query(`SELECT like_count FROM posts WHERE id = $1`, [postId]);
    return { liked: false, like_count: result.rows[0]?.like_count ?? 0 };
  }

  await query(`INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2)`, [postId, userId]);
  await query(
    `UPDATE posts SET like_count = like_count + 1, updated_at = NOW() WHERE id = $1`,
    [postId],
  );

  const result = await query(`SELECT like_count FROM posts WHERE id = $1`, [postId]);
  return { liked: true, like_count: result.rows[0]?.like_count ?? 0 };
}

export async function deletePost({ postId, userId }) {
  const result = await query(
    `DELETE FROM posts WHERE id = $1 AND user_id = $2 RETURNING id`,
    [postId, userId],
  );
  return result.rows[0] ?? null;
}

export async function updatePostCaption({ postId, userId, caption }) {
  const result = await query(
    `UPDATE posts SET caption = $3, updated_at = NOW()
     WHERE id = $1 AND user_id = $2
     RETURNING id, caption, updated_at`,
    [postId, userId, caption],
  );
  return result.rows[0] ?? null;
}

export async function setPostArchived({ postId, userId, archived }) {
  const result = await query(
    `UPDATE posts SET is_archived = $3, updated_at = NOW()
     WHERE id = $1 AND user_id = $2
     RETURNING id, is_archived`,
    [postId, userId, archived],
  );
  return result.rows[0] ?? null;
}

export async function voteOnPoll({ postId, userId, optionIndex }) {
  const row = await query(
    `SELECT post_meta FROM posts WHERE id = $1 LIMIT 1`,
    [postId],
  );
  const post = row.rows[0];
  if (!post) return null;

  const meta = post.post_meta ?? {};
  const poll = meta.poll;
  if (!poll || !Array.isArray(poll.options)) return null;
  if (poll.expires_at && new Date(poll.expires_at) < new Date()) return null;
  if (optionIndex < 0 || optionIndex >= poll.options.length) return null;

  poll.votes = Array.isArray(poll.votes) ? poll.votes : poll.options.map(() => 0);
  poll.voters = poll.voters && typeof poll.voters === 'object' ? poll.voters : {};

  const prev = poll.voters[userId];
  if (prev != null && poll.votes[prev] > 0) {
    poll.votes[prev] -= 1;
  }

  poll.voters[userId] = optionIndex;
  poll.votes[optionIndex] = (poll.votes[optionIndex] ?? 0) + 1;
  meta.poll = poll;

  await query(
    `UPDATE posts SET post_meta = $2::jsonb, updated_at = NOW() WHERE id = $1`,
    [postId, JSON.stringify(meta)],
  );

  return meta.poll;
}
