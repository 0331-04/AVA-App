/**
 * AVA Claim Photo Upload Middleware
 * Handles claim photo uploads with validation
 */

const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads directory if it doesn't exist
const uploadsDir = './uploads/claims';
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    // Generate unique filename: claim-{timestamp}-{random}.{ext}
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `claim-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

// File filter - only images
const fileFilter = (req, file, cb) => {
  // Allowed extensions
  const allowedTypes = /jpeg|jpg|png|heic|webp/;
  
  // Check extension
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  
  // Check mimetype
  const mimetype = allowedTypes.test(file.mimetype) || file.mimetype === 'image/heic';

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only image files are allowed (jpeg, jpg, png, heic, webp)'));
  }
};

// Configure multer
const claimUpload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit per file
  },
  fileFilter: fileFilter
});

module.exports = claimUpload;