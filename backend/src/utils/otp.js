import crypto from 'crypto';
import env from '../config/env.js';

export function generateOtp() {
  if (env.otp.mockEnabled) {
    return env.otp.mockCode;
  }

  return String(crypto.randomInt(100000, 999999));
}

export function hashOtp(otp) {
  return crypto.createHash('sha256').update(String(otp)).digest('hex');
}

export function verifyOtp(otp, hash) {
  return hashOtp(otp) === hash;
}

export function otpExpiryDate() {
  return new Date(Date.now() + env.otp.expiresMinutes * 60 * 1000);
}

export function secondsUntilResend(lastSentAt) {
  const elapsed = Math.floor((Date.now() - new Date(lastSentAt).getTime()) / 1000);
  return Math.max(0, env.otp.resendCooldownSeconds - elapsed);
}

export function includeMockOtp(otp) {
  if (!env.otp.mockEnabled) {
    return {};
  }

  return { mock_otp: otp };
}
