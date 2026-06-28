import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import compression from 'compression';
import env from './config/env.js';
import registerRoutes from './routes/index.js';
import { notFound } from './middleware/notFound.js';
import { errorHandler } from './middleware/errorHandler.js';
import { apiLimiter } from './middleware/rateLimit.js';
import { validateEnvironment } from './middleware/security.js';

validateEnvironment();

const app = express();

// Trust the first proxy (e.g. ngrok, Heroku, Railway) for accurate rate limiting IP detection
app.set('trust proxy', 1);

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(compression());
app.use(cors({ origin: env.cors.origin, credentials: env.cors.credentials }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(apiLimiter);

app.use('/uploads', express.static(path.resolve(env.upload.dir)));

registerRoutes(app, env.apiPrefix);

app.use(notFound);
app.use(errorHandler);

export default app;
