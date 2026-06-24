import env from '../config/env.js';

const DEFAULT_JWT_SECRET = 'zyntraplus-dev-secret-change-me';

export function validateEnvironment() {
  if (env.nodeEnv !== 'production') return;

  if (!process.env.JWT_SECRET || env.jwt.secret === DEFAULT_JWT_SECRET) {
    throw new Error('JWT_SECRET must be set to a strong value in production');
  }

  if (!process.env.DB_PASSWORD && !process.env.DATABASE_URL?.trim()) {
    throw new Error('Set DATABASE_URL (Railway Postgres) or DB_PASSWORD in production');
  }
}
