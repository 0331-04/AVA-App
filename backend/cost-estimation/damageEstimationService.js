const axios = require('axios');
const FormData = require('form-data');

const DAMAGE_DETECTION_URL = process.env.DAMAGE_DETECTION_URL || 'http://localhost:5000';

class DamageEstimationService {
  /**
   * Analyze image for damage and get raw ML result
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
          timeout: 60000
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

  /**
   * Build a simple rule-based estimate from ML analysis
   */
  buildRuleBasedEstimate(analysis) {
    const damagePercentage = Number(analysis?.damage_percentage || 0);
    const damageCounts = analysis?.damage_counts || {};

    const totalDetected = Object.values(damageCounts).reduce(
      (sum, count) => sum + Number(count || 0),
      0
    );

    let severity = 'none';
    if (damagePercentage > 0 && damagePercentage <= 5) severity = 'minor';
    else if (damagePercentage <= 15) severity = 'moderate';
    else if (damagePercentage <= 30) severity = 'major';
    else if (damagePercentage > 30) severity = 'severe';

    let baseMin = 0;
    let baseMax = 0;

    switch (severity) {
      case 'minor':
        baseMin = 5000;
        baseMax = 15000;
        break;
      case 'moderate':
        baseMin = 15000;
        baseMax = 40000;
        break;
      case 'major':
        baseMin = 40000;
        baseMax = 90000;
        break;
      case 'severe':
        baseMin = 90000;
        baseMax = 200000;
        break;
      default:
        baseMin = 0;
        baseMax = 5000;
    }

    let typeAdjustment = 0;

    for (const [type, count] of Object.entries(damageCounts)) {
      const qty = Number(count || 0);
      const normalized = String(type).toLowerCase();

      if (normalized.includes('scratch')) typeAdjustment += 3000 * qty;
      else if (normalized.includes('dent')) typeAdjustment += 7000 * qty;
      else if (normalized.includes('crack')) typeAdjustment += 9000 * qty;
      else if (normalized.includes('broken')) typeAdjustment += 15000 * qty;
      else typeAdjustment += 5000 * qty;
    }

    const min = baseMin + Math.round(typeAdjustment * 0.6);
    const max = baseMax + typeAdjustment;

    const parts = Math.round(max * 0.5);
    const labor = Math.round(max * 0.3);
    const paint = Math.round(max * 0.15);
    const contingency = Math.round(max * 0.05);

    return {
      severity,
      estimated_cost: {
        min,
        max,
        currency: 'LKR'
      },
      breakdown: {
        parts,
        labor,
        paint,
        contingency
      },
      summary: {
        damage_percentage: damagePercentage,
        total_detected_items: totalDetected,
        damage_counts: damageCounts
      }
    };
  }
}

module.exports = new DamageEstimationService();
