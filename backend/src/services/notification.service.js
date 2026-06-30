import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import env from '../config/env.js';
import { query } from '../config/db.js';
import { createNotification, shouldSendNotification } from '../models/notification.model.js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

let firebaseInitialized = false;
// Attempt to initialize Firebase Admin SDK
try {
  const serviceAccountVar = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (serviceAccountVar) {
    const serviceAccount = JSON.parse(serviceAccountVar);
    initializeApp({
      credential: cert(serviceAccount),
    });
    firebaseInitialized = true;
    console.log('Firebase Admin SDK initialized successfully via process.env');
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    // Try to read the file directly
    try {
      const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      let serviceAccount;
      
      // Check if it's a relative path
      if (!serviceAccountPath.startsWith('/')) {
        const absolutePath = join(__dirname, '..', '..', serviceAccountPath);
        serviceAccount = JSON.parse(readFileSync(absolutePath, 'utf8'));
      } else {
        serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
      }
      
      initializeApp({
        credential: cert(serviceAccount),
      });
      firebaseInitialized = true;
      console.log('Firebase Admin SDK initialized successfully via file');
    } catch (fileErr) {
      console.warn('Failed to read Firebase service account file:', fileErr.message);
      // Fallback to application default
      initializeApp({
        credential: applicationDefault(),
      });
      firebaseInitialized = true;
      console.log('Firebase Admin SDK initialized successfully via GOOGLE_APPLICATION_CREDENTIALS (fallback)');
    }
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
    const type = data.type || 'system';

    // Check if user has enabled this notification type
    const shouldSend = await shouldSendNotification(userId, type);
    if (!shouldSend) {
      console.log(`[Push Notification Skipped] User ${userId} has disabled ${type} notifications`);
      return { success: false, reason: 'user_disabled' };
    }

    // 1. Save notification to database in real-time
    const senderId = data.sender_id || data.liker_id || data.follower_id || data.commenter_id || data.actor_id || null;

    await createNotification({
      recipientId: userId,
      senderId,
      type,
      message: body,
      metadata: data,
    }).catch((err) => console.error('Failed to save notification record to DB:', err.message));

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
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          visibility: 'public',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
      data: Object.keys(data).reduce((acc, key) => {
        acc[key] = String(data[key]);
        return acc;
      }, {}),
    };

    const response = await getMessaging().send(message);
    console.log(`Push notification sent successfully to user ${userId}: ${response}`);
    return { success: true, messageId: response };
  } catch (err) {
    console.error(`Failed to send push notification to user ${userId}:`, err.message);
    return { success: false, error: err.message };
  }
}
