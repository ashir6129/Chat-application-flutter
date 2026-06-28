-- Channel/page metadata on conversations (kind, privacy, etc.)

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_conversations_metadata_kind
  ON conversations ((metadata->>'kind'))
  WHERE metadata->>'kind' IS NOT NULL;
