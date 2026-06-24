export function validateProfileUpdate(body) {
  if (body.bio != null && typeof body.bio !== 'string') {
    return 'Bio must be a string';
  }

  if (body.bio != null && body.bio.length > 500) {
    return 'Bio must be 500 characters or less';
  }

  if (body.location != null && typeof body.location !== 'string') {
    return 'Location must be a string';
  }

  if (body.website != null && typeof body.website !== 'string') {
    return 'Website must be a string';
  }

  if (body.website?.trim()) {
    const urlPattern = /^(https?:\/\/)?[\w.-]+\.[a-z]{2,}(\/.*)?$/i;
    if (!urlPattern.test(body.website.trim())) {
      return 'Invalid website URL';
    }
  }

  if (body.latitude != null && (typeof body.latitude !== 'number' || isNaN(body.latitude))) {
    return 'Latitude must be a valid number';
  }

  if (body.longitude != null && (typeof body.longitude !== 'number' || isNaN(body.longitude))) {
    return 'Longitude must be a valid number';
  }

  if (body.username != null) {
    const usernameError = validateUsername(body.username);
    if (usernameError) return usernameError;
  }

  return null;
}

export function validateUsername(username) {
  if (!username || typeof username !== 'string') {
    return 'Username is required';
  }

  const trimmed = username.trim().toLowerCase();
  if (trimmed.length < 3) {
    return 'Username must be at least 3 characters';
  }

  if (trimmed.length > 50) {
    return 'Username must be 50 characters or less';
  }

  if (!/^[a-z0-9_]+$/.test(trimmed)) {
    return 'Username can only contain letters, numbers, and underscores';
  }

  return null;
}

export function validateAvatar(body) {
  if (!('avatar_url' in body)) {
    return 'avatar_url is required';
  }
  if (body.avatar_url === null || body.avatar_url === '') {
    return null;
  }
  if (typeof body.avatar_url !== 'string') {
    return 'avatar_url must be a string';
  }
  return null;
}

export function validateSearchQuery(query) {
  if (!query?.trim()) return 'Search query q is required';
  if (query.trim().length < 2) return 'Search query must be at least 2 characters';
  return null;
}
