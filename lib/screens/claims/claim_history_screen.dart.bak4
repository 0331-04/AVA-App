import 'package:flutter/material.dart';
import '../claims/claim_detail_screen.dart';


// ── Claim data model
class ClaimRecord {
  final String claimId;
  final String vehicle;
  final String licensePlate;
  final String damageType;
  final String submittedDate;
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
    required this.estimateLKR,
    required this.progress,
    required this.status,
    required this.photosUploaded,
  });
}

// TODO: Replace with real data from your backend API
final List<ClaimRecord> _mockClaims = [
  ClaimRecord(
    claimId: '#CLM-1042',
    vehicle: 'Toyota Camry 2022',
    licensePlate: 'ABC-1234',
    damageType: 'Front Bumper Scratch',
    submittedDate: 'Nov 20, 2024',
    estimateLKR: 375000,
    progress: 1.0,
    status: 'Payment Processing',
    photosUploaded: 4,
  ),
  ClaimRecord(
    claimId: '#CLM-1041',
    vehicle: 'Honda Civic 2020',
    licensePlate: 'WP-CAB-5678',
    damageType: 'Rear Bumper Dent',
    submittedDate: 'Oct 14, 2024',
    estimateLKR: 520000,
    progress: 0.75,
    status: 'In Review',
    photosUploaded: 3,
  ),
  ClaimRecord(
    claimId: '#CLM-1039',
    vehicle: 'Nissan X-Trail 2021',
    licensePlate: 'NW-2233',
    damageType: 'Left Side Panel Damage',
    submittedDate: 'Sep 3, 2024',
    estimateLKR: 980000,
    progress: 1.0,
    status: 'Approved',
    photosUploaded: 5,
  ),
  ClaimRecord(
    claimId: '#CLM-1036',
    vehicle: 'Toyota Prius 2019',
    licensePlate: 'WP-PKQ-9988',
    damageType: 'Windscreen Crack',
    submittedDate: 'Aug 11, 2024',
    estimateLKR: 145000,
    progress: 1.0,
    status: 'Rejected',
    photosUploaded: 2,
  ),
  ClaimRecord(
    claimId: '#CLM-1033',
    vehicle: 'Suzuki Alto 2023',
    licensePlate: 'SP-4421',
    damageType: 'Right Side Mirror',
    submittedDate: 'Jul 29, 2024',
    estimateLKR: 48000,
    progress: 0.4,
    status: 'In Review',
    photosUploaded: 3,
  ),
];

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
  const ClaimHistoryScreen({super.key});

  @override
  State<ClaimHistoryScreen> createState() => _ClaimHistoryScreenState();
}

class _ClaimHistoryScreenState extends State<ClaimHistoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _filters = ['All', 'Active', 'Completed', 'Rejected'];

  // Active = In Review or Payment Processing
  // Completed = Approved or Payment Processing (100%)
  List<ClaimRecord> get _filteredClaims {
    return _mockClaims.where((c) {
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
          c.damageType.toLowerCase().contains(q);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _onRefresh() async {
    // TODO: Call your backend API to refresh claims list
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
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
            child: RefreshIndicator(
              color: const Color(0xFF004AAD),
              onRefresh: _onRefresh,
              child: claims.isEmpty
                  ? _EmptyState(filter: _selectedFilter)
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
  const _EmptyState({required this.filter});

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
                filter == 'All'
                    ? 'Your claim history will appear here'
                    : 'Try a different filter or search term',
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
