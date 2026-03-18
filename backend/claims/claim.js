/**
 * AVA Claim Model
 * Comprehensive insurance claim schema
 */

const mongoose = require('mongoose');

const ClaimSchema = new mongoose.Schema({
  // Claim Identification
  claimNumber: {
    type: String,
    unique: true,
    required: true
  },
  
  // User Reference
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  
  // User Details (denormalized for faster access)
  userEmail: {
    type: String,
    required: true
  },
  
  userName: {
    type: String,
    required: true
  },
  
  userPhone: {
    type: String,
    required: true
  },
  
  // Policy Details
  policyNumber: {
    type: String,
    required: [true, 'Policy number is required']
  },
  
  // Vehicle Information
  vehicle: {
    make: {
      type: String,
      required: true
    },
    model: {
      type: String,
      required: true
    },
    year: {
      type: Number,
      required: true
    },
    licensePlate: {
      type: String,
      required: true
    },
    vin: String,
    color: String
  },
  
  // Incident Details
  incidentDate: {
    type: Date,
    required: [true, 'Incident date is required']
  },
  
  incidentTime: String,
  
  incidentLocation: {
    address: String,
    city: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  
  incidentDescription: {
    type: String,
    required: [true, 'Please describe what happened'],
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  
  incidentType: {
    type: String,
    enum: ['collision', 'theft', 'vandalism', 'natural_disaster', 'hit_and_run', 'fire', 'other'],
    required: true
  },
  
  // Photos and Evidence
  photos: [{
    url: {
      type: String,
      required: true
    },
    key: String, // S3 key or storage identifier
    type: {
      type: String,
      enum: ['front', 'rear', 'left', 'right', 'damage_closeup', 'scene', 'other'],
      default: 'other'
    },
    uploadedAt: {
      type: Date,
      default: Date.now
    },
    qualityCheck: {
      passed: Boolean,
      score: Number,
      issues: [String]
    }
  }],
  
  // Damage Assessment (from AI)
  damageAnalysis: {
    totalDamages: Number,
    damages: [{
      type: String,
      severity: String,
      location: String,
      estimatedCost: {
        min: Number,
        max: Number
      },
      boundingBox: {
        x: Number,
        y: Number,
        width: Number,
        height: Number
      }
    }],
    overallSeverity: {
      type: String,
      enum: ['minor', 'moderate', 'severe', 'critical']
    },
    drivable: Boolean,
    requiresProfessionalInspection: Boolean,
    totalEstimatedCost: {
      min: Number,
      max: Number
    },
    confidence: Number,
    analyzedAt: Date
  },
  
  // Claim Assessment
  estimatedAmount: {
    type: Number,
    required: true
  },
  
  approvedAmount: Number,
  
  // Claim Status
  status: {
    type: String,
    enum: [
      'pending',           // Just submitted
      'documents_review',  // Reviewing documents
      'damage_assessment', // AI/Manual assessment
      'investigation',     // Fraud check
      'approved',          // Claim approved
      'rejected',          // Claim rejected
      'disputed',          // User disputed rejection
      'settled',           // Payment completed
      'closed'            // Claim closed
    ],
    default: 'pending'
  },
  
  statusHistory: [{
    status: String,
    changedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    changedAt: {
      type: Date,
      default: Date.now
    },
    reason: String,
    notes: String
  }],
  
  // Priority
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  
  // Assignment
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  
  assignedAt: Date,
  
  // Dispute Information
  dispute: {
    isDisputed: {
      type: Boolean,
      default: false
    },
    disputeReason: String,
    disputeDate: Date,
    disputeEvidence: [String], // Additional photo URLs
    disputeNotes: String,
    disputeStatus: {
      type: String,
      enum: ['pending', 'under_review', 'resolved', 'rejected']
    },
    resolvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    resolvedAt: Date,
    resolution: String
  },
  
  // Notes and Communication
  internalNotes: [{
    note: String,
    addedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  customerNotes: [{
    note: String,
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Rejection Details
  rejectionReason: String,
  rejectionDate: Date,
  rejectedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  
  // Approval Details
  approvalDate: Date,
  approvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  
  // Payment Information
  payment: {
    method: {
      type: String,
      enum: ['bank_transfer', 'check', 'direct_deposit']
    },
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'failed']
    },
    amount: Number,
    paidAt: Date,
    transactionId: String,
    bankDetails: {
      accountNumber: String,
      bankName: String,
      accountHolderName: String
    }
  },
  
  // Police Report
  policeReport: {
    filed: {
      type: Boolean,
      default: false
    },
    reportNumber: String,
    policeStation: String,
    officerName: String,
    reportDate: Date,
    reportUrl: String // PDF upload
  },
  
  // Third Party (if involved)
  thirdParty: {
    involved: {
      type: Boolean,
      default: false
    },
    name: String,
    contact: String,
    insuranceCompany: String,
    policyNumber: String,
    vehicleDetails: String
  },
  
  // Witness Information
  witnesses: [{
    name: String,
    contact: String,
    statement: String
  }],
  
  // Timestamps
  submittedAt: {
    type: Date,
    default: Date.now
  },
  
  lastUpdatedAt: {
    type: Date,
    default: Date.now
  },
  
  closedAt: Date,
  
  // Metadata
  category: {
    type: String,
    enum: ['minor_repair', 'standard_repair', 'major_repair', 'total_loss'],
    default: 'standard_repair'
  },
  
  autoApproved: {
    type: Boolean,
    default: false
  },
  
  fraudRisk: {
    level: {
      type: String,
      enum: ['low', 'medium', 'high']
    },
    score: Number,
    flags: [String]
  }
}, {
  timestamps: true
});


// INDEXES
ClaimSchema.index({ userId: 1, submittedAt: -1 });
ClaimSchema.index({ claimNumber: 1 });
ClaimSchema.index({ status: 1 });
ClaimSchema.index({ assignedTo: 1 });
ClaimSchema.index({ 'vehicle.licensePlate': 1 });


// PRE-SAVE MIDDLEWARE

// Generate unique claim number
ClaimSchema.pre('save', async function(next) {
  if (this.isNew && !this.claimNumber) {
    const year = new Date().getFullYear();
    const count = await this.constructor.countDocuments();
    this.claimNumber = `AVA-CLM-${year}-${String(count + 1).padStart(6, '0')}`;
  }
  
  this.lastUpdatedAt = Date.now();
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

/**
 * Add status change to history
 */
ClaimSchema.methods.changeStatus = async function(newStatus, userId, reason, notes) {
  this.statusHistory.push({
    status: this.status, // Old status
    changedBy: userId,
    changedAt: Date.now(),
    reason,
    notes
  });
  
  this.status = newStatus;
  
  // Set specific dates based on status
  if (newStatus === 'approved') {
    this.approvalDate = Date.now();
    this.approvedBy = userId;
  } else if (newStatus === 'rejected') {
    this.rejectionDate = Date.now();
    this.rejectedBy = userId;
    this.rejectionReason = reason;
  } else if (newStatus === 'closed') {
    this.closedAt = Date.now();
  }
  
  await this.save();
  return this;
};

/**
 * Add internal note
 */
ClaimSchema.methods.addInternalNote = async function(note, userId) {
  this.internalNotes.push({
    note,
    addedBy: userId,
    addedAt: Date.now()
  });
  await this.save();
  return this;
};

/**
 * Add customer note
 */
ClaimSchema.methods.addCustomerNote = async function(note) {
  this.customerNotes.push({
    note,
    addedAt: Date.now()
  });
  await this.save();
  return this;
};

/**
 * Submit dispute
 */
ClaimSchema.methods.submitDispute = async function(disputeData) {
  this.dispute = {
    isDisputed: true,
    disputeReason: disputeData.reason,
    disputeDate: Date.now(),
    disputeEvidence: disputeData.evidence || [],
    disputeNotes: disputeData.notes,
    disputeStatus: 'pending'
  };
  
  this.status = 'disputed';
  await this.save();
  return this;
};

/**
 * Get public claim data (for customer)
 */
ClaimSchema.methods.getPublicData = function() {
  return {
    id: this._id,
    claimNumber: this.claimNumber,
    status: this.status,
    vehicle: this.vehicle,
    incidentDate: this.incidentDate,
    incidentDescription: this.incidentDescription,
    estimatedAmount: this.estimatedAmount,
    approvedAmount: this.approvedAmount,
    photos: this.photos.map(p => ({
      url: p.url,
      type: p.type,
      uploadedAt: p.uploadedAt
    })),
    damageAnalysis: this.damageAnalysis,
    submittedAt: this.submittedAt,
    lastUpdatedAt: this.lastUpdatedAt,
    statusHistory: this.statusHistory.map(h => ({
      status: h.status,
      changedAt: h.changedAt,
      reason: h.reason
    })),
    dispute: this.dispute.isDisputed ? {
      status: this.dispute.disputeStatus,
      reason: this.dispute.disputeReason,
      disputeDate: this.dispute.disputeDate
    } : null,
    payment: this.payment.status ? {
      status: this.payment.status,
      amount: this.payment.amount,
      paidAt: this.payment.paidAt
    } : null
  };
};


// STATIC METHODS
/**
 * Get claims summary statistics
 */
ClaimSchema.statics.getStatistics = async function(userId = null) {
  const match = userId ? { userId } : {};
  
  const stats = await this.aggregate([
    { $match: match },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 },
        totalAmount: { $sum: '$estimatedAmount' }
      }
    }
  ]);
  
  return stats;
};

module.exports = mongoose.model('Claim', ClaimSchema);