const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  claimId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Claim'
  },
  type: {
    type: String,
    enum: [
      'claim_submitted',
      'ai_analysis_complete',
      'in_review',
      'assessment_done',
      'approved',
      'rejected',
      'payment_processing',
      'dispute_submitted',
      'general'
    ],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: true
});

// Indexes for faster queries
NotificationSchema.index({ userId: 1, isRead: 1 });
NotificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', NotificationSchema);
