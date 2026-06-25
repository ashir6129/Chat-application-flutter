# ZyntraPlus API Reference (v1)

Base URL: `http://localhost:4000/api/v1`

All protected routes require:

```
Authorization: Bearer <access_token>
```

Socket.IO: `http://localhost:4000` path `/socket.io`

```javascript
io('http://localhost:4000', { auth: { token: accessToken } });
```

---

## Health

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | No | Server + PostgreSQL health |

---

## Auth

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| POST | `/auth/register` | No | `{ name, email, password }` | Register (returns JWT) |
| POST | `/auth/login` | No | `{ email, password }` | Email login |
| POST | `/auth/google` | No | `{ id_token }` | Google Sign-In (verify via Google tokeninfo) |
| POST | `/auth/apple` | No | `{ id_token, name? }` | Apple Sign-In |
| POST | `/auth/refresh` | No | `{ refresh_token }` | New access token |
| POST | `/auth/logout` | Yes | `{ refresh_token? }` | Revoke refresh token(s) |
| POST | `/auth/forgot-password` | No | `{ email }` | Start reset (mock OTP in dev) |
| POST | `/auth/resend-otp` | No | `{ email, reset_token }` | Resend OTP |
| POST | `/auth/verify-otp` | No | `{ email, otp, reset_token }` | Verify OTP |
| POST | `/auth/reset-password` | No | `{ email, otp, reset_token, new_password, confirm_password }` | Reset password |

**Login response:** `access_token`, `refresh_token`, `user_uid`, `access_token_expiry_datetime`, `refresh_token_expiry_datetime`

---

## Feed & Posts

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/posts/feed?page=1&limit=20` | Yes | Home feed (excludes archived) |
| GET | `/posts/reels?page=1&limit=10` | Yes | Reels / video feed |
| POST | `/posts/get_reels` | Yes | Same as reels (body: page, limit) |
| GET | `/posts/:id` | Yes | Single post |
| POST | `/posts/` | Yes | Create post |
| PUT | `/posts/:id` | Yes | Update caption `{ caption }` |
| DELETE | `/posts/:id` | Yes | Delete own post |
| PATCH | `/posts/:id/archive` | Yes | Archive / restore `{ archived: true\|false }` |
| POST | `/posts/:id/like` | Yes | Toggle like |
| POST | `/posts/:id/poll/vote` | Yes | Vote on poll `{ option_index: 0 }` |
| POST | `/posts/media/upload` | Yes | Multipart `files` (max 10) |

**Create post body:**

```json
{
  "caption": "Hello",
  "post_type": "text",
  "media_urls": [],
  "media_meta": [],
  "location": "Karachi",
  "post_meta": {
    "poll": {
      "question": "How are you?",
      "options": ["Fine", "Great", "Tired"],
      "duration_days": 7
    }
  }
}
```

**Post types:** `text`, `image`, `video`, `reel`, `mixed`

**Poll rules:**
- 2–4 options stored in `post_meta.poll`
- Votes tracked server-side; users can change vote (Instagram-style)
- `expires_at` set from `duration_days` (default 7)
- Voting blocked after expiry

---

## Comments

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/posts/:postId/comments` | Yes | List comments + replies |
| POST | `/posts/:postId/comments` | Yes | Add `{ body, parent_id? }` |
| PUT | `/posts/:postId/comments/:commentId` | Yes | Edit own comment |
| DELETE | `/posts/:postId/comments/:commentId` | Yes | Delete own comment |
| POST | `/posts/:postId/comments/:commentId/react` | Yes | React `{ emoji }` |
| POST | `/posts/:postId/comments/:commentId/report` | Yes | Report `{ reason? }` |

---

