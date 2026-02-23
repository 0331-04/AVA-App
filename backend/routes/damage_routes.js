/**
 * AVA Backend - Damage Detection Routes
 * Express routes for vehicle damage analysis
 */

const express = require('express');
const router = express.Router();
const multer = require('multer');
const { 
  DamageDetectionService,
  analyzeClaimDamage,
  generateClaimRecommendation
} = require('../services/damage_integration');

const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
    files: 20
  },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'), false);
    }
    cb(null, true);
  }
});

const damageService = new DamageDetectionService();

/**
 * POST /api/damage/detect
 * Detect damage in a single image
 */
router.post('/detect', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No image provided',
        message: 'Please upload an image file'
      });
    }

    const annotate = req.body.annotate === 'true';
    const vehiclePart = req.body.vehicle_part || null;

    const result = await damageService.detectDamage(
      req.file.buffer,
      annotate,
      vehiclePart
    );

    if (!result.success) {
      return res.status(500).json({
        error: 'Damage detection failed',
        message: result.error
      });
    }

    // Generate claim recommendation
    const recommendation = generateClaimRecommendation(result.data);

    return res.json({
      success: true,
      filename: req.file.originalname,
      analysis: result.data,
      recommendation
    });

  } catch (error) {
    console.error('Error in damage detection:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * POST /api/damage/analyze-claim
 * Analyze all photos for a complete claim
 */
router.post('/analyze-claim', upload.array('photos', 20), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        error: 'No photos provided',
        message: 'Please upload vehicle photos'
      });
    }

    const photoTypes = JSON.parse(req.body.photoTypes || '[]');
    
    const photos = req.files.map((file, index) => ({
      buffer: file.buffer,
      filename: file.originalname,
      type: photoTypes[index] || 'general'
    }));

    const analysis = await analyzeClaimDamage(photos);
    const recommendation = generateClaimRecommendation({
      total_damages: analysis.totalDamages,
      overall_severity: analysis.results.length > 0 ? 
        analysis.results[0].data?.overall_severity || 'minor' : 'minor',
      total_estimated_cost: analysis.totalEstimatedCost,
      requires_inspection: analysis.requiresInspection,
      drivable: !analysis.notDrivable
    });

    return res.json({
      success: true,
      analysis,
      recommendation
    });

  } catch (error) {
    console.error('Error analyzing claim:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * GET /api/damage/types
 * Get detectable damage types
 */
router.get('/types', async (req, res) => {
  try {
    const result = await damageService.getDamageTypes();
    
    if (!result.success) {
      return res.status(500).json({
        error: 'Failed to fetch damage types',
        message: result.error
      });
    }

    return res.json({
      success: true,
      ...result.data
    });

  } catch (error) {
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * POST /api/damage/estimate-cost
 * Estimate repair cost
 */
router.post('/estimate-cost', async (req, res) => {
  try {
    const { damages } = req.body;

    if (!damages || !Array.isArray(damages)) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Please provide damages array'
      });
    }

    const result = await damageService.estimateCost(damages);

    if (!result.success) {
      return res.status(500).json({
        error: 'Cost estimation failed',
        message: result.error
      });
    }

    return res.json({
      success: true,
      ...result.data
    });

  } catch (error) {
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});

/**
 * GET /api/damage/health
 * Check service health
 */
router.get('/health', async (req, res) => {
  try {
    const health = await damageService.healthCheck();
    
    return res.json({
      healthy: health.healthy,
      service: 'AVA Damage Detection Service',
      details: health.details || { error: health.error }
    });

  } catch (error) {
    return res.status(500).json({
      healthy: false,
      error: error.message
    });
  }
});

module.exports = router;