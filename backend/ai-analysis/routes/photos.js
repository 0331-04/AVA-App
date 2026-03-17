const express = require('express');
const multer = require('multer');
const path = require('path');
const Claim = require('../models/Claim');
const damageAnalysisService = require('../services/damageAnalysisService');

const router = express.Router();

// Configure Multer for file uploads (store in 'uploads/' directory temporarily)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// POST /api/photos/upload - Upload photos and trigger analysis
router.post('/upload', upload.array('photos', 10), async (req, res) => {
  try {
    const photos = req.files.map((file) => file.path);
    const claim = new Claim({ photos });
    const savedClaim = await claim.save();

    // Trigger analysis asynchronously
    const analysisResult = await damageAnalysisService.analyzeDamage(photos);
    savedClaim.analysis = analysisResult;
    await savedClaim.save();

    res.status(200).json({
      message: 'Photos uploaded and analyzed successfully.',
      claim: savedClaim,
    });
  } catch (error) {
    console.error('Error uploading or analyzing photos:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;