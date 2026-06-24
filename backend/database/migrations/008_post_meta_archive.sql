-- Post metadata (polls, etc.) and archive support

ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS post_meta JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_posts_user_archived ON posts (user_id, is_archived, created_at DESC);
