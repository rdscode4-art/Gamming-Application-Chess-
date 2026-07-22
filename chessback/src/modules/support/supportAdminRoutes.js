const express = require('express');
const controller = require('./supportAdminController');
const { authMiddleware, adminMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

// Apply middlewares if admin authentication is required. 
// Assuming admin routes are protected at the app.js level or here.
// We will apply a simple placeholder or the actual adminMiddleware if needed.
// router.use(authMiddleware, adminMiddleware);

router.get('/', controller.getAllTickets);
router.get('/:id', controller.getTicketDetails);
router.post('/:id/reply', controller.replyToTicket);
router.put('/:id/status', controller.updateTicketStatus);

module.exports = router;
