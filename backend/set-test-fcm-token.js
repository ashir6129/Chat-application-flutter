import { query } from './src/config/db.js';

async function setTestToken() {
  try {
    // Set a test FCM token for the user
    await query(
      `UPDATE users SET fcm_token = $1 WHERE email = $2`,
      ['test_fcm_token_ashir6129', 'ashir6129@gmail.com']
    );
    console.log('Test FCM token set for ashir6129@gmail.com');
  } catch (e) {
    console.error('Error:', e.message);
  }
  process.exit(0);
}

setTestToken();
