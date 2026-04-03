import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.car_crash_outlined,
      title: 'Report Accidents\nInstantly',
      body: 'Involved in an accident? Open AVA-Inspec, select the damaged area and submit your claim in under 3 minutes — right from the scene.',
      gradient: [Color(0xFF004AAD), Color(0xFF1A56DB)],
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'AI-Powered\nDamage Analysis',
      body: 'Our AI analyses your photos and produces a damage estimate with up to 91% accuracy — giving you a cost breakdown before your assessor even arrives.',
      gradient: [Color(0xFF2C2389), Color(0xFF004AAD)],
    ),
    _OnboardingSlide(
      icon: Icons.track_changes_outlined,
      title: 'Track Every Step\nIn Real Time',
      body: 'Follow your claim from submission to payment with live status updates, assessor notes, and instant notifications at every milestone.',
      gradient: [Color(0xFF1A56DB), Color(0xFF3B82F6)],
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToTerms();
    }
  }

  void _goToTerms() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('accepted_terms', true);

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const TermsScreen()),
  );
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
          ),

          // Skip button
          Positioned(
            top: 55,
            right: 24,
            child: SafeArea(
              child: GestureDetector(
                onTap: _goToTerms,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Next / Get Started button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ── Single slide ─
class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
  });
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Icon(slide.icon, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 8,
                        color: Color(0x40000000)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Body
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
