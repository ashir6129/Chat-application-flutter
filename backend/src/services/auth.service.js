import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import env from '../config/env.js';
import { AppError } from '../utils/AppError.js';
import {
  generateOtp,
  hashOtp,
  verifyOtp,
  otpExpiryDate,
  secondsUntilResend,
  includeMockOtp,
} from '../utils/otp.js';
import {
  signAccessToken,
  signRefreshToken,
  hashToken,
  authResponse,
  verifyToken,
} from '../utils/tokens.js';
import {
  findUserByEmail,
  findUserByUsername,
  findUserById,
  createUser,
  createProfile,
  updateUserPassword,
  markUserVerified,
  saveRefreshToken,
  deleteRefreshTokens,
  findRefreshToken,
  deleteRefreshToken,
  findUserByGoogleId,
  findUserByAppleId,
  createOAuthUser,
  linkGoogleId,
  linkAppleId,
} from '../models/user.model.js';
import {
  deleteOtpsForEmail,
  createOtpRecord,
  findOtpByResetToken,
  updateOtpResend,
  deleteOtpById,
  markOtpVerified,
} from '../models/otp.model.js';
import { sendOtpEmail } from '../utils/email.js';
import { sendPushNotification } from './notification.service.js';
import { listFollowers } from '../models/follow.model.js';

const SALT_ROUNDS = 12;

function normalizeUsername(name, email) {
  const base = (name || email.split('@')[0])
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_]/g, '_')
    .replace(/_+/g, '_')
    .slice(0, 40);

  return base || `user_${Date.now()}`;
}

async function uniqueUsername(base) {
  let username = base;
  let suffix = 1;

  while (await findUserByUsername(username)) {
    username = `${base}_${suffix}`;
    suffix += 1;
  }

  return username;
}

async function persistSession(user) {
  const access = signAccessToken(user);
  const refresh = signRefreshToken(user);

  await deleteRefreshTokens(user.id);
  await saveRefreshToken(user.id, hashToken(refresh.token), refresh.expiry);

  return authResponse(user, access, refresh);
}

export async function register({ name, email, password }) {
  // Strict email format check before hitting the DB
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  if (!emailRegex.test(email?.trim() ?? '')) {
    throw new AppError('Please enter a valid email address', 400);
  }

  const existing = await findUserByEmail(email);
  if (existing) {
    throw new AppError('An account with this email already exists', 409);
  }

  const username = await uniqueUsername(normalizeUsername(name, email));
  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await createUser({ email, username, passwordHash });
  await createProfile(user.id);
  const { ensureWallet } = await import('../models/tip.model.js');
  await ensureWallet(user.id);

  const otp = generateOtp();
  const resetToken = crypto.randomUUID();
  const expiresAt = otpExpiryDate();

  await deleteOtpsForEmail(email);
  const record = await createOtpRecord({
    userId: user.id,
    email,
    resetToken,
    otpHash: hashOtp(otp),
    expiresAt,
  });

  // Send real OTP email — if SMTP not configured, falls back to mock
  const emailSent = await sendOtpEmail({
    to: email,
    otp,
    expiresMinutes: env.otp.expiresMinutes,
    purpose: 'verification',
  });

  // Notify followers that someone they know joined the app
  // This would typically be done after verification, but we'll do it here for now
  // In a real implementation, you'd check if the user has connections from other platforms
  // For now, we'll skip this as it requires additional logic

  return {
    success: true,
    requires_verification: true,
    message: emailSent
      ? `Verification code sent to ${email}`
      : 'OTP sent successfully. Verify your email to continue.',
    reset_token: record.reset_token,
    expires_at: record.expires_at,
    resend_after_seconds: env.otp.resendCooldownSeconds,
    ...includeMockOtp(otp),
  };
}

export async function login({ email, password }) {
  const user = await findUserByEmail(email);
  if (!user) {
    throw new AppError('Invalid email or password', 401);
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    throw new AppError('Invalid email or password', 401);
  }

  if (!user.is_verified) {
    throw new AppError('Please verify your email with the OTP sent at signup.', 403);
  }

  const { ensureWallet } = await import('../models/tip.model.js');
  await ensureWallet(user.id);

  return persistSession(user);
}

