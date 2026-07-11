const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const UserSchema = new mongoose.Schema({
  // --- Core Identity ---
  userId: {
    type: String,
    required: true,
    unique: true,
  },
  playerId: {
    type: String,
    unique: true,
    sparse: true, // e.g. "#CHESS4829"
  },
  fullName: {
    type: String,
    trim: true,
    default: '',
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 20
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true,
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true,
    trim: true,
  },
  passwordHash: {
    type: String,
    select: false, // never returned in queries by default
  },
  isGuest: {
    type: Boolean,
    default: false
  },
  avatarUrl: {
    type: String,
    default: null,
  },
  isProfileComplete: {
    type: Boolean,
    default: false,
  },

  // --- Ratings (Phase 5) ---
  rating: {        // Classic ELO (kept for backwards compat)
    type: Number,
    default: 1200
  },
  classicRating: {
    type: Number,
    default: 1200
  },
  rapidRating: {
    type: Number,
    default: 1200
  },
  ratingHistory: [{
    rating: Number,
    date: { type: Date, default: Date.now }
  }],

  // --- Stats ---
  wins: { type: Number, default: 0 },
  losses: { type: Number, default: 0 },
  draws: { type: Number, default: 0 },
  totalGames: { type: Number, default: 0 },

  // --- Wallet (Phase 4) ---
  depositBalance: { type: Number, default: 0 },
  winningsBalance: { type: Number, default: 0 },
  bonusBalance: { type: Number, default: 0 },

  // --- Referral (Phase 4) ---
  referralCode: { type: String, unique: true, sparse: true },
  referredBy: { type: String, default: null },
  referralCount: { type: Number, default: 0 },

  // --- KYC (Phase 11) ---
  isKycVerified: { type: Boolean, default: false },
  kycData: {
    panNumber: { type: String, select: false },
    aadhaarLast4: { type: String, select: false },
    panImageUrl: { type: String, select: false },
    aadhaarImageUrl: { type: String, select: false },
    verifiedAt: Date,
  },

  // --- Security / Admin ---
  isBanned: { type: Boolean, default: false },
  banReason: { type: String, default: null },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  suspiciousActivityScore: { type: Number, default: 0 },
  fcmTokens: [{ type: String }], // multiple device tokens (Phase 7)

  // --- Social (Phase 8) ---
  friends: [{ type: String }], // array of userIds

  // --- Auth tokens ---
  refreshToken: { type: String, select: false },
  passwordResetOtp: { type: String, select: false },
  passwordResetExpires: { type: Date, select: false },
  preferences: {
    gameSounds: { type: Boolean, default: true },
    moveVibration: { type: Boolean, default: true },
    autoQueenPromotion: { type: Boolean, default: true },
    enablePreMoves: { type: Boolean, default: false },
    inGameChat: { type: Boolean, default: true }
  }

}, { timestamps: true });

// --- Indexes ---
UserSchema.index({ rating: -1 });
UserSchema.index({ classicRating: -1 });
UserSchema.index({ rapidRating: -1 });

// --- Virtual: total balance ---
UserSchema.virtual('totalBalance').get(function () {
  return this.depositBalance + this.winningsBalance + this.bonusBalance;
});

// --- Method: verify password ---
UserSchema.methods.verifyPassword = async function (password) {
  return bcrypt.compare(password, this.passwordHash);
};

// --- Pre-save: generate playerId if missing ---
UserSchema.pre('save', function (next) {
  if (!this.playerId) {
    const suffix = Math.floor(1000 + Math.random() * 9000);
    this.playerId = `#CHESS${suffix}`;
  }
  next();
});

module.exports = mongoose.model('User', UserSchema);
