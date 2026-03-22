import 'package:flutter/material.dart';
import '../../services/claim_service.dart';

// Claim Status data model
class ClaimStatusData {
  final String claimId;
  final String vehicle;
  final String licensePlate;
  final String damageType;
  final String submittedDate;
  final String estimatedCompletion;
  final int estimateLKR;
  final int labourLKR;
  final int partsLKR;
  final int otherLKR;
  final double aiConfidence;
  final String currentStatus;
  final int currentStepIndex;
  final List<String> assessorNotes;
  final int photosUploaded;

  const ClaimStatusData({
    required this.claimId,
    required this.vehicle,
    required this.licensePlate,
    required this.damageType,
    required this.submittedDate,
    required this.estimatedCompletion,
    required this.estimateLKR,
    required this.labourLKR,
    required this.partsLKR,
    required this.otherLKR,
    required this.aiConfidence,
    required this.currentStatus,
    required this.currentStepIndex,
    required this.assessorNotes,
    required this.photosUploaded,
  });
}

ClaimStatusData _emptyClaim() => const ClaimStatusData(
      claimId: 'No Claims',
      vehicle: 'No vehicle data',
      licensePlate: 'N/A',
      damageType: 'No damage data',
      submittedDate: 'N/A',
      estimatedCompletion: 'Pending',
      estimateLKR: 0,
      labourLKR: 0,
      partsLKR: 0,
      otherLKR: 0,
      aiConfidence: 0.0,
      currentStatus: 'Submitted',
      currentStepIndex: 0,
      assessorNotes: ['No claim has been submitted yet.'],
      photosUploaded: 0,
    );

String _formatDate(dynamic value) {
  if (value == null) return 'N/A';
  final raw = value.toString();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
}

String _displayStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Submitted';
    case 'documents_review':
      return 'In Review';
    case 'damage_assessment':
      return 'Assessment';
    case 'investigation':
      return 'In Review';
    case 'approved':
      return 'Approved';
    case 'rejected':
      return 'Rejected';
    case 'settled':
    case 'closed':
      return 'Payment Processing';
    case 'disputed':
      return 'In Review';
    default:
      return status;
  }
}

int _stepFromStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0;
    case 'documents_review':
    case 'investigation':
      return 1;
    case 'damage_assessment':
      return 2;
    case 'approved':
    case 'rejected':
    case 'settled':
    case 'closed':
      return 3;
    default:
      return 0;
  }
}

