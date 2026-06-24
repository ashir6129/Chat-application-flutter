-- 001_dev_seed.sql
-- Development seed data

INSERT INTO users (email, username, password_hash, is_verified, is_spotlight)
VALUES
  ('alex@zyntraplus.app', 'alex', '$2b$10$devplaceholderhash000000000000000000000000000', TRUE, FALSE),
  ('jessica@zyntraplus.app', 'jessica', '$2b$10$devplaceholderhash000000000000000000000000000', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (user_id, bio, location)
SELECT id, 'Explore. Connect. Grow.', 'Lagos, NG'
FROM users
WHERE email = 'alex@zyntraplus.app'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO profiles (user_id, bio, location)
SELECT id, 'Spotlight creator', 'Abuja, NG'
FROM users
WHERE email = 'jessica@zyntraplus.app'
ON CONFLICT (user_id) DO NOTHING;
