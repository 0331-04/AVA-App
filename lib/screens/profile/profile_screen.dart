import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? accessToken;

  const ProfileScreen({
    super.key,
    this.accessToken,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.accessToken == null || widget.accessToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Missing access token';
      });
      return;
    }

    try {
      final result = await _authService.getMe(accessToken: widget.accessToken!);
      if (!mounted) return;
      setState(() {
        _userData = result['data'] ?? {};
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openEditDialog() async {
    final data = _userData ?? {};
    final firstNameController =
        TextEditingController(text: (data['firstName'] ?? '').toString());
    final lastNameController =
        TextEditingController(text: (data['lastName'] ?? '').toString());
    final phoneController =
        TextEditingController(text: (data['phone'] ?? '').toString());
    final addressController = TextEditingController(
      text: ((data['address'] ?? {})['street'] ?? '').toString(),
    );

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Edit Personal Information',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogField('First Name', firstNameController),
                const SizedBox(height: 10),
                _dialogField('Last Name', lastNameController),
                const SizedBox(height: 10),
                _dialogField('Phone', phoneController),
                const SizedBox(height: 10),
                _dialogField('Address', addressController, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (widget.accessToken == null ||
                          widget.accessToken!.isEmpty) {
                        return;
                      }

                      setState(() => _isSaving = true);
                      setModalState(() {});
                      try {
                        await _authService.updateDetails(
                          accessToken: widget.accessToken!,
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          phone: phoneController.text.trim(),
                          address: addressController.text.trim(),
                        );

                        if (!mounted) return;
                        Navigator.of(ctx).pop();
                        await _loadProfile();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      } finally {
                        if (!mounted) return;
                        setState(() => _isSaving = false);
                        setModalState(() {});
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }

  String get _fullName {
    final first = (_userData?['firstName'] ?? '').toString().trim();
    final last = (_userData?['lastName'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    return full.isEmpty ? 'User' : full;
  }

  String get _email => (_userData?['email'] ?? 'No email').toString();
  String get _phone => (_userData?['phone'] ?? 'N/A').toString();
  String get _nic => (_userData?['nic'] ?? 'N/A').toString();

  String get _address {
    final address = (_userData?['address'] as Map?) ?? {};
    final street = (address['street'] ?? '').toString();
    final city = (address['city'] ?? '').toString();
    final zipCode = (address['zipCode'] ?? '').toString();
    final parts = [street, city, zipCode]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  Map<String, dynamic>? get _primaryVehicle {
    final vehicles = _userData?['vehicles'];
    if (vehicles is List && vehicles.isNotEmpty && vehicles.first is Map) {
      return Map<String, dynamic>.from(vehicles.first);
    }
    return null;
  }

  String get _memberSince {
    final createdAt = (_userData?['createdAt'] ?? '').toString();
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return 'AVA-Inspec member';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return 'AVA-Inspec member since ${months[dt.month - 1]} ${dt.year}';
  }

  String get _policyNumber =>
      (_userData?['policyNumber'] ?? 'No active policy').toString();

  String get _policyValidUntil {
    final raw = (_userData?['policyEndDate'] ?? '').toString();
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'N/A';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  bool get _policyActive {
    final raw = (_userData?['policyEndDate'] ?? '').toString();
    final dt = DateTime.tryParse(raw);
    if (dt == null) return false;
    return dt.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _primaryVehicle;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _ProfileHeader(
            fullName: _fullName,
            email: _email,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004AAD),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      children: [
                        if (_error != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
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
                                fontFamily: 'Poppins',
                                color: Colors.red,
                              ),
                            ),
                          ),
                        _PersonalInfoCard(
                          fullName: _fullName,
                          email: _email,
                          phone: _phone,
                          nic: _nic,
                          address: _address,
                          onEdit: _openEditDialog,
                        ),
                        const SizedBox(height: 14),
                        _VehicleCard(vehicle: vehicle),
                        const SizedBox(height: 14),
                        _InsurancePolicyCard(
                          policyNumber: _policyNumber,
                          validUntil: _policyValidUntil,
                          isActive: _policyActive,
                        ),
                        const SizedBox(height: 14),
                        _AppSettingsCard(
                          notificationsEnabled: _notificationsEnabled,
                          biometricEnabled: _biometricEnabled,
                          darkMode: _darkMode,
                          onNotificationsChanged: (v) =>
                              setState(() => _notificationsEnabled = v),
                          onBiometricChanged: (v) =>
                              setState(() => _biometricEnabled = v),
                          onDarkModeChanged: (v) =>
                              setState(() => _darkMode = v),
                        ),
                        const SizedBox(height: 14),
                        _AccountActionsCard(),
                        const SizedBox(height: 14),
                        _MemberBadge(text: _memberSince),
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
// HEADER WITH AVATAR
// ----------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;

  const _ProfileHeader({
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 220,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        fontSize: 20,
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=12',
                          ),
                          backgroundColor: Colors.white24,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF004AAD),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 13,
                              color: Color(0xFF004AAD),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'WorkSans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
// PERSONAL INFO CARD
// ----------------------------------------------------------
class _PersonalInfoCard extends StatelessWidget {
  final String fullName;
  final String email;
  final String phone;
  final String nic;
  final String address;
  final VoidCallback onEdit;

  const _PersonalInfoCard({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nic,
    required this.address,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      trailing: GestureDetector(
        onTap: onEdit,
        child: const Text(
          'Edit',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF004AAD),
          ),
        ),
      ),
      children: [
        _InfoRow(
          icon: Icons.badge_outlined,
          label: 'Full Name',
          value: fullName,
        ),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: email,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: phone,
        ),
        _InfoRow(
          icon: Icons.credit_card_outlined,
          label: 'NIC Number',
          value: nic,
        ),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: address,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// VEHICLE CARD
// ----------------------------------------------------------
class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic>? vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final make = (vehicle?['make'] ?? 'No vehicle').toString();
    final model = (vehicle?['model'] ?? '').toString();
    final year = (vehicle?['year'] ?? '').toString();
    final plate = (vehicle?['licensePlate'] ?? 'N/A').toString();
    final color = (vehicle?['color'] ?? 'N/A').toString();
    final vin = (vehicle?['vin'] ?? 'N/A').toString();

    final title = [make, model, year]
        .where((e) => e.trim().isNotEmpty)
        .join(' ');

    return _SectionCard(
      title: 'My Vehicle',
      icon: Icons.directions_car_outlined,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2389).withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2389),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'No vehicle added' : title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    plate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: Color(0xFF004AAD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.palette_outlined,
          label: 'Colour',
          value: color,
        ),
        _InfoRow(
          icon: Icons.event_outlined,
          label: 'Year',
          value: year.isEmpty ? 'N/A' : year,
        ),
        _InfoRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Chassis No.',
          value: vin,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// INSURANCE POLICY CARD
// ----------------------------------------------------------
class _InsurancePolicyCard extends StatelessWidget {
  final String policyNumber;
  final String validUntil;
  final bool isActive;

  const _InsurancePolicyCard({
    required this.policyNumber,
    required this.validUntil,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004AAD), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insurance Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : Colors.orange).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.green.shade300 : Colors.orange.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PolicyRow(label: 'Policy No.', value: policyNumber),
          _PolicyRow(label: 'Type', value: 'Comprehensive'),
          _PolicyRow(label: 'Valid Until', value: validUntil),
          _PolicyRow(label: 'Coverage', value: 'As per insurer'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View full policy',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontFamily: 'Poppins',
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

class _PolicyRow extends StatelessWidget {
  final String label;
  final String value;
  const _PolicyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// APP SETTINGS CARD
// ----------------------------------------------------------
class _AppSettingsCard extends StatelessWidget {
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool darkMode;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const _AppSettingsCard({
    required this.notificationsEnabled,
    required this.biometricEnabled,
    required this.darkMode,
    required this.onNotificationsChanged,
    required this.onBiometricChanged,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'App Settings',
      icon: Icons.settings_outlined,
      children: [
        _ToggleRow(
          icon: Icons.notifications_outlined,
          label: 'Push Notifications',
          subtitle: 'Claim updates and alerts',
          value: notificationsEnabled,
          onChanged: onNotificationsChanged,
        ),
        const Divider(height: 16),
        _ToggleRow(
          icon: Icons.fingerprint,
          label: 'Biometric Login',
          subtitle: 'Use fingerprint or Face ID',
          value: biometricEnabled,
          onChanged: onBiometricChanged,
        ),
        const Divider(height: 16),
        _ToggleRow(
          icon: Icons.dark_mode_outlined,
          label: 'Dark Mode',
          subtitle: 'Switch app appearance',
          value: darkMode,
          onChanged: onDarkModeChanged,
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.language_outlined,
          label: 'Language',
          trailing: Row(
            children: [
              Text(
                'English',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// ACCOUNT ACTIONS CARD
// ----------------------------------------------------------
class _AccountActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Account',
      icon: Icons.manage_accounts_outlined,
      children: [
        _TapRow(
          icon: Icons.lock_outline,
          label: 'Change Password',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: () {},
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.help_outline,
          label: 'Help & Support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            );
          },
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.logout,
          label: 'Logout',
          labelColor: Colors.red,
          iconColor: Colors.red,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of AVA-Inspec?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
              Navigator.of(ctx).pop();
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TermsScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// MEMBER BADGE
// ----------------------------------------------------------
class _MemberBadge extends StatelessWidget {
  final String text;

  const _MemberBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF004AAD).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF004AAD).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            color: const Color(0xFF004AAD).withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: const Color(0xFF004AAD).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// REUSABLE SECTION CARD
// ----------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF004AAD), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF004AAD).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF004AAD), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF004AAD),
        ),
      ],
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _TapRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF004AAD)).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF004AAD),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: labelColor ?? Colors.black87,
              ),
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right,
                  size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
