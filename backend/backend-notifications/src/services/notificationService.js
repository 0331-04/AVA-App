const Notification = require('../models/Notification');
const UserToken = require('../models/UserToken');
const admin = require('../config/firebase');

/**
 * Create a notification in the database and send a push notification
 */
async function createNotification(data) {
  try {
    const notification = await Notification.create(data);

    // Send push notification - runs in background, won't block the response
    sendPushNotification(data.userId, {
      title: data.title,
      message: data.message,
      claimId: data.claimId,
      type: data.type
    }).catch(err => console.error('Background push notification failed:', err.message));

    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    throw error;
  }
}

/**
 * Send a push notification via Firebase Cloud Messaging
 */
async function sendPushNotification(userId, payload) {
  try {
    // Check Firebase is initialized before trying to send
    if (!admin.apps || admin.apps.length === 0) {
      console.warn('⚠️  Firebase not initialized - skipping push notification');
      return;
    }

    // Get user's FCM token
    const userToken = await UserToken.findOne({ userId });

    if (!userToken || !userToken.fcmToken) {
      console.log(`No FCM token found for user ${userId} - skipping push notification`);
      return;
    }

    const message = {
      notification: {
        title: payload.title,
        body: payload.message
      },
      data: {
        claimId: payload.claimId ? payload.claimId.toString() : '',
        type: payload.type || 'general',
        timestamp: new Date().toISOString()
      },
      token: userToken.fcmToken
    };

    const response = await admin.messaging().send(message);
    console.log('✅ Push notification sent:', response);

    return response;

  } catch (error) {
    console.error('❌ Push notification error:', error.message);

    // If the token is invalid or expired, remove it from the database
    if (
      error.code === 'messaging/invalid-registration-token' ||
      error.code === 'messaging/registration-token-not-registered'
    ) {
      await UserToken.findOneAndDelete({ userId });
      console.log('Removed invalid FCM token for user', userId);
    }
  }
}

/**
 * Save or update a user's FCM device token
 */
async function saveFCMToken(userId, fcmToken, platform = 'android') {
  try {
    const userToken = await UserToken.findOneAndUpdate(
      { userId },
      {
        userId,
        fcmToken,
        platform,
        updatedAt: new Date()
      },
      { upsert: true, new: true }
    );

    return userToken;
  } catch (error) {
    console.error('Error saving FCM token:', error);
    throw error;
  }
}

module.exports = {
  createNotification,
  sendPushNotification,
  saveFCMToken
};
