/**
 * AVA User Profile Controller
 * Handles user profile, vehicle, avatar, and policy management
 */

const User = require('../authentication/user');

/**
 * @desc    Get user profile
 * @route   GET /api/user/profile
 * @access  Private
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: user.getPublicProfile()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve profile',
      message: error.message
    });
  }
};

/**
 * @desc    Update user profile (name, phone, address)
 * @route   PUT /api/user/profile
 * @access  Private
 */
exports.updateProfile = async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      phone,
      nic,
      address,
      notificationPreferences
    } = req.body;

    // Build update object (only include provided fields)
    const fieldsToUpdate = {};
    
    if (firstName) fieldsToUpdate.firstName = firstName;
    if (lastName) fieldsToUpdate.lastName = lastName;
    if (phone) fieldsToUpdate.phone = phone;
    if (nic) fieldsToUpdate.nic = nic;
    if (address) fieldsToUpdate.address = address;
    if (notificationPreferences) fieldsToUpdate.notificationPreferences = notificationPreferences;

    // Update user
    const user = await User.findByIdAndUpdate(
      req.user.id,
      fieldsToUpdate,
      {
        new: true,
        runValidators: true
      }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user.getPublicProfile()
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: messages.join(', ')
      });
    }

    res.status(500).json({
      success: false,
      error: 'Could not update profile',
      message: error.message
    });
  }
};

/**
 * @desc    Get user vehicles
 * @route   GET /api/user/vehicles
 * @access  Private
 */
exports.getVehicles = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      count: user.vehicles.length,
      data: user.vehicles
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve vehicles',
      message: error.message
    });
  }
};

/**
 * @desc    Add vehicle
 * @route   POST /api/user/vehicle
 * @access  Private
 */
exports.addVehicle = async (req, res) => {
  try {
    const {
      make,
      model,
      year,
      licensePlate,
      vin,
      color,
      registrationDate
    } = req.body;

    // Validate required fields
    if (!make || !model || !year || !licensePlate) {
      return res.status(400).json({
        success: false,
        error: 'Please provide make, model, year, and license plate'
      });
    }

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Check if license plate already exists for this user
    const plateExists = user.vehicles.some(
      v => v.licensePlate.toLowerCase() === licensePlate.toLowerCase()
    );

    if (plateExists) {
      return res.status(400).json({
        success: false,
        error: 'Vehicle with this license plate already exists'
      });
    }

    // Add vehicle
    user.vehicles.push({
      make,
      model,
      year,
      licensePlate,
      vin,
      color,
      registrationDate: registrationDate || Date.now()
    });

    await user.save();

    res.status(201).json({
      success: true,
      message: 'Vehicle added successfully',
      data: user.vehicles
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not add vehicle',
      message: error.message
    });
  }
};

/**
 * @desc    Update vehicle
 * @route   PUT /api/user/vehicle/:vehicleId
 * @access  Private
 */
exports.updateVehicle = async (req, res) => {
  try {
    const { vehicleId } = req.params;
    const updates = req.body;

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Find vehicle
    const vehicle = user.vehicles.id(vehicleId);

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        error: 'Vehicle not found'
      });
    }

    // Update vehicle fields
    Object.keys(updates).forEach(key => {
      vehicle[key] = updates[key];
    });

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Vehicle updated successfully',
      data: vehicle
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not update vehicle',
      message: error.message
    });
  }
};

/**
 * @desc    Delete vehicle
 * @route   DELETE /api/user/vehicle/:vehicleId
 * @access  Private
 */
exports.deleteVehicle = async (req, res) => {
  try {
    const { vehicleId } = req.params;

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Remove vehicle
    user.vehicles.pull(vehicleId);
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Vehicle deleted successfully',
      data: user.vehicles
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not delete vehicle',
      message: error.message
    });
  }
};

/**
 * @desc    Upload profile avatar
 * @route   POST /api/user/avatar
 * @access  Private
 */
exports.uploadAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'Please upload an image file'
      });
    }

    // For local storage (simple version)
    // In production, upload to AWS S3 or Cloudinary
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { profilePicture: avatarUrl },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: {
        profilePicture: user.profilePicture
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not upload avatar',
      message: error.message
    });
  }
};

/**
 * @desc    Get user policy details
 * @route   GET /api/user/policy
 * @access  Private
 */
exports.getPolicy = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    if (!user.policyNumber) {
      return res.status(404).json({
        success: false,
        error: 'No policy found for this user',
        message: 'Please contact support to activate your insurance policy'
      });
    }

    // Calculate policy status
    const now = new Date();
    const isActive = user.policyEndDate && user.policyEndDate > now;
    const daysRemaining = user.policyEndDate 
      ? Math.ceil((user.policyEndDate - now) / (1000 * 60 * 60 * 24))
      : 0;

    const policyData = {
      policyNumber: user.policyNumber,
      startDate: user.policyStartDate,
      endDate: user.policyEndDate,
      status: isActive ? 'active' : 'expired',
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
      isActive,
      holder: {
        name: `${user.firstName} ${user.lastName}`,
        email: user.email,
        phone: user.phone,
        nic: user.nic
      },
      vehicles: user.vehicles,
      totalVehiclesCovered: user.vehicles.length
    };

    res.status(200).json({
      success: true,
      data: policyData
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve policy',
      message: error.message
    });
  }
};

/**
 * @desc    Update policy details (Admin only)
 * @route   PUT /api/user/policy
 * @access  Private/Admin
 */
exports.updatePolicy = async (req, res) => {
  try {
    const {
      policyNumber,
      policyStartDate,
      policyEndDate
    } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      {
        policyNumber,
        policyStartDate,
        policyEndDate
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Policy updated successfully',
      data: {
        policyNumber: user.policyNumber,
        policyStartDate: user.policyStartDate,
        policyEndDate: user.policyEndDate
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not update policy',
      message: error.message
    });
  }
};

/**
 * @desc    Delete user account
 * @route   DELETE /api/user/account
 * @access  Private
 */
exports.deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        error: 'Please provide your password to confirm account deletion'
      });
    }

    // Get user with password
    const user = await User.findById(req.user.id).select('+password');

    // Verify password
    const isPasswordMatch = await user.comparePassword(password);

    if (!isPasswordMatch) {
      return res.status(401).json({
        success: false,
        error: 'Incorrect password'
      });
    }

    // Soft delete (deactivate account)
    user.isActive = false;
    await user.save();

    // Or hard delete (uncomment if you want permanent deletion):
    // await User.findByIdAndDelete(req.user.id);

    res.status(200).json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not delete account',
      message: error.message
    });
  }
};

module.exports = exports;