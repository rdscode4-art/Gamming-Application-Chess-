const express = require('express');
const { getWithdrawals, updateWithdrawalStatus } = require('./walletAdminController');

const router = express.Router();

router.get('/', getWithdrawals);
router.put('/:id', updateWithdrawalStatus);

module.exports = router;
