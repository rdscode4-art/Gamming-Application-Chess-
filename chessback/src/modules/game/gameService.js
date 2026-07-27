const { Chess } = require('chess.js');
const { v4: uuidv4 } = require('uuid');
const redisService = require('../../services/redisService');
const { REDIS_KEYS, SOCKET_EVENTS, TIME_CONTROLS, DISCONNECT_TIMEOUT } = require('../../utils/constants');
const logger = require('../../config/logger');

class GameService {

  // ─── Create Game ────────────────────────────────────────────────────────────
  async createGame(roomId, p1, p2, io, options = {}) {
    const chess = new Chess();
    const timeControl = options.timeControl || 'rapid_10';
    const tc = TIME_CONTROLS[timeControl] || TIME_CONTROLS.rapid_10;

    const roomState = {
      roomId,
      status: 'active',
      whitePlayer: p1,
      blackPlayer: p2,
      fen: chess.fen(),
      pgn: '',
      moves: [],
      whiteTime: tc.base,
      blackTime: tc.base,
      increment: tc.increment,
      timeControl,
      lastMoveTime: Date.now(),
      turn: 'w',
      drawOfferedBy: null,
      contestType: options.contestType || 'casual',
      entryFee: options.entryFee || 0,
      prizePool: options.prizePool || 0,
      isRated: options.isRated || false,
      startedAt: Date.now(),
    };

    await redisService.setJSON(`${REDIS_KEYS.ROOM_PREFIX}${roomId}`, roomState);

    // Map users to room
    await redisService.setJSON(`${REDIS_KEYS.USER_SESSION_PREFIX}${p1.userId}`, roomId);
    await redisService.setJSON(`${REDIS_KEYS.USER_SESSION_PREFIX}${p2.userId}`, roomId);

    // Make sockets join room
    const sockets = await io.fetchSockets();
    const s1 = sockets.find(s => s.id === p1.socketId);
    const s2 = sockets.find(s => s.id === p2.socketId);
    if (s1) s1.join(roomId);
    if (s2) s2.join(roomId);

    io.to(roomId).emit(SOCKET_EVENTS.MATCH_FOUND, {
      roomId,
      whitePlayer: p1,
      blackPlayer: p2,
      fen: roomState.fen,
      whiteTime: roomState.whiteTime,
      blackTime: roomState.blackTime,
      increment: roomState.increment,
      timeControl: roomState.timeControl,
      contestType: roomState.contestType,
      entryFee: roomState.entryFee,
      prizePool: roomState.prizePool,
    });

    logger.info(`Game created: ${roomId} | ${p1.username} vs ${p2.username} | ${timeControl}`);
  }

