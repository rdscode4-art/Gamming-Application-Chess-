const express = require('express');
const { getBanners } = require('./bannerController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getBanners);

module.exports = router;
