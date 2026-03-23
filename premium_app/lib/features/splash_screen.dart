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
    // Reduced delay for "Instant" feel, but enough for the animation to be seen
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 0),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumUI.logo(height: 120)
                .animate()
                .fadeIn(duration: 1.seconds)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                Text(
                  "SANT-VAANI",
                  style: PremiumTokens.sansStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 8,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 1.seconds)
                .shimmer(delay: 2.seconds, duration: 2.seconds, color: PremiumTokens.nebulaBlue),
                
                const SizedBox(height: 8),
                
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
                .fadeIn(delay: 800.ms, duration: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
