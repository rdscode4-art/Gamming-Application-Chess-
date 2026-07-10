const gameService = require('./gameService');
const { SOCKET_EVENTS } = require('../../utils/constants');
const logger = require('../../config/logger');

const registerGameHandlers = (io, socket) => {

  // ── Make Move ──────────────────────────────────────────────────────────────
  socket.on(SOCKET_EVENTS.MAKE_MOVE, async (data) => {
    // data: { roomId, move: { from, to, promotion? } }
    if (!data?.roomId || !data?.move) return;
    logger.info(`[MAKE_MOVE] Move by ${socket.user.username} in ${data.roomId} | Move: ${JSON.stringify(data.move)}`);
    await gameService.handleMove(data.roomId, socket.user.userId, data.move, io);
  });

  // ── Resign ─────────────────────────────────────────────────────────────────
  socket.on(SOCKET_EVENTS.RESIGN, async (data) => {
    if (!data?.roomId) return;
    logger.info(`${socket.user.username} resigned in ${data.roomId}`);
    await gameService.handleResign(data.roomId, socket.user.userId, io);
  });

  // ── Draw Offer / Accept / Decline ──────────────────────────────────────────
  socket.on(SOCKET_EVENTS.OFFER_DRAW, async (data) => {
    if (!data?.roomId) return;
    await gameService.handleDrawOffer(data.roomId, socket.user.userId, io);
  });

  socket.on(SOCKET_EVENTS.ACCEPT_DRAW, async (data) => {
    if (!data?.roomId) return;
    await gameService.handleAcceptDraw(data.roomId, socket.user.userId, io);
  });

  socket.on(SOCKET_EVENTS.DECLINE_DRAW, async (data) => {
    if (!data?.roomId) return;
    await gameService.handleDeclineDraw(data.roomId, socket.user.userId, io);
  });

  // ── Rejoin Game (after disconnect/app backgrounded) ────────────────────────
  socket.on(SOCKET_EVENTS.REJOIN_GAME, async () => {
    logger.info(`[REJOIN_GAME] ${socket.user.username} rejoining game...`);
    await gameService.handleReconnect(socket.user.userId, socket, io);
  });

  // ── Chat ───────────────────────────────────────────────────────────────────
  socket.on(SOCKET_EVENTS.CHAT_MESSAGE, (data) => {
    if (!data?.roomId || !data?.message) return;
    socket.to(data.roomId).emit(SOCKET_EVENTS.CHAT_MESSAGE, {
      message: data.message,
      byUsername: socket.user.username,
      byUserId: socket.user.userId,
      timestamp: Date.now()
    });
  });

  // ── Internal disconnect (triggered by socket middleware) ───────────────────
  socket.on('internal_disconnect', async () => {
    await gameService.handleDisconnect(socket.user.userId, io);
  });
};

module.exports = registerGameHandlers;
