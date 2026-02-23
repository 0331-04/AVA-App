/**
 * AVA Backend - Photo Quality Routes
 * Express routes for image quality validation during claim submission
 */

const express = require('express');
const router = express.Router();
const multer = require('multer');
const { 
  ImageQualityService, 
  imageQualityMiddleware, 
  validateClaimPhotos 
} = require('../services/quality_integration');

// Multer configuration for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
    files: 20 // Maximum 20 files
  },
  fileFilter: (req, file, cb) => {
    // Accept images only
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'), false);
    }
    cb(null, true);
  }
});

const qualityService = new ImageQualityService();

/**
 * POST /api/quality/check-single
 * Check quality of a single image
 */
router.post('/check-single', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No image provided',
        message: 'Please upload an image file'
      });
    }

    const photoType = req.body.photo_type || req.body.photoType || 'general';

    const result = await qualityService.checkImageQuality(
      req.file.buffer,
      photoType
    );

    if (!result.success) {
      return res.status(500).json({
        error: 'Quality check failed',
        message: result.error
      });
    }

    return res.json({
      success: true,
      filename: req.file.originalname,
      size: req.file.size,
      quality: result.data
    });

  } catch (error) {
    console.error('Error in single quality check:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * POST /api/quality/check-batch
 * Check quality of multiple images
 */
router.post('/check-batch', upload.array('images', 20), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        error: 'No images provided',
        message: 'Please upload at least one image file'
      });
    }

    const images = req.files.map(f => f.buffer);
    const result = await qualityService.checkBatchQuality(images);

    if (!result.success) {
      return res.status(500).json({
        error: 'Batch quality check failed',
        message: result.error
      });
    }

    // Add filenames to results
    result.data.results.forEach((r, index) => {
      if (req.files[index]) {
        r.filename = req.files[index].originalname;
        r.size = req.files[index].size;
      }
    });

    return res.json({
      success: true,
      totalImages: req.files.length,
      results: result.data.results,
      summary: result.data.summary
    });

  } catch (error) {
    console.error('Error in batch quality check:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * POST /api/quality/validate-claim-photos
 * Validate all required photos for a claim submission
 * Expects: front, rear, left, right, damage photos
 */
router.post('/validate-claim-photos', upload.array('photos', 20), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        error: 'No photos provided',
        message: 'Please upload vehicle photos'
      });
    }

    // Parse photo types from request body
    const photoTypes = JSON.parse(req.body.photoTypes || '[]');

    // Organize photos by type
    const photos = req.files.map((file, index) => ({
      buffer: file.buffer,
      filename: file.originalname,
      type: photoTypes[index] || 'general',
      size: file.size
    }));

    // Validate all photos
    const validationResult = await validateClaimPhotos(photos);

    // Check if required photo types are present
    const requiredTypes = ['front', 'rear', 'left', 'right'];
    const submittedTypes = photos.map(p => p.type);
    const missingTypes = requiredTypes.filter(type => !submittedTypes.includes(type));

    if (missingTypes.length > 0) {
      return res.status(400).json({
        error: 'Missing required photos',
        message: `Please upload photos of: ${missingTypes.join(', ')}`,
        missingTypes,
        validationResult
      });
    }

    // Check if all photos passed quality check
    if (!validationResult.allPassed) {
      return res.status(400).json({
        error: 'Some photos failed quality check',
        message: `${validationResult.failedPhotos} out of ${validationResult.totalPhotos} photos failed quality standards`,
        validationResult
      });
    }

    return res.json({
      success: true,
      message: 'All photos passed quality validation',
      validationResult
    });

  } catch (error) {
    console.error('Error validating claim photos:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * GET /api/quality/standards
 * Get quality standards and requirements
 */
router.get('/standards', async (req, res) => {
  try {
    const result = await qualityService.getQualityStandards();

    if (!result.success) {
      return res.status(500).json({
        error: 'Failed to fetch standards',
        message: result.error
      });
    }

    return res.json({
      success: true,
      standards: result.data,
      requiredPhotos: {
        types: ['front', 'rear', 'left', 'right', 'damage'],
        descriptions: {
          front: 'Front view of the vehicle showing license plate',
          rear: 'Rear view of the vehicle showing license plate',
          left: 'Left side view of the vehicle',
          right: 'Right side view of the vehicle',
          damage: 'Close-up photos of all damage areas'
        }
      }
    });

  } catch (error) {
    console.error('Error fetching standards:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * GET /api/quality/health
 * Check health of quality service
 */
router.get('/health', async (req, res) => {
  try {
    const health = await qualityService.healthCheck();
    
    return res.json({
      healthy: health.healthy,
      service: 'AVA Image Quality Service',
      details: health.details || { error: health.error }
    });

  } catch (error) {
    return res.status(500).json({
      healthy: false,
      error: error.message
    });
  }
});

// Error handler for multer errors
router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        error: 'File too large',
        message: 'Maximum file size is 10MB'
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        error: 'Too many files',
        message: 'Maximum 20 files allowed'
      });
    }
  }
  
  if (error.message === 'Only image files are allowed') {
    return res.status(400).json({
      error: 'Invalid file type',
      message: 'Only image files (JPG, PNG, etc.) are allowed'
    });
  }

  next(error);
});

module.exports = router;