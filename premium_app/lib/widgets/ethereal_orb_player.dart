import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/audio_provider.dart';
import '../core/design_system.dart';
import '../features/global_player_screen.dart';

class EtherealOrbPlayer extends ConsumerWidget {
  const EtherealOrbPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final content = audioState.currentContent;
    final isPlaying = audioState.isPlaying;
    final duration = audioState.duration;
    final position = audioState.position;
    
    final progress = duration.inMilliseconds > 0 
        ? position.inMilliseconds / duration.inMilliseconds 
        : 0.0;

    if (content == null) return const SizedBox.shrink();

    final accentColor = _getCategoryColor(content.category);

    return Positioned(
      right: 24,
      bottom: 110, // Elevated above the navbar, right-aligned
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                const GlobalPlayerScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
                    ),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Hero(
          tag: 'audio_player_orb',
          child: Container(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Outer Diffuse Aura
                if (isPlaying)
                  Animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    effects: [
                      ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 3.seconds, curve: PremiumTokens.breathingSine),
                      FadeEffect(begin: 0.05, end: 0.2),
                    ],
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.3),
                      ),
                    ),
                  ),

                // 2. Liquid Core Shimmer
                Animate(
                   onPlay: (c) => c.repeat(),
                   effects: [
                     RotateEffect(duration: 10.seconds),
                   ],
                   child: Container(
                     width: 70,
                     height: 70,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       gradient: SweepGradient(
                         colors: [
                           accentColor.withOpacity(0.0),
                           accentColor.withOpacity(0.4),
                           accentColor.withOpacity(0.0),
                         ],
                         stops: const [0.0, 0.5, 1.0],
                       ),
                     ),
                   ),
                ),

                // 3. Custom Progress Rim
                CustomPaint(
                  size: const Size(80, 80),
                  painter: _CelestialProgressPainter(
                    progress: progress,
                    color: accentColor,
                  ),
                ),

                // 4. Glass Sphere
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Inner Core Glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  accentColor.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Symbolic Icon
                          Text(
                            'ॐ',
                            style: GoogleFonts.spectral(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(color: accentColor.withOpacity(0.8), blurRadius: 15),
                              ],
                            ),
                          ),

                          // Liquid Glass Reflection
                          Positioned(
                            top: 4,
                            left: 12,
                            child: Transform.rotate(
                              angle: -math.pi / 4,
                              child: Container(
                                width: 40,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.elliptical(40, 20)),
                                  gradient: PremiumTokens.glassReflection,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Minimal Play Indicator
                if (!isPlaying)
                  Positioned(
                    bottom: 12,
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white.withOpacity(0.5), size: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    category = category.toLowerCase();
    if (category.contains('shloka')) return PremiumTokens.nebulaBlue;
    if (category.contains('mantra')) return PremiumTokens.saffronGlow;
    if (category.contains('poem')) return PremiumTokens.celestialGlow;
    return PremiumTokens.nebulaBlue;
  }
}

class _CelestialProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CelestialProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    // Rim Background
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // Glowing Progress Path
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    
    // Draw Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Draw solid progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CelestialProgressPainter oldDelegate) => 
    oldDelegate.progress != progress || oldDelegate.color != color;
}
