const mongoose = require('mongoose');

const TournamentSchema = new mongoose.Schema({
  tournamentId: { type: String, required: true, unique: true },
  name: { type: String, required: true, trim: true },
  description: { type: String, default: '' },

  // --- Format ---
  format: {
    type: String,
    enum: ['knockout', 'swiss'],
    default: 'knockout'
  },
  timeControl: {
    type: String,
    enum: ['rapid_3', 'rapid_5', 'rapid_10', 'classic_15', 'classic_30', 'classic_60'],
    default: 'rapid_10'
  },

  // --- Players ---
  maxPlayers: { type: Number, default: 8 }, // 4, 8, 16, 32, 64, custom
  registeredPlayers: [{ type: String }],     // array of userIds
  currentRound: { type: Number, default: 0 },
  totalRounds: { type: Number, default: 0 },

  // --- Money ---
  entryFee: { type: Number, default: 0 },
  prizePool: { type: Number, default: 0 },
  platformFee: { type: Number, default: 0 },
  commissionPercentage: { type: Number, default: 10 },
  distributionStrategy: { type: String, enum: ['winner_takes_all', 'top_2', 'top_3', 'custom'], default: 'winner_takes_all' },
  prizeDistribution: [{
    position: Number,
    percentage: Number,
    amount: Number,
  }],

  // --- Access ---
  isPrivate: { type: Boolean, default: false },
  inviteCode: { type: String, unique: true, sparse: true },
  createdBy: { type: String, required: true }, // userId
  createdByRole: { type: String, enum: ['admin', 'user'], default: 'admin' },

  // --- Scheduling ---
  registrationDeadline: { type: Date },
  startTime: { type: Date },
  endTime: { type: Date },
  reminderSent: { type: Boolean, default: false },

  // --- Status ---
  status: {
    type: String,
    enum: ['draft', 'registration', 'ongoing', 'completed', 'cancelled'],
    default: 'draft'
  },

  // --- Results ---
  winnerId: { type: String, default: null },
  finalStandings: [{
    userId: String,
    position: Number,
    score: Number,
    prize: Number,
  }],

  // --- Rounds & Matches ---
  rounds: [{
    roundNumber: Number,
    status: { type: String, enum: ['pending', 'ongoing', 'completed'], default: 'pending' },
    matches: [{
      matchId: String,
      gameId: String,
      player1: String, // userId
      player2: String, // userId
      winnerId: String,
      status: { type: String, enum: ['pending', 'ongoing', 'completed', 'bye'], default: 'pending' }
    }]
  }],

}, { timestamps: true });

TournamentSchema.index({ status: 1 });
TournamentSchema.index({ startTime: 1 });
TournamentSchema.index({ createdBy: 1 });

module.exports = mongoose.model('Tournament', TournamentSchema);
