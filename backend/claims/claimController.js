/**
 * AVA Claims Controller
 * Handles claim submission, management, photos, and reports
 */

const Claim = require('../claims/claim');
const User = require('../authentication/user');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const safeJsonParse = (value) => {
  if (!value) return {};
  if (typeof value === 'object') return value;
  try {
    return JSON.parse(value);
  } catch (_) {
    return {};
  }
};


/**
 * @desc    Submit new claim
 * @route   POST /api/claims/submit
 * @access  Private
 */
exports.submitClaim = async (req, res) => {
  try {
    const {
      incidentDate,
      incidentTime,
      incidentDescription,
      incidentType,
      estimatedAmount,
      policeReport,
      thirdParty,
      witnesses,
      damageAnalysis,
      vehicleMake,
      vehicleModel,
      vehicleYear,
      vehicleLicensePlate,
      vehicleVin,
      vehicleColor,
      incidentAddress,
      incidentCity
    } = req.body;

    // Get user details
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Temporary relaxed policy validation for demo
    const now = new Date();
    const effectivePolicyNumber = user.policyNumber || 'DEMO-POLICY';

    if (user.policyNumber && user.policyEndDate && user.policyEndDate < now) {
      return res.status(400).json({
        success: false,
        error: 'Policy expired',
        message: 'Your insurance policy has expired. Please renew to submit claims.'
      });
    }

    // Process uploaded photos if any
    const photos = [];
    if (req.files && req.files.length > 0) {
      req.files.forEach((file, index) => {
        photos.push({
          url: `/uploads/claims/${file.filename}`,
          key: file.filename,
          type: req.body.photoTypes?.[index] || 'other',
          uploadedAt: Date.now()
        });
      });
    }

    const safeVehicle = {
      make: vehicleMake || 'Unknown',
      model: vehicleModel || 'Unknown',
      year: Number(vehicleYear) || new Date().getFullYear(),
      licensePlate: vehicleLicensePlate || 'UNKNOWN',
      vin: vehicleVin || '',
      color: vehicleColor || ''
    };

    const safeIncidentLocation = {
      address: incidentAddress || '',
      city: incidentCity || ''
    };

    // Create claim
    const claim = await Claim.create({
      userId: req.user.id,
      userEmail: user.email,
      userName: `${user.firstName} ${user.lastName}`,
      userPhone: user.phone,
      policyNumber: effectivePolicyNumber,
      vehicle: safeVehicle,
      incidentLocation: safeIncidentLocation,
      incidentDate,
      incidentTime,
      incidentDescription,
      incidentType,
      estimatedAmount,
      photos,
      policeReport,
      thirdParty,
      witnesses,
      damageAnalysis,
      status: 'pending',
      submittedAt: Date.now()
    });

    // Auto-categorize claim
    if (estimatedAmount < 1000) {
      claim.category = 'minor_repair';
      claim.priority = 'low';
    } else if (estimatedAmount < 3000) {
      claim.category = 'standard_repair';
      claim.priority = 'medium';
    } else if (estimatedAmount < 5000) {
      claim.category = 'major_repair';
      claim.priority = 'high';
    } else {
      claim.category = 'total_loss';
      claim.priority = 'critical';
    }

    // Auto-approve minor claims (under $1000 with low risk)
    if (claim.category === 'minor_repair' && photos.length >= 3) {
      claim.autoApproved = true;
      claim.status = 'approved';
      claim.approvedAmount = estimatedAmount;
      claim.approvalDate = Date.now();
      claim.approvedBy = null; // System auto-approval
    }

    await claim.save();

    res.status(201).json({
      success: true,
      message: claim.autoApproved 
        ? 'Claim submitted and auto-approved!' 
        : 'Claim submitted successfully',
      data: claim.getPublicData()
    });
  } catch (error) {
    console.error('Submit claim error:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: messages.join(', ')
      });
    }

    res.status(500).json({
      success: false,
      error: 'Could not submit claim',
      message: error.message
    });
  }
};

/**
 * @desc    Get all claims for logged in user
 * @route   GET /api/claims
 * @access  Private
 */
