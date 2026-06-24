import { Router } from 'express';
import { authLimiter } from '../../middleware/rateLimit.js';
import { requireAuth } from '../../middleware/auth.js';
import * as authController from '../../controllers/auth.controller.js';

const router = Router();

router.use(authLimiter);

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshAccessToken);
router.post('/refresh_access_token', authController.refreshAccessToken);
router.post('/logout', requireAuth, authController.logout);
router.post('/forgot-password', authController.forgotPassword);
router.post('/resend-otp', authController.resendOtp);
router.post('/verify-registration', authController.verifyRegistration);
router.post('/verify-otp', authController.verifyOtp);
router.post('/reset-password', authController.resetPassword);
router.post('/google', authController.loginGoogle);
router.post('/apple', authController.loginApple);

export default router;
