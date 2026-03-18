const mongoose = require('mongoose');

const UserTokenSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  fcmToken: {
    type: String,
    required: true
  },
  platform: {
    type: String,
    enum: ['ios', 'android', 'web'],
    default: 'android'
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('UserToken', UserTokenSchema);
