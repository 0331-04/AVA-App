const axios = require('axios');
const FormData = require('form-data');

const DAMAGE_DETECTION_URL = process.env.DAMAGE_DETECTION_URL || 'http://localhost:5002';

class DamageEstimationService {
  
  /**
   * Analyze image for damage and get cost estimate
   */
  async analyzeDamage(fileBuffer, filename) {
    try {
      const formData = new FormData();
      formData.append('image', fileBuffer, filename);
      
      const response = await axios.post(
        `${DAMAGE_DETECTION_URL}/analyze`,
        formData,
        {
          headers: formData.getHeaders(),
          timeout: 60000 // 60 second timeout
        }
      );
      
      return response.data;
      
    } catch (error) {
      console.error('Damage analysis error:', error.message);
      throw new Error('Failed to analyze damage. Please try again.');
    }
  }
  
  /**
   * Calculate cost estimate from existing damage data
   */
  async calculateCost(damageData) {
    try {
      const response = await axios.post(
        `${DAMAGE_DETECTION_URL}/estimate`,
        damageData,
        { timeout: 10000 }
      );
      
      return response.data;
      
    } catch (error) {
      console.error('Cost estimation error:', error.message);
      throw new Error('Failed to calculate cost estimate.');
    }
  }
  
  /**
   * Convert damage analysis to assessment format
   */
  formatAssessment(analysisResult) {
    const { analysis, cost_estimate } = analysisResult;
    
    return {
      damagePercentage: analysis.damage_percentage,
      damageCounts: analysis.damage_counts,
      detectedDamages: analysis.detected_damages,
      severity: cost_estimate.severity,
      estimatedCost: cost_estimate.breakdown.total,
      breakdown: {
        partsCost: cost_estimate.breakdown.parts_cost,
        laborCost: cost_estimate.breakdown.labor_cost,
        paintCost: cost_estimate.breakdown.paint_cost,
        contingency: cost_estimate.breakdown.contingency,
        total: cost_estimate.breakdown.total
      },
      damageDetails: cost_estimate.damage_details
    };
  }
}

module.exports = new DamageEstimationService();