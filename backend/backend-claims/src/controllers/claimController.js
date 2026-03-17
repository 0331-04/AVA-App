const Claim = require('../models/Claim');
const PDFDocument = require('pdfkit');

// Submit new claim
exports.submitClaim = async (req, res) => {
  try {
    const { incidentDate, incidentLocation, incidentDescription, damageType } = req.body;

    const claim = new Claim({
      userId: req.user.id,
      incidentDate,
      incidentLocation,
      incidentDescription,
      damageType,
      status: 'submitted'
    });

    await claim.save();

    res.status(201).json({
      success: true,
      message: 'Claim submitted successfully',
      data: { claim }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get all user claims
exports.getUserClaims = async (req, res) => {
  try {
    const claims = await Claim.find({ userId: req.user.id })
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: { claims }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get single claim
exports.getClaimById = async (req, res) => {
  try {
    const claim = await Claim.findOne({
      _id: req.params.id,
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
      data: { claim }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Update claim status
exports.updateClaimStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const claim = await Claim.findById(req.params.id);

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: 'Claim not found'
      });
    }

    claim.status = status;
    claim.updatedAt = new Date();
    await claim.save();

    res.json({
      success: true,
      message: 'Claim status updated',
      data: { claim }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Submit dispute
exports.submitDispute = async (req, res) => {
  try {
    const { reason } = req.body;

    const claim = await Claim.findOne({
      _id: req.params.id,
      userId: req.user.id
    });

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: 'Claim not found'
      });
    }

    if (claim.status !== 'rejected') {
      return res.status(400).json({
        success: false,
        message: 'Can only dispute rejected claims'
      });
    }

    claim.dispute = {
      reason,
      submittedAt: new Date(),
      resolved: false
    };

    await claim.save();

    res.json({
      success: true,
      message: 'Dispute submitted',
      data: { claim }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Generate PDF report
exports.generateReport = async (req, res) => {
  try {
    const claim = await Claim.findOne({
      _id: req.params.id,
      userId: req.user.id
    });

    if (!claim) {
      return res.status(404).json({
        success: false,
        message: 'Claim not found'
      });
    }

    const doc = new PDFDocument();

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=claim-${claim.claimNumber}.pdf`);

    doc.pipe(res);

    doc.fontSize(20).text('Insurance Claim Report', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12);
    doc.text(`Claim Number: ${claim.claimNumber}`);
    doc.text(`Status: ${claim.status.toUpperCase()}`);
    doc.text(`Submitted: ${claim.submittedAt.toLocaleDateString()}`);
    doc.moveDown();
    doc.text(`Incident Date: ${claim.incidentDate.toLocaleDateString()}`);
    doc.text(`Location: ${claim.incidentLocation?.address || 'N/A'}`);
    doc.text(`Description: ${claim.incidentDescription}`);
    doc.moveDown();

    if (claim.analysis?.costBreakdown) {
      doc.text('Cost Breakdown:', { underline: true });
      doc.text(`Labour: LKR ${claim.analysis.costBreakdown.labour.toLocaleString()}`);
      doc.text(`Parts: LKR ${claim.analysis.costBreakdown.parts.toLocaleString()}`);
      doc.text(`Paint: LKR ${claim.analysis.costBreakdown.paint.toLocaleString()}`);
      doc.text(`Total: LKR ${claim.analysis.costBreakdown.total.toLocaleString()}`, { bold: true });
    }

    doc.end();
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
