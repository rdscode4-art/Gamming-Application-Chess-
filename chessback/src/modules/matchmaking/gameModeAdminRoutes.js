const express = require('express');
const controller = require('./gameModeAdminController');
// const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

// Admin middleware placeholder
const adminMiddleware = (req, res, next) => {
  // if (req.user?.role !== 'admin') return res.status(403).json({ message: 'Forbidden' });
  next();
};

router.use(adminMiddleware);

router.get('/', controller.getGameModes);
router.post('/', controller.createGameMode);
router.put('/:id', controller.updateGameMode);
router.delete('/:id', controller.deleteGameMode);

module.exports = router;
