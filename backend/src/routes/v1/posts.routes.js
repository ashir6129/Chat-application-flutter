import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { upload } from '../../middleware/upload.js';
import * as postController from '../../controllers/post.controller.js';
import * as commentController from '../../controllers/comment.controller.js';

const router = Router();

router.post('/media/upload', requireAuth, upload.array('files', 10), postController.uploadMedia);

router.get('/feed', requireAuth, postController.getFeed);
router.get('/reels', requireAuth, postController.getReels);
router.post('/get_reels', requireAuth, postController.getReels);
router.get('/:id', requireAuth, postController.getPost);

router.post('/', requireAuth, postController.createPost);
router.get('/:postId/comments', requireAuth, commentController.getComments);
router.post('/:postId/comments', requireAuth, commentController.addComment);
router.put('/:postId/comments/:commentId', requireAuth, commentController.updateComment);
router.delete('/:postId/comments/:commentId', requireAuth, commentController.deleteComment);
router.post('/:postId/comments/:commentId/react', requireAuth, commentController.reactComment);
router.post('/:postId/comments/:commentId/report', requireAuth, commentController.reportComment);
router.put('/:id', requireAuth, postController.updatePost);
router.patch('/:id/archive', requireAuth, postController.archivePost);
router.post('/:id/poll/vote', requireAuth, postController.votePoll);
router.delete('/:id', requireAuth, postController.deletePost);
router.post('/:id/like', requireAuth, postController.toggleLike);

export default router;
