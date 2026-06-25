# ZyntraPlus — Implementation Summary

Last updated: June 2026

This document describes features implemented in the app (Flutter + Node.js backend), how they work, and where the code lives.

---

## Overview

The following areas are **fully wired to real APIs** (no dummy John Doe / fake chat lists on core flows):

| Feature | Status |
|---------|--------|
| Real user profiles (own + other users) | ✅ |
| Follow / Following toggle | ✅ |
| Followers & Following lists (Instagram-style) | ✅ |
| Home feed (only followed users + own posts) | ✅ |
| Direct messaging with read receipts | ✅ |
| Message inbox from API | ✅ |
| Polls, delete/archive posts, tips | ✅ |
| Video posts (MP4) vs images | ✅ |

Related references:

- API endpoints: [`backend/docs/API.md`](../backend/docs/API.md)
- Requirements checklist: [`backend/docs/REQUIREMENTS_STATUS.md`](../backend/docs/REQUIREMENTS_STATUS.md)

---

## 1. Follow System

### Behaviour

- **Follow** → button shows **Following** (feed + profile).
- **Unfollow** → button returns to **Follow**; user’s posts disappear from home feed.
- Follow state is stored in PostgreSQL (`user_follows` table).
- Optimistic UI updates with rollback on API failure.

### Backend

| Method | Path | Description |
|--------|------|-------------|
| POST | `/users/:userId/follow` | Follow user |
| DELETE | `/users/:userId/follow` | Unfollow user |
| GET | `/users/:userId/follow-status` | Check if viewer follows target |
| GET | `/users/:userId/followers` | Paginated followers list |
| GET | `/users/:userId/following` | Paginated following list |

Follow list items include:

- `is_following` — does the **viewer** follow this user?
- `follows_viewer` — does this user follow the **viewer**? (for **Follow back** label)

**Files:**

- `backend/src/models/follow.model.js`
- `backend/src/services/follow.service.js`
- `backend/src/controllers/follow.controller.js`
- `backend/src/routes/v1/users.routes.js`

### Flutter

| File | Role |
|------|------|
| `lib/api_services/follow_service.dart` | Follow / unfollow API |
| `lib/models/follow_user.dart` | List item model |
| `lib/screens/user_profile_screen/follow_list_screen.dart` | Followers / Following UI |
| `lib/screens/user_profile_screen/user_profile_screen.dart` | Other user profile + follow toggle |
| `lib/screens/home_screen/feed.dart` | Feed follow button + sync |

### Following list UI (Instagram-style)

- Search bar to filter users
- **Follow** / **Following** / **Follow back** buttons per row
- On **own Following list**: unfollow removes user from list immediately
- **Message** button on Following list → opens direct chat
- Tap row → open user profile

---

## 2. User Profiles

### Behaviour

- Tapping a post author or a user in followers/following opens **real profile** (UUID-based).
- Shows: username, bio, avatar, stats (posts / followers / following), real posts tabs.
- Own profile: edit profile, avatar upload, archived posts in Settings.
- Other profile: Follow, Message, Send me a box (UI); Follow + Message are functional.

### Backend

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Own profile |
| GET | `/users/id/:userId` | Profile by user ID |
| GET | `/users/:username` | Profile by username |
| GET | `/users/:username/posts?type=all\|photos\|reels\|products` | User’s posts |
| PUT/PATCH | `/users/me`, `/users/me/avatar` | Update profile |

Profile response includes:

- `stats.posts`, `stats.followers`, `stats.following`
- `is_following` (when viewing someone else)
- `is_online`, `last_seen_at` (for chat presence)

**Files:**

- `backend/src/services/user.service.js`
- `backend/src/controllers/user.controller.js`

### Flutter

| File | Role |
|------|------|
| `lib/models/user_profile.dart` | Profile model (`isFollowing`, `isOnline`, `lastSeenAt`) |
| `lib/api_services/user_service.dart` | Profile + followers/following/posts APIs |
| `lib/screens/user_profile_screen/user_profile_screen.dart` | Other user profile screen |
| `lib/screens/user_profile_screen/user_profile_details_widget.dart` | Header, stats, Message |
| `lib/screens/my_profile_screen/profile_details_widget.dart` | Own profile + list navigation |
| `lib/widgets/profile/profile_posts_list.dart` | Posts grid/list (own + public via `username`) |