export async function refreshAccessToken(refreshToken) {
  let payload;

  try {
    payload = verifyToken(refreshToken);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }

  if (payload.type !== 'refresh') {
    throw new AppError('Invalid refresh token', 401);
  }

  const stored = await findRefreshToken(hashToken(refreshToken));
  if (!stored) {
    throw new AppError('Refresh token expired', 401);
  }

  const user = await findUserById(payload.sub);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  const access = signAccessToken(user);

  return {
    success: true,
    status: 'success',
    access_token: access.token,
    access_token_expiry_datetime: access.expiry,
    refresh_token_expiry_datetime: stored.expires_at,
  };
}

export async function forgotPassword({ email }) {
  // Strict email format check
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  if (!emailRegex.test(email?.trim() ?? '')) {
    throw new AppError('Please enter a valid email address', 400);
  }

  const user = await findUserByEmail(email);

  if (!user) {
    return {
      success: true,
      message: 'If an account exists for this email, an OTP has been sent.',
      reset_token: null,
      resend_after_seconds: env.otp.resendCooldownSeconds,
    };
  }

  const otp = generateOtp();
  const resetToken = crypto.randomUUID();
  const expiresAt = otpExpiryDate();

  await deleteOtpsForEmail(email);
  const record = await createOtpRecord({
    userId: user.id,
    email,
    resetToken,
    otpHash: hashOtp(otp),
    expiresAt,
  });

  // Send real OTP email
  await sendOtpEmail({
    to: email,
    otp,
    expiresMinutes: env.otp.expiresMinutes,
    purpose: 'reset',
  });

  return {
    success: true,
    message: 'OTP sent successfully. Use the code to reset your password.',
    reset_token: record.reset_token,
    expires_at: record.expires_at,
    resend_after_seconds: env.otp.resendCooldownSeconds,
    ...includeMockOtp(otp),
  };
}

export async function resendOtp({ email, resetToken }) {
  const record = await findOtpByResetToken(resetToken);

  if (!record || record.email.toLowerCase() !== email.trim().toLowerCase()) {
    throw new AppError('Invalid or expired reset session', 400);
  }

  if (new Date(record.expires_at) < new Date() && record.resend_count >= env.otp.maxResends) {
    throw new AppError('Reset session expired. Request a new OTP.', 400);
  }

  const wait = secondsUntilResend(record.last_sent_at);
  if (wait > 0) {
    throw new AppError(`Please wait ${wait}s before resending OTP`, 429);
  }

  if (record.resend_count >= env.otp.maxResends) {
    throw new AppError('Maximum resend attempts reached. Request a new OTP.', 429);
  }

  const otp = generateOtp();
  const expiresAt = otpExpiryDate();

  const updated = await updateOtpResend({
    id: record.id,
    otpHash: hashOtp(otp),
    expiresAt,
    resendCount: record.resend_count + 1,
  });

  // Send real OTP email
  await sendOtpEmail({
    to: email,
    otp,
    expiresMinutes: env.otp.expiresMinutes,
    purpose: record.reset_token ? 'verification' : 'reset',
  });

  return {
    success: true,
    message: 'OTP resent successfully.',
    reset_token: updated.reset_token,
    expires_at: updated.expires_at,
    resend_after_seconds: env.otp.resendCooldownSeconds,
    resend_count: updated.resend_count,
    ...includeMockOtp(otp),
  };
}

export async function resetPassword({ email, otp, resetToken, newPassword }) {
  const record = await findOtpByResetToken(resetToken);

  if (!record || record.email.toLowerCase() !== email.trim().toLowerCase()) {
    throw new AppError('Invalid or expired reset session', 400);
  }

  if (new Date(record.expires_at) < new Date()) {
    throw new AppError('OTP has expired. Request a new one.', 400);
  }

  if (!verifyOtp(otp, record.otp_hash)) {
    throw new AppError('Invalid OTP', 400);
  }

  const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
  await updateUserPassword(record.user_id, passwordHash);
  await deleteOtpById(record.id);
  await deleteRefreshTokens(record.user_id);

  return {
    success: true,
    message: 'Password reset successfully. You can now sign in.',
  };
}