## User Profiles & Follow

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/users/me` | Yes | Own profile + stats |
| PUT | `/users/me` | Yes | Update `{ bio?, location?, website? }` |
| PATCH | `/users/me/avatar` | Yes | Update `{ avatar_url }` |
| GET | `/users/me/posts?type=all&page=1&limit=20` | Yes | Own posts (`all`, `photos`, `reels`) |
| GET | `/users/search?q=john` | Yes | Search users |
| GET | `/users/:username` | Yes | Public profile + stats |
| GET | `/users/:username/posts?type=all` | Yes | User posts by username |
| GET | `/users?page=1&limit=20` | Yes | Browse users |
| GET | `/users/nearby?latitude=24.8607&longitude=67.0011&maxDistanceKm=50` | Yes | Get nearby users based on distance |
| POST | `/users/:userId/follow` | Yes | Follow user |
| DELETE | `/users/:userId/follow` | Yes | Unfollow user |
| GET | `/users/:userId/follow-status` | Yes | `{ following, followers_count, following_count }` |

**Profile stats:** `posts`, `followers`, `following` (real counts from DB)

---

## Tips (In-App Credits)

Virtual credits system (500 starting balance per user). Production can swap to Stripe/wallet later.

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| GET | `/tips/wallet` | Yes | — | Get `{ balance_credits, tips_received_total }` |
| POST | `/tips/send` | Yes | See below | Send tip to creator |
| GET | `/tips/received?page=1` | Yes | — | Tips received history |

**Send tip body:**

```json
{
  "recipient_id": "uuid-of-creator",
  "post_id": "optional-post-uuid",
  "tip_type": "Rose",
  "amount": 5
}
```

**Errors:** `402` insufficient credits

---

## Box Requests (Nearby Connection)

Users can send "Boxes" containing coins to nearby users to request a connection.

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| POST | `/boxes` | Yes | `{ receiver_id, coins, note? }` | Send a box request |
| GET | `/boxes/received` | Yes | — | Get pending received boxes |
| GET | `/boxes/sent` | Yes | — | Get sent boxes |
| PUT | `/boxes/:id/status` | Yes | `{ status }` | Accept or decline box (`accepted` / `declined`) |
| GET | `/boxes/wallet` | Yes | — | Check box coins balance |

---

## Messaging (REST)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/conversations?page=1&limit=30` | Yes | Inbox |
| POST | `/conversations/direct` | Yes | `{ user_id }` — start/get DM |
| POST | `/conversations/group` | Yes | `{ title, member_ids[] }` |
| GET | `/conversations/:id` | Yes | Conversation + members |
| GET | `/conversations/:id/messages?limit=50&before=<id>` | Yes | Message history |
| POST | `/conversations/:id/messages` | Yes | Send `{ body, message_type?, metadata? }` |
| POST | `/conversations/:id/read` | Yes | Mark read |
| POST | `/conversations/:id/members` | Yes | Add member (group admin) |
| DELETE | `/conversations/:id/members/:userId` | Yes | Remove / leave |

**Delivery status:** `sent` → `delivered` → `read`

---

## Socket.IO Events

### Client → Server

| Event | Payload |
|-------|---------|
| `conversation:join` | `{ conversation_id }` |
| `conversation:leave` | `{ conversation_id }` |
| `message:send` | `{ conversation_id, body, message_type?, metadata? }` |
| `message:read` | `{ conversation_id }` |
| `typing:start` / `typing:stop` | `{ conversation_id }` |

### Server → Client

| Event | Description |
|-------|-------------|
| `connected` | `{ user_id }` |
| `message:new` | New message + receipts |
| `message:read` | Read receipt |
| `conversation:updated` | Inbox preview |
| `conversation:member_added` / `member_removed` | Group changes |
| `typing:start` / `typing:stop` | Typing |

---

## Errors

```json
{ "success": false, "message": "Error description" }
```

| Code | Meaning |
|------|---------|
| 400 | Validation |
| 401 | Auth required / invalid token |
| 402 | Insufficient tip credits |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Conflict |
| 429 | Rate limited |
| 500 | Server error |

---

## Security

- JWT Bearer on protected routes
- Rate limit: 300 req/15min (API), 40 req/15min (auth)
- Helmet, CORS, bcrypt (12 rounds)
- Refresh tokens stored as SHA-256 hashes
- Production: set strong `JWT_SECRET`

See `.env.example` and `REQUIREMENTS_STATUS.md` for setup and roadmap.
