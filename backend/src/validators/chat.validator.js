export function validateDirectChat(body) {
  if (!body.user_id || typeof body.user_id !== 'string') {
    return 'user_id is required';
  }
  return null;
}

export function validateGroupChat(body) {
  if (!body.title?.trim()) return 'title is required';
  if (body.title.trim().length > 120) return 'title must be 120 characters or less';

  if (body.member_ids != null && !Array.isArray(body.member_ids)) {
    return 'member_ids must be an array';
  }

  if (body.kind != null && !['group', 'channel'].includes(body.kind)) {
    return 'kind must be group or channel';
  }

  if (body.privacy != null && !['public', 'private', 'anonymous'].includes(body.privacy)) {
    return 'privacy must be public, private, or anonymous';
  }

  return null;
}

export function validateSendMessage(body) {
  const VALID_TYPES = ['text', 'image', 'voice', 'system'];
  if (body.message_type && !VALID_TYPES.includes(body.message_type)) {
    return 'Invalid message_type';
  }

  // Voice messages carry audio in metadata, body is just a label
  if (!body.body?.trim() && !['image', 'voice'].includes(body.message_type)) {
    return 'body is required';
  }

  // Allow larger payloads for voice messages (base64 audio)
  const maxLen = body.message_type === 'voice' ? 10_000_000 : 5000;
  if (body.body && body.body.length > maxLen) {
    return 'Message too long';
  }

  return null;
}

export function validateAddMember(body) {
  if (!body.user_id || typeof body.user_id !== 'string') {
    return 'user_id is required';
  }
  return null;
}
