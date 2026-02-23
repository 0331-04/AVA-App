// Controller for damage analysis endpoints
const damageEstimationService = require('../services/damageEstimationService');
const Claim = require('../models/Claim');
const Assessment = require('../models/Assessment');

/**
 * Analyze uploaded damage photo and provide cost estimate
 */
exports.analyzeDamagePhoto = async (req, res) => {
  try {
    const { claimId } = req.body;
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }
    
    console.log(`🔍 Analyzing damage for claim: ${claimId}`);
    
    // Call Python service for analysis
    const analysisResult = await damageEstimationService.analyzeDamage(
      req.file.buffer,
      req.file.originalname
    );
    
    if (!analysisResult.success) {
      return res.status(500).json({
        success: false,
        message: 'Damage analysis failed'
      });
    }
    
    // Format assessment data
    const assessmentData = damageEstimationService.formatAssessment(analysisResult);
    
    // If claimId provided, create assessment and update claim
    if (claimId) {
      const claim = await Claim.findById(claimId);
      
      if (claim) {
        // Create assessment
        const assessment = await Assessment.create({
          claimId: claim._id,
          assessorId: req.user?.id || null,
          damagedParts: assessmentData.damageDetails.map(d => ({
            partName: d.damage_type,
            damageType: d.damage_type.toLowerCase(),
            severity: d.severity,
            estimatedCost: d.subtotal
          })),
          totalEstimate: assessmentData.estimatedCost,
          laborCost: assessmentData.breakdown.laborCost,
          partsCost: assessmentData.breakdown.partsCost,
          additionalCosts: assessmentData.breakdown.paintCost,
          aiDamageScore: assessmentData.damagePercentage,
          aiEstimate: assessmentData.estimatedCost,
          aiConfidence: 85, // Average confidence from detections
          assessmentNotes: `AI-generated assessment: ${assessmentData.severity} damage detected`,
          assessmentDate: new Date()
        });
        
        // Update claim with estimate
        claim.estimatedAmount = assessmentData.estimatedCost;
        await claim.save();
        
        console.log(`✅ Assessment created for claim ${claimId}`);
      }
    }
    
    res.json({
      success: true,
      message: 'Damage analyzed successfully',
      data: {
        analysis: analysisResult.analysis,
        estimate: assessmentData,
        currency: 'LKR'
      }
    });
    
  } catch (error) {
    console.error('Error analyzing damage:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

/**
 * Get cost estimate from existing damage data
 */
exports.getEstimate = async (req, res) => {
  try {
    const { damageData } = req.body;
    
    const result = await damageEstimationService.calculateCost(damageData);
    
    res.json({
      success: true,
      data: result
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