Map<String, dynamic> _latestClaim(List<Map<String, dynamic>> claims) {
  if (claims.isEmpty) return {};
  final sorted = List<Map<String, dynamic>>.from(claims);
  sorted.sort((a, b) {
    final aDate = DateTime.tryParse((a['submittedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = DateTime.tryParse((b['submittedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return sorted.first;
}

ClaimStatusData _claimStatusFromApi(Map<String, dynamic> c) {
  final vehicle = (c['vehicle'] as Map?) ?? {};
  final make = (vehicle['make'] ?? '').toString();
  final model = (vehicle['model'] ?? '').toString();
  final year = (vehicle['year'] ?? '').toString();
  final plate = (vehicle['licensePlate'] ?? 'N/A').toString();

  final vehicleText =
      [make, model, year].where((e) => e.trim().isNotEmpty).join(' ');

  final estimatedAmount = c['estimatedAmount'];
  final estimatedAmountValue = estimatedAmount is num
      ? estimatedAmount.toInt()
      : int.tryParse(estimatedAmount?.toString() ?? '') ?? 0;

  final damageAnalysis = (c['damageAnalysis'] as Map?) ?? {};
  final totalEstimatedCost = (damageAnalysis['totalEstimatedCost'] as Map?) ?? {};
  final aiConfidenceRaw = damageAnalysis['confidence'];
  final aiConfidence = aiConfidenceRaw is num
      ? aiConfidenceRaw.toDouble()
      : double.tryParse(aiConfidenceRaw?.toString() ?? '') ?? 0.0;

  final minEstimate = totalEstimatedCost['min'] is num
      ? (totalEstimatedCost['min'] as num).toInt()
      : 0;
  final maxEstimate = totalEstimatedCost['max'] is num
      ? (totalEstimatedCost['max'] as num).toInt()
      : 0;

  final total = maxEstimate > 0 ? maxEstimate : estimatedAmountValue;
  final parts = total > 0 ? (total * 0.50).toInt() : 0;
  final labour = total > 0 ? (total * 0.30).toInt() : 0;
  final other = total > 0 ? (total - labour - parts).clamp(0, total) : 0;

  final photos = c['photos'];
  final status = (c['status'] ?? 'pending').toString();
  final incidentDescription =
      (c['incidentDescription'] ?? 'No description').toString();

  final damagesRaw = damageAnalysis['damages'];
  final damages = damagesRaw is List
      ? damagesRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
      : <String>[];

  final severity = (damageAnalysis['overallSeverity'] ?? '').toString();
  final drivable = damageAnalysis['drivable'];
  final needsInspection = damageAnalysis['requiresProfessionalInspection'];

  final notes = <String>[
    'Status: ${_displayStatus(status)}',
    if (incidentDescription.isNotEmpty) incidentDescription,
    if (severity.isNotEmpty)
      'AI severity: ${severity[0].toUpperCase()}${severity.substring(1)}',
    if (damages.isNotEmpty)
      'Detected damages: ${damages.join(', ')}',
    if (minEstimate > 0 || maxEstimate > 0)
      'Estimated repair cost: ${ClaimStatusScreen.formatLKR(minEstimate)} - ${ClaimStatusScreen.formatLKR(maxEstimate)}',
    if (drivable is bool)
      drivable ? 'Vehicle likely drivable' : 'Vehicle may not be safely drivable',
    if (needsInspection is bool && needsInspection)
      'Professional inspection recommended',
  ];

  return ClaimStatusData(
    claimId: '#${(c['claimNumber'] ?? c['id'] ?? 'Unknown').toString()}',
    vehicle: vehicleText.isEmpty ? 'Unknown Vehicle' : vehicleText,
    licensePlate: plate,
    damageType: incidentDescription,
    submittedDate: _formatDate(c['submittedAt']),
    estimatedCompletion: _displayStatus(status) == 'Approved'
        ? 'Completed'
        : _displayStatus(status) == 'Payment Processing'
            ? 'Finalizing'
            : 'Pending',
    estimateLKR: total,
    labourLKR: labour,
    partsLKR: parts,
    otherLKR: other,
    aiConfidence: aiConfidence,
    currentStatus: _displayStatus(status),
    currentStepIndex: _stepFromStatus(status),
    assessorNotes: notes,
    photosUploaded: photos is List ? photos.length : 0,
  );
}

class ClaimStatusScreen extends StatefulWidget {
  final String? accessToken;
  final ClaimStatusData? claim;

  const ClaimStatusScreen({
    super.key,
    this.accessToken,
    this.claim,
  });

  static String formatLKR(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return 'LKR ${result.toString()}';
  }

  @override
  State<ClaimStatusScreen> createState() => _ClaimStatusScreenState();
}

class _ClaimStatusScreenState extends State<ClaimStatusScreen> {
  final ClaimService _claimService = ClaimService();
  late ClaimStatusData _claim;
  List<ClaimStatusData> _claims = [];
  int _selectedClaimIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _claim = widget.claim ?? _emptyClaim();
    if (widget.claim != null) {
      _claims = [widget.claim!];
      _selectedClaimIndex = 0;
      _isLoading = false;
    } else {
      _loadClaim();
    }
  }

  Future<void> _loadClaim() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _claim = _emptyClaim();
        _isLoading = false;
        _error = 'Missing access token';
      });
      return;
    }

    try {
      final claims = await _claimService.getClaims(accessToken: widget.accessToken!);
      if (!mounted) return;

      if (claims.isEmpty) {
        setState(() {
          _claims = [_emptyClaim()];
          _selectedClaimIndex = 0;
          _claim = _claims.first;
          _isLoading = false;
          _error = null;
        });
        return;
      }

      final sorted = List<Map<String, dynamic>>.from(claims);
      sorted.sort((a, b) {
        final aDate = DateTime.tryParse((a['submittedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse((b['submittedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      final mappedClaims = sorted.map(_claimStatusFromApi).toList();

      setState(() {
        _claims = mappedClaims;
        _selectedClaimIndex = 0;
        _claim = _claims.first;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _claims = [_emptyClaim()];
        _selectedClaimIndex = 0;
        _claim = _claims.first;
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final claim = _claims.isNotEmpty
        ? _claims[_selectedClaimIndex.clamp(0, _claims.length - 1)]
        : _claim;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF004AAD),
              ),
            )
          : Column(
              children: [
                _StatusHeader(claim: claim),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF004AAD),
                    onRefresh: _loadClaim,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        children: [
                          if (_claims.length > 1)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select Claim',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _claims.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (_, index) {
                                        final item = _claims[index];
                                        final isSelected = index == _selectedClaimIndex;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedClaimIndex = index;
                                              _claim = _claims[index];
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF004AAD)
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF004AAD)
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                item.claimId,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _VehicleCard(claim: claim),
                          const SizedBox(height: 14),
                          _TimelineStepper(currentStep: claim.currentStepIndex),
                          const SizedBox(height: 14),
                          _AIConfidenceCard(confidence: claim.aiConfidence),
                          const SizedBox(height: 14),
                          _CostBreakdownCard(claim: claim),
                          const SizedBox(height: 14),
                          _PhotoStripCard(photosUploaded: claim.photosUploaded),
                          const SizedBox(height: 14),
                          _AssessorNotesCard(notes: claim.assessorNotes),
                          const SizedBox(height: 14),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          _ActionButtons(claim: claim),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ----------------------------------------------------------
// HEADER
// ----------------------------------------------------------
class _StatusHeader extends StatelessWidget {
  final ClaimStatusData claim;
  const _StatusHeader({required this.claim});

  Color get _statusColor {
    switch (claim.currentStatus) {
      case 'Approved':
        return Colors.green.shade600;
      case 'Rejected':
        return Colors.red.shade600;
      case 'Payment Processing':
        return Colors.blue.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 215,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const Text(
                      'AVA-Inspec',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Text(
                        claim.currentStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Claim Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color(0x40000000),
                      ),
                    ],
                  ),
                ),
                Text(
                  claim.claimId,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    fontFamily: 'WorkSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 45);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper old) => false;
}

class _VehicleCard extends StatelessWidget {
  final ClaimStatusData claim;
  const _VehicleCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2389),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim.vehicle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'License Plate: ${claim.licensePlate}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepper extends StatelessWidget {
  final int currentStep;
  const _TimelineStepper({required this.currentStep});

  static const _steps = [
    {'label': 'Submitted', 'icon': Icons.upload_file_outlined},
    {'label': 'In Review', 'icon': Icons.manage_search_outlined},
    {'label': 'Assessment', 'icon': Icons.analytics_outlined},
    {'label': 'Decision', 'icon': Icons.gavel_outlined},
  ];

  static const _descriptions = [
    'Claim received & photos verified by AI',
    'Human assessor reviewing your case',
    'Damage cost estimated & confirmed',
    'Final approval & payment initiated',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claim Progress',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final done = i < currentStep;
            final active = i == currentStep;
            final isLast = i == _steps.length - 1;
            final label = _steps[i]['label'] as String;
            final icon = _steps[i]['icon'] as IconData;
            final desc = _descriptions[i];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? Colors.green
                            : active
                                ? const Color(0xFF004AAD)
                                : Colors.grey.shade200,
                        border: Border.all(
                          color: done
                              ? Colors.green
                              : active
                                  ? const Color(0xFF004AAD)
                                  : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        done ? Icons.check : icon,
                        color: done || active ? Colors.white : Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: done ? Colors.green.shade300 : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: done
                                ? Colors.green.shade700
                                : active
                                    ? const Color(0xFF004AAD)
                                    : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            color: active ? Colors.black54 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _AIConfidenceCard extends StatelessWidget {
  final double confidence;
  const _AIConfidenceCard({required this.confidence});

  Color get _confidenceColor {
    if (confidence >= 0.85) return Colors.green.shade600;
    if (confidence >= 0.65) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String get _confidenceLabel {
    if (confidence >= 0.85) return 'High Confidence';
    if (confidence >= 0.65) return 'Medium Confidence';
    return 'Low Confidence';
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _confidenceColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _confidenceColor.withOpacity(0.4)),
            ),
            child: Icon(Icons.auto_awesome, color: _confidenceColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Analysis Score',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_confidenceColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: _confidenceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _confidenceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _confidenceLabel,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: _confidenceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostBreakdownCard extends StatelessWidget {
  final ClaimStatusData claim;
  const _CostBreakdownCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Damage Estimation',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.monetization_on_outlined,
                  color: Colors.grey.shade400, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          _CostRow(label: 'Labour', amount: claim.labourLKR, color: Colors.blue.shade400),
          const SizedBox(height: 8),
          _CostRow(label: 'Parts', amount: claim.partsLKR, color: Colors.purple.shade400),
          const SizedBox(height: 8),
          _CostRow(label: 'Other', amount: claim.otherLKR, color: Colors.orange.shade400),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimate',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                ClaimStatusScreen.formatLKR(claim.estimateLKR),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004AAD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a preliminary AI-generated estimate. Final amount may vary after physical assessment.',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      color: Colors.amber.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _CostRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          ClaimStatusScreen.formatLKR(amount),
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _PhotoStripCard extends StatelessWidget {
  final int photosUploaded;
  const _PhotoStripCard({required this.photosUploaded});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Uploaded Photos',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$photosUploaded photos',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photosUploaded,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2389).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: const Color(0xFF2C2389).withOpacity(0.6),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Photo ${i + 1}',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessorNotesCard extends StatelessWidget {
  final List<String> notes;
  const _AssessorNotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.rate_review_outlined,
                  color: Color(0xFF004AAD), size: 18),
              SizedBox(width: 8),
              Text(
                'Assessor Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFF004AAD)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ClaimStatusData claim;
  const _ActionButtons({required this.claim});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF004AAD).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF004AAD).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF004AAD), size: 16),
              const SizedBox(width: 10),
              const Text(
                'Estimated completion: ',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                ),
              ),
              Text(
                claim.estimatedCompletion,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004AAD),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report download coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF004AAD), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.download_outlined,
                color: Color(0xFF004AAD), size: 18),
            label: const Text(
              'Download Report',
              style: TextStyle(
                color: Color(0xFF004AAD),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contacting assessor — coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.support_agent_outlined,
                color: Colors.white, size: 18),
            label: const Text(
              'Contact Assessor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
