import Redis from 'ioredis';
import env from './env.js';

let client = null;
let enabled = false;

export async function initRedis() {
  if (!env.redis.url) {
    console.log('Redis: not configured (using in-memory cache fallback)');
    return null;
  }

  try {
    client = new Redis(env.redis.url, {
      maxRetriesPerRequest: 2,
      enableReadyCheck: true,
      lazyConnect: true,
    });

    await client.connect();
    enabled = true;
    console.log('Redis connected');
    return client;
  } catch (err) {
    console.error('Redis connection failed:', err.message);
    client = null;
    enabled = false;
    return null;
  }
}

export function getRedis() {
  return enabled ? client : null;
}

export function isRedisEnabled() {
  return enabled && client != null;
}
