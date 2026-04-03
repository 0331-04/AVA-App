import 'package:flutter/material.dart';
import '../claims/report_claim_screen.dart';
import '../claims/claim_history_screen.dart';
import '../claims/claim_status_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../services/auth_service.dart';
import '../../services/claim_service.dart';

class DashboardScreen extends StatefulWidget {
  final String? accessToken;

  const DashboardScreen({
    super.key,
    this.accessToken,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primaryBlue = Color(0xFF1A56DB);

  final AuthService _authService = AuthService();
  final ClaimService _claimService = ClaimService();

  int _unreadNotifications = 3;
  String _userName = 'Loading...';
  List<Map<String, dynamic>> _claims = [];
  int _selectedClaimIndex = 0;
  bool _isLoadingClaim = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadClaims(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _userName = 'User';
      });
      return;
    }

    try {
      final result = await _authService.getMe(
        accessToken: widget.accessToken!,
      );

      final data = result['data'] ?? {};
      final firstName = (data['firstName'] ?? '').toString().trim();
      final lastName = (data['lastName'] ?? '').toString().trim();
      final fullName = '$firstName $lastName'.trim();

      if (!mounted) return;
      setState(() {
        _userName = fullName.isEmpty ? 'User' : fullName;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName = 'User';
      });
    }
  }

  Future<void> _loadClaims() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _claims = [];
        _selectedClaimIndex = 0;
        _isLoadingClaim = false;
      });
      return;
    }

    try {
      final claims = await _claimService.getClaims(
        accessToken: widget.accessToken!,
      );

      if (!mounted) return;
      setState(() {
        _claims = claims;
        if (_selectedClaimIndex >= _claims.length) {
          _selectedClaimIndex = _claims.isEmpty ? 0 : _claims.length - 1;
        }
        _isLoadingClaim = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _claims = [];
        _selectedClaimIndex = 0;
        _isLoadingClaim = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadDashboardData();
    if (!mounted) return;
    setState(() {});
  }

  void _showPreviousClaim() {
    if (_claims.isEmpty) return;
    setState(() {
      _selectedClaimIndex =
          (_selectedClaimIndex - 1).clamp(0, _claims.length - 1);
    });
  }

  void _showNextClaim() {
    if (_claims.isEmpty) return;
    setState(() {
      _selectedClaimIndex =
          (_selectedClaimIndex + 1).clamp(0, _claims.length - 1);
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_outlined;
    if (hour < 17) return Icons.light_mode_outlined;
    return Icons.nights_stay_outlined;
  }

  void _goToReportClaim() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportClaimScreen(
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  void _goToClaimHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClaimHistoryScreen(
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  void _goToClaimStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClaimStatusScreen(
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedClaim =
        _claims.isNotEmpty ? _claims[_selectedClaimIndex] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _Header(
            greeting: _greeting,
            greetingIcon: _greetingIcon,
            userName: _userName,
            unreadNotifications: _unreadNotifications,
            onNotificationTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    accessToken: widget.accessToken,
                  ),
                ),
              );
              setState(() => _unreadNotifications = 0);
            },
                        onProfileTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    accessToken: widget.accessToken,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              color: primaryBlue,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _ActiveClaimBanner(
                      claim: selectedClaim,
                      isLoading: _isLoadingClaim,
                      accessToken: widget.accessToken,
                    ),
                    const SizedBox(height: 10),
                    _ClaimSelector(
                      claims: _claims,
                      selectedIndex: _selectedClaimIndex,
                      onPrevious: _showPreviousClaim,
                      onNext: _showNextClaim,
                    ),
                    const SizedBox(height: 20),
                    _SearchBar(),
                    const SizedBox(height: 22),
                    _QuickActions(
                      onReportAccident: _goToReportClaim,
                      onClaimHistory: _goToClaimHistory,
                      onClaimStatus: _goToClaimStatus,
                    ),
                    const SizedBox(height: 26),
                    _QuickStats(
                      claim: selectedClaim,
                      isLoading: _isLoadingClaim,
                    ),
                    const SizedBox(height: 22),
                    _TipsTiles(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          _BottomNavBar(onReportClaim: _goToReportClaim, accessToken: widget.accessToken),
        ],
      ),
    );
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

double _progressFromStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0.25;
    case 'documents_review':
      return 0.50;
    case 'damage_assessment':
      return 0.75;
    case 'investigation':
      return 0.85;
    case 'approved':
    case 'settled':
    case 'closed':
    case 'rejected':
      return 1.0;
    default:
      return 0.20;
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
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

// ----------------------------------------------------------
// HEADER
// ----------------------------------------------------------
class _Header extends StatelessWidget {
  final String greeting;
  final IconData greetingIcon;
  final String userName;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _Header({
    required this.greeting,
    required this.greetingIcon,
    required this.userName,
    required this.unreadNotifications,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

 @override
Widget build(BuildContext context) {
  return ClipPath(
    clipper: _DiagonalClipper(),
    child: Container(
      width: double.infinity,
      height: 215,
      color: const Color(0xFF1A56DB),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE (TEXT)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'AVA-Inspec',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(greetingIcon,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT SIDE (NOTIFICATIONS + PROFILE)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 🔔 Notifications
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (unreadNotifications > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadNotifications',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 👤 PROFILE (FIX APPLIED HERE)
                  GestureDetector(
                    onTap: onProfileTap,
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12',
                      ),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ----------------------------------------------------------
// ACTIVE CLAIM BANNER
// ----------------------------------------------------------
class _ActiveClaimBanner extends StatelessWidget {
  final Map<String, dynamic>? claim;
  final bool isLoading;
  final String? accessToken;

  const _ActiveClaimBanner({
    required this.claim,
    required this.isLoading,
    required this.accessToken,
  });

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

  String _formatLKR(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return 'LKR ${result.toString()}';
  }

  
Color _severityColor(String s) {
  switch (s.toLowerCase()) {
    case 'minor':
      return Colors.green;
    case 'moderate':
      return Colors.orange;
    case 'major':
    case 'severe':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (claim == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56DB).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No active claims yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Submit a claim to see AI insights and live claim progress here.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    final claimId = '#${(claim!['claimNumber'] ?? claim!['id'] ?? 'Unknown').toString()}';
    final status = _displayStatus((claim!['status'] ?? 'pending').toString());
    final currentStep = _stepFromStatus((claim!['status'] ?? 'pending').toString());

    final vehicle = (claim!['vehicle'] as Map?) ?? {};
    final make = (vehicle['make'] ?? '').toString();
    final model = (vehicle['model'] ?? '').toString();
    final year = (vehicle['year'] ?? '').toString();
    final vehicleText = [make, model, year].where((e) => e.trim().isNotEmpty).join(' ');

    final submittedDate = _formatDate(claim!['submittedAt']);

    final damageAnalysis = (claim!['damageAnalysis'] as Map?) ?? {};
    final severity = _titleCase((damageAnalysis['overallSeverity'] ?? 'Unknown').toString());
    final drivable = damageAnalysis['drivable'];
    final totalEstimatedCost = (damageAnalysis['totalEstimatedCost'] as Map?) ?? {};
    final minCost = totalEstimatedCost['min'] is num ? (totalEstimatedCost['min'] as num).toInt() : 0;
    final maxCost = totalEstimatedCost['max'] is num ? (totalEstimatedCost['max'] as num).toInt() : 0;

    final damageText = (claim!['incidentDescription'] ?? 'Damage report submitted').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Active Claim $claimId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vehicleText.isEmpty ? 'Unknown Vehicle' : vehicleText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            damageText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Filed: $submittedDate',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BannerInfoChip(
                label: 'Severity',
                value: severity,
              ),
              if (minCost > 0 || maxCost > 0)
                _BannerInfoChip(
                  label: 'Estimate',
                  value: '${_formatLKR(minCost)} - ${_formatLKR(maxCost)}',
                ),
              if (drivable is bool)
                _BannerInfoChip(
                  label: 'Vehicle',
                  value: drivable ? 'Likely drivable' : 'Inspection needed',
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ClaimStepProgress(currentStep: currentStep),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClaimStatusScreen(
                  accessToken: accessToken,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View full details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white70,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerInfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _BannerInfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _chipColor {
    switch (status) {
      case 'Approved':
        return Colors.green.shade600;
      case 'Rejected':
        return Colors.red.shade600;
      case 'In Review':
        return Colors.orange.shade700;
      case 'Assessment':
        return Colors.amber.shade700;
      case 'Payment Processing':
        return Colors.blue.shade700;
      case 'Submitted':
        return Colors.white;
      default:
        return Colors.grey.shade600;
    }
  }

  Color get _textColor {
    if (status == 'Submitted') return const Color(0xFF1A56DB);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status == 'Submitted'
            ? Colors.white.withOpacity(0.92)
            : _chipColor.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: status == 'Submitted'
              ? Colors.white
              : _chipColor.withOpacity(0.65),
          width: 1,
        ),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _textColor,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClaimStepProgress extends StatelessWidget {
  final int currentStep;
  const _ClaimStepProgress({required this.currentStep});

  static const List<String> _steps = [
    'Submitted',
    'In Review',
    'Assessment',
    'Decision',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length, (i) {
        final done = i <= currentStep;
        final isLast = i == _steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? Colors.white
                            : Colors.white.withOpacity(0.28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.65),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _steps[i],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: done
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        fontSize: 8,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: (done && i < currentStep)
                        ? Colors.white
                        : Colors.white.withOpacity(0.28),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ----------------------------------------------------------
// SEARCH BAR
// ----------------------------------------------------------

class _ClaimSelector extends StatelessWidget {
  final List<Map<String, dynamic>> claims;
  final int selectedIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ClaimSelector({
    required this.claims,
    required this.selectedIndex,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (claims.isEmpty) return const SizedBox.shrink();

    final selected = claims[selectedIndex];
    final claimNumber = '#${(selected['claimNumber'] ?? selected['id'] ?? 'Unknown').toString()}';
    final status = _displayStatus((selected['status'] ?? 'pending').toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: selectedIndex > 0 ? onPrevious : null,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selectedIndex > 0 ? Colors.white : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_left,
                color: selectedIndex > 0 ? const Color(0xFF1A56DB) : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  claimNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A56DB),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Viewing claim ${selectedIndex + 1} of ${claims.length} • $status',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: selectedIndex < claims.length - 1 ? onNext : null,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selectedIndex < claims.length - 1 ? Colors.white : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chevron_right,
                color: selectedIndex < claims.length - 1 ? const Color(0xFF1A56DB) : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
            onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFEAF2FF),
                        child: Icon(
                          Icons.miscellaneous_services,
                          color: Color(0xFF004AAD),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Available Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF171725),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _ServiceTile(
                    icon: Icons.car_repair_outlined,
                    title: 'Roadside Assistance',
                    subtitle: 'Quick support after an accident',
                  ),
                  const _ServiceTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Towing Service',
                    subtitle: 'Vehicle transport to a repair center',
                  ),
                  const _ServiceTile(
                    icon: Icons.build_outlined,
                    title: 'Nearby Repair Shops',
                    subtitle: 'Repair guidance and next-step support',
                  ),
                  const _ServiceTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Emergency Support',
                    subtitle: 'Help and claim-related assistance',
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF978B8B)),
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 10),
            Text(
              'Search services',
              style: TextStyle(
                color: Colors.black.withOpacity(0.45),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEAF2FF),
            child: Icon(icon, color: const Color(0xFF004AAD), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF171725),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
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

// ----------------------------------------------------------
// QUICK ACTION CARDS
// ----------------------------------------------------------
class _QuickActions extends StatelessWidget {
  final VoidCallback onReportAccident;
  final VoidCallback onClaimHistory;
  final VoidCallback onClaimStatus;

  const _QuickActions({
    required this.onReportAccident,
    required this.onClaimHistory,
    required this.onClaimStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionCard(
          icon: Icons.car_crash_outlined,
          label: 'Report an\nAccident',
          onTap: onReportAccident,
        ),
        _ActionCard(
          icon: Icons.history_rounded,
          label: 'Claim\nHistory',
          onTap: onClaimHistory,
        ),
        _ActionCard(
          icon: Icons.task_alt_rounded,
          label: 'Claim\nStatus',
          onTap: onClaimStatus,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 90,
        decoration: ShapeDecoration(
          color: const Color(0xFFE7EDF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1A56DB)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// QUICK STATS CARD
// ----------------------------------------------------------
class _QuickStats extends StatelessWidget {
  final Map<String, dynamic>? claim;
  final bool isLoading;

  const _QuickStats({
    required this.claim,
    required this.isLoading,
  });

  String _formatLKR(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return 'LKR ${result.toString()}';
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: const Color(0xFFE7EDF5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A56DB),
              ),
            ),
          ),
        ],
      );
    }

    final statusRaw = (claim?['status'] ?? 'pending').toString();
    final progress = claim == null ? 0.0 : _progressFromStatus(statusRaw);
    final displayStatus =
        claim == null ? 'No claims yet' : _displayStatus(statusRaw);

    final photos = claim?['photos'];
    final photoCount = photos is List ? photos.length : 0;

    final damageAnalysis = (claim?['damageAnalysis'] as Map?) ?? {};
    final damages = (damageAnalysis['damages'] as List?) ?? [];
    final severityRaw = (damageAnalysis['overallSeverity'] ?? 'unknown').toString();
    final severity = _titleCase(severityRaw);

    final totalEstimatedCost =
        (damageAnalysis['totalEstimatedCost'] as Map?) ?? {};
    final minCost = totalEstimatedCost['min'] is num
        ? (totalEstimatedCost['min'] as num).toInt()
        : 0;
    final maxCost = totalEstimatedCost['max'] is num
        ? (totalEstimatedCost['max'] as num).toInt()
        : 0;

    final confidenceRaw = damageAnalysis['confidence'];
    final confidence = confidenceRaw is num
        ? ((confidenceRaw.toDouble()) * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFE7EDF5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected claim insights:',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                claim == null
                    ? 'No claims submitted'
                    : '${(progress * 100).toInt()}% completed',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A56DB),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1A56DB),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                claim == null
                    ? 'Submit a claim to see progress here.'
                    : 'Current status: $displayStatus • $photoCount photo(s) uploaded',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              if (claim != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MiniStat(
                      label: 'Severity',
                      value: severity,
                    ),
                    _MiniStat(
                      label: 'Damages',
                      value: '${damages.length}',
                    ),
                    _MiniStat(
                      label: 'AI Confidence',
                      value: '$confidence%',
                    ),
                  ],
                ),
                if (minCost > 0 || maxCost > 0) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Estimated Repair Cost',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatLKR(minCost)} - ${_formatLKR(maxCost)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A56DB),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A56DB),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// TIPS / NEWS TILES
// ----------------------------------------------------------
class _TipsTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TipCard(
            icon: Icons.camera_alt_outlined,
            text: 'How to take the perfect damage photo',
                        onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: const [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFEAF2FF),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFF004AAD),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Perfect Damage Photo Tips',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF171725),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _InfoBullet(
                          text: 'Use bright lighting for clearer damage detection',
                        ),
                        const _InfoBullet(
                          text: 'Capture the damaged area as closely as possible',
                        ),
                        const _InfoBullet(
                          text: 'Avoid blurry or tilted photos',
                        ),
                        const _InfoBullet(
                          text: 'Include only one vehicle in the frame',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TipCard(
            icon: Icons.tips_and_updates_outlined,
            text: 'New AI: engine update for scratch detection',
                        onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: const [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFEAF2FF),
                              child: Icon(
                                Icons.tips_and_updates_outlined,
                                color: Color(0xFF004AAD),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI Update',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF171725),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _InfoBullet(
                          text: 'The latest model improves preliminary scratch and surface damage detection.',
                        ),
                        const _InfoBullet(
                          text: 'AI results are still preliminary and may change after professional review.',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF004AAD),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _TipCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0xFFE7EDF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF1A56DB)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// BOTTOM NAV BAR
// ----------------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  final VoidCallback onReportClaim;
  final String? accessToken;
  const _BottomNavBar({
    required this.onReportClaim,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFFD6E4F7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.home_outlined,
              size: 30,
              color: Color(0xFF1A56DB),
            ),
          ),
          _NavItemCenter(onTap: onReportClaim),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(accessToken: accessToken)),
              );
            },
            child: const Icon(
              Icons.person_outline_rounded,
              size: 30,
              color: Color(0xFF393939),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemCenter extends StatelessWidget {
  final VoidCallback onTap;
  const _NavItemCenter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF393939), width: 2),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 28,
              color: Color(0xFF393939),
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
