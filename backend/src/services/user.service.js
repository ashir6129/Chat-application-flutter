import env from '../config/env.js';
import { AppError } from '../utils/AppError.js';
import {
  findProfileByUserId,
  findPublicProfileByUsername,
  findUserById,
  updateProfile,
  updateUserAvatar,
  updateUsername,
  findUsernameTakenByOther,
  searchUsers,
  listUsers,
  listUsersForViewer,
  listSuggestedUsers,
  deleteUserById,
  listNearbyUsers,
} from '../models/user.model.js';
import { countPostsByUser, listPostsByUser } from '../models/post.model.js';
import { countFollowers, countFollowing } from '../models/follow.model.js';
import { isUserOnline } from '../socket/presence.js';
import { timeAgo } from '../utils/format.js';
import { cacheRemember } from '../utils/cache.js';
import { resolveMediaList, resolvePublicUrl, toStoredMediaPath } from '../utils/mediaUrl.js';

function serializeProfile(row, { includeEmail = false } = {}) {
  if (!row) return null;

  const profile = {
    id: row.id,
    username: row.username,
    avatar_url: resolvePublicUrl(row.avatar_url),
    is_verified: row.is_verified,
    is_spotlight: row.is_spotlight,
    bio: row.bio ?? '',
    location: row.location ?? null,
    website: row.website ?? null,
    latitude: row.latitude != null ? Number(row.latitude) : null,
    longitude: row.longitude != null ? Number(row.longitude) : null,
    created_at: row.created_at,
  };

  if (includeEmail) {
    profile.email = row.email;
    profile.profile_updated_at = row.profile_updated_at ?? null;
  }

  if (row.last_seen_at) {
    profile.last_seen_at = row.last_seen_at;
  }

  return profile;
}

