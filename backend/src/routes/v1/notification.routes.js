import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as notificationController from '../../controllers/notification.controller.js';

const router = Router();

router.get('/', requireAuth, notificationController.getNotifications);
router.put('/read-all', requireAuth, notificationController.markAllRead);
router.put('/:id/read', requireAuth, notificationController.markRead);
router.delete('/:id', requireAuth, notificationController.deleteNotif);

export default router;
