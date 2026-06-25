import { sendPushNotification, updateUserFcmToken } from './src/services/notification.service.js';
import { query } from './src/config/db.js';

async function testPush() {
  try {
    // 1. Get a random user
    const res = await query('SELECT id FROM users LIMIT 1');
    if (res.rows.length === 0) {
      console.log('No users found in DB.');
      process.exit(0);
    }
    const userId = res.rows[0].id;

    console.log(`Testing push for user: ${userId}`);

    // 2. Set a mock FCM token for this user
    await updateUserFcmToken(userId, 'mock_fcm_token_123');
    console.log('Mock FCM token set successfully.');

    // 3. Send notification
    const result = await sendPushNotification(userId, {
      title: 'Test Notification',
      body: 'This is a test FCM push notification from ZyntraPlus.',
      data: { type: 'test' }
    });

    console.log('Notification Service Result:', result);
    process.exit(0);
  } catch (err) {
    console.error('Error testing push:', err);
    process.exit(1);
  }
}

testPush();
