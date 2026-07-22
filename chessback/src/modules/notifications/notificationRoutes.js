const express = require('express');
const { getNotifications, markAsRead } = require('./notificationController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getNotifications);
router.put('/:id/read', authMiddleware, markAsRead);

module.exports = router;
