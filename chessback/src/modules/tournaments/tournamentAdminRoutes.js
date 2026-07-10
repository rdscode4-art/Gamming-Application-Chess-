const express = require('express');
const controller = require('./tournamentAdminController');

const router = express.Router();

const adminMiddleware = (req, res, next) => {
  next();
};

router.use(adminMiddleware);

router.get('/', controller.getTournaments);
router.post('/', controller.createTournament);
router.put('/:id', controller.updateTournament);
router.delete('/:id', controller.deleteTournament);

module.exports = router;
