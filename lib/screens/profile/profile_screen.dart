import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/help_support_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //  Settings toggles 
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _PersonalInfoCard(),
                  const SizedBox(height: 14),
                  _VehicleCard(),
                  const SizedBox(height: 14),
                  _InsurancePolicyCard(),
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
                  _AccountActionsCard(context: context),
                  const SizedBox(height: 14),
                  _MemberBadge(),
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
//  HEADER WITH AVATAR
// ----------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
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
                // Back button + title
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

                // Avatar row
                Row(
                  children: [
                    Stack(
                      children: [
                        // TODO: Replace with the real user profile image
                        const CircleAvatar(
                          radius: 38,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=12',
                          ),
                          backgroundColor: Colors.white24,
                        ),
                        // Edit avatar button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            // TODO  Open image picker to change thr avatar
                            onTap: () {},
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF004AAD),
                                    width: 1.5),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 13,
                                  color: Color(0xFF004AAD)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO Replace with real user name from auth
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // TODO Replace with real email from auth
                        Text(
                          'johndoe@email.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Premium Member',
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
//  PERSONAL INFO CARD
// ----------------------------------------------------------
class _PersonalInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      trailing: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        ),
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
      children: const [
        // TODOm Replace all values with real data from auth/user service
        _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Full Name',
            value: 'John Doe'),
        _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'johndoe@email.com'),
        _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+94 77 123 4567'),
        _InfoRow(
            icon: Icons.credit_card_outlined,
            label: 'NIC Number',
            value: '199912345678V'),
        _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: '45/A, Galle Road, Colombo 03'),
      ],
    );
  }
}

// ----------------------------------------------------------
//  VEHICLE CARD
// ----------------------------------------------------------
class _VehicleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'My Vehicle',
      icon: Icons.directions_car_outlined,
      trailing: GestureDetector(
        // TODO Navigate to EditVehicleScreen()
        onTap: () {},
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
        // Vehicle icon + name banner
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO Replace with real vehicle data
                  Text(
                    'Toyota Camry 2022',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'ABC-1234',
                    style: TextStyle(
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
        const _InfoRow(
            icon: Icons.palette_outlined,
            label: 'Colour',
            value: 'Pearl White'),
        const _InfoRow(
            icon: Icons.settings_outlined,
            label: 'Engine',
            value: '2.5L Hybrid'),
        const _InfoRow(
            icon: Icons.event_outlined,
            label: 'Year',
            value: '2022'),
        const _InfoRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Chassis No.',
            value: 'JTDBF3EH7C3012345'),
      ],
    );
  }
}

// ----------------------------------------------------------
//  INSURANCE POLICY CARD
// ----------------------------------------------------------
class _InsurancePolicyCard extends StatelessWidget {
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
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.green.shade300, width: 1),
                ),
                child: const Text(
                  'Active',
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
          const SizedBox(height: 14),
          // TODO: Replace with real policy data
          _PolicyRow(label: 'Policy No.', value: 'AVA-2024-001234'),
          _PolicyRow(label: 'Type', value: 'Comprehensive'),
          _PolicyRow(label: 'Valid Until', value: 'Dec 31, 2025'),
          _PolicyRow(
              label: 'Coverage',
              value: 'LKR 5,000,000'),
          const SizedBox(height: 8),
          GestureDetector(
            // TODO: Open policy document PDF
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  APP SETTINGS CARD
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
        // Language selector
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
          onTap: () {
            // TODO  Open language selection sheet
          },
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
//  ACCOUNT ACTIONS CARD
// ----------------------------------------------------------
class _AccountActionsCard extends StatelessWidget {
  final BuildContext context;
  const _AccountActionsCard({required this.context});

  @override
  Widget build(BuildContext _) {
    return _SectionCard(
      title: 'Account',
      icon: Icons.manage_accounts_outlined,
      children: [
        _TapRow(
          icon: Icons.lock_outline,
          label: 'Change Password',
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          },
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: () {
            // TODO: Open privacy policy URL
          },
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.help_outline,
          label: 'Help & Support',
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
          },
        ),
        const Divider(height: 16),
        _TapRow(
          icon: Icons.logout,
          label: 'Logout',
          labelColor: Colors.red.shade600,
          iconColor: Colors.red.shade400,
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
            borderRadius: BorderRadius.circular(16)),
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
              // TODO: Call authService.logout() to clear tokens
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TermsScreen()),
                (route) => false, 
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  MEMBER BADGE
// ----------------------------------------------------------
class _MemberBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF004AAD).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF004AAD).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined,
              color: const Color(0xFF004AAD).withOpacity(0.7),
              size: 16),
          const SizedBox(width: 8),
          Text(
            // TODO: Replace with real member since date from auth
            'AVA-Inspec member since January 2024',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: const Color(0xFF004AAD).withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  REUSABLE SECTION CARD
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
          // Section header
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

//  Reusable info display row 
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

//  Toggle row for settings 
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

//  Tappable row for actions 
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
              color: (iconColor ?? const Color(0xFF004AAD))
                  .withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                color: iconColor ?? const Color(0xFF004AAD),
                size: 18),
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
