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

  /// Award XP and handle progression (DISABLED)
  Future<void> awardXP(
    BuildContext context, 
    int amount, 
    String reason, {
    bool triggerCheck = true,
  }) async {
    // Gamification system removed for now.
    return;
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

  /// Check for newly earned achievements (DISABLED)
  Future<void> checkAchievements(BuildContext context) async {
    // Gamification system removed for now.
    return;
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

