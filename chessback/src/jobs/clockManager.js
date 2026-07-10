const redisService = require('../services/redisService');
const { REDIS_KEYS, SOCKET_EVENTS } = require('../utils/constants');
const logger = require('../config/logger');

/**
 * Clock Manager runs on an interval to tick down the timers of active games.
 * In a real distributed system, you'd want a master node to run this, or run it
 * via Redis Pub/Sub so that only one node ticks a specific room, avoiding double-ticking.
 */
class ClockManager {
  constructor(io) {
    this.io = io;
    this.interval = null;
  }

  start() {
    this.interval = setInterval(() => this.tick(), 1000);
    logger.info('Clock Manager started.');
  }

  stop() {
    if (this.interval) clearInterval(this.interval);
  }

  async tick() {
    // This is a naive implementation that fetches all active rooms.
    // At scale, you would use Redis sets to track active room IDs and process them in batches.
    try {
      const keys = await redisService.redisClient.keys(`${REDIS_KEYS.ROOM_PREFIX}*`);
      
      for (const key of keys) {
        // Lock room for atomic update
        const roomId = key.split(':').pop();
        const lockKey = `lock:room:${roomId}`;
        
        if (await redisService.acquireLock(lockKey, 1)) {
          try {
            const room = await redisService.getJSON(key);
            if (room && room.status === 'active') {
              let updated = false;

              if (room.turn === 'w') {
                room.whiteTime -= 1;
                updated = true;
              } else if (room.turn === 'b') {
                room.blackTime -= 1;
                updated = true;
              }

              if (updated) {
                await redisService.setJSON(key, room);
                
                // Emit time periodically or rely on clients to tick locally and sync every few seconds
                // For exact sync, emit every second (can be heavy at scale)
                this.io.to(roomId).emit(SOCKET_EVENTS.CLOCK_UPDATE, {
                  whiteTime: room.whiteTime,
                  blackTime: room.blackTime
                });

                // Check for timeout loss
                if (room.whiteTime <= 0) {
                  this.handleTimeout(room, 'black');
                } else if (room.blackTime <= 0) {
                  this.handleTimeout(room, 'white');
                }
              }
            }
          } finally {
            await redisService.releaseLock(lockKey);
          }
        }
      }
    } catch (err) {
      logger.error(`Clock tick error: ${err.message}`);
    }
  }

  async handleTimeout(room, winner) {
    // Call game service to properly end game, calculate elo, distribute prize, and save
    const gameService = require('../modules/game/gameService');
    await gameService._endGame(room, winner, 'timeout', this.io);
  }
}

module.exports = ClockManager;
