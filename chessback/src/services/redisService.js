const logger = require('../config/logger');

/**
 * RedisService — In-memory fallback (for local dev without Redis).
 * In production, swap this for a real ioredis / redis client.
 */
class RedisService {
  constructor() {
    this.store = new Map();
    this.queues = new Map();
    this.locks = new Map(); // key → expiryTimestamp

    // Fake redisClient for compatibility with clockManager & gameService
    this.redisClient = {
      keys: async (pattern) => {
        const regex = new RegExp('^' + pattern.replace(/\*/g, '.*') + '$');
        return Array.from(this.store.keys()).filter(k => regex.test(k));
      },
      set: async (key, value, options = {}) => {
        this.store.set(key, value);
        if (options.EX) {
          setTimeout(() => this.store.delete(key), options.EX * 1000);
        }
        return 'OK';
      },
      get: async (key) => {
        return this.store.get(key) ?? null;
      },
      del: async (key) => {
        this.store.delete(key);
        return 1;
      },
    };
  }

  // ── JSON store ──────────────────────────────────────────────────────────────
  async setJSON(key, value, expireSeconds = null) {
    this.store.set(key, value);
    if (expireSeconds) {
      setTimeout(() => this.store.delete(key), expireSeconds * 1000);
    }
  }

  async getJSON(key) {
    return this.store.get(key) ?? null;
  }

  async del(key) {
    this.store.delete(key);
  }

  // ── Queues (per key, by prefix so each time-control/entryFee has its own queue) ──
  async pushToQueue(queueName, value) {
    if (!this.queues.has(queueName)) {
      this.queues.set(queueName, []);
    }
    this.queues.get(queueName).push(value);
  }

  async popFromQueue(queueName) {
    const q = this.queues.get(queueName);
    if (!q || q.length === 0) return null;
    return q.shift();
  }

  async removeFromQueue(queueName, userId) {
    if (this.queues.has(queueName)) {
      const q = this.queues.get(queueName);
      this.queues.set(queueName, q.filter(v => v.userId !== userId));
    }
  }

  async getQueueLength(queueName) {
    return this.queues.get(queueName)?.length ?? 0;
  }

  async getAllQueueNames() {
    return Array.from(this.queues.keys());
  }

  // ── Locks ────────────────────────────────────────────────────────────────────
  async acquireLock(key, ttlSeconds = 5) {
    const now = Date.now();
    const existing = this.locks.get(key);
    // Allow re-acquire if expired
    if (existing && now < existing) return false;
    this.locks.set(key, now + ttlSeconds * 1000);
    return true;
  }

  async releaseLock(key) {
    this.locks.delete(key);
  }
}

module.exports = new RedisService();
