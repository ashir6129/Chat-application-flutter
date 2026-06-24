import { query } from '../config/db.js';

export async function findUserByEmail(email) {
  const result = await query(
    `SELECT id, email, username, password_hash, avatar_url, is_verified, is_spotlight, created_at
     FROM users WHERE LOWER(email) = LOWER($1) LIMIT 1`,
    [email.trim()],
  );
  return result.rows[0] ?? null;
}

export async function findUserByUsername(username) {
  const result = await query(
    `SELECT id, email, username, password_hash, avatar_url, is_verified, is_spotlight, created_at
     FROM users WHERE LOWER(username) = LOWER($1) LIMIT 1`,
    [username.trim()],
  );
  return result.rows[0] ?? null;
}

export async function findUserById(id) {
  const result = await query(
    `SELECT id, email, username, password_hash, avatar_url, is_verified, is_spotlight, created_at
     FROM users WHERE id = $1 LIMIT 1`,
    [id],
  );
  return result.rows[0] ?? null;
}

export async function findUserByGoogleId(googleId) {
  const result = await query(
    `SELECT id, email, username, password_hash, avatar_url, is_verified, is_spotlight, created_at
     FROM users WHERE google_id = $1 LIMIT 1`,
    [googleId],
  );
  return result.rows[0] ?? null;
}

export async function findUserByAppleId(appleId) {
  const result = await query(
    `SELECT id, email, username, password_hash, avatar_url, is_verified, is_spotlight, created_at
     FROM users WHERE apple_id = $1 LIMIT 1`,
    [appleId],
  );
  return result.rows[0] ?? null;
}

export async function createOAuthUser({ email, username, authProvider, googleId, appleId, avatarUrl }) {
  const result = await query(
    `INSERT INTO users (email, username, password_hash, auth_provider, google_id, apple_id, avatar_url, is_verified)
     VALUES ($1, $2, NULL, $3, $4, $5, $6, TRUE)
     RETURNING id, email, username, avatar_url, is_verified, is_spotlight, created_at`,
    [
      email.trim().toLowerCase(),
      username.trim(),
      authProvider,
      googleId ?? null,
      appleId ?? null,
      avatarUrl ?? null,
    ],
  );
  return result.rows[0];
}

export async function linkGoogleId(userId, googleId) {
  await query(`UPDATE users SET google_id = $2, auth_provider = 'google', updated_at = NOW() WHERE id = $1`, [
    userId,
    googleId,
  ]);
}

export async function linkAppleId(userId, appleId) {
  await query(`UPDATE users SET apple_id = $2, auth_provider = 'apple', updated_at = NOW() WHERE id = $1`, [
    userId,
    appleId,
  ]);
}

export async function markUserVerified(userId) {
  await query(
    `UPDATE users SET is_verified = TRUE, updated_at = NOW() WHERE id = $1`,
    [userId],
  );
}

export async function createUser({ email, username, passwordHash }) {
  const result = await query(
    `INSERT INTO users (email, username, password_hash)
     VALUES ($1, $2, $3)
     RETURNING id, email, username, avatar_url, is_verified, is_spotlight, created_at`,
    [email.trim().toLowerCase(), username.trim(), passwordHash],
  );
  return result.rows[0];
}

export async function createProfile(userId) {
  await query(
    `INSERT INTO profiles (user_id, bio) VALUES ($1, $2)`,
    [userId, 'Explore. Connect. Grow.'],
  );
}

export async function updateUserPassword(userId, passwordHash) {
  await query(
    `UPDATE users SET password_hash = $2, updated_at = NOW() WHERE id = $1`,
    [userId, passwordHash],
  );
}

