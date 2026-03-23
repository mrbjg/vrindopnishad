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
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          // Ambient bokeh background
          Positioned.fill(child: PremiumUI.bokehBackground()),
          
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
                            : Colors.white.withValues(alpha: 0.2),
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
                        color: Colors.white38,
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
              color: Colors.white,
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
                color: Colors.white38,
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
      padding: const EdgeInsets.fromLTRB(40, 100, 40, 150),
      child: Column(
        children: [
          Text(
            "TELL US ABOUT YOUR SPIRIT",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: PremiumTokens.saffronGlow,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          Text(
            "Experience level",
            style: GoogleFonts.newsreader(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // Level Selection
          _LevelOption(
            title: "Just starting my journey",
            value: "seeker",
            selected: selectedLevel == "seeker",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "seeker",
          ),
          const SizedBox(height: 8),
          _LevelOption(
            title: "I practice regularly",
            value: "sadhak",
            selected: selectedLevel == "sadhak",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "sadhak",
          ),
          const SizedBox(height: 8),
          _LevelOption(
            title: "I am dedicated to deep practice",
            value: "tapasvi",
            selected: selectedLevel == "tapasvi",
            onTap: () => ref.read(selectedSpiritualityLevelProvider.notifier).state = "tapasvi",
          ),

          const SizedBox(height: 40),
          Text(
            "Daily Naam Jap Goal",
            style: GoogleFonts.newsreader(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),

          // Goal Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoalOption(
                label: "3",
                value: 3,
                selected: selectedGoal == 3,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 3,
              ),
              const SizedBox(width: 12),
              _GoalOption(
                label: "11",
                value: 11,
                selected: selectedGoal == 11,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 11,
              ),
              const SizedBox(width: 12),
              _GoalOption(
                label: "21",
                value: 21,
                selected: selectedGoal == 21,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 21,
              ),
              const SizedBox(width: 12),
              _GoalOption(
                label: "108",
                value: 108,
                selected: selectedGoal == 108,
                onTap: () => ref.read(selectedDailyGoalProvider.notifier).state = 108,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            "Malas per day",
            style: GoogleFonts.manrope(
              color: Colors.white24,
              fontSize: 12,
            ),
          ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 300.ms,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? PremiumTokens.saffronGlow.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? PremiumTokens.saffronGlow : Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Iconsax.tick_circle, color: PremiumTokens.saffronGlow, size: 20),
          ],
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
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 300.ms,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: selected ? PremiumTokens.saffronGlow : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? PremiumTokens.saffronGlow : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: selected ? PremiumTokens.charcoal : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
