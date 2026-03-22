/**
 * AVA Image Quality Service Integration
 * Node.js service to integrate Python quality checker with Express backend
 */

const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

// Configuration
const QUALITY_SERVICE_URL = process.env.QUALITY_SERVICE_URL || 'http://localhost:5001';
const QUALITY_CHECK_TIMEOUT = 30000; // 30 seconds

/**
 * Image Quality Service Client
 */
class ImageQualityService {
  constructor(baseUrl = QUALITY_SERVICE_URL) {
    this.baseUrl = baseUrl;
    this.client = axios.create({
      baseURL: baseUrl,
      timeout: QUALITY_CHECK_TIMEOUT,
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
  }

  /**
   * Check health of quality service
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
   * Check quality of a single image
   * @param {Buffer|string} imageData - Image buffer or file path
   * @param {string} photoType - Type of photo (front, rear, left, right, damage)
   * @returns {Object} Quality check result
   */
  async checkImageQuality(imageData, photoType = 'general') {
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

      formData.append('photo_type', photoType);

      const response = await this.client.post('/api/v1/check-quality', formData, {
        headers: formData.getHeaders()
      });

      return {
        success: true,
        data: response.data
      };

    } catch (error) {
      console.error('Error checking image quality:', error.message);
      
      if (error.response) {
        return {
          success: false,
          error: error.response.data.message || 'Quality check failed',
          statusCode: error.response.status
        };
      }

      return {
        success: false,
        error: error.message || 'Quality service unavailable'
      };
    }
  }

  /**
   * Check quality of multiple images
   * @param {Array<Buffer|string>} images - Array of image buffers or file paths
   * @returns {Object} Batch quality check results
   */
  async checkBatchQuality(images) {
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

      const response = await this.client.post('/api/v1/batch-check', formData, {
        headers: formData.getHeaders()
      });

      return {
        success: true,
        data: response.data
      };

    } catch (error) {
      console.error('Error in batch quality check:', error.message);
      
      return {
        success: false,
        error: error.message || 'Batch quality check failed'
      };
    }
  }

  /**
   * Get quality standards
   */
  async getQualityStandards() {
    try {
      const response = await this.client.get('/api/v1/quality-standards');
      return {
        success: true,
        data: response.data.standards
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
 * Express Middleware for image quality validation
 */
const imageQualityMiddleware = (options = {}) => {
  const {
    rejectOnFail = false,
    photoType = 'general',
    attachResult = true
  } = options;

  return async (req, res, next) => {
    try {
      // Check if file exists
      if (!req.file && !req.files) {
        return next();
      }

      const qualityService = new ImageQualityService();

      // Single file
      if (req.file) {
        const result = await qualityService.checkImageQuality(
          req.file.buffer || req.file.path,
          photoType
        );

        if (!result.success) {
          return res.status(500).json({
            error: 'Quality check failed',
            message: result.error
          });
        }

        // Attach quality result to request
        if (attachResult) {
          req.qualityCheck = result.data;
        }

        // Reject if quality check didn't pass
        if (rejectOnFail && !result.data.passed) {
          return res.status(400).json({
            error: 'Image quality check failed',
            message: 'Please upload a higher quality image',
            details: {
              issues: result.data.issues,
              recommendations: result.data.recommendations,
              scores: result.data.scores
            }
          });
        }
      }

      // Multiple files
      else if (req.files && Array.isArray(req.files)) {
        const images = req.files.map(f => f.buffer || f.path);
        const result = await qualityService.checkBatchQuality(images);

        if (!result.success) {
          return res.status(500).json({
            error: 'Batch quality check failed',
            message: result.error
          });
        }

        if (attachResult) {
          req.qualityChecks = result.data.results;
          req.qualitySummary = result.data.summary;
        }

        // Reject if any image failed
        if (rejectOnFail && result.data.summary.failed > 0) {
          return res.status(400).json({
            error: 'Some images failed quality check',
            message: `${result.data.summary.failed} out of ${result.data.summary.total_images} images failed`,
            details: result.data.results.filter(r => !r.passed)
          });
        }
      }

      next();

    } catch (error) {
      console.error('Quality middleware error:', error);
      next(error);
    }
  };
};

/**
 * Helper function to validate claim photos
 * @param {Array<Object>} photos - Array of photo objects with buffer and type
 * @returns {Object} Validation results
 */
async function validateClaimPhotos(photos) {
  const qualityService = new ImageQualityService();
  const results = [];
  
  for (const photo of photos) {
    const result = await qualityService.checkImageQuality(
      photo.buffer || photo.path,
      photo.type
    );
    
    results.push({
      type: photo.type,
      filename: photo.filename,
      ...result
    });
  }

  const passedCount = results.filter(r => r.success && r.data.passed).length;
  
  return {
    totalPhotos: photos.length,
    passedPhotos: passedCount,
    failedPhotos: photos.length - passedCount,
    allPassed: passedCount === photos.length,
    results
  };
}

module.exports = {
  ImageQualityService,
  imageQualityMiddleware,
  validateClaimPhotos
};

// Example usage
if (require.main === module) {
  (async () => {
    console.log('='.repeat(60));
    console.log('AVA Image Quality Service - Node.js Integration Test');
    console.log('='.repeat(60));

    const service = new ImageQualityService();

    // Health check
    console.log('\n1. Health Check...');
    const health = await service.healthCheck();
    console.log(`   Status: ${health.healthy ? '✓ Healthy' : '✗ Unhealthy'}`);
    if (health.details) {
      console.log(`   Service: ${health.details.service}`);
      console.log(`   Version: ${health.details.version}`);
    }

    // Get quality standards
    console.log('\n2. Quality Standards...');
    const standards = await service.getQualityStandards();
    if (standards.success) {
      console.log('   Resolution (min):', standards.data.resolution.minimum);
      console.log('   Resolution (rec):', standards.data.resolution.recommended);
      console.log('   Blur threshold:', standards.data.blur.minimum_threshold);
      console.log('   Brightness range:', 
        `${standards.data.brightness.ideal_range.min}-${standards.data.brightness.ideal_range.max}`
      );
    }

    console.log('\n' + '='.repeat(60));
    console.log('Integration test complete!');
    console.log('To test with actual images, provide sample image files.');
    console.log('='.repeat(60));
  })();
}