exports.getClaims = async (req, res) => {
  try {
    const { status, sortBy = '-submittedAt', page = 1, limit = 10 } = req.query;

    // Build query
    const query = { userId: req.user.id };
    if (status) {
      query.status = status;
    }

    // Execute query with pagination
    const claims = await Claim.find(query)
      .sort(sortBy)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    // Get total count
    const count = await Claim.countDocuments(query);

    res.status(200).json({
      success: true,
      count: claims.length,
      total: count,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      data: claims.map(c => c.getPublicData())
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve claims',
      message: error.message
    });
  }
};

/**
 * @desc    Get single claim by ID
 * @route   GET /api/claims/:id
 * @access  Private
 */
exports.getClaim = async (req, res) => {
  try {
    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Check ownership (or if user is admin/officer)
    if (
      claim.userId.toString() !== req.user.id &&
      !['admin', 'claim_officer', 'assessor'].includes(req.user.role)
    ) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view this claim'
      });
    }

    // Return full data for admins/officers, public data for customers
    const data = ['admin', 'claim_officer', 'assessor'].includes(req.user.role)
      ? claim
      : claim.getPublicData();

    res.status(200).json({
      success: true,
      data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve claim',
      message: error.message
    });
  }
};

/**
 * @desc    Update claim status
 * @route   PUT /api/claims/:id/status
 * @access  Private/Admin/Officer
 */
exports.updateClaimStatus = async (req, res) => {
  try {
    const { status, reason, notes, approvedAmount } = req.body;

    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Validate status
    const validStatuses = [
      'pending', 'documents_review', 'damage_assessment',
      'investigation', 'approved', 'rejected', 'disputed', 'settled', 'closed'
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status',
        message: `Status must be one of: ${validStatuses.join(', ')}`
      });
    }

    // Update status using method
    await claim.changeStatus(status, req.user.id, reason, notes);

    // Update approved amount if status is approved
    if (status === 'approved' && approvedAmount) {
      claim.approvedAmount = approvedAmount;
      claim.payment = {
        status: 'pending',
        amount: approvedAmount
      };
      await claim.save();
    }

    res.status(200).json({
      success: true,
      message: 'Claim status updated successfully',
      data: claim.getPublicData()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not update claim status',
      message: error.message
    });
  }
};

/**
 * @desc    Submit dispute for rejected claim
 * @route   POST /api/claims/:id/dispute
 * @access  Private
 */
exports.submitDispute = async (req, res) => {
  try {
    const { reason, notes } = req.body;

    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Check ownership
    if (claim.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to dispute this claim'
      });
    }

    // Can only dispute rejected claims
    if (claim.status !== 'rejected') {
      return res.status(400).json({
        success: false,
        error: 'Can only dispute rejected claims'
      });
    }

    // Check if already disputed
    if (claim.dispute.isDisputed) {
      return res.status(400).json({
        success: false,
        error: 'Claim already disputed',
        message: `Current dispute status: ${claim.dispute.disputeStatus}`
      });
    }

    // Process additional evidence photos if uploaded
    const evidence = [];
    if (req.files && req.files.length > 0) {
      req.files.forEach(file => {
        evidence.push(`/uploads/claims/${file.filename}`);
      });
    }

    // Submit dispute
    await claim.submitDispute({
      reason,
      notes,
      evidence
    });

    res.status(200).json({
      success: true,
      message: 'Dispute submitted successfully. We will review your case within 3-5 business days.',
      data: claim.getPublicData()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not submit dispute',
      message: error.message
    });
  }
};

/**
 * @desc    Upload photos to existing claim
 * @route   POST /api/claims/:id/photos
 * @access  Private
 */
exports.uploadClaimPhotos = async (req, res) => {
  try {
    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Check ownership or admin
    if (
      claim.userId.toString() !== req.user.id &&
      !['admin', 'claim_officer'].includes(req.user.role)
    ) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to upload photos for this claim'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Please upload at least one photo'
      });
    }

    // Add photos to claim
    req.files.forEach((file, index) => {
      claim.photos.push({
        url: `/uploads/claims/${file.filename}`,
        key: file.filename,
        type: req.body.photoTypes?.[index] || 'other',
        uploadedAt: Date.now()
      });
    });

    await claim.save();

    res.status(200).json({
      success: true,
      message: `${req.files.length} photo(s) uploaded successfully`,
      data: {
        claimNumber: claim.claimNumber,
        totalPhotos: claim.photos.length,
        newPhotos: claim.photos.slice(-req.files.length)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not upload photos',
      message: error.message
    });
  }
};

