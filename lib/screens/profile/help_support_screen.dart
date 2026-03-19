import 'package:flutter/material.dart';


class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaq;

  static const _faqs = [
    {
      'q': 'How long does a claim take to process?',
      'a': 'Most claims are reviewed within 3–5 working days after submission. Complex cases may take up to 10 working days. You will receive notifications at each step of the process.',
    },
    {
      'q': 'How is the damage estimate calculated?',
      'a': 'Our AI analyses your uploaded photos and estimates repair costs based on damage type, vehicle model, and current Sri Lankan market rates for parts and labour. The estimate is preliminary and may be adjusted after physical inspection.',
    },
    {
      'q': 'What photos should I upload?',
      'a': 'Upload at least 3 photos: a close-up of the damage, a mid-range shot from 1–2 metres, and a wide-angle shot showing the full side of the vehicle. Clear, well-lit photos improve AI accuracy.',
    },
    {
      'q': 'Can I edit my claim after submitting?',
      'a': 'You can upload additional photos while the claim is In Review. Once it reaches Assessment stage, no further edits are possible. Contact our support team if you need to make corrections.',
    },
    {
      'q': 'Why was my claim rejected?',
      'a': 'Common reasons include insufficient photo evidence, damage inconsistent with the reported incident, or a lapsed insurance policy. Check the Assessor Notes in your Claim Detail screen for the specific reason.',
    },
    {
      'q': 'How do I dispute a rejected claim?',
      'a': 'Tap "Dispute this Decision" on the Claim Detail screen and provide additional evidence or explanation. Our team will review the dispute within 5 working days.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _HelpHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact options
                  _ContactCard(context: context),
                  const SizedBox(height: 14),

                  // FAQ section
                  const Text('Frequently Asked Questions',
                      style: TextStyle(fontSize: 15, fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 10),
                  ...List.generate(_faqs.length, (i) {
                    final isExpanded = _expandedFaq == i;
                    return GestureDetector(
                      onTap: () => setState(() =>
                          _expandedFaq = isExpanded ? null : i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpanded
                                ? const Color(0xFF004AAD).withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04),
                                blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(_faqs[i]['q']!,
                                      style: TextStyle(
                                        fontSize: 13, fontFamily: 'Poppins',
                                        fontWeight: isExpanded
                                            ? FontWeight.w700 : FontWeight.w500,
                                        color: isExpanded
                                            ? const Color(0xFF004AAD) : Colors.black87,
                                      )),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: isExpanded
                                      ? const Color(0xFF004AAD) : Colors.grey.shade400,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Text(_faqs[i]['a']!,
                                  style: TextStyle(
                                    fontSize: 12, fontFamily: 'Poppins',
                                    color: Colors.grey.shade700, height: 1.6,
                                  )),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),

                  // Quick links
                  _QuickLinks(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Contact card 
class _ContactCard extends StatelessWidget {
  final BuildContext context;
  const _ContactCard({required this.context});

  @override
  Widget build(BuildContext _) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Support',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Our team is available Mon–Fri, 8AM–6PM',
              style: TextStyle(fontSize: 11, fontFamily: 'Poppins',
                  color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _ContactBtn(
                icon: Icons.phone_outlined,
                label: 'Call Us',
                color: Colors.green.shade600,
                onTap: () {
                  // TODO: launch('tel:+94112345678')
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling +94 11 234 5678...'),
                        duration: Duration(seconds: 1)));
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _ContactBtn(
                icon: Icons.email_outlined,
                label: 'Email Us',
                color: const Color(0xFF004AAD),
                onTap: () {
                  // TODO: launch('mailto:support@ava-inspec.lk')
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email...'),
                        duration: Duration(seconds: 1)));
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _ContactBtn(
                icon: Icons.chat_bubble_outline,
                label: 'Live Chat',
                color: Colors.purple.shade600,
                onTap: () {
                  // TODO: Open live chat widget
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live chat coming soon!'),
                        duration: Duration(seconds: 1)));
                },
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

//  Quick links 
class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          _LinkRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy',
              onTap: () {}),
          const Divider(height: 16),
          _LinkRow(icon: Icons.description_outlined, label: 'Terms & Conditions',
              onTap: () {}),
          const Divider(height: 16),
          _LinkRow(icon: Icons.info_outline, label: 'App Version 1.0.0',
              showArrow: false, onTap: () {}),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;
  const _LinkRow({required this.icon, required this.label,
      required this.onTap, this.showArrow = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF004AAD), size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 13, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500, color: Colors.black87))),
          if (showArrow)
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
//  HEADER
// ----------------------------------------------------------
class _HelpHeader extends StatelessWidget {
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
                const Text('Help & Support',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontFamily: 'WorkSans', fontWeight: FontWeight.w700,
                        shadows: [Shadow(offset: Offset(0, 4), blurRadius: 4,
                            color: Color(0x40000000))])),
                Text('We are here to help you',
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
