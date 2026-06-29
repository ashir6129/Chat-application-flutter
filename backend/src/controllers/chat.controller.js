import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as chatService from '../services/chat.service.js';
import * as chatValidator from '../validators/chat.validator.js';

export const listConversations = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 30);
  const data = await chatService.getConversations(req.user.sub, { page, limit });
  res.json({ success: true, data });
});

export const getConversation = asyncHandler(async (req, res) => {
  const conversation = await chatService.getConversation(req.user.sub, req.params.id);
  res.json({ success: true, data: { conversation } });
});

export const startDirect = asyncHandler(async (req, res) => {
  const error = chatValidator.validateDirectChat(req.body);
  if (error) throw new AppError(error, 400);

  const conversation = await chatService.startDirectConversation(
    req.user.sub,
    req.body.user_id,
  );
  res.status(201).json({ success: true, data: { conversation } });
});

export const createGroup = asyncHandler(async (req, res) => {
  const error = chatValidator.validateGroupChat(req.body);
  if (error) throw new AppError(error, 400);

  const conversation = await chatService.createGroupConversation(req.user.sub, {
    title: req.body.title,
    memberIds: req.body.member_ids ?? [],
    kind: req.body.kind ?? 'group',
    privacy: req.body.privacy ?? 'public',
  });
  res.status(201).json({ success: true, data: { conversation } });
});

export const listMessages = asyncHandler(async (req, res) => {
  const limit = Number(req.query.limit ?? 50);
  const before = req.query.before ?? null;
  const data = await chatService.getConversationMessages(req.user.sub, req.params.id, {
    limit,
    before,
  });
  res.json({ success: true, data });
});

export const unsendMessage = asyncHandler(async (req, res) => {
  const { messageId } = req.params;
  const result = await chatService.unsendMessage(req.user.sub, req.params.id, messageId);
  res.json({ success: true, data: result });
});

export const addReaction = asyncHandler(async (req, res) => {
  const { messageId } = req.params;
  const { emoji } = req.body;
  const result = await chatService.addReaction(req.user.sub, req.params.id, messageId, emoji);
  res.json({ success: true, data: result });
});

export const removeReaction = asyncHandler(async (req, res) => {
  const { messageId } = req.params;
  const result = await chatService.removeReaction(req.user.sub, req.params.id, messageId);
  res.json({ success: true, data: result });
});

export const sendMessage = asyncHandler(async (req, res) => {
  const error = chatValidator.validateSendMessage(req.body);
  if (error) throw new AppError(error, 400);

  const message = await chatService.sendMessage(
    req.user.sub,
    req.params.id,
    req.body.body,
    {
      messageType: req.body.message_type,
      metadata: req.body.metadata,
    },
  );
  res.status(201).json({ success: true, data: { message } });
});

export const markRead = asyncHandler(async (req, res) => {
  const result = await chatService.markRead(req.user.sub, req.params.id);
  res.json({ success: true, data: result });
});

export const addMember = asyncHandler(async (req, res) => {
  const error = chatValidator.validateAddMember(req.body);
  if (error) throw new AppError(error, 400);

  const conversation = await chatService.addGroupMember(
    req.user.sub,
    req.params.id,
    req.body.user_id,
  );
  res.json({ success: true, data: { conversation } });
});

export const removeMember = asyncHandler(async (req, res) => {
  const result = await chatService.removeGroupMember(
    req.user.sub,
    req.params.id,
    req.params.userId,
  );
  res.json({ success: true, data: result });
});

export const leaveConversation = asyncHandler(async (req, res) => {
  const result = await chatService.leaveConversation(req.user.sub, req.params.id);
  res.json({ success: true, data: result });
});
