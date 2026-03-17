const express = require('express');
const router = express.Router();
const claimController = require('../controllers/claimController');
const auth = require('../middleware/auth');

router.post('/submit', auth, claimController.submitClaim);
router.get('/', auth, claimController.getUserClaims);
router.get('/:id', auth, claimController.getClaimById);
router.put('/:id/status', auth, claimController.updateClaimStatus);
router.post('/:id/dispute', auth, claimController.submitDispute);
router.get('/:id/report', auth, claimController.generateReport);

module.exports = router;
