const axios = require('axios');

async function analyzeDamage(photoUrls) {
  try {
    const response = await axios.post(
      process.env.DAMAGE_DETECTION_API || 'http://localhost:5002/analyze',
      { photos: photoUrls },
      { timeout: 60000 }
    );

    if (response.data && response.data.success) {
      const { analysis, cost_estimate } = response.data;

      return {
        damageType: analysis.damage_counts ? Object.keys(analysis.damage_counts).join(', ') : 'Unknown',
        affectedArea: 'Multiple areas',
        damagePercentage: analysis.damage_percentage || 0,
        confidenceScore: analysis.detected_damages ?
          analysis.detected_damages.reduce((sum, d) => sum + d.confidence, 0) / analysis.detected_damages.length : 0,
        detectedDamages: analysis.detected_damages || [],
        costBreakdown: {
          labour: cost_estimate.breakdown.labor_cost || 0,
          parts: cost_estimate.breakdown.parts_cost || 0,
          paint: cost_estimate.breakdown.paint_cost || 0,
          other: cost_estimate.breakdown.contingency || 0,
          total: cost_estimate.breakdown.total || 0
        }
      };
    } else {
      throw new Error('Invalid AI response');
    }
  } catch (error) {
    console.error('AI analysis error:', error.message);
    throw new Error('Damage analysis failed: ' + error.message);
  }
}

module.exports = { analyzeDamage };