/**
 * @desc    Get photos for a claim
 * @route   GET /api/claims/:id/photos
 * @access  Private
 */
exports.getClaimPhotos = async (req, res) => {
  try {
    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Check authorization
    if (
      claim.userId.toString() !== req.user.id &&
      !['admin', 'claim_officer', 'assessor'].includes(req.user.role)
    ) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view photos for this claim'
      });
    }

    res.status(200).json({
      success: true,
      count: claim.photos.length,
      data: claim.photos.map(photo => ({
        url: photo.url,
        type: photo.type,
        uploadedAt: photo.uploadedAt,
        qualityCheck: photo.qualityCheck
      }))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve photos',
      message: error.message
    });
  }
};

/**
 * @desc    Generate PDF report for claim
 * @route   GET /api/claims/:id/report
 * @access  Private
 */
exports.generateClaimReport = async (req, res) => {
  try {
    const claim = await Claim.findById(req.params.id).populate('userId', 'firstName lastName email');

    if (!claim) {
      return res.status(404).json({
        success: false,
        error: 'Claim not found'
      });
    }

    // Check authorization
    if (
      claim.userId._id.toString() !== req.user.id &&
      !['admin', 'claim_officer'].includes(req.user.role)
    ) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to generate report for this claim'
      });
    }

    // Create PDF
    const doc = new PDFDocument({ margin: 50 });
    const fileName = `claim-report-${claim.claimNumber}.pdf`;
    const filePath = path.join(__dirname, '../uploads/reports', fileName);

    // Ensure directory exists
    if (!fs.existsSync(path.join(__dirname, '../uploads/reports'))) {
      fs.mkdirSync(path.join(__dirname, '../uploads/reports'), { recursive: true });
    }

    // Pipe to file
    doc.pipe(fs.createWriteStream(filePath));

    // Header
    doc.fontSize(20).text('AVA Insurance', { align: 'center' });
    doc.fontSize(16).text('Claim Report', { align: 'center' });
    doc.moveDown();

    // Claim Information
    doc.fontSize(14).text('Claim Information', { underline: true });
    doc.fontSize(10);
    doc.text(`Claim Number: ${claim.claimNumber}`);
    doc.text(`Status: ${claim.status.toUpperCase()}`);
    doc.text(`Submitted: ${claim.submittedAt.toLocaleDateString()}`);
    doc.text(`Priority: ${claim.priority.toUpperCase()}`);
    doc.moveDown();

    // Customer Information
    doc.fontSize(14).text('Customer Information', { underline: true });
    doc.fontSize(10);
    doc.text(`Name: ${claim.userName}`);
    doc.text(`Email: ${claim.userEmail}`);
    doc.text(`Phone: ${claim.userPhone}`);
    doc.text(`Policy Number: ${claim.policyNumber}`);
    doc.moveDown();

    // Vehicle Information
    doc.fontSize(14).text('Vehicle Information', { underline: true });
    doc.fontSize(10);
    doc.text(`Make: ${claim.vehicle.make}`);
    doc.text(`Model: ${claim.vehicle.model}`);
    doc.text(`Year: ${claim.vehicle.year}`);
    doc.text(`License Plate: ${claim.vehicle.licensePlate}`);
    if (claim.vehicle.vin) doc.text(`VIN: ${claim.vehicle.vin}`);
    doc.moveDown();

    // Incident Details
    doc.fontSize(14).text('Incident Details', { underline: true });
    doc.fontSize(10);
    doc.text(`Date: ${new Date(claim.incidentDate).toLocaleDateString()}`);
    if (claim.incidentTime) doc.text(`Time: ${claim.incidentTime}`);
    doc.text(`Type: ${claim.incidentType.replace('_', ' ').toUpperCase()}`);
    if (claim.incidentLocation.address) {
      doc.text(`Location: ${claim.incidentLocation.address}, ${claim.incidentLocation.city || ''}`);
    }
    doc.text(`Description: ${claim.incidentDescription}`, {
      width: 500,
      align: 'justify'
    });
    doc.moveDown();

    // Damage Analysis (if available)
    if (claim.damageAnalysis && claim.damageAnalysis.damages) {
      doc.fontSize(14).text('Damage Assessment', { underline: true });
      doc.fontSize(10);
      doc.text(`Total Damages Found: ${claim.damageAnalysis.totalDamages || 0}`);
      doc.text(`Overall Severity: ${claim.damageAnalysis.overallSeverity || 'N/A'}`.toUpperCase());
      doc.text(`Vehicle Drivable: ${claim.damageAnalysis.drivable ? 'Yes' : 'No'}`);
      
      if (claim.damageAnalysis.damages.length > 0) {
        doc.text('\nDamage Details:');
        claim.damageAnalysis.damages.forEach((damage, index) => {
          doc.text(`  ${index + 1}. ${damage.type.toUpperCase()} - ${damage.severity} (${damage.location})`);
          if (damage.estimatedCost) {
            doc.text(`     Est. Cost: $${damage.estimatedCost.min} - $${damage.estimatedCost.max}`);
          }
        });
      }
      doc.moveDown();
    }

    // Financial Information
    doc.fontSize(14).text('Financial Information', { underline: true });
    doc.fontSize(10);
    doc.text(`Estimated Amount: $${claim.estimatedAmount.toFixed(2)}`);
    if (claim.approvedAmount) {
      doc.text(`Approved Amount: $${claim.approvedAmount.toFixed(2)}`);
    }
    if (claim.damageAnalysis?.totalEstimatedCost) {
      doc.text(`AI Estimate: $${claim.damageAnalysis.totalEstimatedCost.min} - $${claim.damageAnalysis.totalEstimatedCost.max}`);
    }
    doc.moveDown();

    // Status History
    if (claim.statusHistory && claim.statusHistory.length > 0) {
      doc.fontSize(14).text('Status History', { underline: true });
      doc.fontSize(10);
      claim.statusHistory.forEach(history => {
        doc.text(`${new Date(history.changedAt).toLocaleDateString()} - ${history.status.toUpperCase()}`);
        if (history.reason) doc.text(`  Reason: ${history.reason}`);
      });
      doc.moveDown();
    }

    // Photos
    if (claim.photos && claim.photos.length > 0) {
      doc.fontSize(14).text('Attached Photos', { underline: true });
      doc.fontSize(10);
      doc.text(`Total Photos: ${claim.photos.length}`);
      claim.photos.forEach((photo, index) => {
        doc.text(`  ${index + 1}. ${photo.type.toUpperCase()} - Uploaded: ${new Date(photo.uploadedAt).toLocaleDateString()}`);
      });
    }

    // Footer
    doc.moveDown(2);
    doc.fontSize(8).text(
      `This report was generated on ${new Date().toLocaleDateString()} at ${new Date().toLocaleTimeString()}`,
      { align: 'center' }
    );
    doc.text('AVA Insurance - Claim Management System', { align: 'center' });

    // Finalize PDF
    doc.end();

    // Wait for file to be written
    doc.on('finish', () => {
      res.download(filePath, fileName, (err) => {
        if (err) {
          console.error('Download error:', err);
          res.status(500).json({
            success: false,
            error: 'Could not download report'
          });
        }
        // Clean up file after download
        fs.unlinkSync(filePath);
      });
    });
  } catch (error) {
    console.error('Generate report error:', error);
    res.status(500).json({
      success: false,
      error: 'Could not generate report',
      message: error.message
    });
  }
};

/**
 * @desc    Get claim statistics (Admin)
 * @route   GET /api/claims/stats
 * @access  Private/Admin
 */
exports.getClaimStatistics = async (req, res) => {
  try {
    const userId = req.user.role === 'customer' ? req.user.id : null;
    const stats = await Claim.getStatistics(userId);

    res.status(200).json({
      success: true,
      data: stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Could not retrieve statistics',
      message: error.message
    });
  }
};

module.exports = exports;