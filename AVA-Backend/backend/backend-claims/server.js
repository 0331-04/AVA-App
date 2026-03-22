const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const claimRoutes = require('./src/routes/claims');
const photoRoutes = require('./src/routes/photos');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ava-claims', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB connected (Claims Module)'))
.catch(err => console.error('❌ MongoDB error:', err));

// Routes
app.get('/', (req, res) => {
  res.json({
    module: 'AVA Claims Management',
    version: '1.0.0',
    port: PORT,
    endpoints: {
      claims: '/api/claims',
      submit: 'POST /api/claims/submit',
      photos: 'POST /api/claims/:id/photos',
      report: 'GET /api/claims/:id/report'
    }
  });
});

app.use('/api/claims', claimRoutes);
app.use('/api/claims', photoRoutes);

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

// Start server
app.listen(PORT, () => {
  console.log('===========================================');
  console.log('🚀 Claims Module Started');
  console.log(`📡 Port: ${PORT}`);
  console.log(`🔗 URL: http://localhost:${PORT}`);
  console.log('===========================================');
});

module.exports = app;
