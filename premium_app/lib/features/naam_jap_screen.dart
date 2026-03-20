import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/stats_provider.dart';

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen> {
  // Use Animate widget directly to avoid mixin conflicts and initialization errors

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(naamJapStateProvider);
    final isFocusMode = ref.watch(focusModeProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final streak = statsAsync.value?.streakCount ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ethereal Background
          Positioned.fill(child: PremiumUI.masterBackground(index: 2)),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isFocusMode),
                
                const Spacer(flex: 1),
                
                // Professional Counter Display
                _buildProfessionalCounter(count),
                
                const Spacer(flex: 1),
                
                // Interaction Area
                _buildInteractionArea(count, isFocusMode),
                
                const SizedBox(height: 40),
                
                // Session Stats
                _buildSessionStats(isFocusMode, streak),
                
                const SizedBox(height: 140), // Spacing for Navbar + MiniPlayer
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isFocusMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // If in bottom nav, switch to Home
                ref.read(navigationIndexProvider.notifier).state = 0;
              }
            },
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 14,
              child: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 20),
            ),
          ),
          Text(
            "NAAM JAP",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: PremiumTokens.nebulaBlue,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(focusModeProvider.notifier).state = !isFocusMode;
            },
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 14,
              child: Icon(
                isFocusMode ? Iconsax.eye_slash : Iconsax.eye,
                color: isFocusMode ? PremiumTokens.nebulaBlue : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCounter(int count) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Breathing Aura using Animate widget for safety
            Animate(
              onPlay: (c) => c.repeat(reverse: true),
              effects: [
                ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
              ],
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumTokens.nebulaBlue.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Glass Disk
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Center(
                child: Animate(
                  target: count > 0 ? 1 : 0,
                  effects: [
                    ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms),
                  ],
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.spectral(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.5), blurRadius: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          "TOTAL CHANTS",
          style: PremiumTokens.sansStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionArea(int count, bool isFocusMode) {
    return PremiumUI.focusContainer(
      isFocusMode: isFocusMode,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(naamJapStateProvider.notifier).increment();
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: PremiumTokens.nebulaGradient,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "ॐ",
                  style: GoogleFonts.spectral(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            "Tap to chant",
            style: PremiumTokens.sansStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats(bool isFocusMode, int streak) {
    return PremiumUI.focusContainer(
      isFocusMode: isFocusMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: PremiumUI.glassCard(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          borderRadius: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatItem("DAILY GOAL", "108", PremiumTokens.nebulaBlue)),
              Container(width: 1, height: 30, color: Colors.white10),
              Expanded(child: _buildStatItem("SESSIONS", "12", Colors.white70)),
              Container(width: 1, height: 30, color: Colors.white10),
              Expanded(child: _buildStatItem("STREAK", "${streak}d", PremiumTokens.saffronGlow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color accent) {
    return Column(
      children: [
        Text(
          label,
          style: PremiumTokens.sansStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PremiumTokens.sansStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent),
        ),
      ],
    );
  }
}
