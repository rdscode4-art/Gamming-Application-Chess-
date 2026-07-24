const express = require('express');
const router = express.Router();
const notificationAdminController = require('./notificationAdminController');
const { authMiddleware, adminMiddleware } = require('../../middleware/authMiddleware');

router.use(authMiddleware);
router.use(adminMiddleware);

router.post('/send', notificationAdminController.sendNotification);

module.exports = router;
