const Tournament = require('../models/Tournament');
const User = require('../models/User');
const Game = require('../models/Game');
const Transaction = require('../models/Transaction');
const { sendPushNotification } = require('../config/firebaseAdmin');
const { v4: uuidv4 } = require('uuid');
const socketManager = require('../socket/socketManager');

const getNextPowerOfTwo = (n) => {
  return Math.pow(2, Math.ceil(Math.log2(n)));
};

const isPowerOfTwo = (n) => {
  return n > 0 && (n & (n - 1)) === 0;
};

class TournamentEngine {
  /**
   * Starts a tournament: checks requirements, assigns BYEs, creates Round 1 matches/games.
   */
  static async startTournament(tournamentId) {
    try {
      const tournament = await Tournament.findById(tournamentId);
      if (!tournament || tournament.status !== 'registration') return;

      const players = tournament.registeredPlayers || [];

      // If it is not full, cancel and refund
      if (players.length !== tournament.maxPlayers) {
        tournament.status = 'cancelled';
        await tournament.save();
        await this.refundEntryFees(tournament);
        
        const reason = "insufficient registrations";
        await this.notifyPlayers(players, 'Tournament Cancelled', `Your tournament "${tournament.name}" was cancelled due to ${reason}. Entry fee refunded.`);
        console.log(`[TournamentEngine] Tournament ${tournamentId} cancelled because it did not reach max players.`);
        return;
      }

      tournament.status = 'ongoing';
      tournament.currentRound = 1;

      // Calculate Bracket Size (which is exactly players.length now)
      const bracketSize = players.length;

      // Fetch user docs to get ObjectIds for Game model
      const userDocs = await User.find({ userId: { $in: players } });
      const userMap = {};
      userDocs.forEach(u => { userMap[u.userId] = u._id; });

      // Shuffle players randomly
      const shuffledPlayers = [...players].sort(() => Math.random() - 0.5);

      let matches = [];
      let nextMatchId = 1;

      // Generate pairs
      let playerIndex = 0;
      for (let i = 0; i < bracketSize / 2; i++) {
        const p1 = shuffledPlayers[playerIndex++];
        const p2 = shuffledPlayers[playerIndex++];

        const match = {
          matchId: uuidv4(),
          player1: p1,
          player2: p2,
          winnerId: null,
          status: 'pending',
        };

        // Create the actual Game in DB
        const gameId = uuidv4();
        match.gameId = gameId;

        await Game.create({
          gameId: gameId,
          whitePlayer: userMap[p1],
          blackPlayer: userMap[p2],
          timeControl: tournament.timeControl,
          contestType: 'tournament',
          tournamentId: tournament._id,
          status: 'waiting',
        });

        matches.push(match);
      }

      tournament.rounds.push({
        roundNumber: 1,
        status: 'ongoing',
        matches: matches
      });

      tournament.totalRounds = Math.log2(bracketSize);
      await tournament.save();
      console.log(`[TournamentEngine] Tournament ${tournamentId} started with ${players.length} players.`);

      // Notify each player individually with their gameId
      for (const match of matches) {
        if (match.status === 'pending' && match.gameId) {
          const payload = { type: 'TOURNAMENT_MATCH_STARTED', gameId: match.gameId };
          await this.notifyPlayers([match.player1], 'Your Match is Starting!', `Your Round 1 match in "${tournament.name}" is starting NOW!`, payload);
          await this.notifyPlayers([match.player2], 'Your Match is Starting!', `Your Round 1 match in "${tournament.name}" is starting NOW!`, payload);
        }
      }

      // Note: We might want to immediately advance if Round 1 is somehow entirely BYEs (unlikely since players >= 2)
      await this.checkRoundCompletion(tournament._id);
    } catch (error) {
      console.error('[TournamentEngine] Error starting tournament:', error);
    }
  }

  /**
   * Records the match result inside the Tournament document and checks for round completion
   */
  static async recordMatchResult(tournamentId, gameId, winnerUserId) {
    try {
      const tournament = await Tournament.findById(tournamentId);
      if (!tournament || tournament.status !== 'ongoing') return;

      const currentRoundObj = tournament.rounds.find(r => r.roundNumber === tournament.currentRound);
      if (!currentRoundObj) return;

      const match = currentRoundObj.matches.find(m => m.gameId === gameId);
      if (!match) return;

      match.winnerId = winnerUserId;
      match.status = 'completed';
      await tournament.save();

      console.log(`[TournamentEngine] Match ${gameId} in Tournament ${tournamentId} completed. Winner: ${winnerUserId}`);
      
      // After recording, check if the whole round is finished
      await this.checkRoundCompletion(tournamentId);
    } catch (error) {
      console.error('[TournamentEngine] Error recording match result:', error);
    }
  }

