const admin = require('firebase-admin');
const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const path = require('path');
const serviceAccount = require('../../firebase-service-account.json');

try {
  initializeApp({
    credential: cert(serviceAccount)
  });
  console.log('Firebase Admin initialized successfully.');
} catch (error) {
  if (!/already exists/.test(error.message)) {
    console.error('Firebase Admin initialization error', error.stack);
  }
}

/**
 * Send push notification using FCM
 * @param {string|string[]} fcmTokens - A single token or an array of tokens
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {Object} data - Optional data payload
 */
const sendPushNotification = async (fcmTokens, title, body, data = {}) => {
  try {
    if (!fcmTokens || (Array.isArray(fcmTokens) && fcmTokens.length === 0)) {
      console.log('No FCM tokens provided. Skipping push notification.');
      return;
    }

    const message = {
      notification: {
        title,
        body
      },
      data,
    };

    let response;
    if (Array.isArray(fcmTokens)) {
      message.tokens = fcmTokens;
      response = await getMessaging().sendEachForMulticast(message);
      console.log(`Successfully sent multicast message: ${response.successCount} successes, ${response.failureCount} failures`);
    } else {
      message.token = fcmTokens;
      response = await getMessaging().send(message);
      console.log('Successfully sent message:', response);
    }
    return response;
  } catch (error) {
    console.error('Error sending push notification:', error);
    throw error;
  }
};

module.exports = {
  admin,
  sendPushNotification
};
