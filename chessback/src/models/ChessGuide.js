const mongoose = require('mongoose');

const ChessGuideSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  content: {
    type: String,
    required: true,
  },
  mediaType: {
    type: String,
    enum: ['none', 'image', 'video', 'youtube'],
    default: 'none',
  },
  mediaUrl: {
    type: String,
    default: null,
  },
  order: {
    type: Number,
    default: 0,
  }
}, { timestamps: true });

module.exports = mongoose.model('ChessGuide', ChessGuideSchema);
