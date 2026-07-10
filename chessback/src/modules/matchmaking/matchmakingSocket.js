const matchmakingService = require('./matchmakingService');
const { SOCKET_EVENTS } = require('../../utils/constants');
const logger = require('../../config/logger');
const User = require('../../models/User');

const registerMatchmakingHandlers = (io, socket) => {

  // ── Join Queue ──────────────────────────────────────────────────────────────
  socket.on(SOCKET_EVENTS.JOIN_QUEUE, async (data = {}) => {
    const options = {
      timeControl: data.timeControl || 'rapid_10',
      entryFee: data.entryFee || 0,
      isRated: data.isRated !== undefined ? data.isRated : false,
      contestType: data.contestType || 'casual',
    };

    const userDoc = await User.findOne({ userId: socket.user.userId });
    if (!userDoc) {
      socket.emit('ERROR', { message: 'User not found.' });
      return;
    }

    if (options.entryFee > 0) {
      const totalBalance = (userDoc.depositBalance || 0) + (userDoc.winningsBalance || 0) + (userDoc.bonusBalance || 0);
      if (totalBalance < options.entryFee) {
        socket.emit('ERROR', { message: 'Insufficient balance to join this paid match.' });
        return;
      }
    }

    logger.info(`${socket.user.username} joining queue | ${options.timeControl} | fee:${options.entryFee} | rated:${options.isRated}`);

    socket.emit(SOCKET_EVENTS.QUEUE_JOINED, {
      message: 'Joined queue successfully',
      timeControl: options.timeControl,
      entryFee: options.entryFee,
      isRated: options.isRated,
    });

    const freshUser = {
      userId: userDoc.userId,
      username: userDoc.username,
      rating: userDoc.rating || 1200,
      avatarUrl: userDoc.avatarUrl
    };

    await matchmakingService.joinQueue(freshUser, socket.id, options, io);
  });

  // ── Leave Queue ─────────────────────────────────────────────────────────────
  socket.on(SOCKET_EVENTS.LEAVE_QUEUE, async (data = {}) => {
    logger.info(`${socket.user.username} leaving queue`);
    await matchmakingService.leaveAllQueues(socket.user.userId);
  });
};

module.exports = registerMatchmakingHandlers;
