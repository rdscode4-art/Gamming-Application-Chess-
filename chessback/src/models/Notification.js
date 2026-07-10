const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  type: {
    type: String,
    enum: [
      'match_found', 'game_result', 'tournament_start', 'tournament_reminder',
      'wallet_credit', 'wallet_debit', 'withdrawal_update',
      'badge_unlocked', 'friend_request', 'game_invite', 'system'
    ],
    required: true
  },
  title: { type: String, required: true },
  body: { type: String, required: true },
  data: { type: mongoose.Schema.Types.Mixed, default: {} }, // extra payload for deep link
  isRead: { type: Boolean, default: false },
  readAt: { type: Date, default: null },
}, { timestamps: true });

NotificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', NotificationSchema);
