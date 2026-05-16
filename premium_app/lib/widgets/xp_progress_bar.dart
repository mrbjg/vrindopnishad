import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';

class XPProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int level;
  final Color? color;

  const XPProgressBar({
    super.key,
    required this.progress,
    required this.level,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? PremiumTokens.nebulaBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LEVEL $level',
              style: PremiumTokens.sansStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: barColor,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: PremiumTokens.sansStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: PremiumTokens.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: PremiumTokens.borderSubtle,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withValues(alpha: 0.7),
                        barColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(progress)).shimmer(duration: 2.seconds),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