---

## 3. Home Feed

### Behaviour

- Feed shows posts **only from users you follow + your own posts**.
- Unfollowed users’ posts are **not** shown (backend filter + client refresh).
- Unfollow from feed removes that user’s posts immediately.
- Follow button shows correct **Follow / Following** (loaded from API on start).
- Empty state: *“Follow people to see their posts here”*.

### Backend

`GET /posts/feed` uses `followingOnly: true` in `listFeedPosts()`:

```sql
-- Posts where author is viewer OR viewer follows author
p.user_id = viewer_id OR EXISTS (
  SELECT 1 FROM user_follows
  WHERE follower_id = viewer_id AND following_id = p.user_id
)
```

**Files:**

- `backend/src/models/post.model.js` — `listFeedPosts({ followingOnly })`
- `backend/src/services/post.service.js` — `getHomeFeed()`

### Flutter

| File | Role |
|------|------|
| `lib/screens/home_screen/feed.dart` | Feed UI, follow toggle, `_followed` set |
| `lib/core/feed_refresh.dart` | Reload feed after unfollow elsewhere |
| `lib/api_services/post_services.dart` | `getFeed()` |

### Removed dummy data (feed area)

- Home header uses real name from `/users/me` (not “Alex”).
- Stories strip: only **Your story** (no fake Rahul/Priya stories).
- Feed posts come only from API.

---

## 4. Messaging

### Behaviour

- **Inbox** loads real conversations from `GET /conversations`.
- **Message** on profile or Following list → `POST /conversations/direct` → chat screen.
- **Read receipts** on sent messages:
  - ✓ gray = sent
  - ✓✓ gray = delivered
  - ✓✓ blue = read
- Opening chat calls `POST /conversations/:id/read`.
- **Last seen** / **Online** in chat header from profile API.
- Messages poll every ~4s for receipt updates (no Socket client in Flutter yet).

### Backend

| Method | Path | Description |
|--------|------|-------------|
| GET | `/conversations` | List chats |
| POST | `/conversations/direct` | Start/get 1:1 chat `{ user_id }` |
| GET | `/conversations/:id/messages` | Messages + `receipts[]` |
| POST | `/conversations/:id/messages` | Send message |
| POST | `/conversations/:id/read` | Mark read |

Migration **`011_last_seen.sql`**: adds `users.last_seen_at` (updated on socket disconnect).

**Files:**

- `backend/src/services/chat.service.js`
- `backend/src/routes/v1/chat.routes.js`
- `backend/database/migrations/011_last_seen.sql`

### Flutter

| File | Role |
|------|------|
| `lib/api_services/chat_service.dart` | Conversations, messages, markRead, `MessageReceiptStatus` |
| `lib/widgets/message/conversations_list_view.dart` | Shared inbox list |
| `lib/screens/message_screen/main_message_screen/main_message_screen.dart` | General messages tab |
| `lib/creators_messages_screen.dart` | Direct chats only |
| `lib/screens/marketplace_screen/marketplace_message_screen.dart` | Direct chats only |
| `lib/screens/message_screen/main_message_screen/personal_chat_screen.dart` | 1:1 chat + ticks |
| `lib/widgets/message/chat_message_bubble.dart` | Tick UI |

---

## 5. Posts, Polls, Tips, Archive

### Posts

- Create, edit caption, delete, archive/restore
- Media upload to `uploads/` (local dev)
- Polls: 2–4 options, vote, change vote, expiry in `post_meta`
- Likes and comments via existing APIs

### Tips

- Virtual wallet (500 starting credits)
- Send tip from feed / profile / photo viewer

### Archived posts

- Settings → **Archived Posts** tab
- Restore or keep archived

**Key Flutter files:** `profile_posts_list.dart`, `menu_bottom_sheet.dart`, `feed_sheets.dart`, `tip_service.dart`

---

## 6. Media: Video vs Image

### Problem fixed

Browsers cannot decode `.mp4` as `NetworkImage`. Videos were causing `ImageCodecException`.

### Solution

`lib/core/media_url_utils.dart`:

```dart
MediaUrlUtils.isVideoUrl(url)  // .mp4, .mov, .webm, ...
MediaUrlUtils.isImageUrl(url)
```

Videos use **`FeedVideoPreview`** / **`VideoPlayer`**; images use **`Image.network`**.

**Updated files:**

- `lib/widgets/feed/feed_image_grid.dart`
- `lib/widgets/feed/feed_photo_viewer.dart`
- `lib/screens/home_screen/feed.dart`
- `lib/widgets/profile/profile_posts_list.dart`
- `lib/screens/reels_screen/reels_screen.dart`

---

## 7. Reels

- Reels load from `POST /posts/get_reels` (real posts).
- Author tap → real profile (`authorUserId`).
- Follow on reel uses `FollowService`.
- No hardcoded `fit_with_anna` / `Aman K` dummy reels.

**File:** `lib/screens/reels_screen/reels_screen.dart`

---

## 8. Database Migrations (relevant)

| Migration | Purpose |
|-----------|---------|
| `008_post_meta_archive.sql` | Poll meta, archive flag |
| `009_tips_wallets.sql` | Tips + wallets |
| `010_follows_oauth.sql` | `user_follows`, OAuth columns |
| `011_last_seen.sql` | `users.last_seen_at` |

Run migrations:

```bash
cd backend
npm run db:migrate
```

---

## 9. Environment & Run

### Backend

```bash
cd backend
cp .env.example .env   # if needed
npm install
npm run db:migrate
npm run dev
```

Default API: `http://localhost:4000/api/v1`

### Flutter

```bash
flutter pub get
flutter run -d chrome
```

API base URL: `lib/core/api_config.dart` (default `http://localhost:4000/api/v1`)

After backend or Dart changes: **hot restart** (`R`) in terminal.

---

## 10. Test Checklist

1. **Follow** a user from feed → button shows **Following**; their posts appear in feed.
2. **Unfollow** from Following list → user removed from list; posts gone from feed.
3. Open **Followers / Following** → search, Follow back, Message (Following tab).
4. Tap post author → **real profile** with real posts.
5. **Message** from profile → send text → see ✓ / ✓✓ / blue ✓✓ when read.
6. **Messages tab** → real conversation list from API.
7. Upload **video post** → plays in feed without image decode error.
8. **Poll** → vote and see results; **delete/archive** own post.

---

## 11. Known Limitations / Next Steps

| Item | Notes |
|------|-------|
| Real-time chat | Backend has Socket.IO; Flutter uses REST + polling for receipts |
| Message requests | Empty state only; no mutual-follow gate yet |
| Group / channel chats | UI exists; group create uses real user list; full API wiring partial |
| Reels “Following” tab | UI tab present; same API as For You for now |
| Nearby, search, marketplace | Some screens still use placeholder/demo data |
| Push notifications | Not implemented |
| Production media | Local `uploads/`; use S3/Cloudinary for production |
| Swagger UI | Markdown docs only (`API.md`) |

---

## 12. Quick File Map

```
backend/
  src/
    models/follow.model.js      # follow queries + lists
    models/post.model.js        # feed with followingOnly filter
    services/user.service.js    # profiles + stats + presence
    services/chat.service.js    # messages + receipts
    services/follow.service.js
  database/migrations/008-011

lib/
  api_services/
    follow_service.dart
    user_service.dart
    chat_service.dart
    post_services.dart
  core/
    feed_refresh.dart
    media_url_utils.dart
  screens/
    home_screen/feed.dart
    user_profile_screen/
    message_screen/
  widgets/
    profile/profile_posts_list.dart
    message/conversations_list_view.dart
    feed/feed_image_grid.dart
```

---

## 13. Changelog (this implementation phase)

- Replaced dummy user profile (John Doe) with API-driven profiles
- Added followers/following list APIs and Instagram-style UI
- Feed filtered to followed users only; unfollow syncs feed + lists
- Message inbox + chat wired to backend; read ticks + last seen
- Removed dummy message lists and fake story users from home
- Reels from API; group member picker from real users
- Fixed MP4 loaded as image (`MediaUrlUtils` + `FeedVideoPreview`)
- Migration `011_last_seen` for chat presence

For API request/response examples, see [`backend/docs/API.md`](../backend/docs/API.md).
