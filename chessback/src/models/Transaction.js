const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  transactionId: { type: String, required: true, unique: true },
  userId: { type: String, required: true },
  type: {
    type: String,
    enum: ['deposit', 'withdrawal', 'prize', 'entry_fee', 'refund', 'bonus', 'referral_bonus'],
    required: true
  },
  amount: { type: Number, required: true },
  balanceType: {
    type: String,
    enum: ['deposit', 'winnings', 'bonus', 'mixed'],
    default: 'deposit'
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'pending'
  },
  razorpayOrderId: { type: String, default: null },
  razorpayPaymentId: { type: String, default: null },
  description: { type: String, default: '' },
  gameId: { type: String, default: null },
  contestId: { type: String, default: null },
}, { timestamps: true });

TransactionSchema.index({ userId: 1, createdAt: -1 });
TransactionSchema.index({ razorpayPaymentId: 1 });

module.exports = mongoose.model('Transaction', TransactionSchema);
