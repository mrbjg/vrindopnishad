import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/spirituality_engine.dart';
import '../core/spirituality_provider.dart';
import '../core/stats_provider.dart';
import '../widgets/xp_toast.dart';
import '../widgets/achievement_dialog.dart';
import '../core/auth_provider.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref);
});

class GamificationService {
  final Ref ref;
  final List<VoidCallback> _dialogQueue = [];
  bool _isShowingDialog = false;

  GamificationService(this.ref);

  /// Award XP and handle progression
  Future<void> awardXP(
    BuildContext context, 
    int amount, 
    String reason, {
    bool triggerCheck = true,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final multiplier = ref.read(xpMultiplierProvider);
    final finalAmount = (amount * multiplier).toInt();

    final stats = ref.read(userStatsProvider).value;
    if (stats != null) {
      final newXp = stats.experiencePoints + finalAmount;
      final newLevel = (newXp / 1000).floor() + 1;

      await ref.read(statsServiceProvider).updateStats(user.uid, {
        'experience_points': newXp,
        'level': newLevel,
      });

      if (!context.mounted) return;
      XPToast.show(context, finalAmount, reason, multiplier: multiplier);

      if (newLevel > stats.level) {
        _queueDialog(() => _showLevelUpDialog(context, newLevel));
      }

      ref.invalidate(userStatsProvider);
      
      if (triggerCheck) {
        checkAchievements(context);
      }
    }
  }

  /// Sequence dialogs to prevent overlap (YouTube Style)
  void _queueDialog(VoidCallback dialogTrigger) {
    _dialogQueue.add(dialogTrigger);
    _processQueue();
  }

  void _processQueue() {
    if (_isShowingDialog || _dialogQueue.isEmpty) return;
    
    _isShowingDialog = true;
    final trigger = _dialogQueue.removeAt(0);
    trigger();
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
      try {
        await ref.read(spiritualContentServiceProvider).unlockAchievement(user.uid, achievement.id);
        
        if (context.mounted) {
          _queueDialog(() => AchievementUnlockDialog.show(context, achievement, onDismiss: () {
            _isShowingDialog = false;
            _processQueue();
          }));
          
          if (context.mounted) {
            awardXP(
              context, 
              achievement.xpBonus, 
              'Achievement: ${achievement.title}',
              triggerCheck: false,
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to unlock achievement ${achievement.id}: $e');
        // Still show the dialog once, but don't re-trigger XP to avoid loops
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
      barrierDismissible: false,
      builder: (context) => RepaintBoundary(
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: PremiumUI.etherealCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 32,
            glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
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
                  onTap: () {
                    Navigator.pop(context);
                    _isShowingDialog = false;
                    _processQueue();
                  },
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
        ),
      ),
    );
  }
}

