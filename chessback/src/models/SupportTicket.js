const mongoose = require('mongoose');

const SupportTicketSchema = new mongoose.Schema({
  ticketId: { type: String, required: true, unique: true },
  userId: { type: String, required: true },
  category: {
    type: String,
    enum: ['general', 'refund', 'cheat_report', 'technical', 'kyc', 'wallet'],
    required: true
  },
  subject: { type: String, required: true, trim: true },
  description: { type: String, required: true },
  attachments: [{ type: String }], // URLs to uploaded screenshots
  status: {
    type: String,
    enum: ['open', 'in_progress', 'resolved', 'closed'],
    default: 'open'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  // Conversation thread
  replies: [{
    authorId: String,
    authorRole: { type: String, enum: ['user', 'admin'], default: 'user' },
    message: String,
    attachments: [String],
    createdAt: { type: Date, default: Date.now }
  }],
  assignedTo: { type: String, default: null }, // admin userId
  resolvedAt: { type: Date, default: null },
  autoCloseAt: { type: Date },  // auto-close after 7 days of inactivity
}, { timestamps: true });

SupportTicketSchema.index({ userId: 1, status: 1 });
SupportTicketSchema.index({ status: 1, priority: 1 });
SupportTicketSchema.index({ autoCloseAt: 1 });

module.exports = mongoose.model('SupportTicket', SupportTicketSchema);
