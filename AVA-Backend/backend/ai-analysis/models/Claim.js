const mongoose = require('mongoose');

const ClaimSchema = new mongoose.Schema({
  photos: [String], // URLs or base64 data for the photos
  analysis: {
    damageType: String,
    affectedArea: String,
    confidenceScore: Number,
    costBreakdown: {
      labour: Number,
      parts: Number,
      other: Number,
    },
  },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Claim', ClaimSchema);