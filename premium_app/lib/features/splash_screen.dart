import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  void _startTransition() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Stack(
        children: [
          // Cosmic Background
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 0, context: context),
          ),

          // Liquid Glass Orb — expanding radial glow behind logo
          Center(
            child: RepaintBoundary(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumTokens.nebulaBlue.withValues(alpha: 0.12),
                      PremiumTokens.nebulaBlue.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.2, 1.2),
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 800.ms),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with elastic entrance
                PremiumUI.logo(height: 120)
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms)
                .then()
                .shimmer(
                  duration: 2.seconds,
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
                ),
                
                const SizedBox(height: 32),
                
                // Title with staggered letter appearance
                Text(
                  "SANT-VAANI",
                  style: PremiumTokens.sansStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 8,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic)
                .then()
                .shimmer(delay: 1.seconds, duration: 2.seconds, color: PremiumTokens.nebulaBlue),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  "THE ETHEREAL VOID",
                  style: PremiumTokens.sansStyle(
                    fontSize: 10,
                    color: PremiumTokens.nebulaBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 800.ms)
                .slideY(begin: 0.5, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
