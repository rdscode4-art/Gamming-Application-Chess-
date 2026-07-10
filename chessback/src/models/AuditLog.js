const mongoose = require('mongoose');

const AuditLogSchema = new mongoose.Schema({
  action: { type: String, required: true },  // e.g. 'USER_BANNED', 'WITHDRAWAL_APPROVED'
  performedBy: { type: String, required: true }, // admin userId
  targetUserId: { type: String, default: null },
  targetResourceType: { type: String, default: null }, // 'user', 'transaction', 'tournament', etc
  targetResourceId: { type: String, default: null },
  details: { type: mongoose.Schema.Types.Mixed, default: {} },
  ipAddress: { type: String, default: null },
}, { timestamps: true });

AuditLogSchema.index({ performedBy: 1, createdAt: -1 });
AuditLogSchema.index({ targetUserId: 1 });
AuditLogSchema.index({ action: 1 });

module.exports = mongoose.model('AuditLog', AuditLogSchema);
