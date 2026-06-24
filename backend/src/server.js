import http from 'http';
import app from './app.js';
import env from './config/env.js';
import pool from './config/db.js';
import { initRedis } from './config/redis.js';
import { initSocket } from './socket/index.js';

function formatDbError(err) {
  if (!err) return 'unknown error';
  const parts = [err.message, err.code, err.errno, err.syscall, err.address, err.port].filter(Boolean);
  if (parts.length) return parts.join(' | ');
  try {
    return JSON.stringify(err, Object.getOwnPropertyNames(err));
  } catch {
    return String(err);
  }
}

function logDbTarget() {
  if (env.db.connectionString) {
    console.log('DB target: DATABASE_URL (linked Postgres)');
  } else {
    console.log(
      `DB target: ${env.db.host}:${env.db.port}/${env.db.name} (user: ${env.db.user})`,
    );
  }
}

async function start() {
  logDbTarget();

  try {
    await pool.query('SELECT 1');
    console.log('PostgreSQL connected');
  } catch (err) {
    console.error('PostgreSQL connection failed:', formatDbError(err));

    const onRailway = Boolean(process.env.RAILWAY_ENVIRONMENT || process.env.RAILWAY_PROJECT_ID);

    if (onRailway && !env.db.connectionString) {
      console.error(
        'Railway: open your API service (zyntraplus-1) → Variables → Add Reference → DATABASE_URL = ${{Postgres.DATABASE_URL}}',
      );
    } else if (env.db.connectionString) {
      console.error('Using DATABASE_URL — ensure Postgres is linked and the service was redeployed.');
    } else if (env.nodeEnv === 'production') {
      console.error(
        'Set DATABASE_URL (Postgres reference) or DB_HOST/DB_PASSWORD on this service.',
      );
    } else {
      console.error('Start Postgres with: docker compose up -d');
    }
    process.exit(1);
  }

  const server = http.createServer(app);
  await initRedis();
  await initSocket(server);

  server.listen(env.port, () => {
    console.log(`API running on http://localhost:${env.port}${env.apiPrefix}`);
    console.log(`Socket.IO on ws://localhost:${env.port}${env.socket.path}`);
  });
}

start();