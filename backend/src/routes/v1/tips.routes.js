import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as tipController from '../../controllers/tip.controller.js';

const router = Router();

router.get('/wallet', requireAuth, tipController.getWallet);
router.post('/send', requireAuth, tipController.sendTip);
router.get('/received', requireAuth, tipController.getReceivedTips);

export default router;
