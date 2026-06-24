import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as tipService from '../services/tip.service.js';

export const getWallet = asyncHandler(async (req, res) => {
  const wallet = await tipService.getUserWallet(req.user.sub);
  res.json({ success: true, data: { wallet } });
});

export const sendTip = asyncHandler(async (req, res) => {
  const { recipient_id, post_id, tip_type, amount } = req.body;
  if (!recipient_id) throw new AppError('recipient_id is required', 400);

  const data = await tipService.tipCreator(req.user.sub, {
    recipientId: recipient_id,
    postId: post_id,
    tipType: tip_type,
    amount,
  });

  res.status(201).json({ success: true, data });
});

export const getReceivedTips = asyncHandler(async (req, res) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 20);
  const data = await tipService.getReceivedTips(req.user.sub, { page, limit });
  res.json({ success: true, data });
});
