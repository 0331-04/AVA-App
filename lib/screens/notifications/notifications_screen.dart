import 'package:flutter/material.dart';



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

// TODO: Replace with real notifications from the backend API
List<AppNotification> _mockNotifications = [
  AppNotification(
    id: '1',
    title: 'Claim Approved!',
    body: 'Your claim #CLM-1039 has been approved. Payment of LKR 980,000 will be processed within 3 working days.',
    time: '9:15 AM',
    group: 'Today',
    type: NotifType.claimUpdate,
    isRead: false,
  ),
  AppNotification(
    id: '2',
    title: 'AI Analysis Complete',
    body: 'AI has completed damage analysis for claim #CLM-1042 with 91% confidence. Assessor review initiated.',
    time: '7:42 AM',
    group: 'Today',
    type: NotifType.ai,
    isRead: false,
  ),
  AppNotification(
    id: '3',
    title: 'Payment Processing',
    body: 'Payment of LKR 375,000 for claim #CLM-1042 is now being processed by your insurer.',
    time: '11:30 AM',
    group: 'Yesterday',
    type: NotifType.payment,
    isRead: false,
  ),
  AppNotification(
    id: '4',
    title: 'Upload Reminder',
    body: 'Your claim #CLM-1041 is missing 1 photo. Please upload the wide-angle shot to avoid delays.',
    time: '3:00 PM',
    group: 'Yesterday',
    type: NotifType.reminder,
    isRead: true,
  ),
  AppNotification(
    id: '5',
    title: 'Claim Submitted',
    body: 'Your new claim #CLM-1042 has been successfully submitted and is under review.',
    time: 'Nov 20',
    group: 'Earlier',
    type: NotifType.claimUpdate,
    isRead: true,
  ),
  AppNotification(
    id: '6',
    title: 'System Maintenance',
    body: 'AVA-Inspec will undergo scheduled maintenance on Dec 1 from 2:00–4:00 AM. The app may be temporarily unavailable.',
    time: 'Nov 18',
    group: 'Earlier',
    type: NotifType.system,
    isRead: true,
  ),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = List.from(_mockNotifications);
  final _searchController = TextEditingController();
  String _searchQuery = '';

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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
        title: const Text('Clear all notifications?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          'This will remove all notifications from your list.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _notifications.clear());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
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
    return _notifications.where((n) =>
      n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      n.body.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
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
          // Search bar
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
                    color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Icon(Icons.close,
                            color: Colors.grey.shade400, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF004AAD), width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
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
                          ...entry.value.map((notif) => Dismissible(
                                key: Key(notif.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _dismiss(notif.id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.white, size: 24),
                                ),
                                child: _NotifCard(
                                  notif: notif,
                                  onTap: () => _markRead(notif.id),
                                ),
                              )),
                          const SizedBox(height: 4),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  HEADER
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
                              color: Color(0x40000000)),
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
//  NOTIFICATION CARD
// ----------------------------------------------------------
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  Color get _typeColor {
    switch (notif.type) {
      case NotifType.claimUpdate: return const Color(0xFF004AAD);
      case NotifType.payment:     return Colors.green.shade600;
      case NotifType.reminder:    return Colors.orange.shade600;
      case NotifType.ai:          return Colors.purple.shade600;
      case NotifType.system:      return Colors.grey.shade600;
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case NotifType.claimUpdate: return Icons.assignment_outlined;
      case NotifType.payment:     return Icons.payments_outlined;
      case NotifType.reminder:    return Icons.notification_important_outlined;
      case NotifType.ai:          return Icons.auto_awesome;
      case NotifType.system:      return Icons.info_outline;
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

// ----------------------------------------------------------
//  EMPTY STATE
// ----------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey.shade300),
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
            "You're all caught up!",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
