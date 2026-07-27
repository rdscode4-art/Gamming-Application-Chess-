const { Server } = require('socket.io');
const logger = require('../config/logger');
const { verifySocketToken } = require('../middleware/authMiddleware');

// Import socket handlers
const registerMatchmakingHandlers = require('../modules/matchmaking/matchmakingSocket');
const registerGameHandlers = require('../modules/game/gameSocket');
const matchmakingService = require('../modules/matchmaking/matchmakingService');
const gameService = require('../modules/game/gameService');

let ioInstance;

const initSocket = (server) => {
  const io = new Server(server, {
    cors: {
      origin: true, // Allow all origins
      methods: ['GET', 'POST'],
      credentials: true,
    },
    // Allow both polling and websocket — Apache config handles upgrade
    transports: ['polling', 'websocket'],
    pingTimeout: 30000,
    pingInterval: 10000,
  });

  // ── Auth Middleware ───────────────────────────────────────────────────────────
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      const decoded = verifySocketToken(token); // throws if invalid
      socket.user = decoded; // { userId, username, role }
      next();
    } catch (err) {
      next(new Error(`Auth error: ${err.message}`));
    }
  });

  // ── Connection ────────────────────────────────────────────────────────────────
  io.on('connection', (socket) => {
    logger.info(`🔌 Connected: ${socket.user.username} (${socket.id})`);
    
    // Join a room with their userId for targeted push events
    socket.join(socket.user.userId);

    // Socket Event Rate Limiting
    const rateLimit = { count: 0, lastReset: Date.now() };
    socket.use((event, next) => {
      const now = Date.now();
      if (now - rateLimit.lastReset > 1000) {
        rateLimit.count = 0;
        rateLimit.lastReset = now;
      }
      rateLimit.count++;
      
      if (rateLimit.count > 20) {
        logger.warn(`Rate limit exceeded for user ${socket.user.username} on event ${event[0]}`);
        return next(new Error('Rate limit exceeded. Too many events.'));
      }
      next();
    });

    registerMatchmakingHandlers(io, socket);
    registerGameHandlers(io, socket);

    // Auto-rejoin if player was in a game
    gameService.handleReconnect(socket.user.userId, socket, io)
      .catch(err => logger.error(`Auto-rejoin error: ${err.message}`));

    // ── Disconnect ──────────────────────────────────────────────────────────────
    socket.on('disconnect', async (reason) => {
      logger.info(`🔌 Disconnected: ${socket.user.username} | reason: ${reason}`);

      // Leave all matchmaking queues
      await matchmakingService.leaveAllQueues(socket.user.userId)
        .catch(() => {});

      // Trigger game forfeit timer if in active game
      await gameService.handleDisconnect(socket.user.userId, io)
        .catch(err => logger.error(`Disconnect handler error: ${err.message}`));
    });
  });

  // ── Start Periodic Queue Scan ─────────────────────────────────────────────────
  matchmakingService.startPeriodicScan(io);

  ioInstance = io;
  return io;
};

const getIo = () => ioInstance;

module.exports = { initSocket, getIo };
