import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as chatController from '../../controllers/chat.controller.js';

const router = Router();

router.get('/', requireAuth, chatController.listConversations);
router.post('/direct', requireAuth, chatController.startDirect);
router.post('/group', requireAuth, chatController.createGroup);
router.get('/:id', requireAuth, chatController.getConversation);
router.get('/:id/messages', requireAuth, chatController.listMessages);
router.post('/:id/messages', requireAuth, chatController.sendMessage);
router.post('/:id/read', requireAuth, chatController.markRead);
router.post('/:id/members', requireAuth, chatController.addMember);
router.delete('/:id/members/:userId', requireAuth, chatController.removeMember);
router.delete('/:id', requireAuth, chatController.leaveConversation);

export default router;
