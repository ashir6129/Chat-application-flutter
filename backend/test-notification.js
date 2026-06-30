import { sendPushNotification } from './src/services/notification.service.js';
import { findUserByEmail } from './src/models/user.model.js';

async function test() {
  try {
    const user = await findUserByEmail('ashir6129@gmail.com');
    if (!user) {
      console.log('User not found');
      return;
    }
    console.log('Found user:', user.id);
    const result = await sendPushNotification(user.id, {
      title: 'Test Notification',
      body: 'This is a test popup notification',
      data: { type: 'test' }
    });
    console.log('Notification result:', result);
  } catch (e) {
    console.error('Error:', e.message);
  }
  process.exit(0);
}

test();
