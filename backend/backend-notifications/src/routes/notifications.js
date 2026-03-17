const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const auth = require('../middleware/auth');

// Get all notifications for logged in user
router.get('/', auth, notificationController.getNotifications);

// Mark specific notifications as read
router.post('/read', auth, notificationController.markAsRead);

// Mark all notifications as read
router.post('/read-all', auth, notificationController.markAllAsRead);

// Clear all notifications
router.delete('/', auth, notificationController.clearAllNotifications);

// Delete single notification
router.delete('/:id', auth, notificationController.deleteNotification);

// Save FCM token (sent by mobile app after login)
router.post('/fcm-token', auth, notificationController.saveFCMToken);

// FIX: Added auth middleware here - the original had no auth on this route,
// meaning anyone could create notifications for any user without a token.
// The claims module must include a valid JWT when calling this endpoint.
router.post('/create', auth, notificationController.createNotification);

module.exports = router;
