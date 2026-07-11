const express = require('express');
const { getMyProfile, updateMyProfile, deleteMyAccount, getPublicProfile, getMatchHistory } = require('./userController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/me', authMiddleware, getMyProfile);
router.put('/me', authMiddleware, updateMyProfile);
router.delete('/me', authMiddleware, deleteMyAccount);
router.get('/me/games', authMiddleware, getMatchHistory);
router.get('/:id', authMiddleware, getPublicProfile);

module.exports = router;
