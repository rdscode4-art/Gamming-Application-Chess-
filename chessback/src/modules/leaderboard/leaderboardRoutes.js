const express = require('express');
const { getLeaderboard } = require('./leaderboardController');

const router = express.Router();

router.get('/', getLeaderboard);

module.exports = router;
