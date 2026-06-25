import { query } from './src/config/db.js';

async function check() {
  try {
    const res = await query(`
      SELECT w.user_id, u.username, w.balance_credits, w.tips_received_total 
      FROM user_wallets w 
      LEFT JOIN users u ON u.id = w.user_id
    `);
    console.log("=== WALLETS ===");
    console.table(res.rows);
  } catch (err) {
    console.error("Error querying database:", err);
  }
  process.exit(0);
}

check();
