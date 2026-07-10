const express = require('express');
const { guestLogin, requestOtp, verifyOtp, completeProfile, refreshToken, logout, checkUsername } = require('./authController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.post('/guest', guestLogin);
router.post('/request-otp', requestOtp);
router.post('/verify-otp', verifyOtp);
router.post('/check-username', checkUsername);
router.post('/complete-profile', authMiddleware, completeProfile);
router.post('/refresh', refreshToken);
router.post('/logout', authMiddleware, logout);

module.exports = router;
