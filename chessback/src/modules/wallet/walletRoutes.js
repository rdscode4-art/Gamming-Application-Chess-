const express = require('express');
const { getWalletBalance, getTransactionHistory, createOrder, verifyPayment, markPaymentFailed, requestWithdrawal } = require('./walletController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getWalletBalance);
router.get('/transactions', authMiddleware, getTransactionHistory);
router.post('/deposit/initiate', authMiddleware, createOrder);
router.post('/deposit/verify', authMiddleware, verifyPayment);
router.post('/deposit/fail', authMiddleware, markPaymentFailed);
router.post('/withdraw', authMiddleware, requestWithdrawal);

module.exports = router;
