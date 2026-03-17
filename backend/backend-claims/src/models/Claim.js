const mongoose = require('mongoose');

const ClaimSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  claimNumber: {
    type: String,
    unique: true,
    required: true
  },

  // Incident Details
  incidentDate: {
    type: Date,
    required: true
  },
  incidentLocation: {
    address: String,
    latitude: Number,
    longitude: Number
  },
  incidentDescription: {
    type: String,
    required: true
  },
  damageType: {
    type: String,
    enum: ['collision', 'vandalism', 'natural', 'theft', 'other'],
    required: true
  },

  // Photos
  photos: [{
    url: String,
    publicId: String,
    uploadedAt: Date
  }],

  // AI Analysis Results
  analysis: {
    damageType: String,
    affectedArea: String,
    damagePercentage: Number,
    confidenceScore: Number,
    detectedDamages: [{
      type: String,
      confidence: Number,
      bbox: [Number]
    }],
    costBreakdown: {
      labour: { type: Number, default: 0 },
      parts: { type: Number, default: 0 },
      paint: { type: Number, default: 0 },
      other: { type: Number, default: 0 },
      total: { type: Number, default: 0 }
    },
    analyzedAt: Date
  },

  // Status Tracking
  status: {
    type: String,
    enum: ['submitted', 'ai_analysis', 'in_review', 'assessment', 'approved', 'rejected', 'payment_processing', 'settled'],
    default: 'submitted'
  },

  // Amounts
  estimatedAmount: Number,
  approvedAmount: Number,

  // Dispute
  dispute: {
    reason: String,
    submittedAt: Date,
    resolved: { type: Boolean, default: false }
  },

  // Timestamps
  submittedAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, {
  timestamps: true
});

// Auto-generate claim number
ClaimSchema.pre('save', async function(next) {
  if (this.isNew && !this.claimNumber) {
    const year = new Date().getFullYear();
    const random = Math.floor(100000 + Math.random() * 900000);
    this.claimNumber = `CLM-${year}-${random}`;
  }
  next();
});

module.exports = mongoose.model('Claim', ClaimSchema);
