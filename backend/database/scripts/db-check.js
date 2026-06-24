import pool from '../../src/config/db.js';
import { printDbHelp } from './db-utils.js';

async function run() {
  try {
    const result = await pool.query('SELECT current_database() AS db, current_user AS user, NOW() AS now');
    const row = result.rows[0];

    console.log('PostgreSQL connection OK');
    console.log(`  database: ${row.db}`);
    console.log(`  user: ${row.user}`);
    console.log(`  server time: ${row.now}`);
  } catch (err) {
    printDbHelp(err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

run();
