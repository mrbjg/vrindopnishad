import 'package:flutter/material.dart';
import 'package:path_morph/path_morph.dart';
import 'dart:math' as math;

class SacredMorphWidget extends StatefulWidget {
  final double size;
  final Color color;

  const SacredMorphWidget({
    super.key,
    this.size = 100,
    this.color = const Color(0xFFF59E0B),
  });

  @override
  State<SacredMorphWidget> createState() => _SacredMorphWidgetState();
}

class _SacredMorphWidgetState extends State<SacredMorphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late SampledPathData _pathData;
  late Animation<double> _animation;

  // Path data (Simplified paths for morphing)
  // 1. Lotus (Simplified)
  static const String lotusPath =
      "M50 85 C30 85 15 65 15 45 C15 25 35 10 50 10 C65 10 85 25 85 45 C85 65 70 85 50 85 Z M50 70 C40 70 35 60 35 50 C35 40 45 35 50 35 C55 35 65 40 65 50 C65 60 60 70 50 70 Z";
  
  // 2. Om (Simplified circle for now to ensure compatibility)
  static const String omPath =
      "M50 90 C25 90 10 70 10 45 C10 20 25 5 50 5 C75 5 90 20 90 45 C90 70 75 90 50 90 Z M50 75 C35 75 25 65 25 50 C25 35 35 25 50 25 C65 25 75 35 75 50 C75 65 65 75 50 75 Z";

  // 3. Diya (Simplified)
  static const String diyaPath = 
      "M20 60 Q50 90 80 60 L80 40 Q50 30 20 40 Z M50 20 Q55 35 50 45 Q45 35 50 20 Z";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);

    // Initial morph (Lotus to Om)
    _pathData = PathMorph.samplePaths(
      PathMorph.parseSvgPathData(lotusPath),
      PathMorph.parseSvgPathData(omPath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: MorphPainter(
            pathData: _pathData,
            value: _animation.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class MorphPainter extends CustomPainter {
  final SampledPathData pathData;
  final double value;
  final Color color;

  MorphPainter({
    required this.pathData,
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Scale the shapes to fit the size
    double scale = size.width / 100;
    canvas.scale(scale);

    Path shiftedPath = PathMorph.generatePath(pathData, value);
    canvas.drawPath(shiftedPath, paint);

    // Add a subtle glow
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(shiftedPath, paint.copyWith(color: color.withOpacity(0.3)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