  // ─── Handle Move ────────────────────────────────────────────────────────────
  async handleMove(roomId, userId, moveData, io) {
    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${roomId}`;
    const lockKey = `lock:room:${roomId}`;

    if (!await redisService.acquireLock(lockKey, 2)) return;

    try {
      const room = await redisService.getJSON(roomKey);
      if (!room || room.status !== 'active') {
        logger.info(`handleMove: room not active or not found. status: ${room?.status}`);
        return;
      }

      const isWhite = room.whitePlayer.userId === userId;
      const isBlack = room.blackPlayer.userId === userId;
      if (!isWhite && !isBlack) {
        logger.info(`handleMove: user ${userId} not in game`);
        return;
      }
      if ((isWhite && room.turn !== 'w') || (isBlack && room.turn !== 'b')) {
        logger.info(`handleMove: Not user turn. isWhite:${isWhite}, turn:${room.turn}`);
        return;
      }

      const chess = new Chess(room.fen);
      const now = Date.now();
      const elapsed = Math.floor((now - room.lastMoveTime) / 1000); // seconds elapsed

      try {
        const move = chess.move(moveData); // { from, to, promotion? } or 'e4'
        if (!move) return;

        // Time is already being deducted by clockManager tick by tick.
        // We just add increment (if any) to the player who just moved.
        if (isWhite) {
          room.whiteTime = room.whiteTime + room.increment;
        } else {
          room.blackTime = room.blackTime + room.increment;
        }

        room.fen = chess.fen();
        room.turn = chess.turn();
        room.lastMoveTime = now;
        room.drawOfferedBy = null; // draw offer resets on move

        room.moves.push({
          from: move.from,
          to: move.to,
          san: move.san,
          fen: room.fen,
          moveTime: elapsed * 1000, // ms
        });

        await redisService.setJSON(roomKey, room);

        io.to(roomId).emit(SOCKET_EVENTS.MOVE_ACCEPTED, {
          fen: room.fen,
          move,
          turn: room.turn,
          whiteTime: room.whiteTime,
          blackTime: room.blackTime,
          lastMove: { from: move.from, to: move.to },
        });

        await this.checkGameOver(chess, room, io);

      } catch (err) {
        // Anti-cheat: Track invalid moves
        if (isWhite) {
          room.whitePlayer.invalidMoves = (room.whitePlayer.invalidMoves || 0) + 1;
        } else {
          room.blackPlayer.invalidMoves = (room.blackPlayer.invalidMoves || 0) + 1;
        }
        await redisService.setJSON(roomKey, room);

        const invalidCount = isWhite ? room.whitePlayer.invalidMoves : room.blackPlayer.invalidMoves;
        if (invalidCount >= 3) {
          logger.warn(`Player ${userId} forfeited due to excessive invalid moves in room ${roomId}`);
          const winner = isWhite ? 'black' : 'white';
          await this._endGame(room, winner, 'anti_cheat_forfeit', io);
          return;
        }

        // Emit only to the player who made invalid move
        const sockets = await io.fetchSockets();
        const playerSocket = sockets.find(s => s.user?.userId === userId);
        if (playerSocket) {
          playerSocket.emit(SOCKET_EVENTS.INVALID_MOVE, { reason: 'Illegal move' });
        }
      }
    } finally {
      await redisService.releaseLock(lockKey);
    }
  }

  // ─── Check Game Over ────────────────────────────────────────────────────────
  async checkGameOver(chess, room, io) {
    let reason = null;
    let winner = null;

    if (chess.isCheckmate()) {
      reason = 'checkmate';
      winner = chess.turn() === 'w' ? 'black' : 'white';
    } else if (chess.isStalemate()) {
      reason = 'stalemate';
      winner = 'draw';
    } else if (chess.isInsufficientMaterial()) {
      reason = 'insufficient_material';
      winner = 'draw';
    } else if (chess.isThreefoldRepetition()) {
      reason = 'threefold_repetition';
      winner = 'draw';
    } else if (chess.isDraw()) {
      reason = '50_move_rule';
      winner = 'draw';
    }

    if (reason) {
      await this._endGame(room, winner, reason, io);
    }
  }

  // ─── Handle Resign ──────────────────────────────────────────────────────────
  async handleResign(roomId, userId, io) {
    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${roomId}`;
    const room = await redisService.getJSON(roomKey);
    if (!room || room.status !== 'active') return;

    const winner = room.whitePlayer.userId === userId ? 'black' : 'white';
    await this._endGame(room, winner, 'resign', io);
  }

  // ─── Handle Draw Offer ──────────────────────────────────────────────────────
  async handleDrawOffer(roomId, userId, io) {
    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${roomId}`;
    const room = await redisService.getJSON(roomKey);
    if (!room || room.status !== 'active') return;

    room.drawOfferedBy = userId;
    await redisService.setJSON(roomKey, room);

    // Notify opponent
    io.to(roomId).emit(SOCKET_EVENTS.DRAW_OFFERED, { byUserId: userId });
  }

  async handleAcceptDraw(roomId, userId, io) {
    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${roomId}`;
    const room = await redisService.getJSON(roomKey);
    if (!room || room.status !== 'active') return;
    if (!room.drawOfferedBy || room.drawOfferedBy === userId) return; // can't accept own offer

    await this._endGame(room, 'draw', 'draw_agreement', io);
  }

