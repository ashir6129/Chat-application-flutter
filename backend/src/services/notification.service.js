import admin from 'firebase-admin';
import env from '../config/env.js';
import { query } from '../config/db.js';

let firebaseInitialized = false;

// Attempt to initialize Firebase Admin SDK
try {
  const serviceAccountVar = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (serviceAccountVar) {
    const serviceAccount = JSON.parse(serviceAccountVar);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    firebaseInitialized = true;
    console.log('Firebase Admin SDK initialized successfully via process.env');
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    firebaseInitialized = true;
    console.log('Firebase Admin SDK initialized successfully via GOOGLE_APPLICATION_CREDENTIALS');
  } else {
    console.warn('Firebase Admin SDK not initialized: Missing credentials. Push notifications will be simulated/logged.');
  }
} catch (err) {
  console.error('Failed to initialize Firebase Admin SDK:', err.message);
}

export async function updateUserFcmToken(userId, fcmToken) {
  await query(
    `UPDATE users SET fcm_token = $1 WHERE id = $2`,
    [fcmToken ?? null, userId]
  );
}

export async function getUserFcmToken(userId) {
  const result = await query(
    `SELECT fcm_token FROM users WHERE id = $1`,
    [userId]
  );
  return result.rows[0]?.fcm_token ?? null;
}

export async function sendPushNotification(userId, { title, body, data = {} }) {
  try {
    const token = await getUserFcmToken(userId);
    if (!token) {
      console.log(`[Push Notification Simulation] No FCM token found for user ${userId}. Message: "${title}: ${body}"`);
      return { success: false, reason: 'no_token' };
    }

    if (!firebaseInitialized) {
      console.log(`[Push Notification Simulation] Sending to token ${token} -> Title: "${title}", Body: "${body}", Data:`, data);
      return { success: true, simulated: true };
    }

    const message = {
      token,
      notification: {
        title,
        body,
      },
      data: Object.keys(data).reduce((acc, key) => {
        acc[key] = String(data[key]);
        return acc;
      }, {}),
    };

    const response = await admin.messaging().send(message);
    console.log(`Push notification sent successfully to user ${userId}: ${response}`);
    return { success: true, messageId: response };
  } catch (err) {
    console.error(`Failed to send push notification to user ${userId}:`, err.message);
    return { success: false, error: err.message };
  }
}
