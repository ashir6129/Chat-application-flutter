import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import env from '../config/env.js';

function tokenExpiryIso(token) {
  const decoded = jwt.decode(token);
  return new Date(decoded.exp * 1000).toISOString();
}

export function signAccessToken(user) {
  const token = jwt.sign(
    { sub: user.id, email: user.email, username: user.username },
    env.jwt.secret,
    { expiresIn: env.jwt.accessExpiresIn },
  );

  return { token, expiry: tokenExpiryIso(token) };
}

export function signRefreshToken(user) {
  const token = jwt.sign(
    { sub: user.id, type: 'refresh' },
    env.jwt.secret,
    { expiresIn: env.jwt.refreshExpiresIn },
  );

  return { token, expiry: tokenExpiryIso(token) };
}

export function verifyToken(token) {
  return jwt.verify(token, env.jwt.secret);
}

export function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

export function authResponse(user, access, refresh) {
  return {
    success: true,
    status: 'success',
    message: 'Authenticated successfully',
    access_token: access.token,
    refresh_token: refresh.token,
    access_token_expiry_datetime: access.expiry,
    refresh_token_expiry_datetime: refresh.expiry,
    user_uid: user.id,
    user: {
      id: user.id,
      email: user.email,
      username: user.username,
      is_verified: user.is_verified,
    },
  };
}
