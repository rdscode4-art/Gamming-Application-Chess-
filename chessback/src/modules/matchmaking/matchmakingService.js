const redisService = require('../../services/redisService');
const { REDIS_KEYS, SOCKET_EVENTS, TIME_CONTROLS } = require('../../utils/constants');
const { v4: uuidv4 } = require('uuid');
const logger = require('../../config/logger');
const gameService = require('../game/gameService');

// Queue key format: chess:queue:{timeControl}:{entryFee}:{isRated}
// e.g. chess:queue:rapid_10:0:rated  OR  chess:queue:rapid_10:50:casual
const buildQueueKey = (timeControl, entryFee = 0, isRated = false) =>
  `${REDIS_KEYS.MATCHMAKING_QUEUE}:${timeControl}:${entryFee}:${isRated ? 'rated' : 'casual'}`;

// ELO range expands every 30s the player is waiting
const getEloRange = (waitTimeSeconds) => {
  if (waitTimeSeconds < 30) return 200;
  if (waitTimeSeconds < 60) return 400;
  return Infinity; // after 60s, match anyone
};

class MatchmakingService {

  // ── Join Queue ──────────────────────────────────────────────────────────────
  async joinQueue(user, socketId, options, io) {
    const {
      timeControl = 'rapid_10',
      entryFee = 0,
      isRated = true,
      contestType = 'casual',
    } = options;

    if (!TIME_CONTROLS[timeControl]) {
      logger.warn(`Invalid timeControl: ${timeControl}`);
      return;
    }

    // Check if user already has active game
    const existingRoom = await redisService.getJSON(`${REDIS_KEYS.USER_SESSION_PREFIX}${user.userId}`);
    if (existingRoom) {
      logger.warn(`User ${user.userId} tried to join queue but already in game ${existingRoom}`);
      return;
    }

    const playerObj = {
      userId: user.userId,
      username: user.username,
      rating: user.rating || 1200,
      classicRating: user.classicRating || 1200,
      rapidRating: user.rapidRating || 1200,
      avatarUrl: user.avatarUrl || null,
      socketId,
      joinedAt: Date.now(),
      timeControl,
      entryFee,
      isRated,
      contestType,
    };

    const queueKey = buildQueueKey(timeControl, entryFee, isRated);
    await redisService.pushToQueue(queueKey, playerObj);

    logger.info(`[DEBUG] ${user.username} (ID: ${user.userId}) joined queue: ${queueKey} with rating: ${user.rating}`);
    await this.processQueue(queueKey, io);
  }

  // ── Leave Queue ─────────────────────────────────────────────────────────────
  async leaveQueue(userId, options = {}) {
    const { timeControl = 'rapid_10', entryFee = 0, isRated = true } = options;
    const queueKey = buildQueueKey(timeControl, entryFee, isRated);
    await redisService.removeFromQueue(queueKey, userId);
    logger.info(`User ${userId} left queue: ${queueKey}`);
  }

  async leaveAllQueues(userId) {
    const allQueues = await redisService.getAllQueueNames();
    for (const qName of allQueues) {
      await redisService.removeFromQueue(qName, userId);
    }
  }

  // ── Process Queue (ELO-based matching) ──────────────────────────────────────
  async processQueue(queueKey, io) {
    const lockKey = `lock:${queueKey}`;
    if (!await redisService.acquireLock(lockKey, 3)) return;

    try {
      const len = await redisService.getQueueLength(queueKey);
      if (len < 2) return;

      // Peek at all players in queue to find a good match
      const queue = await this._peekQueue(queueKey);
      if (!queue || queue.length < 2) return;

      // Try to find ANY pair of different users
      let matchedP1 = null;
      let matchedP2 = null;

      for (let i = 0; i < queue.length; i++) {
        for (let j = i + 1; j < queue.length; j++) {
          if (queue[i].userId !== queue[j].userId) {
            matchedP1 = queue[i];
            matchedP2 = queue[j];
            break;
          }
        }
        if (matchedP1) break;
      }

      if (!matchedP1 || !matchedP2) {
        logger.debug(`No ELO match found in queue ${queueKey} (${queue.length} waiting)`);
        return;
      }

      // Remove both matched players from queue
      await redisService.removeFromQueue(queueKey, matchedP1.userId);
      await redisService.removeFromQueue(queueKey, matchedP2.userId);

      // Randomly assign colors
      const [white, black] = Math.random() < 0.5
        ? [matchedP1, matchedP2]
        : [matchedP2, matchedP1];

      const roomId = uuidv4();
      const tc = matchedP1.timeControl;
      const tcConfig = TIME_CONTROLS[tc] || TIME_CONTROLS.rapid_10;

      await gameService.createGame(roomId, white, black, io, {
        timeControl: tc,
        entryFee: matchedP1.entryFee,
        prizePool: matchedP1.entryFee * 2 * (1 - parseFloat(process.env.PLATFORM_FEE_PERCENT || '10') / 100),
        isRated: matchedP1.isRated,
        contestType: matchedP1.contestType,
      });

      logger.info(`Matched: ${white.username} vs ${black.username} | ${tc} | ELO diff: ${Math.abs(white.rating - black.rating)}`);

      // Check if more pairs remain
      setTimeout(() => this.processQueue(queueKey, io), 0);

    } catch (err) {
      logger.error(`Matchmaking error in ${queueKey}: ${err.message}`);
    } finally {
      await redisService.releaseLock(lockKey);
    }
  }

  // ── Peek Queue (non-destructive read) ───────────────────────────────────────
  async _peekQueue(queueKey) {
    // Since our in-memory queue is a plain array we can access it directly
    return redisService.queues.get(queueKey) || [];
  }

  // ── Periodic re-scan (every 15s, to re-evaluate waiting players with expanded ELO range) ──
  startPeriodicScan(io) {
    setInterval(async () => {
      try {
        const allQueues = await redisService.getAllQueueNames();
        for (const qName of allQueues) {
          if (qName.startsWith(REDIS_KEYS.MATCHMAKING_QUEUE)) {
            await this.processQueue(qName, io);
          }
        }
      } catch (err) {
        logger.error(`Periodic queue scan error: ${err.message}`);
      }
    }, 15000); // every 15 seconds
  }

  // ── Get Queue Status ─────────────────────────────────────────────────────────
  async getQueueStatus(timeControl, entryFee, isRated) {
    const queueKey = buildQueueKey(timeControl, entryFee, isRated);
    const len = await redisService.getQueueLength(queueKey);
    return { queueKey, playersWaiting: len };
  }
}

module.exports = new MatchmakingService();
