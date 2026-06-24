-- 015_box_requests.sql
-- Create box_requests table for connection requests

CREATE TABLE IF NOT EXISTS box_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  coins INTEGER NOT NULL DEFAULT 50 CHECK (coins >= 0),
  note TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (sender_id, receiver_id)
);

CREATE INDEX IF NOT EXISTS idx_box_requests_receiver ON box_requests (receiver_id, status);
CREATE INDEX IF NOT EXISTS idx_box_requests_sender ON box_requests (sender_id, status);
