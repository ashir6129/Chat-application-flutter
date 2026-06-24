import jwt from 'jsonwebtoken';
import env from '../config/env.js';

export function socketAuth(socket, next) {
  try {
    const token = socket.handshake.auth?.token ?? socket.handshake.headers?.authorization?.replace('Bearer ', '');

    if (!token) {
      return next(new Error('Authentication required'));
    }

    const payload = jwt.verify(token, env.jwt.secret);
    socket.userId = payload.sub;
    socket.username = payload.username;
    next();
  } catch {
    next(new Error('Invalid or expired token'));
  }
}
