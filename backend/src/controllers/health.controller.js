import { checkConnection } from '../config/db.js';

export async function getHealth(_req, res) {
  const db = await checkConnection();

  res.json({
    status: 'ok',
    service: 'zyntraplus-api',
    timestamp: new Date().toISOString(),
    database: {
      connected: true,
      serverTime: db.now,
    },
  });
}
