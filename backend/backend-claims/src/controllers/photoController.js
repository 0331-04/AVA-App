const Claim = require('../models/Claim');
const cloudinary = require('../config/cloudinary');
const damageAnalysisService = require('../services/damageAnalysisService');

exports.uploadPhotos = async (req, res) => {
  try {
    const claim = await Claim.findOne({
      _id: req.params.claimId,
      userId: req.user.id
    });

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: 'Claim not found'
      });
    }

    const uploadedPhotos = [];

    for (const file of req.files) {
      const b64 = Buffer.from(file.buffer).toString('base64');
      const dataURI = `data:${file.mimetype};base64,${b64}`;

      const result = await cloudinary.uploader.upload(dataURI, {
        folder: `claims/${claim.claimNumber}`,
        resource_type: 'auto'
      });

      uploadedPhotos.push({
        url: result.secure_url,
        publicId: result.public_id,
        uploadedAt: new Date()
      });
    }

    claim.photos = uploadedPhotos;
    claim.status = 'ai_analysis';
    await claim.save();

    // Trigger AI analysis
    const photoUrls = uploadedPhotos.map(p => p.url);

    try {
      const analysisResult = await damageAnalysisService.analyzeDamage(photoUrls);

      claim.analysis = {
        ...analysisResult,
        analyzedAt: new Date()
      };

      claim.estimatedAmount = analysisResult.costBreakdown.total;
      claim.status = 'in_review';
      await claim.save();
    } catch (analysisError) {
      console.error('AI analysis failed:', analysisError);
      claim.status = 'in_review';
      await claim.save();
    }

    res.json({
      success: true,
      message: 'Photos uploaded and analyzed',
      data: { claim }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getClaimPhotos = async (req, res) => {
  try {
    const claim = await Claim.findOne({
      _id: req.params.claimId,
      userId: req.user.id
    });

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: 'Claim not found'
      });
    }

    res.json({
      success: true,
      data: { photos: claim.photos }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
