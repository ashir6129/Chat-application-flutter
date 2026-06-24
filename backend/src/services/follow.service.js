import { AppError } from '../utils/AppError.js';
import { findUserById } from '../models/user.model.js';
import {
  followUser,
  unfollowUser,
  isFollowing,
  countFollowers,
  countFollowing,
  listFollowers,
  listFollowing,
} from '../models/follow.model.js';
import {
  invalidateUserFeedCache,
  invalidateUserSuggestions,
} from '../utils/cache.js';

export async function follow(userId, targetUserId) {
  if (userId === targetUserId) throw new AppError('Cannot follow yourself', 400);

  const target = await findUserById(targetUserId);
  if (!target) throw new AppError('User not found', 404);

  await followUser({ followerId: userId, followingId: targetUserId });
  await invalidateUserFeedCache(userId);
  await invalidateUserSuggestions(userId);

  return {
    following: true,
    followers_count: await countFollowers(targetUserId),
    following_count: await countFollowing(userId),
  };
}

export async function unfollow(userId, targetUserId) {
  const removed = await unfollowUser({ followerId: userId, followingId: targetUserId });
  if (!removed) throw new AppError('Not following this user', 404);

  await invalidateUserFeedCache(userId);
  await invalidateUserSuggestions(userId);

  return {
    following: false,
    followers_count: await countFollowers(targetUserId),
    following_count: await countFollowing(userId),
  };
}

export async function getFollowStatus(viewerId, targetUserId) {
  const following = viewerId ? await isFollowing(viewerId, targetUserId) : false;
  return {
    following,
    followers_count: await countFollowers(targetUserId),
    following_count: await countFollowing(targetUserId),
  };
}

export { countFollowers, countFollowing, listFollowers, listFollowing };

export async function getFollowersList(userId, viewerId, { page = 1, limit = 30 } = {}) {
  const offset = (page - 1) * limit;
  const users = await listFollowers(userId, { limit, offset, viewerId });
  return {
    users: users.map((u) => ({
      id: u.id,
      username: u.username,
      avatar_url: u.avatar_url,
      is_verified: u.is_verified,
      followed_at: u.followed_at,
      is_following: u.is_following === true,
      follows_viewer: u.follows_viewer === true,
    })),
    page,
    limit,
    total: await countFollowers(userId),
  };
}

export async function getFollowingList(userId, viewerId, { page = 1, limit = 30 } = {}) {
  const offset = (page - 1) * limit;
  const users = await listFollowing(userId, { limit, offset, viewerId });
  return {
    users: users.map((u) => ({
      id: u.id,
      username: u.username,
      avatar_url: u.avatar_url,
      is_verified: u.is_verified,
      followed_at: u.followed_at,
      is_following: u.is_following === true,
      follows_viewer: u.follows_viewer === true,
    })),
    page,
    limit,
    total: await countFollowing(userId),
  };
}
