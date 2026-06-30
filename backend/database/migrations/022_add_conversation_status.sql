-- Add status field to conversation_members for message requests
-- pending: message request not yet accepted
-- accepted: conversation is active (default for existing conversations)

ALTER TABLE conversation_members 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'accepted'
CHECK (status IN ('pending', 'accepted'));

-- Create index for efficient querying of pending requests
CREATE INDEX IF NOT EXISTS idx_conversation_members_status 
ON conversation_members (status, user_id);

-- Set all existing conversations to accepted status
UPDATE conversation_members 
SET status = 'accepted' 
WHERE status IS NULL OR status = 'pending';
