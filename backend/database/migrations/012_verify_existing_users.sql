-- Grandfather accounts created before email OTP verification was required.
UPDATE users SET is_verified = TRUE WHERE is_verified = FALSE;
