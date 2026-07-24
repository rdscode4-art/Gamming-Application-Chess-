const express = require('express');
const { getTournaments, createTournament, getTournamentDetails, registerForTournament, getTournamentMatchInit, getMyActiveTournamentMatch } = require('./tournamentController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getTournaments);
router.post('/', authMiddleware, createTournament);
router.get('/my-active-match', authMiddleware, getMyActiveTournamentMatch);
router.get('/match/:gameId', authMiddleware, getTournamentMatchInit);
router.get('/:id', authMiddleware, getTournamentDetails);
router.post('/:id/register', authMiddleware, registerForTournament);

module.exports = router;
