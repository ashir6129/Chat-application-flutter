-- 016_add_fcm_token_to_users.sql
-- Add fcm_token column to users table

ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255);