function enrichPollMeta(postMeta, viewerId) {
  if (!postMeta?.poll) return postMeta ?? {};

  const poll = { ...postMeta.poll };
  if (viewerId) {
    poll.my_vote = poll.voters?.[viewerId] ?? null;
  }
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

async function attachStats(profile, userId, viewerId = null) {
  const postCount = await countPostsByUser(userId);
  profile.stats = {
    posts: postCount,
    followers: await countFollowers(userId),
    following: await countFollowing(userId),
  };
  profile.is_online = isUserOnline(userId);
  if (viewerId && viewerId !== userId) {
    const { isFollowing } = await import('../models/follow.model.js');
    profile.is_following = await isFollowing(viewerId, userId);
  }
  return profile;
}

export async function getMyProfile(userId) {
  const row = await findProfileByUserId(userId);
  if (!row) throw new AppError('User not found', 404);
  const profile = serializeProfile(row, { includeEmail: true });
  return attachStats(profile, userId);
}

export async function getProfileByUsername(username, viewerId = null) {
  const row = await findPublicProfileByUsername(username);
  if (!row) throw new AppError('User not found', 404);
  const profile = serializeProfile(row);
  return attachStats(profile, row.id, viewerId);
}

export async function getProfileByUserId(userId, viewerId = null) {
  const row = await findProfileByUserId(userId);
  if (!row) throw new AppError('User not found', 404);
  const profile = serializeProfile(row);
  return attachStats(profile, row.id, viewerId);
}

export async function updateMyProfile(userId, body) {
  if (body.username != null) {
    const normalized = body.username.trim().toLowerCase();
    const current = await findUserById(userId);
    if (!current) throw new AppError('User not found', 404);

    if (current.username.toLowerCase() !== normalized) {
      const taken = await findUsernameTakenByOther(userId, normalized);
      if (taken) throw new AppError('Username is already taken', 409);
      await updateUsername(userId, normalized);
    }
  }

  const updated = await updateProfile(userId, {
    bio: body.bio,
    location: body.location,
    website: body.website,
    latitude: body.latitude,
    longitude: body.longitude,
  });

  if (!updated) throw new AppError('Profile not found', 404);

  return getMyProfile(userId);
}

export async function setMyAvatar(userId, avatarUrl) {
  if (avatarUrl == null || !String(avatarUrl).trim()) {
    await updateUserAvatar(userId, null);
    return getMyProfile(userId);
  }

  const stored = toStoredMediaPath(avatarUrl.trim());
  await updateUserAvatar(userId, stored);
  return getMyProfile(userId);
}

function serializeDiscoverUser(row) {
  const profile = serializeProfile(row);
  profile.is_following = row.is_following === true;
  profile.follows_viewer = row.follows_viewer === true;
  if (row.follower_count != null) {
    profile.stats = { followers: row.follower_count };
  }
  if (row.distance_km != null) {
    profile.distance_km = Number(row.distance_km);
  }
  profile.box_status = row.box_status ?? null;
  profile.box_sender_id = row.box_sender_id ?? null;
  profile.box_request_id = row.box_request_id ?? null;
  return profile;
}

export async function searchUserProfiles(query, { page = 1, limit = 20, viewerId = null }) {
  if (!query?.trim()) throw new AppError('Search query is required', 400);

  const offset = (page - 1) * limit;
  const rows = await searchUsers(query, { limit, offset });

  return {
    users: rows.map((row) => serializeProfile(row)),
    page,
    limit,
  };
}

export async function browseUsers({ page = 1, limit = 20, viewerId = null }) {
  const offset = (page - 1) * limit;
  const rows = viewerId
    ? await listUsersForViewer(viewerId, { limit, offset })
    : await listUsers(limit, offset);

  return {
    users: rows.map((row) => (viewerId ? serializeDiscoverUser(row) : serializeProfile(row))),
    page,
    limit,
  };
}

export async function getSuggestedUsers(viewerId, { page = 1, limit = 20 }) {
  return cacheRemember(
    `suggestions:${viewerId}:${page}:${limit}`,
    env.redis.suggestionsTtlSeconds,
    async () => {
      const offset = (page - 1) * limit;
      const rows = await listSuggestedUsers(viewerId, { limit, offset });

      return {
        users: rows.map((row) => serializeDiscoverUser(row)),
        page,
        limit,
      };
    },
  );
}

export async function getUserSummary(userId) {
  const user = await findUserById(userId);
  if (!user) throw new AppError('User not found', 404);

  return {
    id: user.id,
    username: user.username,
    avatar_url: resolvePublicUrl(user.avatar_url),
    is_verified: user.is_verified,
  };
}

export async function getMyPosts(userId, { page = 1, limit = 20, type = 'all' }) {
  let postTypes = null;
  let archiveFilter = 'active';
  if (type === 'photos') postTypes = ['image', 'mixed'];
  if (type === 'reels') postTypes = ['reel', 'video'];
  if (type === 'archived') archiveFilter = 'archived';

  const result = await listPostsByUser({
    userId,
    viewerId: userId,
    page,
    limit,
    postTypes,
    baseUrl: env.upload.baseUrl,
    archiveFilter,
  });

  return {
    posts: result.posts.map((p) => serializePost(p, userId)),
    page,
    limit,
    total: result.total,
    has_more: result.hasMore,
  };
}

export async function getUserPostsByUsername(username, viewerId, { page = 1, limit = 20, type = 'all' }) {
  const row = await findPublicProfileByUsername(username);
  if (!row) throw new AppError('User not found', 404);
  return getMyPosts(row.id, { page, limit, type });
}

export async function deleteMyAccount(userId) {
  const row = await findUserById(userId);
  if (!row) throw new AppError('User not found', 404);
  await deleteUserById(userId);
}

export async function getNearbyUsers(viewerId, { latitude, longitude, maxDistanceKm = 50, page = 1, limit = 20 }) {
  const offset = (page - 1) * limit;
  const rows = await listNearbyUsers(viewerId, {
    latitude,
    longitude,
    maxDistanceKm,
    limit,
    offset,
  });

  return {
    users: rows.map((row) => serializeDiscoverUser(row)),
    page,
    limit,
  };
}
