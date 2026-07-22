const express = require('express');
const { getMyProfile, updateMyProfile, deleteMyAccount, getPublicProfile, getMatchHistory, updateFcmToken } = require('./userController');
const { authMiddleware } = require('../../middleware/authMiddleware');
const { uploadAvatarMiddleware } = require('../../middleware/uploadMiddleware');

const router = express.Router();

router.get('/me', authMiddleware, getMyProfile);
router.put('/me', authMiddleware, updateMyProfile);
router.delete('/me', authMiddleware, deleteMyAccount);
router.get('/me/games', authMiddleware, getMatchHistory);
router.post('/avatar', authMiddleware, uploadAvatarMiddleware.single('avatar'), require('./userController').uploadAvatar);
router.post('/fcm-token', authMiddleware, updateFcmToken);
router.get('/:id', authMiddleware, getPublicProfile);

module.exports = router;
