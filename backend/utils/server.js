/**
 * AVA Insurance Backend - Main Server File
 * Handles all API routes and service connections
 */

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const app = express();

// MIDDLEWARE
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// DATABASE CONNECTION - MongoDB
mongoose.connect(process.env.MONGODB_URI)

.then(() => console.log('✓ MongoDB connected successfully'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// IMPORT ROUTES
const authRoutes = require('../authentication/authRoute');
const userRoutes = require("../user profile/userRoute");
const claimRoutes = require('../claims/claimRoutes');
app.use('/api/claims', claimRoutes);

// API ROUTES

// Authentication routes
app.use('/api/auth', authRoutes);

// User profile routes
app.use('/api/user', userRoutes);

// Claim routes
app.use('/api/claims', claimRoutes);


//Static file serving for uploads
app.use('/uploads', express.static('uploads'));


// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'AVA Insurance API is running',
    version: '1.0.0',
    services: {
      quality: process.env.QUALITY_SERVICE_URL || 'Not configured',
      damage: process.env.DAMAGE_SERVICE_URL || 'Not configured'
    }
  });
});

// ERROR HANDLING MIDDLEWARE

// 404 handler - Route not found
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.path}`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    success: false,
    error: err.name || 'Server Error',
    message: err.message || 'Something went wrong',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});


// START SERVER
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log('='.repeat(50));
  console.log('🚀 AVA Insurance Backend Server');
  console.log('='.repeat(50));
  console.log(`✓ Server running on port ${PORT}`);
  console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`✓ Quality Service: ${process.env.QUALITY_SERVICE_URL || 'Not configured'}`);
  console.log(`✓ Damage Service: ${process.env.DAMAGE_SERVICE_URL || 'Not configured'}`);
  console.log('='.repeat(50));
  console.log(`\n📡 API Endpoints:`);
  console.log(`   GET    http://localhost:${PORT}/`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/register`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/login`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/me`);
  console.log(`   POST   http://localhost:${PORT}/api/quality/check-single`);
  console.log(`   POST   http://localhost:${PORT}/api/damage/detect`);
  console.log('='.repeat(50));
});

module.exports = app;