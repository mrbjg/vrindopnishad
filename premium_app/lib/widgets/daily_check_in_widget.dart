import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system.dart';
import '../core/stats_provider.dart';
import '../services/gamification_service.dart';

class DailyCheckInWidget extends ConsumerStatefulWidget {
  const DailyCheckInWidget({super.key});

  @override
  ConsumerState<DailyCheckInWidget> createState() => _DailyCheckInWidgetState();
}

class _DailyCheckInWidgetState extends ConsumerState<DailyCheckInWidget> {
  bool _isClaimed = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) return const SizedBox.shrink();
        
        // Simple heuristic: If last active date is today, consider it "checked in"
        // In a real app, we'd have a 'last_claim_date' column.
        final now = DateTime.now().toIso8601String().split('T')[0];
        final isAlreadyClaimed = stats.lastActiveDate?.toIso8601String().split('T')[0] == now;

        return PremiumUI.voidCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          accentColor: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: EmojiToIcon.getIconWidget('✨', size: 24, color: PremiumTokens.celestialSilver),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY BLESSING',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: PremiumTokens.celestialSilver,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAlreadyClaimed || _isClaimed 
                        ? 'Come back tomorrow!' 
                        : 'Claim your daily XP bonus',
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        color: PremiumTokens.celestialSilver.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IgnorePointer(
                ignoring: isAlreadyClaimed || _isClaimed,
                child: Opacity(
                  opacity: isAlreadyClaimed || _isClaimed ? 0.5 : 1.0,
                  child: PremiumUI.etherealButton(
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      setState(() => _isClaimed = true);
                      
                      await ref.read(gamificationServiceProvider).awardXP(
                        context,
                        100, // Daily bonus Base XP
                        'Daily Blessing',
                      );
                    },
                    child: Text(
                      isAlreadyClaimed || _isClaimed ? 'CLAIMED' : 'CLAIM',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: PremiumTokens.celestialSilver,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },

      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
