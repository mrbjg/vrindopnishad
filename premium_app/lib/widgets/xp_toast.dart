import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';

class XPToast {
  static void show(BuildContext context, int amount, String reason, {double multiplier = 1.0}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumTokens.activeAccent.withValues(alpha: 0.9),
                    PremiumTokens.voidIndigo.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
                border: Border.all(color: PremiumTokens.borderMedium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(
                    '+$amount XP',
                    style: PremiumTokens.sansStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 16, color: PremiumTokens.textHint),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      reason.toUpperCase(),
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: PremiumTokens.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (multiplier > 1.0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '🔥 ${multiplier}x',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.saffronGlow,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.5, duration: 400.ms, curve: Curves.easeOutBack)
              .then(delay: 2.seconds)
              .fadeOut(duration: 400.ms)
              .slideY(end: -0.5),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2800), () {
      overlayEntry.remove();
    });
  }
}
