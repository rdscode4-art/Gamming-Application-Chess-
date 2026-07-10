const express = require('express');
const { quickJoin, getGameModes, getLiveMatches } = require('./contestController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/modes', authMiddleware, getGameModes);
router.post('/quick-join', authMiddleware, quickJoin);
router.get('/live', authMiddleware, getLiveMatches);

module.exports = router;