export async function saveRefreshToken(userId, tokenHash, expiresAt) {
  await query(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)`,
    [userId, tokenHash, expiresAt],
  );
}

export async function deleteRefreshTokens(userId) {
  await query(`DELETE FROM refresh_tokens WHERE user_id = $1`, [userId]);
}

export async function deleteUserById(userId) {
  await deleteRefreshTokens(userId);
  await query(`DELETE FROM users WHERE id = $1`, [userId]);
}

export async function findRefreshToken(tokenHash) {
  const result = await query(
    `SELECT id, user_id, token_hash, expires_at FROM refresh_tokens
     WHERE token_hash = $1 AND expires_at > NOW() LIMIT 1`,
    [tokenHash],
  );
  return result.rows[0] ?? null;
}

export async function deleteRefreshToken(tokenHash) {
  await query(`DELETE FROM refresh_tokens WHERE token_hash = $1`, [tokenHash]);
}

export async function findProfileByUserId(userId) {
  const result = await query(
    `SELECT u.id, u.email, u.username, u.avatar_url, u.is_verified, u.is_spotlight,
            u.created_at, u.last_seen_at, p.bio, p.location, p.website, p.latitude, p.longitude, p.updated_at AS profile_updated_at
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE u.id = $1
     LIMIT 1`,
    [userId],
  );
  return result.rows[0] ?? null;
}

export async function findPublicProfileByUsername(username) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight,
            u.created_at, u.last_seen_at, p.bio, p.location, p.website, p.latitude, p.longitude
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE LOWER(u.username) = LOWER($1)
     LIMIT 1`,
    [username.trim()],
  );
  return result.rows[0] ?? null;
}

export async function updateLastSeen(userId) {
  await query(
    `UPDATE users SET last_seen_at = NOW(), updated_at = NOW() WHERE id = $1`,
    [userId],
  );
}

export async function updateProfile(userId, { bio, location, website, latitude, longitude }) {
  const result = await query(
    `UPDATE profiles
     SET bio = COALESCE($2, bio),
         location = COALESCE($3, location),
         website = COALESCE($4, website),
         latitude = COALESCE($5, latitude),
         longitude = COALESCE($6, longitude),
         updated_at = NOW()
     WHERE user_id = $1
     RETURNING user_id, bio, location, website, latitude, longitude, updated_at`,
    [
      userId,
      bio ?? null,
      location ?? null,
      website ?? null,
      latitude ?? null,
      longitude ?? null,
    ],
  );
  return result.rows[0] ?? null;
}

export async function updateUserAvatar(userId, avatarUrl) {
  const result = await query(
    `UPDATE users SET avatar_url = $2, updated_at = NOW()
     WHERE id = $1
     RETURNING id, avatar_url`,
    [userId, avatarUrl],
  );
  return result.rows[0] ?? null;
}

export async function updateUsername(userId, username) {
  const result = await query(
    `UPDATE users SET username = $2, updated_at = NOW()
     WHERE id = $1
     RETURNING id, username`,
    [userId, username.trim()],
  );
  return result.rows[0] ?? null;
}

export async function findUsernameTakenByOther(userId, username) {
  const result = await query(
    `SELECT id FROM users
     WHERE LOWER(username) = LOWER($1) AND id <> $2
     LIMIT 1`,
    [username.trim(), userId],
  );
  return result.rows[0] ?? null;
}

export async function searchUsers(queryText, { limit = 20, offset = 0 } = {}) {
  const pattern = `%${queryText.trim()}%`;
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight, p.bio
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE LOWER(u.username) LIKE LOWER($1)
     ORDER BY u.username ASC
     LIMIT $2 OFFSET $3`,
    [pattern, limit, offset],
  );
  return result.rows;
}

export async function listUsers(limit = 20, offset = 0) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight, p.bio
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     ORDER BY u.created_at DESC
     LIMIT $1 OFFSET $2`,
    [limit, offset],
  );
  return result.rows;
}

