const express = require('express');
const router = express.Router();
const supportController = require('./supportController');
const { authMiddleware } = require('../../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/', supportController.createTicket);
router.get('/', supportController.getMyTickets);

module.exports = router;
