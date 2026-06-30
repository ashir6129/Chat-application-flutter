import { findUserByEmail } from './src/models/user.model.js';
import { query } from './src/config/db.js';

async function check() {
  try {
    const user = await findUserByEmail('ashir6129@gmail.com');
    if (!user) {
      console.log('User not found');
      return;
    }
    console.log('User ID:', user.id);
    console.log('FCM Token:', user.fcm_token || 'No token');
  } catch (e) {
    console.error('Error:', e.message);
  }
  process.exit(0);
}

check();
