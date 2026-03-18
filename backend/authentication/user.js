/**
 * AVA Insurance - User Model
 * Handles user authentication and profile data
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const UserSchema = new mongoose.Schema({
  // Basic Information
  firstName: {
    type: String,
    required: [true, 'Please provide first name'],
    trim: true,
    maxlength: [50, 'First name cannot exceed 50 characters']
  },
  
  lastName: {
    type: String,
    required: [true, 'Please provide last name'],
    trim: true,
    maxlength: [50, 'Last name cannot exceed 50 characters']
  },
  
  email: {
    type: String,
    required: [true, 'Please provide email'],
    unique: true,
    lowercase: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please provide a valid email'
    ]
  },
  
  password: {
    type: String,
    required: [true, 'Please provide password'],
    minlength: [8, 'Password must be at least 8 characters'],
    select: false
  },
  
  phone: {
    type: String,
    required: [true, 'Please provide phone number'],
    match: [/^[0-9]{10}$/, 'Please provide a valid 10-digit phone number']
  },
  
  nic: {
    type: String,
    required: [true, 'Please provide NIC number'],
    unique: true,
    sparse: true,
    match: [/^([0-9]{9}[vVxX]|[0-9]{12})$/, 'Please provide a valid NIC number']
  },
  
  address: {
    street: String,
    city: String,
    zipCode: String
  },
  
  // Profile Picture
  profilePicture: {
    type: String,
    default: null
  },
  
  // Role-based Access Control
  role: {
    type: String,
    enum: ['customer', 'claim_officer', 'assessor', 'admin'],
    default: 'customer'
  },
  
  // Email Verification
  isVerified: {
    type: Boolean,
    default: false
  },
  
  verifyEmailToken: String,
  verifyEmailExpire: Date,
  
  // Password Reset
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  
  // FCM Token for Push Notifications
  fcmToken: {
    type: String,
    select: false
  },
  
  // Vehicles
  vehicles: [{
    make: {
      type: String,
      required: true
    },
    model: {
      type: String,
      required: true
    },
    year: {
      type: Number,
      required: true
    },
    licensePlate: {
      type: String,
      required: true,
      unique: true,
      sparse: true
    },
    vin: String,
    color: String,
    registrationDate: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Insurance Policy Information
  policyNumber: String,
  policyStartDate: Date,
  policyEndDate: Date,
  
  // Account Status
  isActive: {
    type: Boolean,
    default: true
  },
  
  // Notification Preferences
  notificationPreferences: {
    email: {
      type: Boolean,
      default: true
    },
    sms: {
      type: Boolean,
      default: true
    },
    push: {
      type: Boolean,
      default: true
    }
  }
  
}, {
  timestamps: true
});

// ============================================
// MIDDLEWARE
// ============================================

// Hash password before saving
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

// Compare password
UserSchema.methods.comparePassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Generate JWT Access Token
UserSchema.methods.getSignedJwtToken = function() {
  return jwt.sign(
    { id: this._id, role: this.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE }
  );
};

// Alias for authController
UserSchema.methods.generateAuthToken = function() {
  return this.getSignedJwtToken();
};

// Generate Refresh Token
UserSchema.methods.getRefreshToken = function() {
  return jwt.sign(
    { id: this._id, type: 'refresh' },
    process.env.REFRESH_TOKEN_SECRET || process.env.JWT_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRE || '30d' }
  );
};

// Alias for authController
UserSchema.methods.generateRefreshToken = function() {
  return this.getRefreshToken();
};

// Generate Email Verification Token
UserSchema.methods.getVerifyEmailToken = function() {
  const verifyToken = crypto.randomBytes(20).toString('hex');
  
  this.verifyEmailToken = crypto
    .createHash('sha256')
    .update(verifyToken)
    .digest('hex');
  
  this.verifyEmailExpire = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
  
  return verifyToken;
};

// Alias for authController
UserSchema.methods.generateEmailVerificationToken = function() {
  return this.getVerifyEmailToken();
};

// Generate Password Reset Token
UserSchema.methods.getResetPasswordToken = function() {
  const resetToken = crypto.randomBytes(20).toString('hex');
  
  this.resetPasswordToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');
  
  this.resetPasswordExpire = Date.now() + 60 * 60 * 1000; // 1 hour
  
  return resetToken;
};

// Alias for authController
UserSchema.methods.generatePasswordResetToken = function() {
  return this.getResetPasswordToken();
};

// Get public profile (exclude sensitive fields)
UserSchema.methods.getPublicProfile = function() {
  return {
    id: this._id,
    firstName: this.firstName,
    lastName: this.lastName,
    email: this.email,
    phone: this.phone,
    nic: this.nic,
    address: this.address,
    profilePicture: this.profilePicture,
    role: this.role,
    isVerified: this.isVerified,
    vehicles: this.vehicles,
    policyNumber: this.policyNumber,
    policyStartDate: this.policyStartDate,
    policyEndDate: this.policyEndDate,
    createdAt: this.createdAt
  };
};

// ============================================
// STATIC METHODS
// ============================================

// Find user by email and validate password
UserSchema.statics.findByCredentials = async function(email, password) {
  const user = await this.findOne({ email }).select('+password');
  
  if (!user) {
    throw new Error('Invalid email or password');
  }
  
  if (!user.isActive) {
    throw new Error('Your account has been deactivated. Please contact support.');
  }
  
  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    throw new Error('Invalid email or password');
  }
  
  return user;
};

// Find user by password reset token
UserSchema.statics.findByResetToken = async function(token) {
  const hashedToken = crypto
    .createHash('sha256')
    .update(token)
    .digest('hex');
  
  return await this.findOne({
    resetPasswordToken: hashedToken,
    resetPasswordExpire: { $gt: Date.now() }
  });
};

// Find user by email verification token
UserSchema.statics.findByVerificationToken = async function(token) {
  const hashedToken = crypto
    .createHash('sha256')
    .update(token)
    .digest('hex');
  
  return await this.findOne({
    verifyEmailToken: hashedToken,
    verifyEmailExpire: { $gt: Date.now() }
  });
};

module.exports = mongoose.model('User', UserSchema);