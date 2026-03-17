const axios = require('axios');
const config = require('../config');

// Analyze Damage by Sending Photos to the ML Model API
async function analyzeDamage(photoPaths) {
  try {
    const response = await axios.post(config.damageDetectionAPI, {
      photos: photoPaths,
    });

    if (response.data) {
      const { damageType, affectedArea, confidenceScore, costBreakdown } = response.data;

      // Parse and format the ML response
      return {
        damageType,
        affectedArea,
        confidenceScore,
        costBreakdown: {
          labour: costBreakdown.labour || 0,
          parts: costBreakdown.parts || 0,
          other: costBreakdown.other || 0,
        },
      };
    } else {
      throw new Error('Invalid response from damage detection model.');
    }
  } catch (error) {
    console.error('Error while analyzing damage:', error.message);
    throw new Error('Damage analysis failed.');
  }
}

module.exports = { analyzeDamage };