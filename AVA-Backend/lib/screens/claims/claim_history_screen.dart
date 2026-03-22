import 'package:flutter/material.dart';
import '../claims/claim_detail_screen.dart';
import '../../services/claim_service.dart';


// ── Claim data model
class ClaimRecord {
  final String claimId;
  final String vehicle;
  final String licensePlate;
  final String damageType;
  final String submittedDate;
  final DateTime submittedAt;
  final int estimateLKR;       // Amount in Sri Lankan Rupees
  final double progress;       // 0.0 to 1.0
  final String status;
  final int photosUploaded;

  const ClaimRecord({
    required this.claimId,
    required this.vehicle,
    required this.licensePlate,
    required this.damageType,
    required this.submittedDate,
    required this.submittedAt,
    required this.estimateLKR,
    required this.progress,
    required this.status,
    required this.photosUploaded,
  });
}

double _progressFromStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0.20;
    case 'documents_review':
      return 0.40;
    case 'damage_assessment':
      return 0.60;
    case 'investigation':
      return 0.75;
    case 'approved':
    case 'settled':
    case 'closed':
      return 1.0;
    case 'rejected':
      return 1.0;
    case 'disputed':
      return 0.85;
    default:
      return 0.30;
  }
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

String _formatDate(dynamic value) {
  if (value == null) return 'Unknown';
  final raw = value.toString();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
}

ClaimRecord _claimFromApi(Map<String, dynamic> c) {
  final vehicle = (c['vehicle'] as Map?) ?? {};
  final make = (vehicle['make'] ?? '').toString();
  final model = (vehicle['model'] ?? '').toString();
  final year = (vehicle['year'] ?? '').toString();
  final plate = (vehicle['licensePlate'] ?? '').toString();
  final incidentType = (
    c['incidentType'] ??
    c['damageType'] ??
    c['description'] ??
    c['incidentDescription'] ??
    'Unknown damage'
  ).toString();
  final estimatedAmount =
      c['estimatedAmount'] ??
      c['estimate'] ??
      c['totalEstimate'] ??
      0;
  final status = (c['status'] ?? 'pending').toString();
  final photos = c['photos'];
  final claimNumber = (c['claimNumber'] ?? c['id'] ?? '').toString();
  final rawDate = DateTime.tryParse(c['submittedAt']?.toString() ?? '');

  final vehicleText = [
    make,
    model,
    if (year.isNotEmpty) '($year)',
  ].where((e) => e.trim().isNotEmpty).join(' ');

  final amount = estimatedAmount is num
      ? estimatedAmount.toInt()
      : int.tryParse(estimatedAmount?.toString() ?? '') ?? 0;
  final photoCount = photos is List ? photos.length : 0;

  return ClaimRecord(
    claimId: claimNumber.isEmpty ? 'Unknown' : '#$claimNumber',
    vehicle: vehicleText.isEmpty ? 'Unknown Vehicle' : vehicleText,
    licensePlate: plate.isEmpty ? 'N/A' : plate,
    damageType: incidentType.replaceAll('_', ' '),
    submittedDate: _formatDate(c['submittedAt']),
    submittedAt: rawDate ?? DateTime.now(),
    estimateLKR: amount,
    progress: _progressFromStatus(status),
    status: _displayStatus(status),
    photosUploaded: photoCount,
  );
}

// ── Convert ClaimRecord to ClaimDetail for navigation ────────
ClaimDetail _recordToDetail(ClaimRecord r) {
  // TODO: Replace with real backend fetch: await claimService.getDetail(r.claimId)
  final stepMap = {
    'Submitted':           0,
    'In Review':           1,
    'Assessment':          2,
    'Approved':            3,
    'Payment Processing':  3,
    'Rejected':            3,
  };
  final labourPct  = 0.25;
  final partsPct   = 0.65;
  final otherPct   = 0.10;
  return ClaimDetail(
    claimId:              r.claimId,
    vehicle:              r.vehicle,
    licensePlate:         r.licensePlate,
    damageArea:           r.damageType,
    damageDescription:    'Description not available — tap to view full report.',
    submittedDate:        r.submittedDate,
    estimatedCompletion:  'Pending',
    location:             '',
    estimateLKR:          r.estimateLKR,
    labourLKR:            (r.estimateLKR * labourPct).toInt(),
    partsLKR:             (r.estimateLKR * partsPct).toInt(),
    otherLKR:             (r.estimateLKR * otherPct).toInt(),
    aiConfidence:         0.88,
    status:               r.status,
    currentStepIndex:     stepMap[r.status] ?? 1,
    photosUploaded:       r.photosUploaded,
    assessorNotes:        ['Assessment in progress — notes will appear here once reviewed.'],
  );
}

class ClaimHistoryScreen extends StatefulWidget {
  final String? accessToken;

  const ClaimHistoryScreen({
    super.key,
    this.accessToken,
  });

  @override
  State<ClaimHistoryScreen> createState() => _ClaimHistoryScreenState();
}

