const mongoose = require('mongoose');

const bannerSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subtitle: { type: String },
  cta: { type: String },
  color: { type: String }, // hex color string
  icon: { type: String }, // flutter icon string/code
  isActive: { type: Boolean, default: true },
  order: { type: Number, default: 0 },
}, { timestamps: true });

bannerSchema.methods.toJSON = function () {
  const banner = this.toObject();
  banner.id = banner._id.toString();
  return banner;
};

module.exports = mongoose.model('Banner', bannerSchema);
