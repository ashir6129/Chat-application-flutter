import env from '../config/env.js';

const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '10.0.2.2', '0.0.0.0']);

function uploadBase() {
  return (env.upload.baseUrl || 'http://localhost:4000').replace(/\/$/, '');
}

/** Always return a public URL using the current BASE_URL (fixes old localhost links). */
export function resolvePublicUrl(url) {
  if (!url || typeof url !== 'string') return url;

  const trimmed = url.trim();
  if (!trimmed) return trimmed;

  const base = uploadBase();

  if (trimmed.startsWith('/uploads/')) {
    return `${base}${trimmed}`;
  }

  if (trimmed.startsWith('uploads/')) {
    return `${base}/${trimmed}`;
  }

  try {
    const parsed = new URL(trimmed);
    if (parsed.pathname.startsWith('/uploads/')) {
      if (LOCAL_HOSTS.has(parsed.hostname)) {
        return `${base}${parsed.pathname}${parsed.search || ''}`;
      }
    }
  } catch (_) {
    // not a full URL
  }

  return trimmed;
}

/** Store `/uploads/...` paths in DB so URLs survive host changes. */
export function toStoredMediaPath(url) {
  if (!url || typeof url !== 'string') return url;

  const trimmed = url.trim();
  if (!trimmed) return trimmed;

  if (trimmed.startsWith('/uploads/')) return trimmed;

  try {
    const parsed = new URL(trimmed);
    if (parsed.pathname.startsWith('/uploads/')) {
      return parsed.pathname;
    }
  } catch (_) {
    if (trimmed.startsWith('uploads/')) {
      return `/${trimmed}`;
    }
  }

  return trimmed;
}

export function resolveMediaList(urls) {
  if (!Array.isArray(urls)) return [];
  return urls.map((url) => resolvePublicUrl(url));
}
