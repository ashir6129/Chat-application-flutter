import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as boxModel from '../models/box.model.js';
import { getWallet } from '../models/tip.model.js';
import { getIO } from '../socket/index.js';
import { findUserById } from '../models/user.model.js';

export const sendBox = asyncHandler(async (req, res) => {
  const { receiver_id, coins, note } = req.body;
  const senderId = req.user.sub;

  if (!receiver_id) {
    throw new AppError('Receiver ID is required', 400);
  }

  const coinAmount = Number(coins ?? 50);
  if (isNaN(coinAmount) || coinAmount < 0) {
    throw new AppError('Coins must be a non-negative number', 400);
  }

  // Prevent sending to self
  if (senderId === receiver_id) {
    throw new AppError('You cannot send a box request to yourself', 400);
  }

  const result = await boxModel.createBoxRequest({
    senderId,
    receiverId: receiver_id,
    coins: coinAmount,
    note: note ?? '',
  });

  if (!result.ok) {
    if (result.reason === 'insufficient_balance') {
      throw new AppError('Insufficient wallet balance to send box', 400);
    }
    throw new AppError('Failed to create box request', 500);
  }

  // Real-time WebSocket emission
  try {
    const sender = await findUserById(senderId);
    const io = getIO();
    if (io && sender) {
      io.to(`user:${receiver_id}`).emit('box:received', {
        id: result.request.id,
        sender_id: senderId,
        coins: coinAmount,
        note: note ?? '',
        sender_username: sender.username,
        sender_avatar: sender.avatar_url,
      });
    }

    // Trigger FCM Notification
    const { sendPushNotification } = await import('../services/notification.service.js');
    await sendPushNotification(receiver_id, {
      title: 'New Mystery Box! 🎁',
      body: `${sender.username} sent you a Box request with ${coinAmount} coins!`,
      data: {
        type: 'box_request',
        request_id: result.request.id,
        sender_id: senderId,
      },
    });
  } catch (err) {
    console.error('Failed to process post-sendBox integrations', err);
  }

  res.json({
    success: true,
    message: 'Box request sent successfully',
    data: result.request,
  });
});

export const getReceived = asyncHandler(async (req, res) => {
  const requests = await boxModel.getReceivedBoxRequests(req.user.sub);
  res.json({ success: true, data: requests });
});

export const getSent = asyncHandler(async (req, res) => {
  const requests = await boxModel.getSentBoxRequests(req.user.sub);
  res.json({ success: true, data: requests });
});

export const updateStatus = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const receiverId = req.user.sub;

  if (!['accepted', 'declined'].includes(status)) {
    throw new AppError('Invalid status. Must be accepted or declined', 400);
  }

  const result = await boxModel.updateBoxRequestStatus(id, receiverId, status);

  if (!result.ok) {
    if (result.reason === 'not_found') {
      throw new AppError('Box request not found', 404);
    }
    if (result.reason === 'already_processed') {
      throw new AppError('Box request has already been processed', 400);
    }
    if (result.reason === 'sender_insufficient_balance') {
      throw new AppError('Sender has insufficient balance to complete the transaction', 400);
    }
    throw new AppError('Failed to update box request status', 500);
  }

  // Real-time WebSocket emission to the sender
  try {
    const request = await boxModel.getBoxRequest(id);
    if (request) {
      const io = getIO();
      if (io) {
        io.to(`user:${request.sender_id}`).emit('box:status_changed', {
          id,
          status,
          receiver_id: receiverId,
        });
      }

      // Trigger FCM Notification
      const { sendPushNotification } = await import('../services/notification.service.js');
      const receiver = await findUserById(receiverId);
      await sendPushNotification(request.sender_id, {
        title: `Box Request ${status === 'accepted' ? 'Accepted! 🎉' : 'Declined'}`,
        body: `${receiver.username} has ${status} your box request.`,
        data: {
          type: 'box_status',
          request_id: id,
          status,
        },
      });
    }
  } catch (err) {
    console.error('Failed to process post-updateStatus integrations', err);
  }

  res.json({
    success: true,
    message: `Box request ${status} successfully`,
    data: result.request,
  });
});

export const getWalletBalance = asyncHandler(async (req, res) => {
  const wallet = await getWallet(req.user.sub);
  res.json({ success: true, data: wallet });
});
