const mongoose = require('mongoose');

const gameModeSchema = new mongoose.Schema({
  modeId: { type: String, required: true, unique: true }, // e.g., 'free_rapid_10'
  label: { type: String, required: true }, // e.g., 'Rapid 10+0'
  timeControl: { type: String, required: true }, // e.g., 'rapid_10'
  entryFee: { type: Number, required: true, default: 0 },
  prize: { type: Number, required: true, default: 0 },
  isRated: { type: Boolean, required: true, default: false },
  tag: { type: String }, // e.g., 'Free', 'Rated', '₹10'
  isActive: { type: Boolean, default: true },
  order: { type: Number, default: 0 },
}, { timestamps: true });

// Transform for frontend
gameModeSchema.methods.toJSON = function () {
  const mode = this.toObject();
  mode.id = mode.modeId;
  delete mode._id;
  delete mode.__v;
  delete mode.modeId;
  delete mode.isActive;
  delete mode.order;
  delete mode.createdAt;
  delete mode.updatedAt;
  return mode;
};

module.exports = mongoose.model('GameMode', gameModeSchema);
