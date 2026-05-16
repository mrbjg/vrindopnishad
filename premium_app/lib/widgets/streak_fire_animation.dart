import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';

class StreakFireAnimation extends StatelessWidget {
  final int streak;
  final bool isActive;

  const StreakFireAnimation({
    super.key,
    required this.streak,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow/Pulse
        if (isActive)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1.seconds),

        // Fire Icon
        Text(
          isActive ? '🔥' : '❄️',
          style: const TextStyle(fontSize: 24),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .shake(hz: 2, curve: Curves.easeInOutSine, duration: 500.ms),

        // Streak Number
        if (isActive)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PremiumTokens.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$streak',
                style: TextStyle(
                  color: PremiumTokens.surfaceMain,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),
      ],
    );
  }
}
