import 'package:flutter/material.dart';
import '../../widgets/loading_overlay.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Password strength checker
  double _strength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) score += 0.25;
    return score;
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return Colors.red.shade400;
    if (s <= 0.5)  return Colors.orange.shade400;
    if (s <= 0.75) return Colors.yellow.shade700;
    return Colors.green.shade500;
  }

  String _strengthLabel(double s) {
    if (s <= 0.25) return 'Weak';
    if (s <= 0.5)  return 'Fair';
    if (s <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context, message: 'Updating your password...');
      await Future.delayed(const Duration(seconds: 2)); // TODO replace with real API call
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength(_newController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004AAD).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF004AAD).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              color: Color(0xFF004AAD), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Use at least 8 characters with uppercase letters, numbers and symbols for a strong password.',
                              style: TextStyle(
                                fontSize: 11, fontFamily: 'Poppins',
                                color: const Color(0xFF004AAD).withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fields card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05),
                              blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _PasswordField(
                            label: 'Current Password',
                            controller: _currentController,
                            showPassword: _showCurrent,
                            onToggle: () => setState(() => _showCurrent = !_showCurrent),
                            validator: (v) => v!.isEmpty ? 'Enter current password' : null,
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            label: 'New Password',
                            controller: _newController,
                            showPassword: _showNew,
                            onToggle: () => setState(() {
                              _showNew = !_showNew;
                            }),
                            onChanged: (_) => setState(() {}),
                            validator: (v) {
                              if (v!.isEmpty) return 'Enter new password';
                              if (v.length < 8) return 'Minimum 8 characters';
                              return null;
                            },
                          ),

                          // Password strength bar
                          if (_newController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: strength,
                                      minHeight: 5,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          _strengthColor(strength)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _strengthLabel(strength),
                                  style: TextStyle(
                                    fontSize: 11, fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: _strengthColor(strength),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          const SizedBox(height: 14),
                          _PasswordField(
                            label: 'Confirm New Password',
                            controller: _confirmController,
                            showPassword: _showConfirm,
                            onToggle: () => setState(() => _showConfirm = !_showConfirm),
                            validator: (v) {
                              if (v!.isEmpty) return 'Confirm your new password';
                              if (v != _newController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AAD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.lock_reset_outlined,
                            color: Colors.white, size: 18),
                        label: const Text('Update Password',
                            style: TextStyle(color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, fontSize: 14)),
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

  Widget _buildHeader(BuildContext context) {
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
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('AVA-Inspec',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontFamily: 'WorkSans', fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                const Text('Change Password',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontFamily: 'WorkSans', fontWeight: FontWeight.w700,
                        shadows: [Shadow(offset: Offset(0, 4), blurRadius: 4,
                            color: Color(0x40000000))])),
                Text('Keep your account secure',
                    style: TextStyle(color: Colors.white.withOpacity(0.75),
                        fontSize: 13, fontFamily: 'WorkSans')),
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

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool showPassword;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.showPassword,
    required this.onToggle,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12,
            color: Colors.grey.shade600),
        prefixIcon: const Icon(Icons.lock_outline,
            color: Color(0xFF004AAD), size: 18),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade500, size: 18,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF004AAD), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
