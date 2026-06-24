# ZyntraPlus API

Node.js + Express + PostgreSQL backend for the ZyntraPlus Flutter app.

## Quick start (Windows + local PostgreSQL)

Your machine is using **PostgreSQL 18** as a Windows service (not Docker).

1. Copy env and set your real postgres password:
   ```powershell
   cd backend
   copy .env.example .env
   ```
   Edit `.env` → set `DB_PASSWORD` to the password you chose during PostgreSQL installation.

2. Create the database (pgAdmin → Query Tool, or psql):
   ```sql
   CREATE DATABASE zyntraplus;
   ```

3. Install and verify connection:
   ```powershell
   npm install
   npm run db:check
   ```

4. Migrate and seed:
   ```powershell
   npm run db:migrate
   npm run db:seed
   ```

5. Start API:
   ```powershell
   npm run dev
   ```

Health check: `GET http://localhost:4000/api/v1/health`

API documentation: [`docs/API.md`](docs/API.md)

Socket.IO: `ws://localhost:4000/socket.io` (pass JWT in `auth.token`)

## API modules

| Module | Prefix | Status |
|--------|--------|--------|
| Auth | `/api/v1/auth` | Register, login, refresh, logout, password reset |
| Feed & Posts | `/api/v1/posts` | Feed, reels, CRUD, likes, media upload |
| Comments | `/api/v1/posts/:id/comments` | CRUD, reactions, reports |
| User Profiles | `/api/v1/users` | Me, public profile, search |
| Messaging | `/api/v1/conversations` | Direct + group chat, REST + Socket.IO |

## Quick start (Docker — optional)

If Docker Desktop is installed:

```powershell
copy .env.example .env
docker compose up -d
npm install
npm run db:check
npm run db:migrate
npm run db:seed
npm run dev
```

Set `DB_PASSWORD` and `POSTGRES_PASSWORD` to the same value in `.env`.

## Troubleshooting

| Error | Fix |
|-------|-----|
| `password authentication failed for user "postgres"` | Wrong `DB_PASSWORD` in `.env`. Use your PostgreSQL install password. |
| `database "zyntraplus" does not exist` | Run `CREATE DATABASE zyntraplus;` |
| `ECONNREFUSED` | Start PostgreSQL Windows service or Docker container |

Run `npm run db:check` anytime to test credentials before migrate/seed.

## Folder structure

```
backend/
├── src/
│   ├── server.js
│   ├── app.js
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   └── validators/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── scripts/
├── tests/
├── docker-compose.yml
├── .env.example
└── package.json
```
