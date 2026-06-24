import pg from 'pg';
import env from './env.js';

const { Pool } = pg;

function createPoolConfig() {
  const { connectionString, host, port, name, user, password, poolMax, ssl } = env.db;

  if (connectionString) {
    return {
      connectionString,
      max: poolMax,
      ...(ssl ? { ssl: { rejectUnauthorized: false } } : {}),
    };
  }

  return {
    host,
    port,
    database: name,
    user,
    password,
    max: poolMax,
    ssl: ssl ? { rejectUnauthorized: false } : false,
  };
}

const pool = new Pool(createPoolConfig());

pool.on('error', (err) => {
  console.error('Unexpected PostgreSQL pool error', err);
});

export async function query(text, params) {
  return pool.query(text, params);
}

export async function checkConnection() {
  const result = await pool.query('SELECT NOW() AS now');
  return result.rows[0];
}

export default pool;
