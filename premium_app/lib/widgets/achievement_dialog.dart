import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../models/achievement.dart';

class AchievementUnlockDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementUnlockDialog({super.key, required this.achievement});

  static void show(BuildContext context, Achievement achievement) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(achievement: achievement),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
            ),
          ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

          // Main Card
          PremiumUI.etherealCard(
            padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
            borderRadius: 32,
            glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEW ACHIEVEMENT',
                  style: PremiumTokens.sansStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: PremiumTokens.saffronGlow,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  achievement.title,
                  style: GoogleFonts.spectral(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spectral(
                    fontSize: 16,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    'BONUS +${achievement.xpBonus} XP',
                    style: PremiumTokens.sansStyle(
                      fontSize: 12,
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
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(),

          // Floating Icon
          Positioned(
            top: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: PremiumTokens.voidIndigo,
                shape: BoxShape.circle,
                border: Border.all(
                  color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
          ).animate()
              .scale(begin: const Offset(0.5, 0.5), delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
              .shake(delay: 800.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
