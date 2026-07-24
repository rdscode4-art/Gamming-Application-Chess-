const User = require('../users/userModel');
const Notification = require('./notificationModel');
const { sendPushNotification } = require('../../config/firebaseAdmin');

exports.sendNotification = async (req, res, next) => {
  try {
    const { title, body, targetUserId, data } = req.body;

    if (!title || !body) {
      return res.status(400).json({ status: 'fail', message: 'Title and body are required' });
    }

    let users = [];
    if (targetUserId && targetUserId !== 'ALL') {
      const user = await User.findById(targetUserId).select('+fcmToken');
      if (!user) {
        return res.status(404).json({ status: 'fail', message: 'User not found' });
      }
      users.push(user);
    } else {
      // Find all users who have an FCM token
      users = await User.find({ fcmToken: { $exists: true, $ne: null } }).select('+fcmToken');
    }

    const fcmTokens = users.map(u => u.fcmToken).filter(Boolean);

    // Persist notification to DB for in-app history
    const notifsToInsert = users.map(u => ({
      userId: u._id,
      title,
      body,
      type: 'admin',
      data: data || {},
      isRead: false
    }));
    
    if (notifsToInsert.length > 0) {
      await Notification.insertMany(notifsToInsert);
    }

    if (fcmTokens.length > 0) {
      // Send Push Notifications
      await sendPushNotification(fcmTokens, title, body, data || {});
    }

    res.status(200).json({
      status: 'success',
      message: `Notification sent to ${fcmTokens.length} devices.`
    });
  } catch (error) {
    console.error('Send Notification Error:', error);
    res.status(500).json({ status: 'error', message: 'Failed to send notification' });
  }
};
