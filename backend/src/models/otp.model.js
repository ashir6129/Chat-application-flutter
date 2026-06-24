import { query } from '../config/db.js';

export async function deleteOtpsForEmail(email) {
  await query(`DELETE FROM password_reset_otps WHERE LOWER(email) = LOWER($1)`, [email]);
}

export async function createOtpRecord({ userId, email, resetToken, otpHash, expiresAt }) {
  const result = await query(
    `INSERT INTO password_reset_otps (user_id, email, reset_token, otp_hash, expires_at)
     VALUES ($1, LOWER($2), $3, $4, $5)
     RETURNING reset_token, expires_at, last_sent_at, resend_count`,
    [userId, email, resetToken, otpHash, expiresAt],
  );
  return result.rows[0];
}

export async function findOtpByResetToken(resetToken) {
  const result = await query(
    `SELECT id, user_id, email, reset_token, otp_hash, expires_at, verified, resend_count, last_sent_at
     FROM password_reset_otps
     WHERE reset_token = $1
     LIMIT 1`,
    [resetToken],
  );
  return result.rows[0] ?? null;
}

export async function updateOtpResend({ id, otpHash, expiresAt, resendCount }) {
  const result = await query(
    `UPDATE password_reset_otps
     SET otp_hash = $2, expires_at = $3, resend_count = $4, last_sent_at = NOW()
     WHERE id = $1
     RETURNING reset_token, expires_at, last_sent_at, resend_count`,
    [id, otpHash, expiresAt, resendCount],
  );
  return result.rows[0];
}

export async function markOtpVerified(id) {
  await query(`UPDATE password_reset_otps SET verified = TRUE WHERE id = $1`, [id]);
}

export async function deleteOtpById(id) {
  await query(`DELETE FROM password_reset_otps WHERE id = $1`, [id]);
}
