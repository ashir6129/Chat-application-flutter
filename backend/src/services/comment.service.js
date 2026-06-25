import { AppError } from '../utils/AppError.js';
import { timeAgo } from '../utils/format.js';
import { findPostById } from '../models/post.model.js';
import { findUserById } from '../models/user.model.js';
import { sendPushNotification } from './notification.service.js';
import {
  listCommentsForPost,
  listReactionsForPost,
  createComment,
  getCommentById,
  updateCommentBody,
  deleteComment,
  toggleReaction,
  reportComment,
  getCommentCount,
  postExists,
} from '../models/comment.model.js';

function serializeComment(row, reactions = []) {
  return {
    id: row.id,
    post_id: row.post_id,
    user_id: row.user_id,
    parent_id: row.parent_id,
    body: row.body,
    created_at: row.created_at,
    time_ago: timeAgo(row.created_at),
    author: {
      id: row.user_id,
      username: row.username,
      avatar_url: row.avatar_url,
      is_verified: row.is_verified,
    },
    reactions,
  };
}

function groupReactions(rows, currentUserId) {
  const byComment = rows.reduce((acc, row) => {
    if (!acc[row.comment_id]) acc[row.comment_id] = [];
    acc[row.comment_id].push(row);
    return acc;
  }, {});

  return Object.fromEntries(
    Object.entries(byComment).map(([commentId, items]) => {
      const counts = items.reduce((acc, item) => {
        acc[item.emoji] = (acc[item.emoji] ?? 0) + 1;
        return acc;
      }, {});

      const mine = items.find((item) => item.user_id === currentUserId)?.emoji ?? null;

      return [
        commentId,
        Object.entries(counts).map(([emoji, count]) => ({ emoji, count, mine: emoji === mine })),
      ];
    }),
  );
}

export async function getComments(postId, currentUserId) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  const [rows, reactionRows] = await Promise.all([
    listCommentsForPost(postId),
    listReactionsForPost(postId),
  ]);

  const reactionMap = groupReactions(reactionRows, currentUserId);
  const all = rows.map((row) =>
    serializeComment(row, reactionMap[row.id] ?? []),
  );

  const topLevel = all.filter((c) => !c.parent_id);
  const repliesByParent = all.reduce((acc, c) => {
    if (c.parent_id) {
      if (!acc[c.parent_id]) acc[c.parent_id] = [];
      acc[c.parent_id].push(c);
    }
    return acc;
  }, {});

  return topLevel.map((comment) => ({
    ...comment,
    replies: repliesByParent[comment.id] ?? [],
  }));
}

export async function addComment(userId, postId, { body, parentId = null }) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  if (!body?.trim()) throw new AppError('Comment cannot be empty', 400);

  const row = await createComment({
    postId,
    userId,
    body: body.trim(),
    parentId: parentId || null,
  });

  const commentCount = await getCommentCount(postId);

  // Send push notification to post author asynchronously
  findPostById(postId, userId).then((post) => {
    if (post && post.user_id !== userId) {
      findUserById(userId).then((commenter) => {
        if (commenter) {
          const commenterName = commenter.username || 'Someone';
          sendPushNotification(post.user_id, {
            title: 'New Comment',
            body: `${commenterName} commented on your post: "${body.substring(0, 30)}${body.length > 30 ? '...' : ''}"`,
            data: {
              type: 'comment',
              post_id: postId,
              commenter_id: userId,
            },
          });
        }
      });
    }
  }).catch((err) => console.error('Failed to send comment push notification:', err.message));

  return {
    comment: serializeComment(row, []),
    comment_count: commentCount,
  };
}

export async function editComment(userId, postId, commentId, body) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  if (!body?.trim()) throw new AppError('Comment cannot be empty', 400);

  const comment = await getCommentById(commentId);
  if (!comment || comment.post_id !== postId) throw new AppError('Comment not found', 404);

  const row = await updateCommentBody(commentId, userId, body.trim());
  if (!row) throw new AppError('You can only edit your own comments', 403);

  return serializeComment(row, []);
}

export async function removeComment(userId, postId, commentId) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  const result = await deleteComment(commentId, userId);
  if (!result) throw new AppError('You can only delete your own comments', 403);

  return result;
}

export async function reactToComment(userId, postId, commentId, emoji) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  const comment = await getCommentById(commentId);
  if (!comment || comment.post_id !== postId) throw new AppError('Comment not found', 404);

  if (!emoji?.trim()) throw new AppError('Emoji is required', 400);

  const result = await toggleReaction(commentId, userId, emoji.trim());

  if (result && comment.user_id !== userId) {
    findUserById(userId).then((reactor) => {
      if (reactor) {
        const reactorName = reactor.username || 'Someone';
        sendPushNotification(comment.user_id, {
          title: 'New Like',
          body: `${reactorName} liked your comment`,
          data: {
            type: 'comment_like',
            post_id: postId,
            comment_id: commentId,
            liker_id: userId,
          },
        });
      }
    }).catch(err => console.error('Failed to send comment like push notification:', err.message));
  }

  const reactionRows = await listReactionsForPost(postId);
  const reactionMap = groupReactions(reactionRows, userId);

  return reactionMap[commentId] ?? [];
}

export async function reportCommentByUser(userId, postId, commentId, reason = null) {
  const exists = await postExists(postId);
  if (!exists) throw new AppError('Post not found', 404);

  const comment = await getCommentById(commentId);
  if (!comment || comment.post_id !== postId) throw new AppError('Comment not found', 404);

  await reportComment(commentId, userId, reason);
  return { reported: true };
}