export async function listUsersForViewer(viewerId, { limit = 20, offset = 0 } = {}) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight, p.bio,
            EXISTS(
              SELECT 1 FROM user_follows uf
              WHERE uf.follower_id = $1 AND uf.following_id = u.id
            ) AS is_following,
            EXISTS(
              SELECT 1 FROM user_follows uf
              WHERE uf.follower_id = u.id AND uf.following_id = $1
            ) AS follows_viewer
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE u.id <> $1
     ORDER BY u.created_at DESC
     LIMIT $2 OFFSET $3`,
    [viewerId, limit, offset],
  );
  return result.rows;
}

export async function listSuggestedUsers(viewerId, { limit = 20, offset = 0 } = {}) {
  const result = await query(
    `SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight, p.bio,
            false AS is_following,
            EXISTS(
              SELECT 1 FROM user_follows uf
              WHERE uf.follower_id = u.id AND uf.following_id = $1
            ) AS follows_viewer,
            (SELECT COUNT(*)::int FROM user_follows WHERE following_id = u.id) AS follower_count
     FROM users u
     LEFT JOIN profiles p ON p.user_id = u.id
     WHERE u.id <> $1
       AND NOT EXISTS (
         SELECT 1 FROM user_follows uf
         WHERE uf.follower_id = $1 AND uf.following_id = u.id
       )
     ORDER BY u.is_spotlight DESC, u.created_at DESC
     LIMIT $2 OFFSET $3`,
    [viewerId, limit, offset],
  );
  return result.rows;
}

export async function listNearbyUsers(viewerId, { latitude, longitude, maxDistanceKm = 50, limit = 20, offset = 0 } = {}) {
  const hasCoords = latitude != null && longitude != null;
  const distanceSql = hasCoords
    ? `(6371 * acos(
        LEAST(GREATEST(
          cos(radians($2)) * cos(radians(p.latitude)) * cos(radians(p.longitude) - radians($3)) + 
          sin(radians($2)) * sin(radians(p.latitude)),
          -1.0
        ), 1.0)
      ))`
    : `NULL`;

  const distanceFilter = hasCoords
    ? `AND p.latitude IS NOT NULL AND p.longitude IS NOT NULL AND ${distanceSql} <= $4`
    : ``;

  const params = [viewerId];
  if (hasCoords) {
    params.push(latitude, longitude, maxDistanceKm);
  }
  params.push(limit, offset);

  const limitIndex = params.length - 1;
  const offsetIndex = params.length;

  const queryStr = `
    SELECT u.id, u.username, u.avatar_url, u.is_verified, u.is_spotlight, p.bio, p.location,
           p.latitude, p.longitude,
           EXISTS(
             SELECT 1 FROM user_follows uf
             WHERE uf.follower_id = $1 AND uf.following_id = u.id
           ) AS is_following,
           EXISTS(
             SELECT 1 FROM user_follows uf
             WHERE uf.follower_id = u.id AND uf.following_id = $1
           ) AS follows_viewer,
           (SELECT status FROM box_requests WHERE (sender_id = $1 AND receiver_id = u.id) OR (sender_id = u.id AND receiver_id = $1) LIMIT 1) AS box_status,
           (SELECT sender_id FROM box_requests WHERE (sender_id = $1 AND receiver_id = u.id) OR (sender_id = u.id AND receiver_id = $1) LIMIT 1) AS box_sender_id,
           (SELECT id FROM box_requests WHERE (sender_id = $1 AND receiver_id = u.id) OR (sender_id = u.id AND receiver_id = $1) LIMIT 1) AS box_request_id,
           ${distanceSql} AS distance_km
    FROM users u
    LEFT JOIN profiles p ON p.user_id = u.id
    WHERE u.id <> $1
      ${distanceFilter}
    ORDER BY u.is_spotlight DESC, ${hasCoords ? 'distance_km ASC,' : ''} u.created_at DESC
    LIMIT $${limitIndex} OFFSET $${offsetIndex}
  `;

  const result = await query(queryStr, params);
  return result.rows;
}
