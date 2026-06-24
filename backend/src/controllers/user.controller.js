import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as userService from '../services/user.service.js';
import * as userValidator from '../validators/user.validator.js';
import { getIO } from '../socket/index.js';
import { listConversationPartnerIds } from '../models/conversation.model.js';

export const getMe = asyncHandler(async (req, res) => {
  const profile = await userService.getMyProfile(req.user.sub);
  res.json({ success: true, data: { profile } });
});

export const updateMe = asyncHandler(async (req, res) => {
  const error = userValidator.validateProfileUpdate(req.body);
  if (error) throw new AppError(error, 400);

  const profile = await userService.updateMyProfile(req.user.sub, req.body);
  res.json({ success: true, message: 'Profile updated', data: { profile } });
});

export const updateAvatar = asyncHandler(async (req, res) => {
  const error = userValidator.validateAvatar(req.body);
  if (error) throw new AppError(error, 400);

  const profile = await userService.setMyAvatar(req.user.sub, req.body.avatar_url);
  res.json({ success: true, message: 'Avatar updated', data: { profile } });
});

export const deleteMe = asyncHandler(async (req, res) => {
  await userService.deleteMyAccount(req.user.sub);
  res.json({ success: true, message: 'Account deleted' });
});

export const getByUsername = asyncHandler(async (req, res) => {
  const profile = await userService.getProfileByUsername(req.params.username, req.user.sub);
  res.json({ success: true, data: { profile } });
});

export const getByUserId = asyncHandler(async (req, res) => {
  const profile = await userService.getProfileByUserId(req.params.userId, req.user.sub);
  res.json({ success: true, data: { profile } });
});

export const search = asyncHandler(async (req, res) => {
  const error = userValidator.validateSearchQuery(req.query.q);
  if (error) throw new AppError(error, 400);

  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const data = await userService.searchUserProfiles(req.query.q, {
    page,
    limit,
    viewerId: req.user.sub,
  });
  res.json({ success: true, data });
});

export const suggestions = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const data = await userService.getSuggestedUsers(req.user.sub, { page, limit });
  res.json({ success: true, data });
});

export const list = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const data = await userService.browseUsers({ page, limit, viewerId: req.user.sub });
  res.json({ success: true, data });
});

export const getMyPosts = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const type = req.query.type?.toString() ?? 'all';
  const data = await userService.getMyPosts(req.user.sub, { page, limit, type });
  res.json({ success: true, data });
});

export const getUserPosts = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const type = req.query.type?.toString() ?? 'all';
  const data = await userService.getUserPostsByUsername(req.params.username, req.user.sub, {
    page,
    limit,
    type,
  });
  res.json({ success: true, data });
});

export const getNearby = asyncHandler(async (req, res) => {
  const latitude = req.query.latitude != null ? Number(req.query.latitude) : null;
  const longitude = req.query.longitude != null ? Number(req.query.longitude) : null;
  const maxDistanceKm = req.query.maxDistance != null ? Number(req.query.maxDistance) : 50;
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);

  const data = await userService.getNearbyUsers(req.user.sub, {
    latitude,
    longitude,
    maxDistanceKm,
    page,
    limit,
  });
  res.json({ success: true, data });
});

export const updateLocation = asyncHandler(async (req, res) => {
  const { latitude, longitude, location } = req.body;

  if (latitude == null || longitude == null) {
    throw new AppError('Latitude and longitude are required', 400);
  }

  const profile = await userService.updateMyProfile(req.user.sub, {
    latitude: Number(latitude),
    longitude: Number(longitude),
    location: location,
  });

  try {
    const io = getIO();
    if (io) {
      const partnerIds = await listConversationPartnerIds(req.user.sub);
      for (const partnerId of partnerIds) {
        io.to(`user:${partnerId}`).emit('location:updated', {
          user_id: req.user.sub,
          latitude: Number(latitude),
          longitude: Number(longitude),
          location: location,
        });
      }
    }
  } catch (err) {
    console.error('Failed to emit location:updated event', err);
  }

  res.json({ success: true, message: 'Location updated', data: { profile } });
});

export const updateFcmToken = asyncHandler(async (req, res) => {
  const { fcm_token } = req.body;
  const { updateUserFcmToken } = await import('../services/notification.service.js');

  await updateUserFcmToken(req.user.sub, fcm_token);
  res.json({ success: true, message: 'FCM token updated' });
});
