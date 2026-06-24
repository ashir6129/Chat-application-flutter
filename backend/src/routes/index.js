import healthRoutes from './v1/health.routes.js';
import authRoutes from './v1/auth.routes.js';
import postsRoutes from './v1/posts.routes.js';
import usersRoutes from './v1/users.routes.js';
import chatRoutes from './v1/chat.routes.js';
import tipsRoutes from './v1/tips.routes.js';
import boxesRoutes from './v1/boxes.routes.js';

export default function registerRoutes(app, apiPrefix) {
  app.get(apiPrefix, (_req, res) => {
    res.json({
      message: 'ZyntraPlus API',
      version: 'v1',
      docs: '/docs/API.md',
      socket_path: '/socket.io',
    });
  });

  app.use(`${apiPrefix}/health`, healthRoutes);
  app.use(`${apiPrefix}/auth`, authRoutes);
  app.use(`${apiPrefix}/posts`, postsRoutes);
  app.use(`${apiPrefix}/users`, usersRoutes);
  app.use(`${apiPrefix}/conversations`, chatRoutes);
  app.use(`${apiPrefix}/tips`, tipsRoutes);
  app.use(`${apiPrefix}/boxes`, boxesRoutes);
}
