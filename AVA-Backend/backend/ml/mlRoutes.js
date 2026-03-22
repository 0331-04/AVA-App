const express = require('express');
const router = express.Router();
const multer = require('multer');
const damageEstimationService = require('../cost-estimation/damageEstimationService');

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const path = require('path');
    const mime = (file.mimetype || '').toLowerCase();
    const ext = path.extname(file.originalname || '').toLowerCase();

    const allowedMimeTypes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
      'image/heic',
      'image/heif',
      'application/octet-stream'
    ];

    const allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.heic',
      '.heif'
    ];

    if (
      allowedMimeTypes.includes(mime) ||
      mime.startsWith('image/') ||
      allowedExtensions.includes(ext)
    ) {
      return cb(null, true);
    }

    return cb(new Error(`Only image files are allowed. Got mime=${mime}, ext=${ext}`), false);
  }
});

router.post('/analyze', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    const analysis = await damageEstimationService.analyzeDamage(
      req.file.buffer,
      req.file.originalname
    );

    const estimate = damageEstimationService.buildRuleBasedEstimate(analysis);

    return res.json({
      success: true,
      data: {
        analysis,
        estimate
      }
    });
  } catch (error) {
    console.error('ML analyze error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to analyze image'
    });
  }
});

module.exports = router;
