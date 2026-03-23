import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_engine.dart';
import '../core/spirituality_provider.dart';
import '../core/stats_provider.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../widgets/xp_toast.dart';
import '../widgets/achievement_dialog.dart';
import '../core/auth_provider.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref);
});

class GamificationService {
  final Ref ref;

  GamificationService(this.ref);

  /// Award XP to user and show a floating toast
  Future<void> awardXP(BuildContext context, int amount, String reason) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // 1. Calculate Multiplier
    final multiplier = ref.read(xpMultiplierProvider);
    final finalAmount = (amount * multiplier).toInt();

    // 2. Update stats in Supabase
    final stats = ref.read(userStatsProvider).value;
    if (stats != null) {
      final newXp = stats.experiencePoints + finalAmount;
      final newLevel = (newXp / 1000).floor() + 1;

      await ref.read(statsServiceProvider).updateStats(user.uid, {
        'experience_points': newXp,
        'level': newLevel,
      });

      // Show toast
      XPToast.show(context, finalAmount, reason, multiplier: multiplier);

      // Check for Level Up
      if (newLevel > stats.level) {
        _showLevelUpDialog(context, newLevel);
      }

      // 3. Refresh stats
      ref.invalidate(userStatsProvider);
      
      // 4. Check achievements
      checkAchievements(context);
    }
  }

  /// Check for newly earned achievements
  Future<void> checkAchievements(BuildContext context) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final stats = ref.read(userStatsProvider).value;
    if (stats == null) return;

    final unlockedAsync = await ref.read(userAchievementsProvider.future);
    final unlockedIds = unlockedAsync.map((e) => e.achievementId).toSet();

    final newAchievements = SpiritualityEngine.checkNewAchievements(
      stats: stats,
      alreadyUnlocked: unlockedIds,
    );

    for (final achievement in newAchievements) {
      // Unlock in DB
      await ref.read(spiritualContentServiceProvider).unlockAchievement(user.uid, achievement.id);
      
      // Show Dialog
      if (context.mounted) {
        AchievementUnlockDialog.show(context, achievement);
        
        // Award Bonus XP for achievement
        awardXP(context, achievement.xpBonus, 'Achievement: ${achievement.title}');
      }
    }
    
    if (newAchievements.isNotEmpty) {
      ref.invalidate(userAchievementsProvider);
      ref.invalidate(achievementsWithStatusProvider);
    }
  }

  void _showLevelUpDialog(BuildContext context, int newLevel) {
    if (!context.mounted) return;
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => PremiumUI.etherealCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'LEVEL UP!',
              style: PremiumTokens.sansStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: PremiumTokens.saffronGlow,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have reached Level $newLevel',
              style: PremiumTokens.sansStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            PremiumUI.saffronButton(
              text: 'CONTINUE SADHANA',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}
