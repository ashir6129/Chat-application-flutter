-- In-app tipping & wallet credits

CREATE TABLE IF NOT EXISTS user_wallets (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  balance_credits INTEGER NOT NULL DEFAULT 500 CHECK (balance_credits >= 0),
  tips_received_total INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  tip_type VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tips_recipient ON tips (recipient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tips_sender ON tips (sender_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tips_post ON tips (post_id) WHERE post_id IS NOT NULL;
