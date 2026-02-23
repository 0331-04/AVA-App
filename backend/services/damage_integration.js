/**
 * AVA Damage Detection Integration
 * Node.js service to integrate Python damage detector with Express backend
 */

const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

// Configuration
const DAMAGE_SERVICE_URL = process.env.DAMAGE_SERVICE_URL || 'http://localhost:5002';
const DAMAGE_CHECK_TIMEOUT = 60000; // 60 seconds (damage detection takes longer)

/**
 * Damage Detection Service Client
 */
class DamageDetectionService {
  constructor(baseUrl = DAMAGE_SERVICE_URL) {
    this.baseUrl = baseUrl;
    this.client = axios.create({
      baseURL: baseUrl,
      timeout: DAMAGE_CHECK_TIMEOUT
    });
  }

  /**
   * Check health of damage detection service
   */
  async healthCheck() {
    try {
      const response = await this.client.get('/health');
      return {
        healthy: response.data.status === 'healthy',
        details: response.data
      };
    } catch (error) {
      return {
        healthy: false,
        error: error.message
      };
    }
  }

  /**
   * Detect damage in a single image
   * @param {Buffer|string} imageData - Image buffer or file path
   * @param {boolean} annotate - Whether to return annotated image
   * @param {string} vehiclePart - Specific part to analyze
   * @returns {Object} Damage detection result
   */
  async detectDamage(imageData, annotate = true, vehiclePart = null) {
    try {
      const formData = new FormData();

      // Handle both Buffer and file path
      if (Buffer.isBuffer(imageData)) {
        formData.append('file', imageData, {
          filename: 'upload.jpg',
          contentType: 'image/jpeg'
        });
      } else if (typeof imageData === 'string') {
        const fileStream = fs.createReadStream(imageData);
        formData.append('file', fileStream, {
          filename: path.basename(imageData)
        });
      } else {
        throw new Error('Invalid image data type');
      }

      formData.append('annotate', annotate.toString());
      if (vehiclePart) {
        formData.append('vehicle_part', vehiclePart);
      }

      const response = await this.client.post('/api/v1/detect-damage', formData, {
        headers: formData.getHeaders(),
        maxContentLength: Infinity,
        maxBodyLength: Infinity
      });

      return {
        success: true,
        data: response.data
      };

    } catch (error) {
      console.error('Error detecting damage:', error.message);
      
      if (error.response) {
        return {
          success: false,
          error: error.response.data.message || 'Damage detection failed',
          statusCode: error.response.status
        };
      }

      return {
        success: false,
        error: error.message || 'Damage service unavailable'
      };
    }
  }

  /**
   * Detect damage in multiple images
   * @param {Array<Buffer|string>} images - Array of image buffers or file paths
   * @param {boolean} annotate - Whether to return annotated images
   * @returns {Object} Batch damage detection results
   */
  async detectBatchDamage(images, annotate = false) {
    try {
      const formData = new FormData();

      for (let i = 0; i < images.length; i++) {
        const imageData = images[i];

        if (Buffer.isBuffer(imageData)) {
          formData.append('files[]', imageData, {
            filename: `image_${i + 1}.jpg`,
            contentType: 'image/jpeg'
          });
        } else if (typeof imageData === 'string') {
          const fileStream = fs.createReadStream(imageData);
          formData.append('files[]', fileStream, {
            filename: path.basename(imageData)
          });
        }
      }

      formData.append('annotate', annotate.toString());

      const response = await this.client.post('/api/v1/batch-detect', formData, {
        headers: formData.getHeaders(),
        maxContentLength: Infinity,
        maxBodyLength: Infinity
      });

      return {
        success: true,
        data: response.data
      };

    } catch (error) {
      console.error('Error in batch damage detection:', error.message);
      
      return {
        success: false,
        error: error.message || 'Batch damage detection failed'
      };
    }
  }

