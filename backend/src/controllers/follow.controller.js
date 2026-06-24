import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as followService from '../services/follow.service.js';

export const followUser = asyncHandler(async (req, res) => {
  const targetId = req.params.userId;
  const data = await followService.follow(req.user.sub, targetId);
  res.json({ success: true, data });
});

export const unfollowUser = asyncHandler(async (req, res) => {
  const targetId = req.params.userId;
  const data = await followService.unfollow(req.user.sub, targetId);
  res.json({ success: true, data });
});

export const getFollowStatus = asyncHandler(async (req, res) => {
  const targetId = req.params.userId;
  if (!targetId) throw new AppError('User id required', 400);
  const data = await followService.getFollowStatus(req.user.sub, targetId);
  res.json({ success: true, data });
});

export const listFollowers = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 30);
  const data = await followService.getFollowersList(req.params.userId, req.user.sub, { page, limit });
  res.json({ success: true, data });
});

export const listFollowing = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 30);
  const data = await followService.getFollowingList(req.params.userId, req.user.sub, { page, limit });
  res.json({ success: true, data });
});
