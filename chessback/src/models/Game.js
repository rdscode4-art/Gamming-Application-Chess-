const mongoose = require('mongoose');

const GameSchema = new mongoose.Schema({
  gameId: {
    type: String,
    required: true,
    unique: true
  },
  whitePlayer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  blackPlayer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  moves: [{
    from: String,
    to: String,
    san: String,        // Standard Algebraic Notation e.g. "e4", "Nf3"
    fen: String,        // Board state after this move
    moveTime: Number,   // ms taken to make the move (anti-cheat)
    timestamp: {
      type: Date,
      default: Date.now
    }
  }],

  // --- Time Control ---
  timeControl: {
    type: String,
    enum: ['rapid_3', 'rapid_5', 'rapid_10', 'classic_15', 'classic_30', 'classic_60', 'custom'],
    default: 'rapid_10'
  },
  baseTime: { type: Number, default: 600 },    // seconds
  increment: { type: Number, default: 0 },      // seconds per move

  // --- Contest / Mode ---
  contestType: {
    type: String,
    enum: ['casual', 'rated', 'paid', 'tournament'],
    default: 'casual'
  },
  isRated: { type: Boolean, default: false },
  entryFee: { type: Number, default: 0 },
  prizePool: { type: Number, default: 0 },
  platformFee: { type: Number, default: 0 },
  contestId: { type: String, default: null },       // if part of a contest
  tournamentId: { type: String, default: null },    // if part of a tournament

  // --- Status & Result ---
  status: {
    type: String,
    enum: ['waiting', 'active', 'completed', 'abandoned'],
    default: 'waiting'
  },
  winner: {
    type: String, // 'white', 'black', 'draw', null
    default: null
  },
  reason: {
    type: String, // 'checkmate', 'resign', 'timeout', 'disconnect', 'draw', 'stalemate', 'repetition', '50move'
    default: null
  },

  // --- ELO changes (Phase 5) ---
  whiteRatingBefore: { type: Number, default: null },
  blackRatingBefore: { type: Number, default: null },
  whiteRatingAfter: { type: Number, default: null },
  blackRatingAfter: { type: Number, default: null },

  // --- Anti-Cheat (Phase 11) ---
  whiteAvgMoveTime: { type: Number, default: null },  // ms
  blackAvgMoveTime: { type: Number, default: null },  // ms
  isFlagged: { type: Boolean, default: false },
  flagReason: { type: String, default: null },

  // --- Timestamps ---
  startedAt: { type: Date, default: Date.now },
  endedAt: { type: Date }

}, { timestamps: true });

// --- Indexes ---
GameSchema.index({ whitePlayer: 1, status: 1 });
GameSchema.index({ blackPlayer: 1, status: 1 });
GameSchema.index({ status: 1 });
GameSchema.index({ createdAt: -1 });
GameSchema.index({ contestType: 1 });

module.exports = mongoose.model('Game', GameSchema);
