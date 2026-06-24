import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as postService from '../services/post.service.js';
import { publicUploadUrl, mediaKind } from '../middleware/upload.js';

export const createPost = asyncHandler(async (req, res) => {
  const post = await postService.createUserPost(req.user.sub, req.body);

  res.status(201).json({
    success: true,
    message: 'Post created',
    data: { post },
  });
});

export const getFeed = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);

  const data = await postService.getHomeFeed(req.user.sub, { page, limit });

  res.json({ success: true, data });
});

export const getPost = asyncHandler(async (req, res) => {
  const post = await postService.getPost(req.user.sub, req.params.id);
  res.json({ success: true, data: { post } });
});

export const getReels = asyncHandler(async (req, res) => {
  const page = Number(req.body?.page ?? req.query.page ?? 1);
  const limit = Number(req.body?.limit ?? req.query.limit ?? 10);

  const data = await postService.getReelsFeed(req.user.sub, { page, limit });

  res.json({ success: true, data });
});

export const toggleLike = asyncHandler(async (req, res) => {
  const result = await postService.likePost(req.user.sub, req.params.id);

  res.json({
    success: true,
    data: result,
  });
});

export const deletePost = asyncHandler(async (req, res) => {
  const result = await postService.removePost(req.user.sub, req.params.id);
  res.json(result);
});

export const updatePost = asyncHandler(async (req, res) => {
  const post = await postService.editPost(req.user.sub, req.params.id, req.body.caption);

  res.json({
    success: true,
    message: 'Post updated',
    data: { post },
  });
});

export const archivePost = asyncHandler(async (req, res) => {
  const archived = req.body?.archived !== false;
  const post = await postService.archiveUserPost(req.user.sub, req.params.id, archived);

  res.json({
    success: true,
    message: archived ? 'Post archived' : 'Post restored',
    data: { post },
  });
});

export const votePoll = asyncHandler(async (req, res) => {
  const poll = await postService.castPollVote(
    req.user.sub,
    req.params.id,
    req.body.option_index,
  );

  res.json({
    success: true,
    data: { poll },
  });
});

export const uploadMedia = asyncHandler(async (req, res) => {
  const files = req.files ?? [];

  if (!files.length) {
    throw new AppError('No files uploaded', 400);
  }

  const urls = files.map((file) => ({
    url: publicUploadUrl(file.filename),
    type: mediaKind(file.mimetype, file.originalname),
    filename: file.filename,
  }));

  res.status(201).json({
    success: true,
    message: 'Upload complete',
    data: { files: urls },
  });
});
