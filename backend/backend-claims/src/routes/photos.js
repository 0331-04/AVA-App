const express = require('express');
const router = express.Router();
const photoController = require('../controllers/photoController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/:claimId/photos', auth, upload.array('photos', 10), photoController.uploadPhotos);
router.get('/:claimId/photos', auth, photoController.getClaimPhotos);

module.exports = router;
