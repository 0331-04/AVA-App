import 'package:flutter/material.dart';
import '../../widgets/car_damage_selector.dart';
import '../../widgets/loading_overlay.dart';
import '../dashboard/dashboard_screens.dart';


class ReportClaimScreen extends StatefulWidget {
  const ReportClaimScreen({super.key});

  @override
  State<ReportClaimScreen> createState() => _ReportClaimScreenState();
}

class _ReportClaimScreenState extends State<ReportClaimScreen> {
  int _currentStep = 0;

  // Step 1 state
  String? _selectedArea;
  String _damageDescription = '';
  String _claimReference = '';
  bool _locationCaptured = false;
  String _locationText = '';

  // Step 2 state
  // TODO: Replace String with File when using real camera/gallery
  final Map<String, String?> _capturedPhotos = {
    'Close-up': null,
    'Midrange': null,
    'Wideangle': null,
  };

  bool get _hasAtLeastOnePhoto =>
      _capturedPhotos.values.any((v) => v != null);

  void _nextStep() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _ClaimHeader(currentStep: _currentStep),

          if (_currentStep < 3)
            _StepProgressBar(currentStep: _currentStep),

          // Progress saved indicator
          if (_currentStep > 0 && _currentStep < 3)
            _ProgressSavedBanner(),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));
                return SlideTransition(position: slide, child: child);
              },
              child: _buildStep(),
            ),
          ),

          if (_currentStep < 3)
            _BottomBar(currentStep: _currentStep, onBack: _prevStep),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _Step1SelectArea(
          key: const ValueKey(0),
          selectedArea: _selectedArea,
          damageDescription: _damageDescription,
          claimReference: _claimReference,
          locationCaptured: _locationCaptured,
          locationText: _locationText,
          onAreaSelected: (a) => setState(() => _selectedArea = a),
          onDescriptionChanged: (v) => setState(() => _damageDescription = v),
          onReferenceChanged: (v) => setState(() => _claimReference = v),
          onLocationCapture: () {
            // TODO: Replace with real GPS: geolocator package
            
            setState(() {
              _locationCaptured = true;
              _locationText = '6.0535° N, 80.2210° E — Galle, Sri Lanka';
            });
          },
          onProceed: _selectedArea != null ? _nextStep : null,
        );
      case 1:
        return _Step2AICapture(
          key: const ValueKey(1),
          capturedPhotos: _capturedPhotos,
          hasAtLeastOnePhoto: _hasAtLeastOnePhoto,
          onPhotoCaptured: (type, path) =>
              setState(() => _capturedPhotos[type] = path),
          onProceed: _hasAtLeastOnePhoto ? _nextStep : null,
        );
      case 2:
        return _Step3ReviewSubmit(
          key: const ValueKey(2),
          capturedPhotos: _capturedPhotos,
          selectedArea: _selectedArea ?? 'Unknown',
          damageDescription: _damageDescription,
          claimReference: _claimReference,
          locationText: _locationText,
          onSubmit: () async {
                LoadingOverlay.show(context, message: 'Submitting your claim...');
                await Future.delayed(const Duration(seconds: 2)); // TODO: replace with real API call
                if (mounted) {
                  LoadingOverlay.hide(context);
                  _nextStep();
                }
              },
        );
      case 3:
        return _Step4Complete(
          key: const ValueKey(3),
          onNewClaim: () => setState(() {
            _currentStep = 0;
            _selectedArea = null;
            _damageDescription = '';
            _claimReference = '';
            _locationCaptured = false;
            _locationText = '';
            _capturedPhotos.updateAll((_, __) => null);
          }),
          onGoHome: () {
            final nav = Navigator.of(context);
            nav.pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ----------------------------------------------------------
//  PROGRESS SAVED BANNER
// ----------------------------------------------------------
class _ProgressSavedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Icon(Icons.cloud_done_outlined,
              size: 14, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            'Your progress is being saved automatically',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  SHARED BLUE HEADER
// ----------------------------------------------------------
class _ClaimHeader extends StatelessWidget {
  final int currentStep;
  const _ClaimHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 210,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
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
                        fontSize: 25,
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Report a Claim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
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
                if (currentStep == 0)
                  const Text(
                    'Your AI assistant is here to guide you.',
                    style: TextStyle(
                      color: Colors.white70,
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
//  STEP PROGRESS BAR
// ----------------------------------------------------------
class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  const _StepProgressBar({required this.currentStep});

  static const _labels = [
    'Select\nDamage Side',
    'AI Guided\nCapture',
    'Review &\nSubmit',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF978B8B), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < currentStep;
          final active = i == currentStep;
          final isLast = i == 2;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? Colors.green
                              : active
                                  ? const Color(0xFF004AAD)
                                  : Colors.white,
                          border: Border.all(
                            color: done
                                ? Colors.green
                                : active
                                    ? const Color(0xFF004AAD)
                                    : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          color: active
                              ? const Color(0xFF004AAD)
                              : done
                                  ? Colors.green
                                  : Colors.grey.shade500,
                          fontWeight: active || done
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 28),
                      color:
                          done ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ----------------------------------------------------------
//  STEP 1 — SELECT DAMAGED AREA + DESCRIPTION + LOCATION
// ----------------------------------------------------------
class _Step1SelectArea extends StatelessWidget {
  final String? selectedArea;
  final String damageDescription;
  final String claimReference;
  final bool locationCaptured;
  final String locationText;
  final ValueChanged<String> onAreaSelected;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onReferenceChanged;
  final VoidCallback onLocationCapture;
  final VoidCallback? onProceed;

  const _Step1SelectArea({
    super.key,
    required this.selectedArea,
    required this.damageDescription,
    required this.claimReference,
    required this.locationCaptured,
    required this.locationText,
    required this.onAreaSelected,
    required this.onDescriptionChanged,
    required this.onReferenceChanged,
    required this.onLocationCapture,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Select Damaged Area',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the area of your vehicle that was damaged',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          //  Car Damage Selector 
          CarDamageSelector(
            selectedArea: selectedArea,
            onAreaSelected: onAreaSelected,
          ),
          const SizedBox(height: 18),

          //  Damage description 
          const Text(
            'Describe the damage',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: damageDescription,
            maxLines: 3,
            maxLength: 300,
            onChanged: onDescriptionChanged,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'e.g. Rear-ended at traffic light, significant dent on bumper...',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF978B8B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF004AAD), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          //  Claim reference number 
          const Text(
            'Claim Reference (optional)',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: claimReference,
            onChanged: onReferenceChanged,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter existing claim reference number',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.tag,
                  color: Color(0xFF004AAD), size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF978B8B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF004AAD), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          //  Location capture 
          GestureDetector(
            onTap: onLocationCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: locationCaptured
                    ? Colors.green.shade50
                    : const Color(0xFF004AAD).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: locationCaptured
                      ? Colors.green.shade400
                      : const Color(0xFF004AAD).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    locationCaptured
                        ? Icons.location_on
                        : Icons.location_off_outlined,
                    color: locationCaptured
                        ? Colors.green.shade600
                        : const Color(0xFF004AAD),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationCaptured
                              ? 'Location captured'
                              : 'Capture incident location',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: locationCaptured
                                ? Colors.green.shade700
                                : const Color(0xFF004AAD),
                          ),
                        ),
                        if (locationCaptured)
                          Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: Colors.green.shade600,
                            ),
                          )
                        else
                          Text(
                            'Tap to use your current GPS location',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    locationCaptured
                        ? Icons.check_circle
                        : Icons.my_location,
                    color: locationCaptured
                        ? Colors.green
                        : const Color(0xFF004AAD),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          //  Proceed button 
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                onProceed != null
                    ? 'Proceed To AI Guidance'
                    : 'Select a damage area to proceed',
                style: TextStyle(
                  color: onProceed != null
                      ? Colors.white
                      : Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  STEP 2 AI GUIDED PHOTO CAPTURE (with gallery + validation)
// ----------------------------------------------------------
class _Step2AICapture extends StatefulWidget {
  final Map<String, String?> capturedPhotos;
  final bool hasAtLeastOnePhoto;
  final void Function(String type, String path) onPhotoCaptured;
  final VoidCallback? onProceed;

  const _Step2AICapture({
    super.key,
    required this.capturedPhotos,
    required this.hasAtLeastOnePhoto,
    required this.onPhotoCaptured,
    required this.onProceed,
  });

  @override
  State<_Step2AICapture> createState() => _Step2AICaptureState();
}

class _Step2AICaptureState extends State<_Step2AICapture>
    with SingleTickerProviderStateMixin {
  int _photoIndex = 0;

  static const _photoSteps = [
    {
      'type':  'Close-up',
      'label': 'Close-up of damage',
      'tip':   'Place the damage in the center of the frame',
    },
    {
      'type':  'Midrange',
      'label': 'Mid-range shot (1-2m)',
      'tip':   'Step back 1-2 meters and keep the car centered',
    },
    {
      'type':  'Wideangle',
      'label': 'Wide angle shot',
      'tip':   'Capture the full side of the vehicle',
    },
  ];

  late final AnimationController _borderController;
  late final Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _borderOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
          parent: _borderController, curve: Curves.easeInOut),
    );
    // Advance to first uncaptured photo
    _syncPhotoIndex();
  }

  void _syncPhotoIndex() {
    for (int i = 0; i < _photoSteps.length; i++) {
      final type = _photoSteps[i]['type']!;
      if (widget.capturedPhotos[type] == null) {
        _photoIndex = i;
        return;
      }
    }
    _photoIndex = _photoSteps.length - 1;
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  void _simulateCapture(String source) {
    // TODO: Replace with real camera/gallery integration
    
    final type = _photoSteps[_photoIndex]['type']!;
    widget.onPhotoCaptured(type, 'captured_${type}_from_$source');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_photoSteps[_photoIndex]["label"]} captured from $source!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green.shade700,
      ),
    );

    // Advance to next uncaptured slot
    if (_photoIndex < _photoSteps.length - 1) {
      setState(() => _photoIndex++);
    }
  }

  int get _capturedCount =>
      widget.capturedPhotos.values.where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    final step = _photoSteps[_photoIndex];

    return Column(
      children: [
        const SizedBox(height: 10),

        // Section title + captured count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. AI Guided Photo Capture',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _capturedCount > 0
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _capturedCount > 0
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '$_capturedCount/3',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _capturedCount > 0
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        //  Camera viewfinder 
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF0A023A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: widget.capturedPhotos[step['type']] != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                '${step["label"]} captured!',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                ),

                // Animated scanning border
                if (widget.capturedPhotos[step['type']] == null)
                  AnimatedBuilder(
                    animation: _borderOpacity,
                    builder: (_, __) => Container(
                      margin: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: const Color(0xFFFF0308)
                                .withOpacity(_borderOpacity.value),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // AI tip bar at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Photo ${_photoIndex + 1} of 3: ',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'WorkSans'),
                            ),
                            TextSpan(
                              text: step['label'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('AI Tip: ',
                                style: TextStyle(
                                    color: Color(0xFFFFF200),
                                    fontSize: 11,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Text(
                                step['tip']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Roboto'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        //  Capture buttons row: Camera + Gallery 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera button
            GestureDetector(
              onTap: () => _simulateCapture('camera'),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF919998), width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Color(0xFF004AAD), size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Camera',
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // Gallery button
            GestureDetector(
              onTap: () => _simulateCapture('gallery'),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF004AAD).withOpacity(0.08),
                      border: Border.all(
                          color: const Color(0xFF004AAD).withOpacity(0.4),
                          width: 2),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: Color(0xFF004AAD), size: 26),
                  ),
                  const SizedBox(height: 4),
                  const Text('Gallery',
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        //  Validation message + Proceed button 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (!widget.hasAtLeastOnePhoto)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Capture at least 1 photo to proceed',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: widget.onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    widget.hasAtLeastOnePhoto
                        ? 'Proceed to Review ($_capturedCount/3 captured)'
                        : 'Capture photos to proceed',
                    style: TextStyle(
                      color: widget.hasAtLeastOnePhoto
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 13,
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ----------------------------------------------------------
//  STEP 3 — REVIEW & SUBMIT (with photo previews + summary)
// ----------------------------------------------------------
class _Step3ReviewSubmit extends StatelessWidget {
  final Map<String, String?> capturedPhotos;
  final String selectedArea;
  final String damageDescription;
  final String claimReference;
  final String locationText;
  final Future<void> Function() onSubmit;

  const _Step3ReviewSubmit({
    super.key,
    required this.capturedPhotos,
    required this.selectedArea,
    required this.damageDescription,
    required this.claimReference,
    required this.locationText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final capturedCount =
        capturedPhotos.values.where((v) => v != null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Review and Submit',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          //  Claim summary card 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF004AAD).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Claim Summary',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004AAD),
                  ),
                ),
                const Divider(height: 14),
                _SummaryRow(
                    icon: Icons.directions_car,
                    label: 'Damage Area',
                    value: selectedArea),
                if (damageDescription.isNotEmpty)
                  _SummaryRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: damageDescription),
                if (claimReference.isNotEmpty)
                  _SummaryRow(
                      icon: Icons.tag,
                      label: 'Reference',
                      value: claimReference),
                if (locationText.isNotEmpty)
                  _SummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: locationText),
                _SummaryRow(
                    icon: Icons.photo_camera_outlined,
                    label: 'Photos',
                    value: '$capturedCount photo(s) captured'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          //  Photo preview thumbnails 
          const Text(
            'Photo Previews',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: capturedPhotos.entries.map((entry) {
              final type = entry.key;
              final captured = entry.value != null;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 100,
                  decoration: BoxDecoration(
                    color: captured
                        ? const Color(0xFF2C2389)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: captured
                          ? const Color(0xFF2C2389)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        captured
                            ? Icons.check_circle
                            : Icons.add_photo_alternate_outlined,
                        color: captured
                            ? Colors.white
                            : Colors.grey.shade400,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'WorkSans',
                          fontWeight: FontWeight.w700,
                          color: captured
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (captured)
                        const Text(
                          '✓ Captured',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.greenAccent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          //  Finalize button 
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.cloud_upload_outlined,
                  color: Colors.white, size: 18),
              label: const Text(
                'Finalize and submit claim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF004AAD)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  STEP 4 — CLAIM SUBMISSION COMPLETE
// ----------------------------------------------------------
class _Step4Complete extends StatefulWidget {
  final VoidCallback onNewClaim;
  final VoidCallback onGoHome;

  const _Step4Complete({
    super.key,
    required this.onNewClaim,
    required this.onGoHome,
  });

  @override
  State<_Step4Complete> createState() => _Step4CompleteState();
}

class _Step4CompleteState extends State<_Step4Complete>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(
        parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.green.shade400, width: 2),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 48),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Claim Submission Complete',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your claim has been submitted with 3 AI-verified images.\nWe will contact you shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Roboto',
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // TODO: Replace with the real claim ID from backend response
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF004AAD).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.assignment_outlined,
                      color: Color(0xFF004AAD), size: 18),
                  SizedBox(width: 8),
                  Text('Claim ID: ',
                      style: TextStyle(
                          fontSize: 13, fontFamily: 'Roboto')),
                  Text('#CLM-1043',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF004AAD),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF004AAD).withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.3)),
              ),
              child: TextButton(
                onPressed: widget.onNewClaim,
                child: const Text(
                  'Start a New Claim',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: widget.onGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Roboto',
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

// ----------------------------------------------------------
//  BOTTOM BAR
// ----------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;

  const _BottomBar({
    required this.currentStep,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: Colors.black.withOpacity(0.14)),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios,
                        size: 12, color: Color(0xFF0E0505)),
                    SizedBox(width: 4),
                    Text('Back',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF0E0505),
                        )),
                  ],
                ),
              ),
              Text(
                'Step ${currentStep + 1} of 3',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Roboto',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}