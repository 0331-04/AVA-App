/**
 * AVA Authentication Routes
 * All authentication-related endpoints
 */

const express = require('express');
const router = express.Router();
const {
  register,
  login,
  getMe,
  updateDetails,
  updatePassword,
  forgotPassword,
  resetPassword,
  verifyEmail,
  resendVerification,
  logout,
  refreshToken
} = require('./authController');

const { 
  protect, 
  loginRateLimiter,
  validateRefreshToken
} = require('./auth');

// PUBLIC ROUTES

// Register
router.post('/register', register);

// Login (with rate limiting)
router.post('/login', loginRateLimiter, login);

// Forgot password
router.post('/forgotpassword', forgotPassword);

// Reset password
router.put('/resetpassword/:resettoken', resetPassword);

// Verify email
router.get('/verifyemail/:token', verifyEmail);

// Refresh token
router.post('/refresh', validateRefreshToken, refreshToken);


// PRIVATE ROUTES (require authentication)

// Get current user
router.get('/me', protect, getMe);

// Update user details
router.put('/updatedetails', protect, updateDetails);

// Update password
router.put('/updatepassword', protect, updatePassword);

// Resend verification email
router.post('/resend-verification', protect, resendVerification);

// Logout
router.post('/logout', protect, logout);

module.exports = router;