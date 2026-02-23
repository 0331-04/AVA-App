import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
// TODO: Add shared_preferences to pubspec.yaml dependencies
// then uncomment the import below:
// import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
//  AVA-Inspec — Splash Screen
//  File: lib/screens/splash_screen.dart
//
//  Flow:
//  Stage 1 (0-2s)  → Blue bg + AVA logo fades in
//  Stage 2 (2-4s)  → Crossfades to tagline + car illustration
//                    + animated loading bar
//  After loading   → Navigates to DashboardScreen
//                    (swap for LoginScreen once that's built)
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Stage control ─────────────────────────────────────────
  bool _showStage2 = false;

  // ── Logo fade-in ──────────────────────────────────────────
  late final AnimationController _logoController;
  late final Animation<double> _logoOpacity;

  // ── Stage 2 fade-in ───────────────────────────────────────
  late final AnimationController _stage2Controller;
  late final Animation<double> _stage2Opacity;

  // ── Loading bar ───────────────────────────────────────────
  late final AnimationController _loadingController;
  late final Animation<double> _loadingProgress;

  // ── Car illustration pulse ────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSequence();
  }

  void _setupAnimations() {
    // Logo fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // Stage 2 crossfade
    _stage2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _stage2Opacity = CurvedAnimation(
      parent: _stage2Controller,
      curve: Curves.easeInOut,
    );

    // Loading bar — fills over 1.8 seconds
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _loadingProgress = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );

    // Subtle pulse on the car illustration
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _runSequence() async {
    // Stage 1: show logo
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Stage 2: crossfade to tagline + illustration
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _showStage2 = true);
    _stage2Controller.forward();

    // Start loading bar shortly after stage 2 appears
    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.forward();

    // Wait for loading to finish then navigate
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    // ── First-launch check ────────────────────────────────
    // TODO: Add shared_preferences to pubspec.yaml, then replace with:
    // final prefs = await SharedPreferences.getInstance();
    // final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    // Navigate to OnboardingScreen if false, AuthScreen if true.

    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _stage2Controller.dispose();
    _loadingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004AAD),
      body: Stack(
        children: [
          // ── Background decorative circle (top right) ───────
          Positioned(
            right: -60,
            top: 80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // ── Background decorative circle (bottom left) ─────
          Positioned(
            left: -40,
            bottom: 120,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // ── STAGE 1: Logo screen ───────────────────────────
          if (!_showStage2)
            FadeTransition(
              opacity: _logoOpacity,
              child: const _LogoStage(),
            ),

          // ── STAGE 2: Tagline + illustration + loading ──────
          if (_showStage2)
            FadeTransition(
              opacity: _stage2Opacity,
              child: _TaglineStage(
                pulseScale: _pulseScale,
                loadingProgress: _loadingProgress,
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  STAGE 1 — Logo
// ════════════════════════════════════════════════════════════
class _LogoStage extends StatelessWidget {
  const _LogoStage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White circle with AVA shield logo inside
          Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: _AvaShieldLogo(size: 130),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AVA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  STAGE 2 — Tagline + car illustration + loading bar
// ════════════════════════════════════════════════════════════
class _TaglineStage extends StatelessWidget {
  final Animation<double> pulseScale;
  final Animation<double> loadingProgress;

  const _TaglineStage({
    required this.pulseScale,
    required this.loadingProgress,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // ── App name ──────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AVA-Inspec',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ── Tagline ───────────────────────────────────────
          const Text(
            'Where every claim meets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const Text(
            'clarity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 40),

          // ── AI Car illustration ───────────────────────────
          ScaleTransition(
            scale: pulseScale,
            child: SizedBox(
              width: size.width * 0.85,
              height: size.width * 0.85,
              child: const _AiCarIllustration(),
            ),
          ),

          const Spacer(),

          // ── Loading bar ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: loadingProgress,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: loadingProgress.value,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00CFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.06,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  AVA SHIELD LOGO — drawn with Flutter widgets
//  Matches the shield + person silhouette in your Figma
// ════════════════════════════════════════════════════════════
class _AvaShieldLogo extends StatelessWidget {
  final double size;
  const _AvaShieldLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShieldPainter(),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFF004AAD)
      ..style = PaintingStyle.fill;

    // Outer shield shape
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.95, h * 0.22)
      ..quadraticBezierTo(w * 0.98, h * 0.55, w * 0.5, h * 0.96)
      ..quadraticBezierTo(w * 0.02, h * 0.55, w * 0.05, h * 0.22)
      ..close();

    canvas.drawPath(shieldPath, paint);

    // Inner lighter accent stripe
    final accentPaint = Paint()
      ..color = const Color(0xFF1A8FD1)
      ..style = PaintingStyle.fill;

    final accentPath = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.72, h * 0.24)
      ..quadraticBezierTo(w * 0.78, h * 0.54, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.38, h * 0.60, w * 0.38, h * 0.30)
      ..close();

    canvas.drawPath(accentPath, accentPaint);

    // Person head (circle)
    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.34),
      w * 0.10,
      headPaint,
    );

    // Person body
    final bodyPath = Path()
      ..moveTo(w * 0.34, h * 0.70)
      ..quadraticBezierTo(w * 0.34, h * 0.50, w * 0.50, h * 0.48)
      ..quadraticBezierTo(w * 0.66, h * 0.50, w * 0.66, h * 0.70)
      ..close();

    canvas.drawPath(bodyPath, headPaint);
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => false;
}

// ════════════════════════════════════════════════════════════
//  AI CAR ILLUSTRATION — drawn with Flutter widgets
//  Matches the circuit-board car ring graphic in your Figma
// ════════════════════════════════════════════════════════════
class _AiCarIllustration extends StatelessWidget {
  const _AiCarIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CarIllustrationPainter(),
    );
  }
}

class _CarIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final glowPaint = Paint()
      ..color = const Color(0xFF00CFFF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF00CFFF)
      ..style = PaintingStyle.fill;

    // ── Outer ring ─────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), size.width * 0.46, glowPaint);

    // ── Middle ring ────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, linePaint);

    // ── Inner ring ─────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), size.width * 0.24, linePaint);

    // ── Circuit tick marks around outer ring ───────────────
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * (3.14159 / 180);
      final inner = size.width * 0.44;
      final outer = size.width * 0.48;
      final x1 = cx + inner * _cos(angle);
      final y1 = cy + inner * _sin(angle);
      final x2 = cx + outer * _cos(angle);
      final y2 = cy + outer * _sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    // ── Dots at cardinal points ────────────────────────────
    final dotPositions = [
      Offset(cx, cy - size.width * 0.46),             // top
      Offset(cx + size.width * 0.46, cy),             // right
      Offset(cx, cy + size.width * 0.46),             // bottom
      Offset(cx - size.width * 0.46, cy),             // left
    ];
    for (final pos in dotPositions) {
      canvas.drawCircle(pos, 6, dotPaint);
      // Outer glow ring on dots
      canvas.drawCircle(pos, 10,
          dotPaint..color = const Color(0xFF00CFFF).withOpacity(0.3));
      dotPaint.color = const Color(0xFF00CFFF);
    }

    // ── Car body (simplified side view) ───────────────────
    final carPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final carScale = size.width * 0.28;
    final carX = cx - carScale;
    final carY = cy - carScale * 0.30;

    final carPath = Path();
    // Car bottom / chassis
    carPath.moveTo(carX, carY + carScale * 0.55);
    carPath.lineTo(carX + carScale * 2, carY + carScale * 0.55);
    // Rear wheel arch
    carPath.addArc(
      Rect.fromCenter(
          center: Offset(carX + carScale * 0.38, carY + carScale * 0.55),
          width: carScale * 0.42,
          height: carScale * 0.42),
      0,
      3.14159,
    );
    // Front wheel arch
    carPath.addArc(
      Rect.fromCenter(
          center: Offset(carX + carScale * 1.62, carY + carScale * 0.55),
          width: carScale * 0.42,
          height: carScale * 0.42),
      0,
      3.14159,
    );
    // Cabin roof line
    carPath.moveTo(carX + carScale * 0.5, carY + carScale * 0.55);
    carPath.lineTo(carX + carScale * 0.62, carY);
    carPath.lineTo(carX + carScale * 1.38, carY);
    carPath.lineTo(carX + carScale * 1.5, carY + carScale * 0.55);

    canvas.drawPath(carPath, carPaint);

    // Wheel circles
    final wheelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(
        Offset(carX + carScale * 0.38, carY + carScale * 0.60),
        carScale * 0.18,
        wheelPaint);
    canvas.drawCircle(
        Offset(carX + carScale * 1.62, carY + carScale * 0.60),
        carScale * 0.18,
        wheelPaint);

    // ── Radial circuit lines from car outward ─────────────
    final circuitAngles = [30.0, 150.0, 210.0, 330.0, 60.0, 120.0, 240.0, 300.0];
    for (final deg in circuitAngles) {
      final angle = deg * (3.14159 / 180);
      final r1 = size.width * 0.24;
      final r2 = size.width * 0.34;
      final x1 = cx + r1 * _cos(angle);
      final y1 = cy + r1 * _sin(angle);
      final x2 = cx + r2 * _cos(angle);
      final y2 = cy + r2 * _sin(angle);
      canvas.drawLine(
          Offset(x1, y1), Offset(x2, y2), linePaint..strokeWidth = 1.0);
      // Small dot at junction
      canvas.drawCircle(Offset(x2, y2), 2.5,
          Paint()..color = Colors.white.withOpacity(0.6));
    }
  }

  double _cos(double rad) => _mathCos(rad);
  double _sin(double rad) => _mathSin(rad);

  // Simple trig helpers (dart:math not imported to keep single-file)
  double _mathCos(double x) {
    // Taylor series approximation good enough for drawing
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _mathSin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_CarIllustrationPainter old) => false;
}