  /**
   * Called when a game concludes. Checks if the round is finished.
   */
  static async checkRoundCompletion(tournamentId) {
    try {
      const tournament = await Tournament.findById(tournamentId);
      if (!tournament || tournament.status !== 'ongoing') return;

      const currentRoundObj = tournament.rounds.find(r => r.roundNumber === tournament.currentRound);
      if (!currentRoundObj) return;

      const allMatchesCompleted = currentRoundObj.matches.every(m => ['completed', 'bye'].includes(m.status));
      if (!allMatchesCompleted) return;

      // Round is complete
      currentRoundObj.status = 'completed';

      if (tournament.currentRound >= tournament.totalRounds) {
        // Tournament is finished
        const finalMatch = currentRoundObj.matches[0];
        tournament.winnerId = finalMatch.winnerId;
        tournament.status = 'completed';
        await tournament.save();
        
        await this.distributePrizes(tournament);
        await this.notifyPlayers(tournament.registeredPlayers, 'Tournament Completed', `Tournament "${tournament.name}" has concluded. Congratulations to the winner!`);
        console.log(`[TournamentEngine] Tournament ${tournamentId} completed.`);
      } else {
        // Advance to next round
        tournament.currentRound += 1;
        const nextRoundMatches = [];
        
        const previousWinners = currentRoundObj.matches.map(m => m.winnerId).filter(Boolean);
        
        // Fetch user docs to get ObjectIds for Game model
        const userDocs = await User.find({ userId: { $in: previousWinners } });
        const userMap = {};
        userDocs.forEach(u => { userMap[u.userId] = u._id; });

        for (let i = 0; i < previousWinners.length; i += 2) {
          const p1 = previousWinners[i];
          const p2 = previousWinners[i + 1];
          const gameId = uuidv4();

          nextRoundMatches.push({
            matchId: uuidv4(),
            gameId: gameId,
            player1: p1,
            player2: p2,
            status: 'pending',
          });

          await Game.create({
            gameId: gameId,
            whitePlayer: userMap[p1],
            blackPlayer: userMap[p2],
            timeControl: tournament.timeControl,
            contestType: 'tournament',
            tournamentId: tournament._id,
            status: 'waiting',
          });
        }

        tournament.rounds.push({
          roundNumber: tournament.currentRound,
          status: 'ongoing',
          matches: nextRoundMatches
        });

        await tournament.save();
        console.log(`[TournamentEngine] Tournament ${tournamentId} advanced to Round ${tournament.currentRound}.`);
        
        // Notify each player individually with their gameId for the next round
        for (const match of nextRoundMatches) {
          if (match.status === 'pending' && match.gameId) {
            const payload = { type: 'TOURNAMENT_MATCH_STARTED', gameId: match.gameId };
            await this.notifyPlayers([match.player1], 'Next Round Started', `Round ${tournament.currentRound} of "${tournament.name}" has started!`, payload);
            await this.notifyPlayers([match.player2], 'Next Round Started', `Round ${tournament.currentRound} of "${tournament.name}" has started!`, payload);
          }
        }
      }

    } catch (error) {
      console.error('[TournamentEngine] Error checking round completion:', error);
    }
  }

  static async refundEntryFees(tournament) {
    if (!tournament.entryFee || tournament.entryFee <= 0) return;

    for (const userId of tournament.registeredPlayers) {
      await User.updateOne(
        { userId },
        { $inc: { depositBalance: tournament.entryFee } }
      );

      await Transaction.create({
        transactionId: uuidv4(),
        userId: userId,
        type: 'refund',
        amount: tournament.entryFee,
        balanceType: 'deposit',
        status: 'completed',
        description: `Refund for cancelled tournament ${tournament.name}`,
      });
    }
  }

  static async distributePrizes(tournament) {
    if (tournament.prizeDistribution && tournament.prizeDistribution.length > 0) {
      // Very simplified distribution:
      // In a real system, you'd calculate standings based on round progression.
      // For a knockout, 1st place is the winnerId. 2nd place is the loser of the final match.
      const finalRound = tournament.rounds.find(r => r.roundNumber === tournament.totalRounds);
      const finalMatch = finalRound.matches[0];
      
      const firstPlace = tournament.winnerId;
      const secondPlace = (finalMatch.player1 === tournament.winnerId) ? finalMatch.player2 : finalMatch.player1;

      const standings = [
        { userId: firstPlace, position: 1 },
        { userId: secondPlace, position: 2 }
      ];

      for (const dist of tournament.prizeDistribution) {
        const standing = standings.find(s => s.position === dist.position);
        if (standing && standing.userId) {
          await User.updateOne(
            { userId: standing.userId },
            { $inc: { winningsBalance: dist.amount } }
          );

          await Transaction.create({
            transactionId: uuidv4(),
            userId: standing.userId,
            type: 'prize',
            amount: dist.amount,
            balanceType: 'winnings',
            status: 'completed',
            description: `Prize for ${dist.position} place in ${tournament.name}`,
          });

          tournament.finalStandings.push({
            userId: standing.userId,
            position: dist.position,
            prize: dist.amount
          });
        }
      }
      await tournament.save();
    }
  }

  static async notifyPlayers(userIds, title, body, data = {}) {
    try {
      const users = await User.find({
        userId: { $in: userIds },
        'fcmTokens.0': { $exists: true }
      });
      const fcmTokens = users.flatMap(u => u.fcmTokens || []).filter(Boolean);
      
      if (fcmTokens.length > 0) {
        await sendPushNotification(fcmTokens, title, body, data);
      }
      
      // Emit socket event to players if they are online
      const io = socketManager.getIo();
      if (io && data.type === 'TOURNAMENT_MATCH_STARTED') {
        for (const userId of userIds) {
          io.to(userId).emit('tournament_match_ready', data);
        }
      }
    } catch (e) {
      console.error('[TournamentEngine] Notification error:', e);
    }
  }
}

module.exports = TournamentEngine;
