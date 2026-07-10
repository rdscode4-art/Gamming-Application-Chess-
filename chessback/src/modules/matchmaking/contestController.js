const { v4: uuidv4 } = require('uuid');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const logger = require('../../config/logger');

/**
 * Contest: A matchmade session with optional entry fee.
 * For now contests are matchmaking-based (paid 1v1).
 * Phase 6 (Tournament) will add bracket contests.
 */

// POST /api/contests/quick-join
// Joins a quick-match matchmaking queue with optional fee
exports.quickJoin = async (req, res, next) => {
  try {
    const { timeControl = 'rapid_10', entryFee = 0, isRated = false } = req.body;
    const user = await User.findOne({ userId: req.user.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.isBanned) return res.status(403).json({ message: 'Account banned' });

    // If paid, check and deduct balance
    if (entryFee > 0) {
      const totalBalance = user.depositBalance + user.winningsBalance + user.bonusBalance;
      if (totalBalance < entryFee) {
        return res.status(400).json({
          message: 'Insufficient balance',
          required: entryFee,
          available: totalBalance,
        });
      }

      // Deduct — prioritise deposit, then winnings, then bonus
      let remaining = entryFee;
      if (user.depositBalance >= remaining) {
        user.depositBalance -= remaining;
      } else {
        remaining -= user.depositBalance;
        user.depositBalance = 0;
        if (user.winningsBalance >= remaining) {
          user.winningsBalance -= remaining;
        } else {
          remaining -= user.winningsBalance;
          user.winningsBalance = 0;
          user.bonusBalance -= remaining;
        }
      }
      await user.save();

      // Log transaction
      await Transaction.create({
        transactionId: uuidv4(),
        userId: user.userId,
        type: 'entry_fee',
        amount: entryFee,
        balanceType: 'deposit',
        status: 'completed',
        description: `Entry fee for ${timeControl} match (₹${entryFee})`,
      });
    }

    // Respond so Flutter can now call joinQueue via socket
    res.status(200).json({
      message: 'Balance deducted. Connect via socket and emit join_queue.',
      timeControl,
      entryFee,
      isRated,
      remainingBalance: user.depositBalance + user.winningsBalance + user.bonusBalance,
    });

  } catch (error) {
    next(error);
  }
};

const GameMode = require('../../models/GameMode');

// GET /api/contests/modes
// Returns all available game modes / entry fee options
exports.getGameModes = async (req, res, next) => {
  try {
    const modes = await GameMode.find({ isActive: true }).sort({ order: 1 });
    res.status(200).json({ modes });
  } catch (error) {
    next(error);
  }
};

const redisService = require('../../services/redisService');
const { REDIS_KEYS } = require('../../utils/constants');

// GET /api/contests/live
// Returns live active rooms
exports.getLiveMatches = async (req, res, next) => {
  try {
    const keys = await redisService.redisClient.keys(`${REDIS_KEYS.ROOM_PREFIX}*`);
    const liveMatches = [];

    for (const key of keys) {
      const room = await redisService.getJSON(key);
      if (room && room.status === 'active') {
        liveMatches.push({
          roomId: room.roomId,
          type: room.timeControl,
          p1: room.whitePlayer.username,
          p2: room.blackPlayer.username,
          prize: room.prizePool > 0 ? `₹${room.prizePool}` : '-',
          status: 'LIVE'
        });
      }
    }

    res.status(200).json({ matches: liveMatches });
  } catch (error) {
    next(error);
  }
};
