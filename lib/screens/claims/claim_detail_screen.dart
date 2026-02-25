import 'package:flutter/material.dart';
import '../../widgets/photo_viewer.dart';

class ClaimDetail {
  final String claimId;
  final String vehicle;
  final String licensePlate;
  final String damageArea;
  final String damageDescription;
  final String submittedDate;
  final String estimatedCompletion;
  final String location;
  final int estimateLKR;
  final int labourLKR;
  final int partsLKR;
  final int otherLKR;
  final double aiConfidence;
  final String status;
  final int currentStepIndex;
  final int photosUploaded;
  final List<String> assessorNotes;

  const ClaimDetail({
    required this.claimId,
    required this.vehicle,
    required this.licensePlate,
    required this.damageArea,
    required this.damageDescription,
    required this.submittedDate,
    required this.estimatedCompletion,
    required this.location,
    required this.estimateLKR,
    required this.labourLKR,
    required this.partsLKR,
    required this.otherLKR,
    required this.aiConfidence,
    required this.status,
    required this.currentStepIndex,
    required this.photosUploaded,
    required this.assessorNotes,
  });
}

// TODO: Replace with real data passed from ClaimHistoryScreen
const _mockDetail = ClaimDetail(
  claimId: '#CLM-1042',
  vehicle: 'Toyota Camry 2022',
  licensePlate: 'ABC-1234',
  damageArea: 'Front Bumper',
  damageDescription: 'Rear-ended at traffic light, significant scratch and dent on front bumper.',
  submittedDate: 'Nov 20, 2024',
  estimatedCompletion: 'Dec 5, 2024',
  location: '6.0535° N, 80.2210° E — Galle, Sri Lanka',
  estimateLKR: 375000,
  labourLKR: 95000,
  partsLKR: 245000,
  otherLKR: 35000,
  aiConfidence: 0.91,
  status: 'Payment Processing',
  currentStepIndex: 3,
  photosUploaded: 4,
  assessorNotes: [
    'AI analysis detected moderate front bumper impact.',
    'Physical inspection confirmed scratch depth: 2–3mm.',
    'OEM bumper part recommended for replacement.',
  ],
);

class ClaimDetailScreen extends StatelessWidget {
  final ClaimDetail claim;
  const ClaimDetailScreen({super.key, this.claim = _mockDetail});

  static String formatLKR(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return 'LKR ${result.toString()}';
  }

