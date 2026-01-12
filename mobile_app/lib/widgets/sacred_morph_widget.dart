import 'package:flutter/material.dart';
import 'package:path_morph/path_morph.dart';

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
  SampledPathData? _pathData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Create paths after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePaths();
    });
  }

  void _initializePaths() {
    // Create Lotus-like path (flower shape)
    final path1 = Path()
      ..addOval(Rect.fromCenter(center: const Offset(50, 50), width: 60, height: 60))
      ..addOval(Rect.fromCenter(center: const Offset(50, 30), width: 30, height: 30))
      ..addOval(Rect.fromCenter(center: const Offset(50, 70), width: 30, height: 30));

    // Create Om-like path (rounded shape)
    final path2 = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(50, 50), width: 70, height: 70),
        const Radius.circular(35),
      ))
      ..addOval(Rect.fromCenter(center: const Offset(50, 25), width: 20, height: 20))
      ..addOval(Rect.fromCenter(center: const Offset(50, 75), width: 20, height: 20));

    // Sample the paths
    _pathData = PathMorph.samplePaths(path1, path2);

    // Generate animations
    PathMorph.generateAnimations(_controller, _pathData!, (i, z) {
      setState(() {
        _pathData!.shiftedPoints[i] = z;
      });
    });

    // Start repeating animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pathData == null) {
      // Show placeholder while initializing
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Icon(
            Icons.spa,
            size: widget.size * 0.5,
            color: widget.color.withOpacity(0.5),
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: MorphPainter(
        pathData: _pathData!,
        color: widget.color,
      ),
    );
  }
}

class MorphPainter extends CustomPainter {
  final SampledPathData pathData;
  final Color color;

  MorphPainter({
    required this.pathData,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Scale the shapes to fit the size
    double scale = size.width / 100;
    canvas.scale(scale);

    // Generate the morphed path
    Path shiftedPath = PathMorph.generatePath(pathData);
    canvas.drawPath(shiftedPath, paint);

    // Add a subtle glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawPath(shiftedPath, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
