import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsWithStatusProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 4)),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: PremiumUI.glassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 14,
                          child: const Icon(Iconsax.arrow_left_2,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'CELESTIAL MILESTONES',
                        style: PremiumTokens.sansStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: PremiumTokens.celestialSilver,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Stats Summary
                achievementsAsync.when(
                  data: (achievements) {
                    final unlocked =
                        achievements.where((a) => a.isUnlocked).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PremiumUI.etherealCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        glowColor:
                            PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statColumn(
                                '🏆', '$unlocked', 'EARNED', PremiumTokens.celestialSilver),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white10),
                            _statColumn('🔒',
                                '${achievements.length - unlocked}', 'LOCKED', Colors.white38),
                            Container(
                                width: 1,
                                height: 40,
                                color: Colors.white10),
                            _statColumn(
                                '⚡',
                                '${achievements.where((a) => a.isUnlocked).fold<int>(0, (sum, a) => sum + a.xpBonus)}',
                                'XP BONUS',
                                PremiumTokens.nebulaBlue),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),

                // Achievements Grid
                Expanded(
                  child: achievementsAsync.when(
                    data: (achievements) => GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return _buildAchievementCard(
                            context, achievement, index);
                      },
                    ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: PremiumTokens.nebulaBlue)),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        EmojiToIcon.getIconWidget(emoji, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: PremiumTokens.sansStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: PremiumTokens.sansStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, Achievement achievement, int index) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(context, achievement);
      },
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUnlocked
                ? PremiumTokens.celestialSilver.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: PremiumTokens.etherealBlue.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmojiToIcon.getIconWidget(
                achievement.icon,
                size: 40,
                color: isUnlocked ? null : Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  fontSize: 16,
                  color: isUnlocked ? Colors.white : Colors.white24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: isUnlocked ? Colors.white54 : Colors.white12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? PremiumTokens.celestialSilver.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUnlocked
                      ? '✓ EARNED'
                      : '+${achievement.xpBonus} XP',
                  style: PremiumTokens.sansStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: isUnlocked
                        ? PremiumTokens.celestialSilver
                        : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          delay: (index * 100).ms,
          duration: 400.ms,
        );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PremiumTokens.voidIndigo.withValues(alpha: 0.98),
              PremiumTokens.voidBlack,
            ],
          ),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            EmojiToIcon.getIconWidget(achievement.icon, size: 64, color: PremiumTokens.celestialSilver),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: GoogleFonts.spectral(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.spectral(
                fontSize: 15,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            PremiumUI.voidCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              borderRadius: 100,
              accentColor: achievement.isUnlocked ? PremiumTokens.celestialSilver.withValues(alpha: 0.1) : Colors.transparent,
              child: Text(
                achievement.isUnlocked
                    ? '✓ EARNED +${achievement.xpBonus} XP'
                    : 'LOCKED +${achievement.xpBonus} XP WHEN UNLOCKED',
                style: PremiumTokens.sansStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: achievement.isUnlocked
                      ? PremiumTokens.celestialSilver
                      : Colors.white38,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
