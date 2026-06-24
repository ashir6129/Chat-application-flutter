-- Sample feed posts for development

INSERT INTO posts (user_id, caption, post_type, media_urls, like_count, comment_count, location)
SELECT u.id,
       'Welcome to ZyntraPlus! Start sharing your moments.',
       'text',
       '[]'::jsonb,
       12,
       3,
       'Nearby'
FROM users u
WHERE u.email = 'alex@zyntraplus.app'
AND NOT EXISTS (
  SELECT 1 FROM posts p WHERE p.user_id = u.id AND p.post_type = 'text'
);

INSERT INTO posts (user_id, caption, post_type, media_urls, like_count, comment_count, location)
SELECT u.id,
       'Golden hour vibes from the city skyline.',
       'image',
       '["https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800"]'::jsonb,
       48,
       9,
       '2 km'
FROM users u
WHERE u.email = 'jessica@zyntraplus.app'
AND NOT EXISTS (
  SELECT 1 FROM posts p WHERE p.user_id = u.id AND p.post_type = 'image'
);
