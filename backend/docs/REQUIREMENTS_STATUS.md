# ZyntraPlus — Requirements Status

Last updated: June 2026

This document maps original project requirements to implementation status.

---

## Summary

| Area | Status | Notes |
|------|--------|-------|
| Node.js modular backend | ✅ Done | Express layers: routes → controllers → services → models |
| PostgreSQL + migrations | ✅ Done | 10 migrations (`001`–`010`) |
| Email auth + JWT | ✅ Done | Register, login, refresh, logout |
| Google / Apple auth | ⚠️ Partial | Backend `POST /auth/google`, `/auth/apple`; Flutter buttons need native SDK + client IDs |
| Posts (text, image, video, reels) | ✅ Done | Create, edit, delete, archive, media upload |
| Feed API | ✅ Done | Global chronological feed + reels endpoint |
| Poll posts | ✅ Done | 2–4 options, vote, change vote, expiry, creator sees results |
| Messaging (1-on-1 + group) | ✅ Done | REST + Socket.IO |
| Delivery status | ✅ Done | sent → delivered → read |
| User profile APIs | ✅ Done | CRUD, avatar, posts by user |
| Follow system | ✅ Done | Follow/unfollow + real follower counts |
| Nearby Users & Discovery | ✅ Done | Haversine distance filtering + Map UI |
| Box Requests | ✅ Done | Send coins/boxes to connect with nearby users |
| Tips | ✅ Done | In-app credits (500 start balance); not real money yet |
| Security basics | ✅ Done | JWT, rate limit, helmet, CORS, bcrypt |
| API documentation | ✅ Done | `docs/API.md` (this file + API reference) |

---

## ✅ Completed

### Backend architecture
- Entry: `src/server.js`, `src/app.js`
- Versioned API: `/api/v1`
- Modules: auth, posts, users, chat, tips, health
- Socket.IO: `src/socket/`

### Database tables
- `users`, `profiles`, `posts`, `post_likes`, `post_comments`
- `refresh_tokens`, `password_reset_otps`
- `conversations`, `conversation_members`, `messages`, `message_receipts`
- `box_requests`
- `posts.post_meta`, `posts.is_archived`, `posts.media_meta`
- `user_wallets`, `tips`
- `user_follows`
- OAuth columns: `google_id`, `apple_id`, `auth_provider`

### Flutter app (connected to API)
- Login / register / forgot password
- Home feed, reels, create post (media + filters + poll)
- Profile (real data, posts tabs, edit profile + avatar)
- Comments, likes, share sheet (UI)
- Messaging screens + Socket.IO client
- Post menu: edit, archive, delete (profile + home feed for own posts)
- Poll UI (Instagram-style card)
- Nearby users list + Interactive map (Explore)
- Box requests UI (Send box, Review box, Request center)
- Tips (wallet balance + send tip API)

---

## ⚠️ Partial (works but needs production hardening)

| Item | Current | To complete |
|------|---------|-------------|
| **Google / Apple login** | Backend verifies Google token via Google API; Apple uses JWT payload decode | Add `google_sign_in` / `sign_in_with_apple` in Flutter; set OAuth client IDs; full Apple signature verification |
| **Password reset email** | Mock OTP (`MOCK_OTP_ENABLED=true`, code `123456`) | Integrate SendGrid / SMTP |
| **Tips** | Virtual credits in PostgreSQL | Stripe / PayPal / in-app purchase for real money |
| **Feed personalization** | Global feed (all users) | Filter by followed users only (optional toggle) |
| **Media storage** | Local `uploads/` folder | S3 / Cloudinary for production |
| **Share post** | UI sheet only | Deep links + share API |
| **Voice / Video call** | WebRTC signaling in place | Needs device testing by client |

---

## ❌ Not started (future phases)

- Video transcoding / thumbnails
- Hashtags, search posts
- Block / report users
- Admin moderation panel
- OpenAPI / Swagger UI (markdown docs exist)
- Multi-server Socket.IO (Redis adapter)

---

## Setup checklist

```bash
# Backend
cd backend
cp .env.example .env    # set DB_PASSWORD, JWT_SECRET
npm install
npm run db:migrate
npm run dev             # http://localhost:4000

# Flutter
flutter pub get
flutter run -d chrome   # or device
```

**Migrations:** run `npm run db:migrate` after pull when new files appear in `database/migrations/`.

**Tip credits:** new users get **500 credits** automatically (`user_wallets`).

**Poll:** create via post attachment → 2–4 options, duration 1/3/7/14 days.

**Delete post:** ⋯ menu → Delete → confirm → `DELETE /posts/:id` (owner only).

---

## API quick links

- Full reference: [`API.md`](./API.md)
- Root: `GET /api/v1`
- Health: `GET /api/v1/health`

---

## Flutter ↔ Backend mapping

| Feature | Flutter | Backend |
|---------|---------|---------|
| Delete post | `PostsService.deletePost` | `DELETE /posts/:id` |
| Archive post | `PostsService.archivePost` | `PATCH /posts/:id/archive` |
| Poll vote | `PostsService.votePoll` | `POST /posts/:id/poll/vote` |
| Tip | `TipService.sendTip` | `POST /tips/send` |
| Follow | `FollowService.follow` | `POST /users/:id/follow` |
| Profile posts | `UserService.getMyPosts` | `GET /users/me/posts` |
