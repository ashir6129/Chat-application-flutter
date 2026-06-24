import env from '../../src/config/env.js';

export function printDbConfig() {
  console.log('Connection settings:');
  if (env.db.connectionString) {
    console.log('  DATABASE_URL: ***set*** (Railway / cloud)');
    console.log(`  ssl: ${env.db.ssl}`);
  } else {
    console.log(`  host: ${env.db.host}`);
    console.log(`  port: ${env.db.port}`);
    console.log(`  database: ${env.db.name}`);
    console.log(`  user: ${env.db.user}`);
    console.log(`  password: ${env.db.password ? '***set***' : '(empty)'}`);
    console.log(`  ssl: ${env.db.ssl}`);
  }
}

export function printDbHelp(error) {
  printDbConfig();
  console.error('\nDatabase connection failed:', error.message || error.code || error);

  if (env.db.connectionString) {
    console.error(`
Railway fix:
  1. Create a PostgreSQL service in the same project
  2. Open your API service → Variables
  3. Add reference: DATABASE_URL = \${{Postgres.DATABASE_URL}}
     (or DATABASE_PRIVATE_URL for internal networking)
  4. Redeploy, then run: railway run npm run db:migrate
`);
    return;
  }

  if (error.message?.includes('password authentication failed')) {
    console.error(`
Fix: open backend/.env and set DB_PASSWORD to the password you chose
when installing PostgreSQL on Windows (pgAdmin / installer).

Also make sure these match:
  DB_USER=postgres
  DB_HOST=localhost
  DB_PORT=5432

Then create the database once (pgAdmin Query Tool or psql):
  CREATE DATABASE zyntraplus;
`);
    return;
  }

  if (error.message.includes('does not exist')) {
    console.error(`
Fix: create the database first:
  CREATE DATABASE zyntraplus;
`);
    return;
  }

  if (error.code === 'ECONNREFUSED') {
    console.error(`
Fix: PostgreSQL is not running on ${env.db.host}:${env.db.port}.
Start the "postgresql-x64-*" Windows service, or run:
  docker compose up -d
`);
  }
}
