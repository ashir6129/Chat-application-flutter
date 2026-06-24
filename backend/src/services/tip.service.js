import { AppError } from '../utils/AppError.js';
import { findUserById } from '../models/user.model.js';
import { findPostById } from '../models/post.model.js';
import { getWallet, sendTip, listTipsForUser } from '../models/tip.model.js';
import env from '../config/env.js';

export async function getUserWallet(userId) {
  const wallet = await getWallet(userId);
  if (!wallet) throw new AppError('Wallet not found', 404);
  return {
    balance_credits: wallet.balance_credits,
    tips_received_total: wallet.tips_received_total,
    updated_at: wallet.updated_at,
  };
}

export async function tipCreator(userId, { recipientId, postId, tipType, amount }) {
  const parsedAmount = Number(amount);
  if (!Number.isInteger(parsedAmount) || parsedAmount <= 0) {
    throw new AppError('Invalid tip amount', 400);
  }
  if (!tipType?.trim()) throw new AppError('Tip type is required', 400);
  if (recipientId === userId) throw new AppError('You cannot tip yourself', 400);

  const recipient = await findUserById(recipientId);
  if (!recipient) throw new AppError('Creator not found', 404);

  if (postId) {
    const post = await findPostById(postId, userId, env.upload.baseUrl);
    if (!post) throw new AppError('Post not found', 404);
    if (post.user_id !== recipientId) {
      throw new AppError('Post does not belong to this creator', 400);
    }
  }

  const result = await sendTip({
    senderId: userId,
    recipientId,
    postId: postId ?? null,
    tipType: tipType.trim(),
    amount: parsedAmount,
  });

  if (!result.ok) {
    throw new AppError(
      `Insufficient credits. Balance: ${result.balance ?? 0}`,
      402,
    );
  }

  return {
    tip: result.tip,
    balance_credits: result.balance,
    message: 'Tip sent successfully',
  };
}

export async function getReceivedTips(userId, { page = 1, limit = 20 }) {
  const tips = await listTipsForUser(userId, { page, limit });
  return { tips, page, limit };
}