  Color get _statusColor {
    switch (claim.status) {
      case 'Approved':           return Colors.green.shade600;
      case 'Rejected':           return Colors.red.shade600;
      case 'Payment Processing': return Colors.blue.shade700;
      default:                   return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _DetailHeader(claim: claim, statusColor: _statusColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _SubmissionInfoCard(claim: claim),
                  const SizedBox(height: 14),
                  _TimelineCard(currentStep: claim.currentStepIndex),
                  const SizedBox(height: 14),
                  _AIScoreCard(confidence: claim.aiConfidence),
                  const SizedBox(height: 14),
                  _CostCard(claim: claim),
                  const SizedBox(height: 14),
                  _PhotosCard(count: claim.photosUploaded),
                  const SizedBox(height: 14),
                  _AssessorCard(notes: claim.assessorNotes),
                  const SizedBox(height: 14),
                  if (claim.status == 'Rejected')
                    _DisputeButton(context: context),
                  _DownloadRow(context: context),
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
//  HEADER
// ----------------------------------------------------------
class _DetailHeader extends StatelessWidget {
  final ClaimDetail claim;
  final Color statusColor;
  const _DetailHeader(
      {required this.claim, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 195,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                            size: 16),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Text(
                        claim.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Claim Detail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
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
                  claim.claimId,
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
//  SUBMISSION INFO CARD
// ----------------------------------------------------------
class _SubmissionInfoCard extends StatelessWidget {
  final ClaimDetail claim;
  const _SubmissionInfoCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2389),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim.vehicle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        )),
                    Text('License Plate: ${claim.licensePlate}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade600,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _Row(icon: Icons.warning_amber_outlined,
              label: 'Damage Area', value: claim.damageArea),
          _Row(icon: Icons.description_outlined,
              label: 'Description', value: claim.damageDescription),
          _Row(icon: Icons.calendar_today_outlined,
              label: 'Submitted', value: claim.submittedDate),
          _Row(icon: Icons.event_available_outlined,
              label: 'Est. Completion', value: claim.estimatedCompletion),
          if (claim.location.isNotEmpty)
            _Row(icon: Icons.location_on_outlined,
                label: 'Location', value: claim.location),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  TIMELINE CARD
// ----------------------------------------------------------
class _TimelineCard extends StatelessWidget {
  final int currentStep;
  const _TimelineCard({required this.currentStep});

  static const _steps = ['Submitted', 'In Review', 'Assessment', 'Decision'];
  static const _icons = [
    Icons.upload_file_outlined,
    Icons.manage_search_outlined,
    Icons.analytics_outlined,
    Icons.gavel_outlined,
  ];
  static const _descs = [
    'Claim received & AI verified',
    'Assessor reviewing your case',
    'Damage cost estimated',
    'Final approval & payment',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Claim Progress',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final done   = i < currentStep;
            final active = i == currentStep;
            final isLast = i == _steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? Colors.green
                            : active ? const Color(0xFF004AAD)
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: done ? Colors.green
                              : active ? const Color(0xFF004AAD)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        done ? Icons.check : _icons[i],
                        color: done || active ? Colors.white : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 34,
                        color: done ? Colors.green.shade300 : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_steps[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: done ? Colors.green.shade700
                                  : active ? const Color(0xFF004AAD)
                                  : Colors.grey.shade400,
                            )),
                        Text(_descs[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              color: active ? Colors.black54 : Colors.grey.shade400,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  AI SCORE CARD
// ----------------------------------------------------------
class _AIScoreCard extends StatelessWidget {
  final double confidence;
  const _AIScoreCard({required this.confidence});

  Color get _color {
    if (confidence >= 0.85) return Colors.green.shade600;
    if (confidence >= 0.65) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String get _label {
    if (confidence >= 0.85) return 'High Confidence';
    if (confidence >= 0.65) return 'Medium Confidence';
    return 'Low Confidence';
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _color.withOpacity(0.4)),
            ),
            child: Icon(Icons.auto_awesome, color: _color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Analysis Score',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: _color,
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_label,
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: _color,
                )),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  COST CARD
// ----------------------------------------------------------
class _CostCard extends StatelessWidget {
  final ClaimDetail claim;
  const _CostCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Damage Estimation',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
          const SizedBox(height: 14),
          _CostRow(label: 'Labour', amount: claim.labourLKR, color: Colors.blue.shade400),
          const SizedBox(height: 8),
          _CostRow(label: 'Parts', amount: claim.partsLKR, color: Colors.purple.shade400),
          const SizedBox(height: 8),
          _CostRow(label: 'Other', amount: claim.otherLKR, color: Colors.orange.shade400),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimate',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              Text(ClaimDetailScreen.formatLKR(claim.estimateLKR),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004AAD),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Preliminary AI estimate. Final amount may vary after physical assessment.',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      color: Colors.amber.shade800,
                      height: 1.4,
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

class _CostRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _CostRow({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label,
            style: const TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Colors.black54))),
        Text(ClaimDetailScreen.formatLKR(amount),
            style: const TextStyle(
                fontSize: 13, fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }
}

// ----------------------------------------------------------
//  PHOTOS CARD
// ----------------------------------------------------------
class _PhotosCard extends StatelessWidget {
  final int count;
  const _PhotosCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Uploaded Photos',
                  style: TextStyle(
                    fontSize: 14, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, color: Colors.black87,
                  )),
              Text('$count photos',
                  style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
                      color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => PhotoViewer.show(context, index: i, count: count),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2389).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined,
                          color: const Color(0xFF2C2389).withOpacity(0.5), size: 22),
                      const SizedBox(height: 4),
                      Text('Photo ${i + 1}',
                          style: TextStyle(fontSize: 9, fontFamily: 'Poppins',
                              color: Colors.grey.shade500)),
                    ],
                  ),
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
//  ASSESSOR NOTES CARD
// ----------------------------------------------------------
class _AssessorCard extends StatelessWidget {
  final List<String> notes;
  const _AssessorCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined,
                  color: Color(0xFF004AAD), size: 18),
              const SizedBox(width: 8),
              const Text('Assessor Notes',
                  style: TextStyle(
                    fontSize: 14, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, color: Colors.black87,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ...notes.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle,
                          size: 6, color: Color(0xFF004AAD)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(note,
                          style: TextStyle(
                            fontSize: 12, fontFamily: 'Poppins',
                            color: Colors.grey.shade700, height: 1.5,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  DISPUTE BUTTON (Rejected claims only)
// ----------------------------------------------------------
class _DisputeButton extends StatelessWidget {
  final BuildContext context;
  const _DisputeButton({required this.context});

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          // TODO: Navigate to DisputeScreen or open dispute form
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispute / appeal — coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.gavel, color: Colors.white, size: 18),
          label: const Text('Dispute this Decision',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
//  DOWNLOAD ROW
// ----------------------------------------------------------
class _DownloadRow extends StatelessWidget {
  final BuildContext context;
  const _DownloadRow({required this.context});

  @override
  Widget build(BuildContext _) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        // TODO: Implement PDF report download
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report download coming soon!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF004AAD), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.download_outlined,
            color: Color(0xFF004AAD), size: 18),
        label: const Text('Download Claim Report',
            style: TextStyle(
                color: Color(0xFF004AAD), fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

// ----------------------------------------------------------
//  REUSABLE WIDGETS
// ----------------------------------------------------------
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, fontFamily: 'Poppins',
                    color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
