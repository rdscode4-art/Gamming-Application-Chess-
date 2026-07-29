const express = require('express');
const router = express.Router();
const { getAllGuides } = require('./guideController');

// Public route to fetch all guides
router.get('/', getAllGuides);

module.exports = router;
