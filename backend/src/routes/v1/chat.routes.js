import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as chatController from '../../controllers/chat.controller.js';

const router = Router();

router.get('/', requireAuth, chatController.listConversations);
router.get('/requests', requireAuth, chatController.listMessageRequests);
router.post('/direct', requireAuth, chatController.startDirect);
router.post('/group', requireAuth, chatController.createGroup);
router.get('/:id', requireAuth, chatController.getConversation);
router.get('/:id/messages', requireAuth, chatController.listMessages);
router.post('/:id/messages', requireAuth, chatController.sendMessage);
router.post('/:id/read', requireAuth, chatController.markRead);
router.delete('/:id/messages/:messageId', requireAuth, chatController.unsendMessage);
router.post('/:id/messages/:messageId/reactions', requireAuth, chatController.addReaction);
router.delete('/:id/messages/:messageId/reactions', requireAuth, chatController.removeReaction);
router.post('/:id/messages/:messageId/pin', requireAuth, chatController.pinMessage);
router.delete('/:id/messages/pin', requireAuth, chatController.unpinMessage);
router.post('/:id/members', requireAuth, chatController.addMember);
router.delete('/:id/members/:userId', requireAuth, chatController.removeMember);
router.delete('/:id', requireAuth, chatController.leaveConversation);
router.post('/:id/accept', requireAuth, chatController.acceptMessageRequest);
router.post('/:id/decline', requireAuth, chatController.declineMessageRequest);

export default router;
