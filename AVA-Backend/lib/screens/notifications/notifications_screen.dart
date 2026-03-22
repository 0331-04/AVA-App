import 'package:flutter/material.dart';
import '../../services/claim_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String group;
  final NotifType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.type,
    this.isRead = false,
  });
}

enum NotifType { claimUpdate, payment, reminder, ai, system }

String _formatTime(dynamic value) {
  if (value == null) return '';
  final dt = DateTime.tryParse(value.toString());
  if (dt == null) return '';
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _groupForDate(dynamic value) {
  if (value == null) return 'Earlier';
  final dt = DateTime.tryParse(value.toString());
  if (dt == null) return 'Earlier';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(thatDay).inDays;

  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return 'Earlier';
}

AppNotification _notifFromClaim(Map<String, dynamic> c) {
  final claimNumber = (c['claimNumber'] ?? c['id'] ?? 'Unknown').toString();
  final status = (c['status'] ?? 'pending').toString();
  final submittedAt = c['submittedAt'];
  final amount = c['approvedAmount'] ?? c['estimatedAmount'] ?? 0;
  final incidentDescription =
      (c['incidentDescription'] ?? 'Claim update available').toString();

  String title;
  String body;
  NotifType type;

  switch (status.toLowerCase()) {
    case 'approved':
      title = 'Claim Approved';
      body =
          'Your claim #$claimNumber has been approved. Approved amount: LKR $amount.';
      type = NotifType.payment;
      break;
    case 'rejected':
      title = 'Claim Rejected';
      body =
          'Your claim #$claimNumber was rejected. Check claim status for more details.';
      type = NotifType.claimUpdate;
      break;
    case 'documents_review':
      title = 'Claim Under Review';
      body =
          'Your claim #$claimNumber is under document review. We are checking your submitted details.';
      type = NotifType.claimUpdate;
      break;
    case 'damage_assessment':
      title = 'Damage Assessment In Progress';
      body =
          'AI/manual damage assessment is in progress for claim #$claimNumber.';
      type = NotifType.ai;
      break;
    case 'investigation':
      title = 'Claim Investigation Update';
      body =
          'Your claim #$claimNumber is currently being investigated.';
      type = NotifType.claimUpdate;
      break;
    case 'settled':
    case 'closed':
      title = 'Payment Processing';
      body =
          'Your claim #$claimNumber has progressed to payment/closure stage.';
      type = NotifType.payment;
      break;
    case 'disputed':
      title = 'Dispute Submitted';
      body =
          'Your dispute for claim #$claimNumber has been submitted and is under review.';
      type = NotifType.reminder;
      break;
    case 'pending':
    default:
      title = 'Claim Submitted';
      body =
          'Your claim #$claimNumber has been submitted successfully. $incidentDescription';
      type = NotifType.claimUpdate;
      break;
  }

  return AppNotification(
    id: claimNumber,
    title: title,
    body: body,
    time: _formatTime(submittedAt),
    group: _groupForDate(submittedAt),
    type: type,
    isRead: false,
  );
}

class NotificationsScreen extends StatefulWidget {
  final String? accessToken;

  const NotificationsScreen({
    super.key,
    this.accessToken,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ClaimService _claimService = ClaimService();
  final _searchController = TextEditingController();

  List<AppNotification> _notifications = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _isLoading = false;
        _error = 'Missing access token';
      });
      return;
    }

    try {
      final claims =
          await _claimService.getClaims(accessToken: widget.accessToken!);

      final notifications = claims.map(_notifFromClaim).toList();

      notifications.sort((a, b) {
        const order = {'Today': 0, 'Yesterday': 1, 'Earlier': 2};
        final ga = order[a.group] ?? 3;
        final gb = order[b.group] ?? 3;
        if (ga != gb) return ga.compareTo(gb);
        return b.time.compareTo(a.time);
      });

      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear all notifications?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will remove all notifications from your list.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _notifications.clear());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _dismiss(String id) {
    setState(() => _notifications.removeWhere((n) => n.id == id));
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppNotification> get _filtered {
    if (_searchQuery.isEmpty) return _notifications;
    return _notifications.where((n) {
      final q = _searchQuery.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<AppNotification>> get _grouped {
    final map = <String, List<AppNotification>>{};
    for (final group in ['Today', 'Yesterday', 'Earlier']) {
      final items = _filtered.where((n) => n.group == group).toList();
      if (items.isNotEmpty) map[group] = items;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _NotifHeader(
            unreadCount: _unreadCount,
            onMarkAllRead: _unreadCount > 0 ? _markAllRead : null,
            onClearAll: _notifications.isNotEmpty ? _clearAll : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF004AAD), width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004AAD),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF004AAD),
                    onRefresh: _loadNotifications,
                    child: _filtered.isEmpty
                        ? _EmptyState(message: _error)
                        : ListView(
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            children: [
                              if (_error != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.2),
                                    ),
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
                              ...grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8, top: 4),
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey.shade500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    ...entry.value.map(
                                      (notif) => Dismissible(
                                        key: Key(notif.id),
                                        direction:
                                            DismissDirection.endToStart,
                                        onDismissed: (_) => _dismiss(notif.id),
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          margin: const EdgeInsets.only(
                                              bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade400,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        child: _NotifCard(
                                          notif: notif,
                                          onTap: () => _markRead(notif.id),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                );
                              }),
                            ],
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
class _NotifHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;

  const _NotifHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 190,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
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
                    GestureDetector(
                      onTap: onClearAll,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: onClearAll != null
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
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
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$unreadCount new',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (unreadCount > 0)
                  GestureDetector(
                    onTap: onMarkAllRead,
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.5),
                      ),
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

// ----------------------------------------------------------
// NOTIFICATION CARD
// ----------------------------------------------------------
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  Color get _typeColor {
    switch (notif.type) {
      case NotifType.claimUpdate:
        return const Color(0xFF004AAD);
      case NotifType.payment:
        return Colors.green.shade600;
      case NotifType.reminder:
        return Colors.orange.shade600;
      case NotifType.ai:
        return Colors.purple.shade600;
      case NotifType.system:
        return Colors.grey.shade600;
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case NotifType.claimUpdate:
        return Icons.assignment_outlined;
      case NotifType.payment:
        return Icons.payments_outlined;
      case NotifType.reminder:
        return Icons.notification_important_outlined;
      case NotifType.ai:
        return Icons.auto_awesome;
      case NotifType.system:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.white
              : const Color(0xFF004AAD).withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade200
                : const Color(0xFF004AAD).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        notif.time,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF004AAD),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? message;
  const _EmptyState({this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? "You're all caught up!",
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
