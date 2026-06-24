import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as commentService from '../services/comment.service.js';

export const getComments = asyncHandler(async (req, res) => {
  const comments = await commentService.getComments(req.params.postId, req.user.sub);
  res.json({ success: true, data: { comments } });
});

export const addComment = asyncHandler(async (req, res) => {
  const body = req.body.body?.trim();
  if (!body) throw new AppError('Comment cannot be empty', 400);

  const result = await commentService.addComment(req.user.sub, req.params.postId, {
    body,
    parentId: req.body.parent_id ?? null,
  });

  res.status(201).json({
    success: true,
    message: 'Comment added',
    data: result,
  });
});

export const updateComment = asyncHandler(async (req, res) => {
  const body = req.body.body?.trim();
  if (!body) throw new AppError('Comment cannot be empty', 400);

  const comment = await commentService.editComment(
    req.user.sub,
    req.params.postId,
    req.params.commentId,
    body,
  );

  res.json({ success: true, message: 'Comment updated', data: { comment } });
});

export const deleteComment = asyncHandler(async (req, res) => {
  const result = await commentService.removeComment(
    req.user.sub,
    req.params.postId,
    req.params.commentId,
  );

  res.json({ success: true, message: 'Comment deleted', data: result });
});

export const reactComment = asyncHandler(async (req, res) => {
  const emoji = req.body.emoji?.trim();
  if (!emoji) throw new AppError('Emoji is required', 400);

  const reactions = await commentService.reactToComment(
    req.user.sub,
    req.params.postId,
    req.params.commentId,
    emoji,
  );

  res.json({ success: true, data: { reactions } });
});

export const reportComment = asyncHandler(async (req, res) => {
  await commentService.reportCommentByUser(
    req.user.sub,
    req.params.postId,
    req.params.commentId,
    req.body.reason ?? null,
  );

  res.json({ success: true, message: 'Comment reported' });
});
