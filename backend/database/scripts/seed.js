import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import pool from '../../src/config/db.js';
import { printDbHelp } from './db-utils.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const seedsDir = path.join(__dirname, '..', 'seeds');

async function run() {
  const client = await pool.connect();

  try {
    const files = (await fs.readdir(seedsDir))
      .filter((file) => file.endsWith('.sql'))
      .sort();

    for (const file of files) {
      const sql = await fs.readFile(path.join(seedsDir, file), 'utf8');
      await client.query(sql);
      console.log(`seed  ${file}`);
    }

    console.log('Seeding complete');
  } finally {
    client.release();
    await pool.end();
  }
}

run().catch((err) => {
  printDbHelp(err);
  process.exit(1);
});
