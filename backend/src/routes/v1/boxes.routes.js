import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as boxController from '../../controllers/box.controller.js';

const router = Router();

router.post('/', requireAuth, boxController.sendBox);
router.get('/received', requireAuth, boxController.getReceived);
router.get('/sent', requireAuth, boxController.getSent);
router.put('/:id/status', requireAuth, boxController.updateStatus);
router.get('/wallet', requireAuth, boxController.getWalletBalance);

export default router;
