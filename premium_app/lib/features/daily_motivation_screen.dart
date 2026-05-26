import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../core/spirituality_engine.dart';
import '../core/color_theme_provider.dart';

class DailyMotivationScreen extends ConsumerWidget {
  const DailyMotivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(colorPaletteProvider);
    final motivationAsync = ref.watch(dailyMotivationProvider);
    final contextMotivation = ref.watch(contextualMotivationProvider);
    final levelTier = ref.watch(spiritualityLevelProvider);

    // Sync system status and navigation bar overlay style
    PremiumUI.setSacredStatus();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 0, context: context)),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              MediaQuery.of(context).padding.bottom + 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: PremiumUI.glassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 14,
                          child: Icon(Iconsax.arrow_left_2,
                              color: PremiumTokens.textPrimary, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'DAILY MOTIVATION',
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: PremiumTokens.saffronGlow,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Level Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: PremiumTokens.activeGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        SpiritualityEngine.levelTitle(levelTier),
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PremiumTokens.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 32),

                  // Contextual Motivation (adaptive)
                  PremiumUI.etherealCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 28,
                    glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                    child: Column(
                      children: [
                        const Icon(Iconsax.sun_15,
                            color: PremiumTokens.saffronGlow, size: 40),
                        const SizedBox(height: 20),
                        Text(
                          contextMotivation,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spectral(
                            fontSize: 20,
                            color: PremiumTokens.textPrimary,
                            fontWeight: FontWeight.w300,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Sacred Quote from Database
                  motivationAsync.when(
                    data: (motivation) {
                      if (motivation == null) return const SizedBox.shrink();
                      return PremiumUI.etherealCard(
                        padding: const EdgeInsets.all(28),
                        borderRadius: 28,
                        child: Column(
                          children: [
                            Icon(Iconsax.quote_up5,
                                color: PremiumTokens.activeAccent, size: 32),
                            const SizedBox(height: 20),
                            Text(
                              motivation.content,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spectral(
                                fontSize: 18,
                                color: PremiumTokens.textPrimary,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            if (motivation.source != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                '— ${motivation.source}',
                                style: PremiumTokens.sansStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: PremiumTokens.activeAccent,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: 0.1);
                    },
                    loading: () => Center(
                        child: CircularProgressIndicator(
                            color: PremiumTokens.activeAccent)),
                    error: (e, _) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Level Description
                  PremiumUI.glassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR SPIRITUAL PATH',
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: PremiumTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          SpiritualityEngine.levelDescription(levelTier),
                          style: GoogleFonts.spectral(
                            fontSize: 15,
                            color: PremiumTokens.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Share Button
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        // awardXP removed
                        if (context.mounted) {
                          PremiumUI.showNotification(
                            context,
                            'Sharing sacred wisdom...',
                            icon: Iconsax.share,
                            color: PremiumTokens.activeAccent,
                          );
                        }
                      },
                      child: PremiumUI.glassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        borderRadius: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.share,
                                color: PremiumTokens.activeAccent, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              'SHARE WISDOM',
                              style: PremiumTokens.sansStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: PremiumTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
