const express = require('express');
const { getTournaments, createTournament, getTournamentDetails, registerForTournament } = require('./tournamentController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getTournaments);
router.post('/', authMiddleware, createTournament);
router.get('/:id', authMiddleware, getTournamentDetails);
router.post('/:id/register', authMiddleware, registerForTournament);

module.exports = router;
