/**
 * AVA Claims Routes
 * All claim management endpoints
 */

const express = require('express');
const router = express.Router();
const {
  submitClaim,
  getClaims,
  getClaim,
  updateClaimStatus,
  submitDispute,
  uploadClaimPhotos,
  getClaimPhotos,
  generateClaimReport,
  getClaimStatistics,
  deleteClaim
} = require('../claims/claimController');

const { protect, authorize } = require('../authentication/auth');
const claimUpload = require('../claims/claimUpload');


// CLAIM SUBMISSION & LISTING

// Submit new claim with photos
router.post('/submit', protect, claimUpload.array('photos', 20), submitClaim);

// Get all claims for logged in user
router.get('/', protect, getClaims);

// Get statistics
router.get('/stats', protect, getClaimStatistics);


// INDIVIDUAL CLAIM ROUTES

// Get single claim
router.get('/:id', protect, getClaim);

// Update claim status (Admin/Officer only)
router.put('/:id/status', protect, authorize('admin', 'claim_officer', 'assessor'), updateClaimStatus);

// Submit dispute
router.post('/:id/dispute', protect, claimUpload.array('evidence', 5), submitDispute);

// Delete a specific claim
router.delete('/:id', protect, deleteClaim);


// PHOTOS

// Upload additional photos
router.post('/:id/photos', protect, claimUpload.array('photos', 10), uploadClaimPhotos);

// Get claim photos
router.get('/:id/photos', protect, getClaimPhotos);


// REPORTS

// Generate PDF report
router.get('/:id/report', protect, generateClaimReport);

module.exports = router;