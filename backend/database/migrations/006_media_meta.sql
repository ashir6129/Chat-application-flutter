-- Store per-media filter/edit metadata (video filters, etc.)

ALTER TABLE posts ADD COLUMN IF NOT EXISTS media_meta JSONB NOT NULL DEFAULT '[]';
