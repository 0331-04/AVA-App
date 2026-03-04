import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import '../dashboard/dashboard_screens.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreed = false;

  void _onAccept() {
    if (!_agreed) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Blue header with car image overlay ────────────
          Stack(
            children: [
              // Car background image placeholder
              Container(
                width: double.infinity,
                height: 320,
                decoration: const BoxDecoration(
                  color: Color(0xFF004AAD),
                ),
                child: Stack(
                  children: [
                    // TODO: Replace with real car image asset
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF004AAD),
                            const Color(0xFF001F5C).withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    // Decorative circle overlay
                    Positioned(
                      right: -30,
                      top: 60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AVA-Inspec',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 60),
                            const Center(
                              child: Icon(
                                Icons.shield_outlined,
                                color: Colors.white,
                                size: 72,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // White fade at bottom of header
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── T&C Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  const Text(
                    'Terms of Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // T&C body text
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              'By registering and using the Vehicle Damage Estimation Application, you agree to abide by these Terms of Service. You acknowledge that ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                        const TextSpan(
                          text:
                              'all damage assessments and cost estimations provided by the application are preliminary, computer-generated estimates',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' based solely on the submitted photos and Machine Learning analysis, and are not a final offer or official claim approval from any insurance provider. You assume full responsibility for the accuracy and authenticity of the data and photographs submitted. Your use of this service is at your own risk, and the application\'s developers and associated parties are not liable for any discrepancies between the estimate and the final repair costs or insurance settlement. Continued use constitutes acceptance of these terms and any future modifications.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Checkbox agreement row
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: const Color(0xFF004AAD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'I have read and agree to the Terms of Service',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accept button will only active when checkbox checked
                  SizedBox(
                    width: 120,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _agreed ? _onAccept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AAD),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
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



//  AUTH SCREEN — Login / Signup tab switcher
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Blue header with tab switcher 
          _AuthHeader(
            showLogin: _showLogin,
            onToggle: (isLogin) => setState(() => _showLogin = isLogin),
          ),

          // ── Form area 
          Expanded(
            child: _showLogin
                ? _LoginForm(onSwitchToSignup: () => setState(() => _showLogin = false))
                : const _SignupForm(),
          ),
        ],
      ),
    );
  }
}

// ── Shared blue header with LOGIN | Signup tabs 
class _AuthHeader extends StatelessWidget {
  final bool showLogin;
  final ValueChanged<bool> onToggle;

  const _AuthHeader({required this.showLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _AuthHeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 270,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVA-Inspec',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                // LOGIN | Signup tab row
                Row(
                  children: [
                    // LOGIN tab
                    GestureDetector(
                      onTap: () => onToggle(true),
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          color: showLogin
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                          fontSize: showLogin ? 35 : 25,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 16),

                    // Signup tab
                    GestureDetector(
                      onTap: () => onToggle(false),
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          color: !showLogin
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                          fontSize: !showLogin ? 35 : 25,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  showLogin
                      ? 'Please login using your User name and password'
                      : 'Please enter your details below to sign you up',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
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

class _AuthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_AuthHeaderClipper old) => false;
}




//  LOGIN FORM

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitchToSignup;
  const _LoginForm({required this.onSwitchToSignup});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Replace with real authentication API call
   
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Username field
            _FloatingLabelField(
              label: 'User name',
              hint: 'Enter your name',
              controller: _usernameController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter your username' : null,
            ),
            const SizedBox(height: 20),

            // Password field
            _FloatingLabelField(
              label: 'Password',
              hint: '••••••••••••',
              controller: _passwordController,
              obscure: !_passwordVisible,
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                child: Icon(
                  _passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 28),

            // Login button
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Forgot password
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── OR divider ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Divider(color: const Color(0xFFE4E6EC), thickness: 1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: Color(0xFF9699B7),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: const Color(0xFFE4E6EC), thickness: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Google sign-in button
            // TODO: have to Connect Google Sign-In SDK
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E2E9), width: 1.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.g_mobiledata_rounded,
                    color: Color(0xFFEA4335), size: 26),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Color(0xFF171725),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Sign up redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Not an AVA member?  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onSwitchToSignup,
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color(0xFF004AAD),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




//  SIGNUP FORM

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController       = TextEditingController();
  final _usernameController    = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _telephoneController   = TextEditingController();

  bool _passwordVisible        = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading              = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _onSignup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: have to replace with real registration API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email
            _FloatingLabelField(
              label: 'Email',
              hint: 'Enter your E-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Username
            _FloatingLabelField(
              label: 'User name',
              hint: 'Enter your name',
              controller: _usernameController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter a username' : null,
            ),
            const SizedBox(height: 18),

            // Password
            _FloatingLabelField(
              label: 'Password',
              hint: '••••••••••••',
              controller: _passwordController,
              obscure: !_passwordVisible,
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                child: Icon(
                  _passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter a password';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Confirm password
            _FloatingLabelField(
              label: 'Confirm Password',
              hint: '••••••••••••',
              controller: _confirmPassController,
              obscure: !_confirmPasswordVisible,
              suffixIcon: GestureDetector(
                onTap: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible),
                child: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Telephone
            _FloatingLabelField(
              label: 'Telephone',
              hint: 'Enter your Telephone number',
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter your telephone number' : null,
            ),
            const SizedBox(height: 28),

            // Sign up button
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FloatingLabelField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FloatingLabelField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Colors.black87,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: Colors.black.withOpacity(0.45),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: Color(0xFF004AAD), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
