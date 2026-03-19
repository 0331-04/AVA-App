/**
 * AVA Authentication Middleware
 * Protects routes and verifies JWT tokens
 */

const jwt = require('jsonwebtoken');
const User = require('./user');

/**
 * Protect routes - Verify JWT token
 */
exports.protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in headers
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      // Extract token from "Bearer TOKEN"
      token = req.headers.authorization.split(' ')[1];
    }
    // Check for token in cookies (if using cookie-parser)
    else if (req.cookies && req.cookies.token) {
      token = req.cookies.token;
    }

    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to access this route',
        message: 'Please login to continue'
      });
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from token
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'User not found',
          message: 'Invalid token'
        });
      }

      // Check if user is active
      if (!req.user.isActive) {
        return res.status(401).json({
          success: false,
          error: 'Account deactivated',
          message: 'Your account has been deactivated. Please contact support.'
        });
      }

      next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized',
        message: 'Invalid or expired token'
      });
    }
  } catch (error) {
    next(error);
  }
};

/**
 * Grant access to specific roles
 * Usage: authorize('admin', 'claim_officer')
 */
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: 'Forbidden',
        message: `User role '${req.user.role}' is not authorized to access this route`,
        requiredRoles: roles
      });
    }
    next();
  };
};

/**
 * Optional authentication - Attach user if token is valid but don't require it
 */
exports.optionalAuth = async (req, res, next) => {
  try {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    } else if (req.cookies && req.cookies.token) {
      token = req.cookies.token;
    }

    if (token) {
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = await User.findById(decoded.id).select('-password');
      } catch (error) {
        // Token invalid but don't block request
        req.user = null;
      }
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Check if email is verified
 */
exports.requireVerified = (req, res, next) => {
  if (!req.user.isVerified) {
    return res.status(403).json({
      success: false,
      error: 'Email not verified',
      message: 'Please verify your email to access this feature'
    });
  }
  next();
};

/**
 * Check if user owns the resource
 */
exports.checkOwnership = (req, res, next) => {
  const userId = req.params.userId || req.body.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      error: 'User ID required'
    });
  }

  // Allow admins and claim officers to access any user's data
  if (req.user.role === 'admin' || req.user.role === 'claim_officer') {
    return next();
  }

  // Check if user owns the resource
  if (req.user.id !== userId) {
    return res.status(403).json({
      success: false,
      error: 'Forbidden',
      message: 'You can only access your own data'
    });
  }

  next();
};

/**
 * Rate limiting middleware
 */
const rateLimit = require('express-rate-limit');

exports.loginRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: {
    success: false,
    error: 'Too many login attempts',
    message: 'Please try again after 15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});

exports.apiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests
  message: {
    success: false,
    error: 'Too many requests',
    message: 'Please try again later'
  }
});

/**
 * Validate refresh token
 */
exports.validateRefreshToken = (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: 'Refresh token required'
      });
    }

    const decoded = jwt.verify(
      refreshToken,
      process.env.REFRESH_TOKEN_SECRET || process.env.JWT_SECRET
    );

    if (decoded.type !== 'refresh') {
      return res.status(401).json({
        success: false,
        error: 'Invalid token type'
      });
    }

    req.tokenUserId = decoded.id;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: 'Invalid or expired refresh token'
    });
  }
};
