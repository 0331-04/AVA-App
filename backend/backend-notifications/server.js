const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const notificationRoutes = require('./src/routes/notifications');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ava-notifications', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB connected (Notifications Module)'))
.catch(err => console.error('❌ MongoDB error:', err));

// Health check route
app.get('/', (req, res) => {
  res.json({
    module: 'AVA Notifications System',
    version: '1.0.0',
    port: PORT,
    endpoints: {
      getNotifications: 'GET /api/notifications',
      markAsRead: 'POST /api/notifications/read',
      markAllAsRead: 'POST /api/notifications/read-all',
      deleteNotifications: 'DELETE /api/notifications',
      saveFCMToken: 'POST /api/notifications/fcm-token',
      createNotification: 'POST /api/notifications/create'
    }
  });
});

app.use('/api/notifications', notificationRoutes);

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
  console.log('🔔 Notifications Module Started');
  console.log(`📡 Port: ${PORT}`);
  console.log(`🔗 URL: http://localhost:${PORT}`);
  console.log('===========================================');
});

module.exports = app;
