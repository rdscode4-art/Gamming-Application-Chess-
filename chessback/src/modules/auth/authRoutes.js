const express = require('express');
const { guestLogin, requestOtp, verifyOtp, completeProfile, refreshToken, logout, checkUsername } = require('./authController');
const { adminLogin } = require('./adminAuthController');
const { getDashboardStats } = require('./adminDashboardController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.post('/guest', guestLogin);
router.post('/request-otp', requestOtp);
router.post('/verify-otp', verifyOtp);
router.post('/check-username', checkUsername);
router.post('/complete-profile', authMiddleware, completeProfile);
router.post('/refresh', refreshToken);
router.post('/logout', authMiddleware, logout);
router.post('/admin-login', adminLogin);
router.get('/dashboard-stats', authMiddleware, getDashboardStats);

module.exports = router;
