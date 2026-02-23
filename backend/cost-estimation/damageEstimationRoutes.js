const express = require('express');
const router = express.Router();
const damageEstimationController = require('../controllers/damageEstimationController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

// Analyze damage photo and get cost estimate
router.post('/analyze', 
  auth, 
  upload.single('image'), 
  damageEstimationController.analyzeDamagePhoto
);

// Get cost estimate from damage data
router.post('/estimate', 
  auth, 
  damageEstimationController.getEstimate
);

module.exports = router;