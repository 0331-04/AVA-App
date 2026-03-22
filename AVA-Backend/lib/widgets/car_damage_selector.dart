import 'package:flutter/material.dart';


const List<Map<String, Object>> kDamageAreas = [
  {'label': 'Front Bumper', 'icon': Icons.arrow_upward},
  {'label': 'Rear Bumper',  'icon': Icons.arrow_downward},
  {'label': 'Left Side',    'icon': Icons.arrow_back},
  {'label': 'Right Side',   'icon': Icons.arrow_forward},
  {'label': 'Bonnet',       'icon': Icons.rectangle_outlined},
  {'label': 'Roof',         'icon': Icons.roofing_outlined},
  {'label': 'Boot',         'icon': Icons.vertical_align_bottom},
  {'label': 'Other',        'icon': Icons.more_horiz},
];

class CarDamageSelector extends StatelessWidget {
  final String? selectedArea;
  final ValueChanged<String> onAreaSelected;

  const CarDamageSelector({
    super.key,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Car diagram
        _CarDiagram(
          selectedArea: selectedArea,
          onAreaSelected: onAreaSelected,
        ),
        const SizedBox(height: 14),

        // Selected area label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: selectedArea != null
              ? Container(
                  key: ValueKey(selectedArea),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004AAD).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF004AAD).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF004AAD), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$selectedArea selected',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004AAD),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  'Tap the damaged area on the car',
                  key: const ValueKey('hint'),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                  ),
                ),
        ),
        const SizedBox(height: 14),

        // Area grid 
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: kDamageAreas.map((area) {
            final label = area['label'] as String;
            final isSelected = selectedArea == label;
            return GestureDetector(
              onTap: () => onAreaSelected(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF004AAD)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF004AAD)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF004AAD)
                                .withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

//  Top-down car diagram 
class _CarDiagram extends StatelessWidget {
  final String? selectedArea;
  final ValueChanged<String> onAreaSelected;

  const _CarDiagram({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = w * 1.4;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Car body 
              CustomPaint(
                size: Size(w, h),
                painter: _CarBodyPainter(selectedArea: selectedArea),
              ),

              // Tap zones
              // Front bumper
              _TapZone(
                left: w * 0.2, top: h * 0.03,
                width: w * 0.6, height: h * 0.1,
                label: 'Front Bumper',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Bonnet
              _TapZone(
                left: w * 0.2, top: h * 0.13,
                width: w * 0.6, height: h * 0.18,
                label: 'Bonnet',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Roof
              _TapZone(
                left: w * 0.2, top: h * 0.34,
                width: w * 0.6, height: h * 0.16,
                label: 'Roof',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Boot
              _TapZone(
                left: w * 0.2, top: h * 0.53,
                width: w * 0.6, height: h * 0.14,
                label: 'Boot',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Rear bumper
              _TapZone(
                left: w * 0.2, top: h * 0.87,
                width: w * 0.6, height: h * 0.1,
                label: 'Rear Bumper',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Left side
              _TapZone(
                left: w * 0.01, top: h * 0.15,
                width: w * 0.18, height: h * 0.65,
                label: 'Left Side',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
              // Right side
              _TapZone(
                left: w * 0.81, top: h * 0.15,
                width: w * 0.18, height: h * 0.65,
                label: 'Right Side',
                selectedArea: selectedArea,
                onTap: onAreaSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}

//  Tap zone overlay 
class _TapZone extends StatelessWidget {
  final double left, top, width, height;
  final String label;
  final String? selectedArea;
  final ValueChanged<String> onTap;

  const _TapZone({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.label,
    required this.selectedArea,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedArea == label;
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onTap(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF004AAD).withOpacity(0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF004AAD), width: 2)
                : null,
          ),
        ),
      ),
    );
  }
}

//  Car body painter 
class _CarBodyPainter extends CustomPainter {
  final String? selectedArea;
  _CarBodyPainter({this.selectedArea});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = const Color(0xFFE8EDF5)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF004AAD).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final linePaint = Paint()
      ..color = const Color(0xFF004AAD).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    //  Main car outline (top-down view) 
    final carPath = Path();
    // Start at front-left bumper corner
    carPath.moveTo(w * 0.28, h * 0.03);
    carPath.lineTo(w * 0.72, h * 0.03); // front bumper top
    carPath.quadraticBezierTo(w * 0.82, h * 0.04, w * 0.82, h * 0.12); // front-right corner
    carPath.lineTo(w * 0.82, h * 0.88); // right side
    carPath.quadraticBezierTo(w * 0.82, h * 0.96, w * 0.72, h * 0.97); // rear-right corner
    carPath.lineTo(w * 0.28, h * 0.97); // rear bumper
    carPath.quadraticBezierTo(w * 0.18, h * 0.96, w * 0.18, h * 0.88); // rear-left corner
    carPath.lineTo(w * 0.18, h * 0.12); // left side
    carPath.quadraticBezierTo(w * 0.18, h * 0.04, w * 0.28, h * 0.03); // front-left corner
    carPath.close();
    canvas.drawPath(carPath, bodyPaint);
    canvas.drawPath(carPath, outlinePaint);

    //  Windscreen (front) 
    final windscreenPaint = Paint()
      ..color = const Color(0xFF004AAD).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final windscreen = Path();
    windscreen.moveTo(w * 0.25, h * 0.16);
    windscreen.lineTo(w * 0.75, h * 0.16);
    windscreen.lineTo(w * 0.72, h * 0.30);
    windscreen.lineTo(w * 0.28, h * 0.30);
    windscreen.close();
    canvas.drawPath(windscreen, windscreenPaint);
    canvas.drawPath(windscreen, linePaint);

    //  Rear window 
    final rearWindow = Path();
    rearWindow.moveTo(w * 0.28, h * 0.68);
    rearWindow.lineTo(w * 0.72, h * 0.68);
    rearWindow.lineTo(w * 0.72, h * 0.80);
    rearWindow.lineTo(w * 0.28, h * 0.80);
    rearWindow.close();
    canvas.drawPath(rearWindow, windscreenPaint);
    canvas.drawPath(rearWindow, linePaint);

    //  Roof outline 
    final roofPaint = Paint()
      ..color = const Color(0xFF004AAD).withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final roof = RRect.fromLTRBR(
      w * 0.24, h * 0.32, w * 0.76, h * 0.52,
      const Radius.circular(8),
    );
    canvas.drawRRect(roof, roofPaint);
    canvas.drawRRect(roof, linePaint);

    //  Door lines 
    // Front door line
    canvas.drawLine(
      Offset(w * 0.18, h * 0.42),
      Offset(w * 0.82, h * 0.42),
      linePaint,
    );
    // Rear door line
    canvas.drawLine(
      Offset(w * 0.18, h * 0.58),
      Offset(w * 0.82, h * 0.58),
      linePaint,
    );

    //  Wheels 
    final wheelPaint = Paint()
      ..color = const Color(0xFF2C2389).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final wheelBorder = Paint()
      ..color = const Color(0xFF2C2389).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Front-left
    final flWheel =
        RRect.fromLTRBR(w * 0.04, h * 0.14, w * 0.18, h * 0.30,
            const Radius.circular(4));
    canvas.drawRRect(flWheel, wheelPaint);
    canvas.drawRRect(flWheel, wheelBorder);

    // Front-right
    final frWheel =
        RRect.fromLTRBR(w * 0.82, h * 0.14, w * 0.96, h * 0.30,
            const Radius.circular(4));
    canvas.drawRRect(frWheel, wheelPaint);
    canvas.drawRRect(frWheel, wheelBorder);

    // Rear-left
    final rlWheel =
        RRect.fromLTRBR(w * 0.04, h * 0.68, w * 0.18, h * 0.84,
            const Radius.circular(4));
    canvas.drawRRect(rlWheel, wheelPaint);
    canvas.drawRRect(rlWheel, wheelBorder);

    // Rear-right
    final rrWheel =
        RRect.fromLTRBR(w * 0.82, h * 0.68, w * 0.96, h * 0.84,
            const Radius.circular(4));
    canvas.drawRRect(rrWheel, wheelPaint);
    canvas.drawRRect(rrWheel, wheelBorder);

    //  Direction labels 
    final labelStyle = TextStyle(
      color: const Color(0xFF004AAD).withOpacity(0.4),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    void drawLabel(String text, Offset offset) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    }

    drawLabel('FRONT', Offset(w * 0.5, h * 0.075));
    drawLabel('REAR', Offset(w * 0.5, h * 0.925));
    drawLabel('L', Offset(w * 0.11, h * 0.5));
    drawLabel('R', Offset(w * 0.89, h * 0.5));
  }

  @override
  bool shouldRepaint(_CarBodyPainter old) =>
      old.selectedArea != selectedArea;
}
