const Tournament = require('../../models/Tournament');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const SystemSetting = require('../../models/SystemSetting');
const { v4: uuidv4 } = require('uuid');

// POST /api/tournaments
exports.createTournament = async (req, res, next) => {
  try {
    const { name, description, format, timeControl, maxPlayers, entryFee, startTime, isPrivate, customDistribution = [100] } = req.body;

    let depositDeduct = 0, winningsDeduct = 0, bonusDeduct = 0;
    if (entryFee > 0) {
      const user = await User.findOne({ userId: req.user.userId });
      const totalBalance = user.depositBalance + user.winningsBalance + user.bonusBalance;
      
      if (totalBalance < entryFee) {
        return res.status(400).json({ message: 'Insufficient balance to join your own tournament' });
      }

      let feeRemaining = entryFee;
      if (user.depositBalance >= feeRemaining) {
        depositDeduct = feeRemaining;
        feeRemaining = 0;
      } else {
        depositDeduct = user.depositBalance;
        feeRemaining -= depositDeduct;
      }

      if (feeRemaining > 0) {
        if (user.winningsBalance >= feeRemaining) {
          winningsDeduct = feeRemaining;
          feeRemaining = 0;
        } else {
          winningsDeduct = user.winningsBalance;
          feeRemaining -= winningsDeduct;
        }
      }

      if (feeRemaining > 0) {
        bonusDeduct = feeRemaining;
      }
    }

    const commissionSetting = await SystemSetting.findOne({ key: 'user_private_tournament_commission' });
    const commissionPercentage = commissionSetting && commissionSetting.value !== undefined ? Number(commissionSetting.value) : 10;

    const totalCollection = (entryFee || 0) * (maxPlayers || 8);
    const platformFee = Math.floor(totalCollection * (commissionPercentage / 100));
    const prizePool = totalCollection - platformFee;

    let prizeDistribution = [];
    if (prizePool > 0) {
      customDistribution.forEach((percentage, index) => {
        if (percentage > 0) {
          prizeDistribution.push({
            position: index + 1,
            percentage: percentage,
            amount: Math.floor(prizePool * (percentage / 100))
          });
        }
      });
    }

    const tournament = await Tournament.create({
      tournamentId: uuidv4(),
      name,
      description,
      format,
      timeControl,
      maxPlayers,
      entryFee,
      prizePool,
      platformFee,
      commissionPercentage,
      distributionStrategy: 'custom',
      prizeDistribution,
      startTime,
      isPrivate,
      inviteCode: isPrivate ? Math.random().toString(36).substring(2, 8).toUpperCase() : undefined,
      createdBy: req.user.userId,
      registeredPlayers: [req.user.userId],
      status: 'registration'
    });

    if (entryFee > 0) {
      await User.updateOne(
        { userId: req.user.userId },
        { 
          $inc: { 
            depositBalance: -depositDeduct,
            winningsBalance: -winningsDeduct,
            bonusBalance: -bonusDeduct
          } 
        }
      );
      await Transaction.create({
        transactionId: uuidv4(),
        userId: req.user.userId,
        type: 'entry_fee',
        amount: entryFee,
        balanceType: 'mixed',
        status: 'completed',
        description: `Entry fee for tournament ${name}`,
      });
    }

    res.status(201).json(tournament);
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments
exports.getTournaments = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const tournaments = await Tournament.find({ 
      $or: [
        { isPrivate: false },
        { createdBy: userId },
        { registeredPlayers: userId }
      ],
      status: { $in: ['draft', 'registration', 'ongoing'] }
    })
      .sort({ startTime: 1 })
      .limit(50);
    res.status(200).json(tournaments);
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments/:id
exports.getTournamentDetails = async (req, res, next) => {
  try {
    const tournament = await Tournament.findOne({ tournamentId: req.params.id });
    if (!tournament) return res.status(404).json({ message: 'Tournament not found' });
    
    const tournamentObj = tournament.toObject();
    tournamentObj.isUserRegistered = tournament.registeredPlayers.includes(req.user.userId);
    tournamentObj.isFull = tournament.registeredPlayers.length >= tournament.maxPlayers;

    // Populate registered players' details
    const playersData = await User.find(
      { userId: { $in: tournament.registeredPlayers } },
      'userId username avatarUrl'
    );
    tournamentObj.registeredPlayersData = playersData;

    res.status(200).json(tournamentObj);
  } catch (error) {
    next(error);
  }
};

// POST /api/tournaments/:id/register
exports.registerForTournament = async (req, res, next) => {
  try {
    const tournament = await Tournament.findOne({ tournamentId: req.params.id });
    if (!tournament) return res.status(404).json({ message: 'Tournament not found' });
    if (tournament.status !== 'registration') return res.status(400).json({ message: 'Registration is closed' });
    
    if (tournament.registeredPlayers.includes(req.user.userId)) {
      return res.status(400).json({ message: 'Already registered' });
    }

    if (tournament.registeredPlayers.length >= tournament.maxPlayers) {
      return res.status(400).json({ message: 'Tournament is full' });
    }

    if (tournament.entryFee > 0) {
      const user = await User.findOne({ userId: req.user.userId });
      const totalBalance = user.depositBalance + user.winningsBalance + user.bonusBalance;
      
      if (totalBalance < tournament.entryFee) {
        return res.status(400).json({ message: 'Insufficient balance' });
      }

      // Deduct fee (simplified atomic logic)
      let feeRemaining = tournament.entryFee;
      let depositDeduct = 0, winningsDeduct = 0, bonusDeduct = 0;

      // 1. Deduct from bonus first (if allowed, usually up to x%)
      // For simplicity, deduct entirely from deposit first, then winnings, then bonus
      if (user.depositBalance >= feeRemaining) {
        depositDeduct = feeRemaining;
        feeRemaining = 0;
      } else {
        depositDeduct = user.depositBalance;
        feeRemaining -= depositDeduct;
      }

      if (feeRemaining > 0) {
        if (user.winningsBalance >= feeRemaining) {
          winningsDeduct = feeRemaining;
          feeRemaining = 0;
        } else {
          winningsDeduct = user.winningsBalance;
          feeRemaining -= winningsDeduct;
        }
      }

      if (feeRemaining > 0) {
        bonusDeduct = feeRemaining;
      }

      await User.updateOne(
        { userId: req.user.userId },
        { 
          $inc: { 
            depositBalance: -depositDeduct,
            winningsBalance: -winningsDeduct,
            bonusBalance: -bonusDeduct
          } 
        }
      );

      await Transaction.create({
        transactionId: uuidv4(),
        userId: req.user.userId,
        type: 'entry_fee',
        amount: tournament.entryFee,
        balanceType: 'mixed',
        status: 'completed',
        description: `Entry fee for tournament ${tournament.name}`,
      });
    }

    tournament.registeredPlayers.push(req.user.userId);
    await tournament.save();

    res.status(200).json({ message: 'Successfully registered', tournament });
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments/match/:gameId
exports.getTournamentMatchInit = async (req, res, next) => {
  try {
    const Game = require('../../models/Game');
    const redisService = require('../../services/redisService');
    const { REDIS_KEYS } = require('../../utils/constants');
    const gameService = require('../game/gameService');

    const game = await Game.findOne({ gameId: req.params.gameId }).populate('whitePlayer blackPlayer');
    if (!game) return res.status(404).json({ message: 'Game not found' });

    // Check if room exists in Redis
    let room = await redisService.getJSON(`${REDIS_KEYS.ROOM_PREFIX}${game.gameId}`);
    
    // If room is not in Redis (because TournamentEngine only created the Mongo doc), create it now
    if (!room) {
      const io = req.app.get('io');
      
      const p1 = {
        userId: game.whitePlayer.userId,
        username: game.whitePlayer.username,
        rating: game.whitePlayer.rating,
        avatarUrl: game.whitePlayer.avatarUrl,
        socketId: null
      };
      
      const p2 = {
        userId: game.blackPlayer.userId,
        username: game.blackPlayer.username,
        rating: game.blackPlayer.rating,
        avatarUrl: game.blackPlayer.avatarUrl,
        socketId: null
      };

      await gameService.createGame(game.gameId, p1, p2, io, {
        timeControl: game.timeControl,
        contestType: game.contestType,
        entryFee: game.entryFee,
        prizePool: game.prizePool,
        isRated: game.isRated
      });
      
      // Add tournamentId so gameService knows it's a tournament game on completion
      room = await redisService.getJSON(`${REDIS_KEYS.ROOM_PREFIX}${game.gameId}`);
      if (room) {
        room.tournamentId = game.tournamentId;
        await redisService.setJSON(`${REDIS_KEYS.ROOM_PREFIX}${game.gameId}`, room);
      }
    }

    // Format data similar to what MATCH_FOUND emits, so frontend GameBloc can init
    const initData = {
      roomId: game.gameId,
      whitePlayer: {
        userId: game.whitePlayer.userId,
        username: game.whitePlayer.username,
        rating: game.whitePlayer.rating,
        avatarUrl: game.whitePlayer.avatarUrl,
      },
      blackPlayer: {
        userId: game.blackPlayer.userId,
        username: game.blackPlayer.username,
        rating: game.blackPlayer.rating,
        avatarUrl: game.blackPlayer.avatarUrl,
      },
      fen: room ? room.fen : 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      turn: room ? room.turn : 'w',
      whiteTime: room ? room.whiteTime : game.baseTime,
      blackTime: room ? room.blackTime : game.baseTime,
      increment: game.increment,
      timeControl: game.timeControl,
      contestType: game.contestType,
      entryFee: game.entryFee,
      prizePool: game.prizePool,
      tournamentId: game.tournamentId
    };

    res.status(200).json(initData);
  } catch (error) {
    next(error);
  }
};

// GET /api/tournaments/my-active-match
exports.getMyActiveTournamentMatch = async (req, res, next) => {
  try {
    const Game = require('../../models/Game');
    const User = require('../../models/User');
    
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ activeMatch: false });

    // Look for a waiting or active tournament match for this user
    const game = await Game.findOne({
      $or: [{ whitePlayer: user._id }, { blackPlayer: user._id }],
      contestType: 'tournament',
      status: { $in: ['waiting', 'active'] }
    });

    if (game) {
      return res.status(200).json({ activeMatch: true, gameId: game.gameId });
    } else {
      return res.status(200).json({ activeMatch: false });
    }
  } catch (error) {
    next(error);
  }
};

// POST /api/tournaments/join-by-code
exports.joinTournamentByCode = async (req, res, next) => {
  try {
    const { inviteCode } = req.body;
    if (!inviteCode) return res.status(400).json({ message: 'Invite code is required' });

    const tournament = await Tournament.findOne({ inviteCode: inviteCode.toUpperCase(), isPrivate: true });
    if (!tournament) return res.status(404).json({ message: 'Invalid invite code or tournament not found' });
    if (tournament.status !== 'registration') return res.status(400).json({ message: 'Registration is closed' });
    
    if (tournament.registeredPlayers.includes(req.user.userId)) {
      return res.status(400).json({ message: 'Already registered' });
    }

    if (tournament.registeredPlayers.length >= tournament.maxPlayers) {
      return res.status(400).json({ message: 'Tournament is full' });
    }

    if (tournament.entryFee > 0) {
      const user = await User.findOne({ userId: req.user.userId });
      const totalBalance = user.depositBalance + user.winningsBalance + user.bonusBalance;
      
      if (totalBalance < tournament.entryFee) {
        return res.status(400).json({ message: 'Insufficient balance' });
      }

      let feeRemaining = tournament.entryFee;
      let depositDeduct = 0, winningsDeduct = 0, bonusDeduct = 0;

      if (user.depositBalance >= feeRemaining) {
        depositDeduct = feeRemaining;
        feeRemaining = 0;
      } else {
        depositDeduct = user.depositBalance;
        feeRemaining -= depositDeduct;
      }

      if (feeRemaining > 0) {
        if (user.winningsBalance >= feeRemaining) {
          winningsDeduct = feeRemaining;
          feeRemaining = 0;
        } else {
          winningsDeduct = user.winningsBalance;
          feeRemaining -= winningsDeduct;
        }
      }

      if (feeRemaining > 0) {
        bonusDeduct = feeRemaining;
      }

      await User.updateOne(
        { userId: req.user.userId },
        { 
          $inc: { 
            depositBalance: -depositDeduct,
            winningsBalance: -winningsDeduct,
            bonusBalance: -bonusDeduct
          } 
        }
      );

      const Transaction = require('../../models/Transaction');
      const { v4: uuidv4 } = require('uuid');
      await Transaction.create({
        transactionId: uuidv4(),
        userId: req.user.userId,
        type: 'entry_fee',
        amount: tournament.entryFee,
        balanceType: 'mixed',
        status: 'completed',
        description: `Entry fee for tournament ${tournament.name}`,
      });
    }

    tournament.registeredPlayers.push(req.user.userId);
    await tournament.save();

    res.status(200).json({ message: 'Successfully registered', tournament });
  } catch (error) {
    next(error);
  }
};
