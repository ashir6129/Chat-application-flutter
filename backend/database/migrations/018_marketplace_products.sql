-- 018_marketplace_products.sql
-- Marketplace products for ZyntraPlus

CREATE TABLE IF NOT EXISTS marketplace_products (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  description  TEXT,
  price        NUMERIC(12,2) NOT NULL DEFAULT 0,
  currency     VARCHAR(10) NOT NULL DEFAULT '₦',
  stock        INTEGER NOT NULL DEFAULT 0,
  image_url    TEXT,
  category     VARCHAR(80),
  condition    VARCHAR(30),
  allow_resell BOOLEAN NOT NULL DEFAULT FALSE,
  resell_margin_pct INTEGER DEFAULT 0,  -- e.g. 15 means resellers earn 15%
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_marketplace_products_user_id
  ON marketplace_products (user_id);

CREATE INDEX IF NOT EXISTS idx_marketplace_products_resell
  ON marketplace_products (allow_resell)
  WHERE allow_resell = TRUE AND is_active = TRUE;
