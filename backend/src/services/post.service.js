import env from '../config/env.js';
import { AppError } from '../utils/AppError.js';
import { timeAgo } from '../utils/format.js';
import { sendPushNotification } from './notification.service.js';
import { listFollowers } from '../models/follow.model.js';
import { findUserById } from '../models/user.model.js';
import {
  cacheRemember,
  invalidateAllFeedCaches,
  invalidateUserFeedCache,
  invalidateAllReelsCaches,
} from '../utils/cache.js';
import {
  createPost,
  findPostById,
  listFeedPosts,
  listReels,
  toggleLike,
  deletePost,
  updatePostCaption,
  setPostArchived,
  voteOnPoll,
} from '../models/post.model.js';
import { resolveMediaList, resolvePublicUrl, toStoredMediaPath } from '../utils/mediaUrl.js';

const ALLOWED_TYPES = new Set(['text', 'image', 'video', 'reel', 'mixed']);

function enrichPollMeta(postMeta, viewerId) {
  if (!postMeta?.poll || !viewerId) return postMeta ?? {};

  const poll = { ...postMeta.poll };
  poll.my_vote = poll.voters?.[viewerId] ?? null;
  delete poll.voters;

  return { ...postMeta, poll };
}

function serializePost(row, viewerId = null) {
  const postMeta = enrichPollMeta(row.post_meta ?? {}, viewerId);

  return {
    id: row.id,
    user_id: row.user_id,
    caption: row.caption ?? '',
    post_type: row.post_type,
    media_urls: resolveMediaList(row.media_urls ?? []),
    media_meta: row.media_meta ?? [],
    post_meta: postMeta,
    is_archived: Boolean(row.is_archived),
    like_count: row.like_count ?? 0,
    comment_count: row.comment_count ?? 0,
    share_count: row.share_count ?? 0,
    location: row.location,
    liked: Boolean(row.liked),
    created_at: row.created_at,
    time_ago: timeAgo(row.created_at),
    author: {
      id: row.author_id,
      username: row.username,
      avatar_url: resolvePublicUrl(row.avatar_url),
      is_verified: row.is_verified,
      is_spotlight: row.is_spotlight,
    },
  };
}

export async function createUserPost(userId, body) {
  const postType = body.post_type ?? 'text';

  if (!ALLOWED_TYPES.has(postType)) {
    throw new AppError('Invalid post type', 400);
  }

  const mediaUrls = (Array.isArray(body.media_urls) ? body.media_urls : []).map((url) =>
    toStoredMediaPath(url),
  );

  const postMeta = body.post_meta && typeof body.post_meta === 'object' ? { ...body.post_meta } : {};
  if (postMeta.poll?.options?.length) {
    const durationDays = Number(postMeta.poll.duration_days ?? 7);
    const expiresAt = new Date(Date.now() + durationDays * 24 * 60 * 60 * 1000).toISOString();
    postMeta.poll = {
      question: String(postMeta.poll.question ?? '').trim(),
      options: postMeta.poll.options.map((o) => String(o).trim()).filter(Boolean),
      votes: postMeta.poll.options.map(() => 0),
      voters: {},
      expires_at: expiresAt,
    };
  }

  if ((postType === 'image' || postType === 'video' || postType === 'reel' || postType === 'mixed') && mediaUrls.length === 0) {
    throw new AppError('Media is required for this post type', 400);
  }

  if (postType === 'text' && !body.caption?.trim() && mediaUrls.length === 0 && !postMeta.poll?.options?.length) {
    throw new AppError('Caption, media, or poll is required', 400);
  }

  const row = await createPost({
    userId,
    caption: body.caption?.trim() ?? '',
    postType,
    mediaUrls,
    location: body.location?.trim() ?? null,
    mediaMeta: Array.isArray(body.media_meta) ? body.media_meta : [],
    postMeta,
  });

  const full = await findPostById(row.id, userId, env.upload.baseUrl);
  await invalidateAllFeedCaches();
  await invalidateAllReelsCaches();
  await invalidateUserFeedCache(userId);

  // Send push notifications to followers asynchronously
  Promise.all([
    findUserById(userId),
    listFollowers(userId, { limit: 500 }),
  ]).then(([author, followers]) => {
    if (author && followers && followers.length > 0) {
      const authorName = author.username || 'Someone';
      const postTypeLabel = full.post_type === 'reel' ? 'reel' : 'post';
      for (const follower of followers) {
        sendPushNotification(follower.id, {
          title: 'New Post',
          body: `${authorName} shared a new ${postTypeLabel}`,
          data: {
            type: 'post',
            post_id: full.id,
            post_type: full.post_type,
            author_id: userId,
          },
        });
      }
    }
  }).catch((err) => console.error('Failed to send new post push notifications:', err.message));

  return serializePost(full, userId);
}

