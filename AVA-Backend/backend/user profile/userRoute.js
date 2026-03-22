/**
 * AVA User Profile Routes
 * All user profile management endpoints
 */

const express = require('express');
const router = express.Router();
const {
  getProfile,
  updateProfile,
  getVehicles,
  addVehicle,
  updateVehicle,
  deleteVehicle,
  uploadAvatar,
  getPolicy,
  updatePolicy,
  deleteAccount
} = require('./userController');

const { protect, authorize } = require('../authentication/auth');
const upload = require('../user profile/upload');

// PROFILE ROUTES

// Get and update profile
router.route('/profile')
  .get(protect, getProfile)
  .put(protect, updateProfile);

// VEHICLE ROUTES

// Get all vehicles
router.get('/vehicles', protect, getVehicles);

// Add new vehicle
router.post('/vehicle', protect, addVehicle);

// Update and delete specific vehicle
router.route('/vehicle/:vehicleId')
  .put(protect, updateVehicle)
  .delete(protect, deleteVehicle);

// AVATAR UPLOAD

router.post('/avatar', protect, upload.single('avatar'), uploadAvatar);

// POLICY ROUTES

router.route('/policy')
  .get(protect, getPolicy)
  .put(protect, authorize('admin', 'claim_officer'), updatePolicy);

// ACCOUNT DELETION

router.delete('/account', protect, deleteAccount);

module.exports = router;