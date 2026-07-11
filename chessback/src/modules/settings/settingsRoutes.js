const express = require('express');
const router = express.Router();
const settingsController = require('./settingsController');
const { authMiddleware: protect, adminMiddleware: admin } = require('../../middleware/authMiddleware');

// Public endpoints
router.get('/public', settingsController.getPublicSettings);

// Admin endpoints
router.get('/', protect, admin, settingsController.getAllSettings);
router.put('/:key', protect, admin, settingsController.updateSetting);

module.exports = router;