export async function getPost(userId, postId) {
  const row = await findPostById(postId, userId, env.upload.baseUrl);
  if (!row) throw new AppError('Post not found', 404);
  return serializePost(row, userId);
}

export async function getHomeFeed(userId, { page = 1, limit = 20 }) {
  return cacheRemember(
    `feed:${userId}:${page}:${limit}`,
    env.redis.feedTtlSeconds,
    async () => {
      const result = await listFeedPosts({
        viewerId: userId,
        page,
        limit,
        postTypes: ['text', 'image', 'video', 'mixed'],
        baseUrl: env.upload.baseUrl,
        followingOnly: true,
      });

      return {
        posts: result.posts.map((p) => serializePost(p, userId)),
        page,
        limit,
        total: result.total,
        has_more: result.hasMore,
      };
    },
  );
}

export async function getReelsFeed(userId, { page = 1, limit = 10 }) {
  return cacheRemember(
    `reels:${userId}:${page}:${limit}`,
    env.redis.feedTtlSeconds,
    async () => {
      const result = await listReels({
        viewerId: userId,
        page,
        limit,
        baseUrl: env.upload.baseUrl,
      });

      return {
        reels: result.posts.map((p) => serializePost(p, userId)),
        page,
        limit,
        total: result.total,
        has_more: result.hasMore,
      };
    },
  );
}

export async function likePost(userId, postId) {
  const post = await findPostById(postId, userId, env.upload.baseUrl);
  if (!post) throw new AppError('Post not found', 404);

  const result = await toggleLike({ postId, userId });

  // Send notification to author if someone else likes the post
  if (result.liked && post.user_id !== userId) {
    findUserById(userId).then((liker) => {
      if (liker) {
        const likerName = liker.username || 'Someone';
        sendPushNotification(post.user_id, {
          title: 'New Like',
          body: `${likerName} liked your post`,
          data: {
            type: 'like',
            post_id: postId,
            liker_id: userId,
          },
        });
      }
    }).catch((err) => console.error('Failed to send like push notification:', err.message));
  }

  return result;
}

export async function removePost(userId, postId) {
  const deleted = await deletePost({ postId, userId });
  if (!deleted) throw new AppError('Post not found or not allowed', 404);
  return { success: true, message: 'Post deleted' };
}

export async function editPost(userId, postId, caption) {
  if (!caption?.trim()) throw new AppError('Caption is required', 400);

  const updated = await updatePostCaption({ postId, userId, caption: caption.trim() });
  if (!updated) throw new AppError('Post not found or not allowed', 404);

  const full = await findPostById(postId, userId, env.upload.baseUrl);
  return serializePost(full, userId);
}

export async function archiveUserPost(userId, postId, archived = true) {
  const updated = await setPostArchived({ postId, userId, archived: Boolean(archived) });
  if (!updated) throw new AppError('Post not found or not allowed', 404);

  const full = await findPostById(postId, userId, env.upload.baseUrl);
  return serializePost(full, userId);
}

export async function castPollVote(userId, postId, optionIndex) {
  const index = Number(optionIndex);
  if (!Number.isInteger(index) || index < 0) {
    throw new AppError('Invalid poll option', 400);
  }

  const poll = await voteOnPoll({ postId, userId, optionIndex: index });
  if (!poll) throw new AppError('Poll not found on this post', 404);

  const meta = enrichPollMeta({ poll }, userId);
  return meta.poll;
}
