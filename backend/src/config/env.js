import dotenv from 'dotenv';

dotenv.config();

const env = {
  nodeEnv: process.env.NODE_ENV ?? 'development',
  port: Number(process.env.PORT ?? 4000),
  apiPrefix: process.env.API_PREFIX ?? '/api/v1',
  db: {
    connectionString:
      process.env.DATABASE_URL?.trim() ||
      process.env.DATABASE_PUBLIC_URL?.trim() ||
      null,
    host: process.env.DB_HOST ?? 'localhost',
    port: Number(process.env.DB_PORT ?? 5432),
    name: process.env.DB_NAME ?? 'zyntraplus',
    user: process.env.DB_USER ?? 'postgres',
    password: process.env.DB_PASSWORD ?? 'postgres',
    ssl:
      process.env.DB_SSL === 'true' ||
      (process.env.NODE_ENV === 'production' &&
        Boolean(
          process.env.DATABASE_URL?.trim() || process.env.DATABASE_PUBLIC_URL?.trim(),
        )),
    poolMax: Number(process.env.DB_POOL_MAX ?? 10),
  },
  jwt: {
    secret: process.env.JWT_SECRET ?? 'zyntraplus-dev-secret-change-me',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES ?? '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES ?? '7d',
  },
  oauth: {
    googleClientIds: (process.env.GOOGLE_CLIENT_ID ?? '')
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean),
    appleClientIds: (process.env.APPLE_CLIENT_ID ?? process.env.APPLE_BUNDLE_ID ?? '')
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean),
  },
  otp: {
    mockEnabled: process.env.MOCK_OTP_ENABLED !== 'false',
    mockCode: process.env.MOCK_OTP_CODE ?? '123456',
    expiresMinutes: Number(process.env.OTP_EXPIRES_MINUTES ?? 10),
    resendCooldownSeconds: Number(process.env.OTP_RESEND_COOLDOWN_SECONDS ?? 60),
    maxResends: Number(process.env.OTP_MAX_RESENDS ?? 5),
  },
  upload: {
    dir: process.env.UPLOAD_DIR ?? 'uploads',
    maxFileSizeMb: Number(process.env.UPLOAD_MAX_MB ?? 50),
    baseUrl: process.env.BASE_URL ?? 'http://localhost:4000',
  },
  cors: {
    origin: process.env.CORS_ORIGIN
      ? process.env.CORS_ORIGIN.split(',').map((v) => v.trim())
      : true,
    credentials: process.env.CORS_CREDENTIALS !== 'false',
  },
  rateLimit: {
    windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS ?? 15 * 60 * 1000),
    max: Number(process.env.RATE_LIMIT_MAX ?? 5000),
    authWindowMs: Number(process.env.AUTH_RATE_LIMIT_WINDOW_MS ?? 15 * 60 * 1000),
    authMax: Number(process.env.AUTH_RATE_LIMIT_MAX ?? 1000),
  },
  socket: {
    path: process.env.SOCKET_PATH ?? '/socket.io',
  },
  redis: {
    url: process.env.REDIS_URL?.trim() || null,
    keyPrefix: process.env.REDIS_KEY_PREFIX ?? 'zp:',
    feedTtlSeconds: Number(process.env.CACHE_FEED_TTL_SECONDS ?? 45),
    suggestionsTtlSeconds: Number(process.env.CACHE_SUGGESTIONS_TTL_SECONDS ?? 120),
    conversationsTtlSeconds: Number(process.env.CACHE_CONVERSATIONS_TTL_SECONDS ?? 30),
    profileTtlSeconds: Number(process.env.CACHE_PROFILE_TTL_SECONDS ?? 180),
  },
  email: {
    host: process.env.SMTP_HOST ?? '',
    port: Number(process.env.SMTP_PORT ?? 587),
    secure: process.env.SMTP_SECURE === 'true',   // true = 465, false = 587 STARTTLS
    user: process.env.SMTP_USER ?? '',
    pass: process.env.SMTP_PASS ?? '',
    from: process.env.SMTP_FROM ?? '',            // optional display name override
  },
};

export default env;
