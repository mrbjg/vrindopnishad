import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../core/spirituality_engine.dart';
import '../models/daily_challenge.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(dailyChallengesProvider);
    final xpMultiplier = ref.watch(xpMultiplierProvider);
    final levelTier = ref.watch(spiritualityLevelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 2)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header
                  Row(
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
                        "TODAY'S CHALLENGES",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: PremiumTokens.saffronGlow,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // XP Multiplier Banner
                  if (xpMultiplier > 1.0)
                    PremiumUI.etherealCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      borderRadius: 16,
                      glowColor:
                          PremiumTokens.saffronGlow.withValues(alpha: 0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmojiToIcon.getIconWidget('🔥', size: 20, color: PremiumTokens.saffronGlow),
                          const SizedBox(width: 12),
                          Text(
                            'STREAK BONUS: ${xpMultiplier}x XP',
                            style: PremiumTokens.sansStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: PremiumTokens.saffronGlow,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(duration: 600.ms)
                        .shimmer(delay: 1.seconds, duration: 2.seconds),

                  const SizedBox(height: 24),

                  // Level Info
                  PremiumUI.glassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: PremiumTokens.nebulaGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: EmojiToIcon.getIconWidget(
                            _tierEmoji(levelTier),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                SpiritualityEngine.levelTitle(levelTier),
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Challenges matched to your level',
                                style: GoogleFonts.manrope(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  Text(
                    'DAILY MISSIONS',
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white38,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Challenge Cards
                  challengesAsync.when(
                    data: (challenges) {
                      if (challenges.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        children: challenges
                            .asMap()
                            .entries
                            .map((entry) =>
                                _buildChallengeCard(entry.value, entry.key))
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: PremiumTokens.nebulaBlue),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white54)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Motivation at bottom
                  Center(
                    child: Text(
                      'Complete challenges daily to level up faster! 🚀',
                      style: PremiumTokens.sansStyle(
                        fontSize: 12,
                        color: Colors.white24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, int index) {
    final progressColor = challenge.isCompleted
        ? Colors.greenAccent
        : PremiumTokens.nebulaBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        glowColor: challenge.isCompleted
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmojiToIcon.getIconWidget(challenge.typeIcon, size: 24, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (challenge.description != null)
                        Text(
                          challenge.description!,
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                // XP Reward
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    challenge.isCompleted
                        ? '✓ DONE'
                        : '+${challenge.xpReward} XP',
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${challenge.currentValue}/${challenge.targetValue}',
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      '${(challenge.progressPercent * 100).toInt()}%',
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercent,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: (index * 150).ms, duration: 500.ms)
        .slideX(begin: 0.05, delay: (index * 150).ms);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Iconsax.task_square,
                color: Colors.white10, size: 64),
            const SizedBox(height: 16),
            Text(
              'No challenges available yet',
              style: PremiumTokens.sansStyle(
                color: Colors.white24,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back tomorrow for new missions!',
              style: PremiumTokens.sansStyle(
                color: Colors.white12,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tierEmoji(SpiritualityLevel level) {
    switch (level) {
      case SpiritualityLevel.seeker:
        return '🌱';
      case SpiritualityLevel.sadhak:
        return '📿';
      case SpiritualityLevel.tapasvi:
        return '⭐';
      case SpiritualityLevel.siddha:
        return '🏔️';
    }
  }
}
