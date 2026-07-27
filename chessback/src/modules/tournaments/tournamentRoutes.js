const express = require('express');
const { getTournaments, createTournament, getTournamentDetails, registerForTournament, getTournamentMatchInit, getMyActiveTournamentMatch, joinTournamentByCode } = require('./tournamentController');
const { authMiddleware } = require('../../middleware/authMiddleware');

const router = express.Router();

router.get('/', authMiddleware, getTournaments);
router.post('/', authMiddleware, createTournament);
router.post('/join-by-code', authMiddleware, joinTournamentByCode);
router.get('/my-active-match', authMiddleware, getMyActiveTournamentMatch);
router.get('/match/:gameId', authMiddleware, getTournamentMatchInit);
router.get('/:id', authMiddleware, getTournamentDetails);
router.post('/:id/register', authMiddleware, registerForTournament);

module.exports = router;
