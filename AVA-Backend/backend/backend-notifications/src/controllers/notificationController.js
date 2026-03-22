const Notification = require('../models/Notification');
const notificationService = require('../services/notificationService');

// Get all notifications for the logged in user
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      userId: req.user.id,
      isRead: false
    });

    res.json({
      success: true,
      data: {
        notifications,
        unreadCount
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Mark specific notifications as read
exports.markAsRead = async (req, res) => {
  try {
    const { notificationIds } = req.body;

    if (!notificationIds || !Array.isArray(notificationIds)) {
      return res.status(400).json({
        success: false,
        message: 'notificationIds must be an array'
      });
    }

    await Notification.updateMany(
      {
        _id: { $in: notificationIds },
        userId: req.user.id   // ensures users can only mark their own notifications
      },
      { isRead: true }
    );

    res.json({
      success: true,
      message: 'Notifications marked as read'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Mark all notifications as read for the logged in user
exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user.id, isRead: false },
      { isRead: true }
    );

    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Delete all notifications for the logged in user
exports.clearAllNotifications = async (req, res) => {
  try {
    await Notification.deleteMany({ userId: req.user.id });

    res.json({
      success: true,
      message: 'All notifications cleared'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Delete a single notification by ID
exports.deleteNotification = async (req, res) => {
  try {
    const deleted = await Notification.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id   // ensures users can only delete their own notifications
    });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.json({
      success: true,
      message: 'Notification deleted'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Save FCM token for push notifications (called by mobile app on login)
exports.saveFCMToken = async (req, res) => {
  try {
    const { token, platform } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'FCM token is required'
      });
    }

    await notificationService.saveFCMToken(req.user.id, token, platform);

    res.json({
      success: true,
      message: 'FCM token saved successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Create a notification - called internally by the claims module
// FIX: auth middleware added to this route to prevent anyone from
// creating notifications for arbitrary users without a valid token
exports.createNotification = async (req, res) => {
  try {
    const { userId, type, title, message, claimId } = req.body;

    if (!userId || !type || !title || !message) {
      return res.status(400).json({
        success: false,
        message: 'userId, type, title and message are all required'
      });
    }

    const notification = await notificationService.createNotification({
      userId,
      type,
      title,
      message,
      claimId
    });

    res.status(201).json({
      success: true,
      message: 'Notification created',
      data: { notification }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
