import { getRedis } from '../config/redis.js';
import env from '../config/env.js';

const memory = new Map();
const PREFIX = env.redis.keyPrefix;

function fullKey(key) {
  return `${PREFIX}${key}`;
}

function memGet(key) {
  const entry = memory.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expiresAt) {
    memory.delete(key);
    return null;
  }
  return entry.value;
}

function memSet(key, value, ttlSeconds) {
  memory.set(key, {
    value,
    expiresAt: Date.now() + ttlSeconds * 1000,
  });
}

function memDel(key) {
  memory.delete(key);
}

function memDelPattern(pattern) {
  const prefix = pattern.replace('*', '');
  for (const key of memory.keys()) {
    if (key.startsWith(prefix)) memory.delete(key);
  }
}

export async function cacheGet(key) {
  const redis = getRedis();
  const k = fullKey(key);

  if (redis) {
    try {
      const raw = await redis.get(k);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  const raw = memGet(k);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export async function cacheSet(key, value, ttlSeconds = 60) {
  const redis = getRedis();
  const k = fullKey(key);
  const payload = JSON.stringify(value);

  if (redis) {
    try {
      await redis.set(k, payload, 'EX', ttlSeconds);
    } catch {
      memSet(k, payload, ttlSeconds);
    }
    return;
  }

  memSet(k, payload, ttlSeconds);
}

export async function cacheDel(key) {
  const redis = getRedis();
  const k = fullKey(key);

  if (redis) {
    try {
      await redis.del(k);
    } catch {
      /* ignore */
    }
  }
  memDel(k);
}

export async function cacheDelPattern(pattern) {
  const redis = getRedis();
  const fullPattern = fullKey(pattern);

  if (redis) {
    try {
      let cursor = '0';
      do {
        const [next, keys] = await redis.scan(cursor, 'MATCH', fullPattern, 'COUNT', 100);
        cursor = next;
        if (keys.length) await redis.del(...keys);
      } while (cursor !== '0');
    } catch {
      memDelPattern(fullPattern);
    }
    return;
  }

  memDelPattern(fullPattern);
}

export async function cacheRemember(key, ttlSeconds, loader) {
  const cached = await cacheGet(key);
  if (cached != null) return cached;

  const fresh = await loader();
  await cacheSet(key, fresh, ttlSeconds);
  return fresh;
}

export async function invalidateUserFeedCache(userId) {
  await cacheDelPattern(`feed:${userId}:*`);
}

export async function invalidateAllFeedCaches() {
  await cacheDelPattern('feed:*');
}

export async function invalidateUserSuggestions(userId) {
  await cacheDel(`suggestions:${userId}`);
}

export async function invalidateUserConversations(userId) {
  await cacheDelPattern(`conversations:${userId}:*`);
}

export async function invalidateAllReelsCaches() {
  await cacheDelPattern('reels:*');
}