  async handleDeclineDraw(roomId, userId, io) {
    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${roomId}`;
    const room = await redisService.getJSON(roomKey);
    if (!room || room.status !== 'active') return;

    room.drawOfferedBy = null;
    await redisService.setJSON(roomKey, room);
    io.to(roomId).emit(SOCKET_EVENTS.DRAW_DECLINED, { byUserId: userId });
  }

  // ─── Handle Disconnect ──────────────────────────────────────────────────────
  async handleDisconnect(userId, io) {
    const roomId = await redisService.getJSON(`${REDIS_KEYS.USER_SESSION_PREFIX}${userId}`);
    if (!roomId) return;

    const room = await redisService.getJSON(`${REDIS_KEYS.ROOM_PREFIX}${roomId}`);
    if (!room || room.status !== 'active') return;

    logger.info(`Player ${userId} disconnected from room ${roomId}. Starting forfeit timer.`);
    io.to(roomId).emit(SOCKET_EVENTS.OPPONENT_DISCONNECTED, { userId, timeout: DISCONNECT_TIMEOUT });

    const disconnectTime = Date.now().toString();
    // Store disconnect time in Redis so we can check on reconnect
    await redisService.redisClient.set(
      `${REDIS_KEYS.DISCONNECT_TIMER_PREFIX}${userId}`,
      disconnectTime,
      { EX: DISCONNECT_TIMEOUT * 2 } // expire safely after timeout
    );

    // Schedule forfeit after DISCONNECT_TIMEOUT seconds
    setTimeout(async () => {
      // Check if still disconnected WITH THE SAME TIMESTAMP
      const stillDisconnectedTimestamp = await redisService.redisClient.get(
        `${REDIS_KEYS.DISCONNECT_TIMER_PREFIX}${userId}`
      );
      
      // If the key is gone, or if the timestamp has changed (meaning they reconnected and disconnected again), ignore this old timer.
      if (!stillDisconnectedTimestamp || stillDisconnectedTimestamp !== disconnectTime) return; 

      const currentRoom = await redisService.getJSON(`${REDIS_KEYS.ROOM_PREFIX}${roomId}`);
      if (currentRoom && currentRoom.status === 'active') {
        const winner = room.whitePlayer.userId === userId ? 'black' : 'white';
        await this._endGame(currentRoom, winner, 'disconnect', io);
      }
    }, DISCONNECT_TIMEOUT * 1000);
  }

  // ─── Handle Reconnect ───────────────────────────────────────────────────────
  async handleReconnect(userId, socket, io) {
    const roomId = await redisService.getJSON(`${REDIS_KEYS.USER_SESSION_PREFIX}${userId}`);
    if (!roomId) {
      // If no active session, they probably forfeited or the game ended while they were offline.
      // Fetch their most recent game and send GAME_OVER so the frontend can route to victory screen.
      try {
        const User = require('../../models/User');
        const Game = require('../../models/Game');
        
        const userObj = await User.findOne({ userId });
        if (userObj) {
          const recentGame = await Game.findOne({
            $or: [{ whitePlayer: userObj._id }, { blackPlayer: userObj._id }]
          })
          .sort({ createdAt: -1 })
          .populate('whitePlayer blackPlayer');
          
          if (recentGame) {
            socket.emit(SOCKET_EVENTS.GAME_OVER, {
              winner: recentGame.winner,
              reason: recentGame.reason,
              whitePlayer: recentGame.whitePlayer, // Now populated with User doc
              blackPlayer: recentGame.blackPlayer, // Now populated with User doc
              eloChanges: recentGame.isRated ? {
                white: { 
                  before: recentGame.whiteRatingBefore, 
                  after: recentGame.whiteRatingAfter,
                  delta: (recentGame.whiteRatingAfter || 0) - (recentGame.whiteRatingBefore || 0)
                },
                black: { 
                  before: recentGame.blackRatingBefore, 
                  after: recentGame.blackRatingAfter,
                  delta: (recentGame.blackRatingAfter || 0) - (recentGame.blackRatingBefore || 0)
                }
              } : null
            });
          }
        }
      } catch (e) {
        logger.error(`Error fetching recent game on reconnect: ${e.message}`);
      }
      return;
    }

    const room = await redisService.getJSON(`${REDIS_KEYS.ROOM_PREFIX}${roomId}`);
    if (!room) return;

    // Clear disconnect timer
    await redisService.redisClient.del(`${REDIS_KEYS.DISCONNECT_TIMER_PREFIX}${userId}`);

    socket.join(roomId);

    // Update socket ID for this user in room
    if (room.whitePlayer.userId === userId) {
      room.whitePlayer.socketId = socket.id;
    } else if (room.blackPlayer.userId === userId) {
      room.blackPlayer.socketId = socket.id;
    }
    await redisService.setJSON(`${REDIS_KEYS.ROOM_PREFIX}${roomId}`, room);

    // Send full current game state to reconnecting player
    socket.emit(SOCKET_EVENTS.GAME_STATE, {
      roomId,
      fen: room.fen,
      moves: room.moves,
      whiteTime: room.whiteTime,
      blackTime: room.blackTime,
      increment: room.increment,
      timeControl: room.timeControl,
      turn: room.turn,
      whitePlayer: room.whitePlayer,
      blackPlayer: room.blackPlayer,
      status: room.status,
      contestType: room.contestType,
      entryFee: room.entryFee,
    });

    // Notify opponent
    socket.to(roomId).emit(SOCKET_EVENTS.OPPONENT_RECONNECTED, { userId });
    logger.info(`Player ${userId} reconnected to room ${roomId}`);
  }

  // ─── Internal: End Game ─────────────────────────────────────────────────────
  async _endGame(room, winner, reason, io) {
    const { Chess } = require('chess.js');
    if (reason === 'timeout') {
      const chess = new Chess(room.fen);
      const winningColor = winner === 'white' ? 'w' : 'b';
      
      const board = chess.board();
      let pieces = [];
      for (let row of board) {
        for (let square of row) {
          if (square && square.color === winningColor) {
            pieces.push(square.type);
          }
        }
      }
      
      pieces = pieces.filter(p => p !== 'k');
      const hasInsufficientMaterial = pieces.length === 0 || 
                                      (pieces.length === 1 && (pieces[0] === 'n' || pieces[0] === 'b'));
                                      
      if (hasInsufficientMaterial) {
        winner = 'draw';
        reason = 'timeout_insufficient_material';
      }
    }

    const roomKey = `${REDIS_KEYS.ROOM_PREFIX}${room.roomId}`;
    room.status = 'completed';
    room.endedAt = Date.now();
    await redisService.setJSON(roomKey, room);

    // Compute ELO changes if rated
    let eloChanges = null;
    if (room.isRated) {
      eloChanges = await this._applyElo(room, winner);
    }

    // Distribute prize if paid contest
    if (room.entryFee > 0) {
      await this._distributePrize(room, winner);
    }

    let tournamentDetails = null;
    if (room.contestType === 'tournament' && room.tournamentId) {
      const Tournament = require('../../models/Tournament');
      const tourney = await Tournament.findById(room.tournamentId);
      if (tourney) {
        tournamentDetails = {
          currentRound: tourney.currentRound,
          totalRounds: tourney.totalRounds
        };
      }
    }

    io.to(room.roomId).emit(SOCKET_EVENTS.GAME_OVER, {
      winner,
      reason,
      contestType: room.contestType,
      tournamentId: room.tournamentId,
      tournamentDetails,
      eloChanges,
      whitePlayer: room.whitePlayer,
      blackPlayer: room.blackPlayer,
    });

    // Clean up sessions
    await redisService.redisClient.del(`${REDIS_KEYS.USER_SESSION_PREFIX}${room.whitePlayer.userId}`);
    await redisService.redisClient.del(`${REDIS_KEYS.USER_SESSION_PREFIX}${room.blackPlayer.userId}`);

    // Save to MongoDB
    this._saveToMongo(room, winner, reason, eloChanges);
  }

  // ─── ELO Calculation ────────────────────────────────────────────────────────
  async _applyElo(room, winner) {
    const User = require('../../models/User');
    try {
      const whiteUser = await User.findOne({ userId: room.whitePlayer.userId });
      const blackUser = await User.findOne({ userId: room.blackPlayer.userId });
      if (!whiteUser || !blackUser) return null;

      const isClassic = room.timeControl?.startsWith('classic');
      const ratingField = isClassic ? 'classicRating' : 'rapidRating';

      const Ra = whiteUser[ratingField];
      const Rb = blackUser[ratingField];

      // K-factor
      const kFactor = (r) => r < 2100 ? 32 : r < 2400 ? 24 : 16;
      const Ka = kFactor(Ra);
      const Kb = kFactor(Rb);

      // Expected scores
      const Ea = 1 / (1 + Math.pow(10, (Rb - Ra) / 400));
      const Eb = 1 - Ea;

      // Actual scores
      let Sa, Sb;
      if (winner === 'white')     { Sa = 1; Sb = 0; }
      else if (winner === 'black') { Sa = 0; Sb = 1; }
      else                         { Sa = 0.5; Sb = 0.5; } // draw

      const newRa = Math.round(Ra + Ka * (Sa - Ea));
      const newRb = Math.round(Rb + Kb * (Sb - Eb));
      const deltaA = newRa - Ra;
      const deltaB = newRb - Rb;

      // Update users
      await User.updateOne({ userId: room.whitePlayer.userId }, {
        $set: { [ratingField]: newRa, rating: newRa },
        $push: { ratingHistory: { rating: newRa } },
        $inc: { 
          totalGames: 1,
          ...(winner === 'white' ? { wins: 1 } : winner === 'black' ? { losses: 1 } : { draws: 1 })
        }
      });
      await User.updateOne({ userId: room.blackPlayer.userId }, {
        $set: { [ratingField]: newRb, rating: newRb },
        $push: { ratingHistory: { rating: newRb } },
        $inc: { 
          totalGames: 1,
          ...(winner === 'black' ? { wins: 1 } : winner === 'white' ? { losses: 1 } : { draws: 1 })
        }
      });

      return {
        white: { before: Ra, after: newRa, delta: deltaA },
        black: { before: Rb, after: newRb, delta: deltaB },
      };
    } catch (err) {
      logger.error(`ELO update error: ${err.message}`);
      return null;
    }
  }

  // ─── Prize Distribution ──────────────────────────────────────────────────────
  async _distributePrize(room, winner) {
    if (room.prizePool <= 0) return;
    try {
      const User = require('../../models/User');
      const Transaction = require('../../models/Transaction');
      const platformFeePercent = parseFloat(process.env.PLATFORM_FEE_PERCENT || '10') / 100;
      const prize = Math.floor(room.prizePool * (1 - platformFeePercent));

      let winnerId = null;
      if (winner === 'white') winnerId = room.whitePlayer.userId;
      else if (winner === 'black') winnerId = room.blackPlayer.userId;

      if (winnerId) {
        await User.updateOne({ userId: winnerId }, { $inc: { winningsBalance: prize } });
        await Transaction.create({
          transactionId: uuidv4(),
          userId: winnerId,
          type: 'prize',
          amount: prize,
          balanceType: 'winnings',
          status: 'completed',
          gameId: room.roomId,
          description: `Prize for winning game ${room.roomId}`,
        });
        logger.info(`Prize ₹${prize} credited to ${winnerId}`);
      } else if (winner === 'draw') {
        // Split equally
        const half = Math.floor(prize / 2);
        for (const uid of [room.whitePlayer.userId, room.blackPlayer.userId]) {
          await User.updateOne({ userId: uid }, { $inc: { winningsBalance: half } });
          await Transaction.create({
            transactionId: uuidv4(),
            userId: uid,
            type: 'prize',
            amount: half,
            balanceType: 'winnings',
            status: 'completed',
            gameId: room.roomId,
            description: `Draw prize split for game ${room.roomId}`,
          });
        }
      }
    } catch (err) {
      logger.error(`Prize distribution error: ${err.message}`);
    }
  }

  // ─── Save to MongoDB ─────────────────────────────────────────────────────────
  async _saveToMongo(room, winner, reason, eloChanges) {
    const Game = require('../../models/Game');
    const User = require('../../models/User');
    try {
      const whiteUser = await User.findOne({ userId: room.whitePlayer.userId });
      const blackUser = await User.findOne({ userId: room.blackPlayer.userId });

      // Use updateOne with upsert to avoid duplicate key errors if the game shell was already created (e.g. by TournamentEngine)
      await Game.updateOne({ gameId: room.roomId }, {
        $set: {
          whitePlayer: whiteUser?._id,
          blackPlayer: blackUser?._id,
          moves: room.moves,
          status: 'completed',
          winner,
          reason,
          timeControl: room.timeControl,
          baseTime: TIME_CONTROLS[room.timeControl]?.base,
          increment: room.increment,
          contestType: room.contestType,
          isRated: room.isRated,
          entryFee: room.entryFee,
          prizePool: room.prizePool,
          tournamentId: room.tournamentId,
          whiteRatingBefore: eloChanges?.white?.before || null,
        blackRatingBefore: eloChanges?.black?.before || null,
        whiteRatingAfter: eloChanges?.white?.after || null,
        blackRatingAfter: eloChanges?.black?.after || null,
        startedAt: new Date(room.startedAt),
        endedAt: new Date(room.endedAt || Date.now()),
        // Anti-cheat: avg move time
        whiteAvgMoveTime: this._calcAvgMoveTime(room.moves, 'white', room),
        blackAvgMoveTime: this._calcAvgMoveTime(room.moves, 'black', room),
        }
      }, { upsert: true });
      logger.info(`Game ${room.roomId} saved to MongoDB`);

      if (room.contestType === 'tournament' && room.tournamentId) {
        // Find the winner's user document to pass the exact userId to the tournament engine
        let winnerUserId = null;
        if (winner === 'white') winnerUserId = room.whitePlayer?.userId;
        if (winner === 'black') winnerUserId = room.blackPlayer?.userId;
        if (winner === 'draw') {
          // If draw, we can randomize or use a tiebreaker. Simple random for now.
          winnerUserId = Math.random() > 0.5 ? room.whitePlayer?.userId : room.blackPlayer?.userId;
        }

        const TournamentEngine = require('../../services/tournamentEngine');
        // We will call a new function to record the match result before checking round completion
        await TournamentEngine.recordMatchResult(room.tournamentId, room.roomId, winnerUserId);
      }
    } catch (err) {
      logger.error(`Failed to save game ${room.roomId}: ${err.message}`);
    }
  }

  _calcAvgMoveTime(moves, color, room) {
    const colorMoves = moves.filter((_, i) =>
      color === 'white' ? i % 2 === 0 : i % 2 === 1
    );
    if (!colorMoves.length) return null;
    const total = colorMoves.reduce((sum, m) => sum + (m.moveTime || 0), 0);
    return Math.round(total / colorMoves.length);
  }
}

module.exports = new GameService();