export async function verifyRegistration({ email, otp, resetToken }) {
  const record = await findOtpByResetToken(resetToken);

  if (!record || record.email.toLowerCase() !== email.trim().toLowerCase()) {
    throw new AppError('Invalid or expired verification session', 400);
  }

  if (new Date(record.expires_at) < new Date()) {
    throw new AppError('OTP has expired. Request a new one.', 400);
  }

  if (!verifyOtp(otp, record.otp_hash)) {
    throw new AppError('Invalid OTP', 400);
  }

  const user = await findUserById(record.user_id);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  await markUserVerified(user.id);
  await deleteOtpById(record.id);

  const { ensureWallet } = await import('../models/tip.model.js');
  await ensureWallet(user.id);

  return persistSession(user);
}

export async function verifyOtpOnly({ email, otp, resetToken }) {
  const record = await findOtpByResetToken(resetToken);

  if (!record || record.email.toLowerCase() !== email.trim().toLowerCase()) {
    throw new AppError('Invalid or expired reset session', 400);
  }

  if (new Date(record.expires_at) < new Date()) {
    throw new AppError('OTP has expired. Request a new one.', 400);
  }

  if (!verifyOtp(otp, record.otp_hash)) {
    throw new AppError('Invalid OTP', 400);
  }

  await markOtpVerified(record.id);

  return {
    success: true,
    message: 'OTP verified successfully.',
    reset_token: record.reset_token,
  };
}

export async function logout(userId, refreshToken) {
  if (refreshToken) {
    await deleteRefreshToken(hashToken(refreshToken));
  } else {
    await deleteRefreshTokens(userId);
  }

  return { success: true, message: 'Logged out successfully' };
}

async function oauthLogin(user) {
  await createProfile(user.id).catch(() => {});
  const { ensureWallet } = await import('../models/tip.model.js');
  await ensureWallet(user.id);
  return persistSession(user);
}

export async function loginWithGoogle({ idToken }) {
  if (!idToken?.trim()) throw new AppError('Google ID token is required', 400);

  const response = await fetch(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken.trim())}`,
  );
  if (!response.ok) throw new AppError('Invalid Google token', 401);

  const payload = await response.json();
  const googleId = payload.sub;
  const email = payload.email;
  if (!googleId || !email) throw new AppError('Google account email is required', 400);

  if (env.oauth.googleClientIds.length > 0) {
    const aud = payload.aud?.toString();
    if (!aud || !env.oauth.googleClientIds.includes(aud)) {
      throw new AppError('Google token audience mismatch', 401);
    }
  }

  let user = await findUserByGoogleId(googleId);
  if (!user) {
    const byEmail = await findUserByEmail(email);
    if (byEmail) {
      await linkGoogleId(byEmail.id, googleId);
      user = await findUserById(byEmail.id);
    } else {
      const username = await uniqueUsername(normalizeUsername(payload.name, email));
      user = await createOAuthUser({
        email,
        username,
        authProvider: 'google',
        googleId,
        avatarUrl: payload.picture ?? null,
      });
      await createProfile(user.id);
    }
  }

  return oauthLogin(user);
}

export async function loginWithApple({ idToken, name }) {
  if (!idToken?.trim()) throw new AppError('Apple ID token is required', 400);

  const parts = idToken.split('.');
  if (parts.length !== 3) throw new AppError('Invalid Apple token', 401);

  let payload;
  try {
    payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
  } catch {
    throw new AppError('Invalid Apple token payload', 401);
  }

  const appleId = payload.sub;
  const email = payload.email ?? `${appleId}@privaterelay.appleid.com`;
  if (!appleId) throw new AppError('Invalid Apple account', 400);

  if (env.oauth.appleClientIds.length > 0) {
    const aud = payload.aud?.toString();
    if (!aud || !env.oauth.appleClientIds.includes(aud)) {
      throw new AppError('Apple token audience mismatch', 401);
    }
  }

  let user = await findUserByAppleId(appleId);
  if (!user) {
    const byEmail = await findUserByEmail(email);
    if (byEmail) {
      await linkAppleId(byEmail.id, appleId);
      user = await findUserById(byEmail.id);
    } else {
      const username = await uniqueUsername(normalizeUsername(name, email));
      user = await createOAuthUser({
        email,
        username,
        authProvider: 'apple',
        appleId,
      });
      await createProfile(user.id);
    }
  }

  return oauthLogin(user);
}