class _ClaimHistoryScreenState extends State<ClaimHistoryScreen> {
  final ClaimService _claimService = ClaimService();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ClaimRecord> _claims = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const _filters = ['All', 'Active', 'Completed', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  List<ClaimRecord> get _filteredClaims {
    return _claims.where((c) {
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' &&
              (c.status == 'In Review' || c.status == 'Submitted')) ||
          (_selectedFilter == 'Completed' &&
              (c.status == 'Approved' ||
                  c.status == 'Payment Processing')) ||
          (_selectedFilter == 'Rejected' && c.status == 'Rejected');

      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.vehicle.toLowerCase().contains(q) ||
          c.claimId.toLowerCase().contains(q) ||
          c.licensePlate.toLowerCase().contains(q) ||
          c.damageType.toLowerCase().contains(q) ||
          c.status.toLowerCase().contains(q);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _loadClaims() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _claims = [];
        _isLoading = false;
        _errorMessage = 'No access token found';
      });
      return;
    }

    try {
      final result = await _claimService.getClaims(
        accessToken: widget.accessToken!,
      );

      if (!mounted) return;
      setState(() {
        _claims = result.map(_claimFromApi).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _claims = [];
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadClaims();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claims = _filteredClaims;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Blue header 
          _ClaimHistoryHeader(),

          // ── Search bar 
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by vehicle, claim ID or plate...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF004AAD), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF004AAD), width: 1.5),
                ),
              ),
            ),
          ),

          // ── Filter tabs 
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final filter = _filters[i];
                final isActive = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF004AAD)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF004AAD)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color:
                            isActive ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Claims count label 
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '${claims.length} claim${claims.length != 1 ? "s" : ""} found',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Claims list 
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004AAD),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF004AAD),
                    onRefresh: _onRefresh,
                    child: claims.isEmpty
                        ? _EmptyState(
                            filter: _selectedFilter,
                            message: _errorMessage,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: claims.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) => _ClaimCard(
                              claim: claims[i],
                              onTap: () {
                                final detail = _recordToDetail(claims[i]);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ClaimDetailScreen(claim: detail),
                                ));
                              },
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
//  BLUE HEADER
// ----------------------------------------------------------
class _ClaimHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 175,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Row(
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
                    const SizedBox(width: 10),
                    const Text(
                      'AVA-Inspec',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Claim History',
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
                  'All your past and active claims',
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
    path.lineTo(0, size.height - 30);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper old) => false;
}

// ----------------------------------------------------------
//  CLAIM CARD
//----------------------------------------------------------
class _ClaimCard extends StatelessWidget {
  final ClaimRecord claim;
  final VoidCallback onTap;

  const _ClaimCard({required this.claim, required this.onTap});

  Color get _statusColor {
    switch (claim.status) {
      case 'Approved':           return Colors.green.shade600;
      case 'Rejected':           return Colors.red.shade600;
      case 'Payment Processing': return Colors.blue.shade700;
      case 'In Review':          return Colors.orange.shade700;
      default:                   return Colors.grey.shade600;
    }
  }

  IconData get _statusIcon {
    switch (claim.status) {
      case 'Approved':           return Icons.check_circle_outline;
      case 'Rejected':           return Icons.cancel_outlined;
      case 'Payment Processing': return Icons.payment_outlined;
      case 'In Review':          return Icons.hourglass_top_outlined;
      default:                   return Icons.info_outline;
    }
  }

  // Format LKR with thousands separator
  String get _formattedLKR {
    final amount = claim.estimateLKR;
    if (amount >= 1000000) {
      final m = (amount / 1000000).toStringAsFixed(1);
      return 'LKR ${m}M';
    }
    // Format with commas: 375000 → 375,000
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return 'LKR ${result.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section: vehicle + status 
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2389),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),

                  // Vehicle name + plate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.vehicle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'License Plate: ${claim.licensePlate}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          claim.claimId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            color: Color(0xFF004AAD),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _statusColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: 11, color: _statusColor),
                        const SizedBox(width: 3),
                        Text(
                          claim.status,
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Middle section: damage, date, estimate 
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.warning_amber_outlined,
                    label: 'Damage Type',
                    value: claim.damageType,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Submitted',
                    value: claim.submittedDate,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.monetization_on_outlined,
                    label: 'Damage Estimation',
                    value: _formattedLKR,
                    valueColor: const Color(0xFF004AAD),
                    valueBold: true,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Bottom section: progress + photos 
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  // Progress label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${(claim.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF004AAD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: claim.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        claim.status == 'Rejected'
                            ? Colors.red.shade400
                            : const Color(0xFF004AAD),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Photos count + View details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_camera_outlined,
                              size: 14,
                              color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${claim.photosUploaded} photos uploaded',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            claim.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: const Row(
                          children: [
                            Text(
                              'View details',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF004AAD),
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.arrow_forward,
                                size: 13,
                                color: Color(0xFF004AAD)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Info row inside the card 
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: valueBold
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
//  EMPTY STATE
// ----------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final String filter;
  final String? message;
  const _EmptyState({
    required this.filter,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Icon(Icons.folder_open_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                filter == 'All'
                    ? 'No claims found'
                    : 'No $filter claims found',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    (filter == 'All'
                        ? 'Your claim history will appear here'
                        : 'Try a different filter or search term'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
