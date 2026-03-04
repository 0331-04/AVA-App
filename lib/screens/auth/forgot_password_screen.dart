import 'package:flutter/material.dart';
import '../../widgets/loading_overlay.dart';
import 'auth_screen.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _emailSent   = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context, message: 'Sending reset link...');
      await Future.delayed(const Duration(seconds: 2)); // TODO: have to authService.sendPasswordReset(email)
      if (!mounted) return;
      LoadingOverlay.hide(context);
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _ForgotHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: _emailSent
                  ? _SuccessState(
                      email: _controller.text,
                      onResend: () async {
                        LoadingOverlay.show(context,
                            message: 'Resending...');
                        await Future.delayed(
                            const Duration(seconds: 2));
                        if (!mounted) return;
                        LoadingOverlay.hide(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Reset link resent!'),
                            backgroundColor: Colors.green.shade600,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onBackToLogin: () =>
                          Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const AuthScreen()),
                      ),
                    )
                  : _EmailForm(
                      formKey: _formKey,
                      controller: _controller,
                      onSubmit: _submit,
                    ),
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
class _ForgotHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 12),
                const Text(
                  'Forgot Password?',
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
                Text(
                  'We\'ll send you a reset link',
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



// ----------------------------------------------------------
//  EMAIL FORM
// ----------------------------------------------------------
class _EmailForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _EmailForm({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF004AAD).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF004AAD), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enter the email address linked to your AVA-Inspec account and we\'ll send you a password reset link.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF004AAD).withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email field
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(v)) return 'Please enter a valid email';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade600),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Color(0xFF004AAD), size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF004AAD), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.send_outlined,
                  color: Colors.white, size: 18),
              label: const Text(
                'Send Reset Link',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Back to login
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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
//  SUCCESS STATE
// ----------------------------------------------------------
class _SuccessState extends StatelessWidget {
  final String email;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  const _SuccessState({
    required this.email,
    required this.onResend,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200, width: 2),
          ),
          child: Icon(Icons.mark_email_read_outlined,
              size: 50, color: Colors.green.shade600),
        ),
        const SizedBox(height: 24),

        const Text(
          'Check your email!',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'WorkSans',
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF004AAD),
          ),
        ),
        const SizedBox(height: 32),

        // Back to login
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive it? ',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500),
            ),
            GestureDetector(
              onTap: onResend,
              child: const Text(
                'Resend',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004AAD),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
