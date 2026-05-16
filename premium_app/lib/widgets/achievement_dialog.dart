import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../models/achievement.dart';

class AchievementUnlockDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockDialog({
    super.key, 
    required this.achievement,
    this.onDismiss,
  });

  static void show(BuildContext context, Achievement achievement, {VoidCallback? onDismiss}) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
        onDismiss: onDismiss,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Subtle Static Glow (Faster than animated scale)
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
              ),
            ),

            // 2. Main Card
            PremiumUI.etherealCard(
              padding: const EdgeInsets.fromLTRB(28, 70, 28, 32),
              borderRadius: 32,
              glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NEW ACHIEVEMENT',
                    style: PremiumTokens.sansStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: PremiumTokens.saffronGlow,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    achievement.title,
                    style: GoogleFonts.spectral(
                      fontSize: 26,
                      color: PremiumTokens.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spectral(
                      fontSize: 15,
                      color: PremiumTokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderSubtle,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: PremiumTokens.borderSubtle),
                    ),
                    child: Text(
                      'BONUS +${achievement.xpBonus} XP',
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.nebulaBlue,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: PremiumUI.saffronButton(
                      text: 'DHANYAVAAD',
                      onTap: () {
                      Navigator.pop(context);
                      onDismiss?.call();
                    },
                    ),
                  ),
                ],
              ),
            ).animate()
                .scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.easeOutCubic)
                .fadeIn(),

            // 3. Floating Icon (The Hero)
            Positioned(
              top: -40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: PremiumTokens.surfaceMain,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: EmojiToIcon.getIconWidget(
                    achievement.icon,
                    size: 40,
                    color: PremiumTokens.saffronGlow,
                  ),
                ),
              ),
            ).animate()
                .scale(begin: const Offset(0.7, 0.7), delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
