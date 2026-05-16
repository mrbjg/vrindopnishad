import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/providers.dart';

final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);
final selectedSpiritualityLevelProvider = StateProvider<String>((ref) => 'seeker');
final selectedDailyGoalProvider = StateProvider<int>((ref) => 11);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController();
    final currentIndex = ref.watch(onboardingPageIndexProvider);

    final List<Widget> slides = [
      const OnboardingSlide(
        title: "Divine Wisdom",
        subtitle: "Connect with the timeless teachings of the Gita and ancient saints.",
        icon: Iconsax.book_1,
        quote: '"The soul is neither born, nor does it ever die."',
      ),
      const OnboardingSlide(
        title: "Immersive Stillness",
        subtitle: "Experience the profound peace of Naam Jap with a meditative audio voyage.",
        icon: Iconsax.music_play,
        quote: '"In stillness, the light within reveals itself."',
      ),
      const OnboardingSlide(
        title: "Soul Reflection",
        subtitle: "Document your spiritual evolution in your private celestial journal.",
        icon: Iconsax.edit_2,
        quote: '"Your journey is the destination."',
      ),
      const AssessmentSlide(),
    ];

    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Stack(
        children: [
          // Ambient master background (index 2 for Void feel)
          Positioned.fill(child: PremiumUI.masterBackground(index: 2, context: context)),
          
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) => ref.read(onboardingPageIndexProvider.notifier).state = index,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return slides[index];
            },
          ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (index) {
                    return AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index 
                            ? PremiumTokens.saffronGlow 
                            : PremiumTokens.glassBase.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 48),
                
                // CTA Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: currentIndex == slides.length - 1
                      ? PremiumUI.saffronButton(
                          text: "BEGIN THE JOURNEY",
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            final level = ref.read(selectedSpiritualityLevelProvider);
                            final goal = ref.read(selectedDailyGoalProvider);
                            ref.read(hasSeenOnboardingProvider.notifier).completeOnboardingWithAssessment(
                              level: level,
                              dailyGoal: goal,
                            );
                          },
                        ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9))
                      : PremiumUI.capsuleButton(
                          text: "NEXT",
                          onTap: () {
                            HapticFeedback.lightImpact();
                            pageController.nextPage(
                              duration: 500.ms,
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                ),
                
                if (currentIndex < slides.length - 1) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      pageController.animateToPage(
                        slides.length - 1,
                        duration: 800.ms,
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: Text(
                      "SKIP",
                      style: GoogleFonts.manrope(
                        color: PremiumTokens.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String quote;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PremiumUI.logoAnimated(height: 60),
          const SizedBox(height: 48),
          
          // Icon with Aura
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTokens.saffronGlow.withValues(alpha: 0.05),
              border: Border.all(color: PremiumTokens.saffronGlow.withValues(alpha: 0.1)),
            ),
            child: Icon(
              icon,
              size: 80,
              color: PremiumTokens.saffronGlow,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
          
          const SizedBox(height: 60),
          
          // Title
          Text(
            title.toUpperCase(),
            style: GoogleFonts.manrope(
              color: PremiumTokens.saffronGlow,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              color: PremiumTokens.textPrimary,
              fontSize: 24,
              height: 1.4,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 40),
          
          // Quote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: PremiumTokens.saffronGlow.withValues(alpha: 0.3), width: 2)),
            ),
            child: Text(
              quote,
              style: GoogleFonts.newsreader(
                color: PremiumTokens.textMuted,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class AssessmentSlide extends ConsumerWidget {
  const AssessmentSlide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedSpiritualityLevelProvider);
    final selectedGoal = ref.watch(selectedDailyGoalProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 120, 32, 160),
      child: Column(
        children: [
          // Header with extra spacing and glow
          Text(
            "TELL US ABOUT YOUR SPIRIT",
            textAlign: TextAlign.center,
            style: PremiumTokens.sansStyle(
              color: PremiumTokens.saffronGlow,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ).animate().fadeIn().shimmer(duration: 3.seconds, color: PremiumTokens.textHint),
          
          const SizedBox(height: 48),
          
          Text(
            "Experience level",
            style: PremiumTokens.soulStyle(
              color: PremiumTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 24),

          // Level Selection wrapping options in ethereal cards
          _LevelOption(
            title: "Just starting my journey",
            value: "seeker",
            selected: selectedLevel == "seeker",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "seeker",
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 12),
          
          _LevelOption(
            title: "I practice regularly",
            value: "sadhak",
            selected: selectedLevel == "sadhak",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "sadhak",
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
          
          const SizedBox(height: 12),
          
          _LevelOption(
            title: "I am dedicated to deep practice",
            value: "tapasvi",
            selected: selectedLevel == "tapasvi",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "tapasvi",
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 56),
          
          Text(
            "Daily Naam Jap Goal",
            style: PremiumTokens.soulStyle(
              color: PremiumTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),

          // Goal Selector with pulsing orbs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoalOption(
                label: "3",
                value: 3,
                selected: selectedGoal == 3,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 3,
              ),
              const SizedBox(width: 16),
              _GoalOption(
                label: "11",
                value: 11,
                selected: selectedGoal == 11,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 11,
              ),
              const SizedBox(width: 16),
              _GoalOption(
                label: "21",
                value: 21,
                selected: selectedGoal == 21,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 21,
              ),
              const SizedBox(width: 16),
              _GoalOption(
                label: "108",
                value: 108,
                selected: selectedGoal == 108,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 108,
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
          
          const SizedBox(height: 16),
          
          Text(
            "Malas per day",
            style: PremiumTokens.sansStyle(
              color: PremiumTokens.textPrimary30,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
}

class _LevelOption extends StatelessWidget {
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LevelOption({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumUI.etherealCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      glowColor: selected ? PremiumTokens.saffronGlow : null,
      showGlow: selected,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: 400.ms,
          curve: Curves.easeOutQuint,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: selected 
              ? PremiumTokens.saffronGlow.withValues(alpha: 0.15) 
              : Colors.transparent,
            border: Border.all(
              color: selected 
                ? PremiumTokens.saffronGlow.withValues(alpha: 0.5) 
                : PremiumTokens.borderSubtle,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: PremiumTokens.sansStyle(
                    color: selected ? PremiumTokens.textPrimary : PremiumTokens.textSecondary,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Iconsax.tick_circle, 
                  color: PremiumTokens.saffronGlow, 
                  size: 24
                ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedScale(
        scale: selected ? 1.1 : 1.0,
        duration: 250.ms,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutQuart,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selected 
              ? PremiumTokens.saffronPremiumGradient 
              : RadialGradient(
                  colors: [
                    PremiumTokens.borderSubtle,
                    PremiumTokens.borderSubtle,
                  ],
                ),
            border: Border.all(
              color: selected 
                ? PremiumTokens.textPrimary.withValues(alpha: 0.4) 
                : PremiumTokens.borderMedium,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? [
              BoxShadow(
                color: PremiumTokens.saffronGlow.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: PremiumTokens.sansStyle(
                color: selected ? PremiumTokens.charcoal : PremiumTokens.textPrimary,
                fontSize: selected ? 18 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    ).animate(
      autoPlay: true,
      onPlay: (c) => selected ? c.repeat(reverse: true) : c.stop(),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 2.seconds,
      curve: Curves.easeInOut,
    );
  }
}

