import pool from '../../src/config/db.js';

const users = [
  { username: 'david_dev', email: 'david@zyntraplus.app', bio: 'Living life close by!', location: 'Lekki Phase 1', latitude: 6.4428, longitude: 3.4839, is_verified: true, is_spotlight: false },
  { username: 'sarah_travels', email: 'sarah@zyntraplus.app', bio: 'Wanderlust explorer.', location: 'Victoria Island', latitude: 6.4281, longitude: 3.4219, is_verified: false, is_spotlight: true },
  { username: 'tunde_creative', email: 'tunde@zyntraplus.app', bio: 'Visual artist & creator.', location: 'Ikoyi', latitude: 6.4549, longitude: 3.4246, is_verified: true, is_spotlight: true },
  { username: 'chidi_coder', email: 'chidi@zyntraplus.app', bio: 'Coding from Lagos.', location: 'Yaba', latitude: 6.5095, longitude: 3.3790, is_verified: false, is_spotlight: false },
  { username: 'amara_music', email: 'amara@zyntraplus.app', bio: 'Music is life.', location: 'Ikeja', latitude: 6.6018, longitude: 3.3515, is_verified: false, is_spotlight: false }
];

async function seed() {
  const client = await pool.connect();
  try {
    console.log('Seeding mock user coordinates...');
    for (const u of users) {
      // 1. Insert user
      const userRes = await client.query(
        `INSERT INTO users (email, username, password_hash, is_verified, is_spotlight)
         VALUES ($1, $2, '$2a$10$mE5CjYn9sN.5Lg6ZqE5w9OQ3wM3P.8q825Z45V2D3C4B5A6E7F8G9', $3, $4)
         ON CONFLICT (email) DO UPDATE SET is_verified = $3, is_spotlight = $4
         RETURNING id`,
        [u.email, u.username, u.is_verified, u.is_spotlight]
      );
      
      const userId = userRes.rows[0]?.id;
      
      // 2. Insert/update profile
      await client.query(
        `INSERT INTO profiles (user_id, bio, location, latitude, longitude)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (user_id) DO UPDATE SET bio = $2, location = $3, latitude = $4, longitude = $5`,
        [userId, u.bio, u.location, u.latitude, u.longitude]
      );
      console.log(`Seeded user ${u.username} at location ${u.location} (${u.latitude}, ${u.longitude})`);
    }
    console.log('Mock coordinates seed complete!');
  } catch (err) {
    console.error('Error seeding coordinates', err);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