  /**
   * Get list of detectable damage types
   */
  async getDamageTypes() {
    try {
      const response = await this.client.get('/api/v1/damage-types');
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Estimate repair cost for specific damages
   * @param {Array} damages - Array of {type, severity} objects
   */
  async estimateCost(damages) {
    try {
      const response = await this.client.post('/api/v1/estimate-cost', {
        damages
      });
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Analyze overall severity of damages
   * @param {Array} damages - Array of damage objects with severity
   */
  async analyzeSeverity(damages) {
    try {
      const response = await this.client.post('/api/v1/analyze-severity', {
        damages
      });
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
}

/**
 * Express Middleware for automatic damage detection
 */
const damageDetectionMiddleware = (options = {}) => {
  const {
    attachResult = true,
    requireDamageCheck = false,
    annotate = false
  } = options;

  return async (req, res, next) => {
    try {
      // Check if file exists
      if (!req.file && !req.files) {
        return next();
      }

      const damageService = new DamageDetectionService();

      // Single file
      if (req.file) {
        const result = await damageService.detectDamage(
          req.file.buffer || req.file.path,
          annotate
        );

        if (!result.success) {
          return res.status(500).json({
            error: 'Damage detection failed',
            message: result.error
          });
        }

        // Attach damage result to request
        if (attachResult) {
          req.damageAnalysis = result.data;
        }

        // If damage is critical and required to check
        if (requireDamageCheck && result.data.overall_severity === 'critical') {
          return res.status(400).json({
            error: 'Critical damage detected',
            message: 'Vehicle requires immediate professional inspection',
            damage_analysis: result.data
          });
        }
      }

      // Multiple files
      else if (req.files && Array.isArray(req.files)) {
        const images = req.files.map(f => f.buffer || f.path);
        const result = await damageService.detectBatchDamage(images, annotate);

        if (!result.success) {
          return res.status(500).json({
            error: 'Batch damage detection failed',
            message: result.error
          });
        }

        if (attachResult) {
          req.damageAnalyses = result.data.results;
          req.damageSummary = result.data.summary;
        }
      }

      next();

    } catch (error) {
      console.error('Damage detection middleware error:', error);
      next(error);
    }
  };
};

/**
 * Helper function to analyze claim photos for damage
 * @param {Array<Object>} photos - Array of photo objects with buffer and type
 * @returns {Object} Complete damage analysis
 */
async function analyzeClaimDamage(photos) {
  const damageService = new DamageDetectionService();
  const results = [];
  
  let totalDamages = 0;
  let totalCostMin = 0;
  let totalCostMax = 0;
  let requiresInspection = false;
  let notDrivable = false;
  
  for (const photo of photos) {
    const result = await damageService.detectDamage(
      photo.buffer || photo.path,
      true,  // Include annotations
      photo.type
    );
    
    if (result.success) {
      totalDamages += result.data.total_damages;
      totalCostMin += result.data.total_estimated_cost.min;
      totalCostMax += result.data.total_estimated_cost.max;
      
      if (result.data.requires_inspection) {
        requiresInspection = true;
      }
      
      if (!result.data.drivable) {
        notDrivable = true;
      }
    }
    
    results.push({
      photo_type: photo.type,
      filename: photo.filename,
      ...result
    });
  }

  return {
    totalPhotos: photos.length,
    totalDamages,
    totalEstimatedCost: {
      min: totalCostMin,
      max: totalCostMax,
      currency: 'USD'
    },
    requiresInspection,
    notDrivable,
    results
  };
}

/**
 * Categorize claim by damage severity
 * @param {Object} damageAnalysis - Damage analysis result
 * @returns {string} Claim category
 */
function categorizeClaimBySeverity(damageAnalysis) {
  const severity = damageAnalysis.overall_severity;
  const cost = damageAnalysis.total_estimated_cost.max;

  if (severity === 'critical' || cost > 5000) {
    return 'total_loss_investigation';
  } else if (severity === 'severe' || cost > 3000) {
    return 'major_repair';
  } else if (severity === 'moderate' || cost > 1000) {
    return 'standard_repair';
  } else {
    return 'minor_repair';
  }
}

/**
 * Generate claim recommendation based on damage
 * @param {Object} damageAnalysis - Damage analysis result
 * @returns {Object} Claim processing recommendation
 */
function generateClaimRecommendation(damageAnalysis) {
  const category = categorizeClaimBySeverity(damageAnalysis);
  
  const recommendations = {
    total_loss_investigation: {
      action: 'escalate',
      priority: 'high',
      message: 'Escalate to senior adjuster for total loss evaluation',
      requiresInspection: true,
      autoApprove: false
    },
    major_repair: {
      action: 'inspect',
      priority: 'high',
      message: 'Schedule in-person inspection within 24 hours',
      requiresInspection: true,
      autoApprove: false
    },
    standard_repair: {
      action: 'review',
      priority: 'medium',
      message: 'Standard claim processing - review and approve estimate',
      requiresInspection: damageAnalysis.requires_inspection,
      autoApprove: false
    },
    minor_repair: {
      action: 'approve',
      priority: 'low',
      message: 'Auto-approve for fast track processing',
      requiresInspection: false,
      autoApprove: true
    }
  };

  return {
    category,
    ...recommendations[category],
    damageDetails: {
      totalDamages: damageAnalysis.total_damages,
      severity: damageAnalysis.overall_severity,
      estimatedCost: damageAnalysis.total_estimated_cost,
      drivable: damageAnalysis.drivable
    }
  };
}

module.exports = {
  DamageDetectionService,
  damageDetectionMiddleware,
  analyzeClaimDamage,
  categorizeClaimBySeverity,
  generateClaimRecommendation
};

// Example usage
if (require.main === module) {
  (async () => {
    console.log('='.repeat(70));
    console.log('AVA Damage Detection Service - Node.js Integration Test');
    console.log('='.repeat(70));

    const service = new DamageDetectionService();

    // Health check
    console.log('\n1. Health Check...');
    const health = await service.healthCheck();
    console.log(`   Status: ${health.healthy ? '✓ Healthy' : '✗ Unhealthy'}`);
    if (health.details) {
      console.log(`   Service: ${health.details.service}`);
      console.log(`   Version: ${health.details.version}`);
    }

    // Get damage types
    console.log('\n2. Damage Types...');
    const types = await service.getDamageTypes();
    if (types.success) {
      console.log('   Detectable types:');
      Object.keys(types.data.damage_types).forEach(type => {
        console.log(`     • ${type}`);
      });
    }

    // Example cost estimation
    console.log('\n3. Cost Estimation Example...');
    const costResult = await service.estimateCost([
      { type: 'scratch', severity: 'minor' },
      { type: 'dent', severity: 'moderate' }
    ]);
    if (costResult.success) {
      console.log(`   Estimated cost: $${costResult.data.total_cost.min} - $${costResult.data.total_cost.max}`);
    }

    console.log('\n' + '='.repeat(70));
    console.log('Integration test complete!');
    console.log('To test with actual images, provide sample damaged vehicle images.');
    console.log('='.repeat(70));
  })();
}