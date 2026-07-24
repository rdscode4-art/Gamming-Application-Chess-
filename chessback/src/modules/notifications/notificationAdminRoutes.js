const express = require('express');
const router = express.Router();
const notificationAdminController = require('./notificationAdminController');
const { protect, restrictTo } = require('../../middleware/authMiddleware');

router.use(protect);
router.use(restrictTo('admin'));

router.post('/send', notificationAdminController.sendNotification);

module.exports = router;
