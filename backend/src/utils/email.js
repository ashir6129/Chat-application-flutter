import nodemailer from 'nodemailer';
import env from '../config/env.js';
import { AppError } from './AppError.js';

let _transporter = null;

function getTransporter() {
  if (_transporter) return _transporter;

  if (!env.email.host || !env.email.user || !env.email.pass) {
    return null; // email not configured → fall back to mock
  }

  _transporter = nodemailer.createTransport({
    host: env.email.host,
    port: env.email.port,
    secure: env.email.secure,     // true = port 465, false = 587 (STARTTLS)
    auth: {
      user: env.email.user,
      pass: env.email.pass?.replace(/\s+/g, ''),
    },
  });

  return _transporter;
}

/**
 * Send OTP email.
 * Returns true if sent, false if email is not configured (caller handles mock fallback).
 */
export async function sendOtpEmail({ to, otp, expiresMinutes = 10, purpose = 'verification' }) {
  const transporter = getTransporter();

  if (!transporter) {
    // Email not configured — caller should use mock OTP fallback
    return false;
  }

  const purposeLabel =
    purpose === 'reset' ? 'password reset' : 'email verification';

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 32px; background: #f9f9f9; border-radius: 12px;">
      <h2 style="color: #111; margin-bottom: 8px;">ZyntraPlus</h2>
      <p style="color: #444; font-size: 15px;">Your ${purposeLabel} code is:</p>
      <div style="font-size: 40px; font-weight: 700; letter-spacing: 10px; color: #111; text-align: center; padding: 20px 0;">
        ${otp}
      </div>
      <p style="color: #666; font-size: 13px;">
        This code expires in <strong>${expiresMinutes} minutes</strong>. Do not share it with anyone.
      </p>
      <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
      <p style="color: #aaa; font-size: 11px;">If you did not request this, please ignore this email.</p>
    </div>
  `;

  try {
    await transporter.sendMail({
      from: `"ZyntraPlus" <${env.email.from || env.email.user}>`,
      to,
      subject: `${otp} is your ZyntraPlus ${purposeLabel} code`,
      html,
    });
    return true;
  } catch (error) {
    throw new AppError('Could not send OTP. Please check if your email address is correct.', 400);
  }
}
