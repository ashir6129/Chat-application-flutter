import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as userController from '../../controllers/user.controller.js';
import * as followController from '../../controllers/follow.controller.js';

const router = Router();

router.get('/me', requireAuth, userController.getMe);
router.get('/me/posts', requireAuth, userController.getMyPosts);
router.put('/me', requireAuth, userController.updateMe);
router.patch('/me/avatar', requireAuth, userController.updateAvatar);
router.delete('/me', requireAuth, userController.deleteMe);
router.get('/suggestions', requireAuth, userController.suggestions);
router.get('/nearby', requireAuth, userController.getNearby);
router.put('/me/location', requireAuth, userController.updateLocation);
router.put('/me/fcm-token', requireAuth, userController.updateFcmToken);
router.get('/search', requireAuth, userController.search);
router.get('/', requireAuth, userController.list);
router.get('/id/:userId', requireAuth, userController.getByUserId);
router.post('/:userId/follow', requireAuth, followController.followUser);
router.delete('/:userId/follow', requireAuth, followController.unfollowUser);
router.get('/:userId/follow-status', requireAuth, followController.getFollowStatus);
router.get('/:userId/followers', requireAuth, followController.listFollowers);
router.get('/:userId/following', requireAuth, followController.listFollowing);
router.get('/:username/posts', requireAuth, userController.getUserPosts);
router.get('/:username', requireAuth, userController.getByUsername);

export default router;
