import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/mood_theme_provider.dart';
import '../core/color_theme_provider.dart';

final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);
final selectedSpiritualityLevelProvider = StateProvider<String>((ref) => 'seeker');
final selectedDailyGoalProvider = StateProvider<int>((ref) => 11);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingPageIndexProvider);

    const List<_SlideData> slides = [
      _SlideData(
        icon: Iconsax.book_1,
        title: "Divine Wisdom",
        subtitle: "Connect with the timeless teachings\nof the Gita and ancient saints.",
        quote: "The soul is neither born, nor does it ever die.",
      ),
      _SlideData(
        icon: Iconsax.music_play,
        title: "Immersive Stillness",
        subtitle: "Experience the profound peace of\nNaam Jap with a meditative audio voyage.",
        quote: "In stillness, the light within reveals itself.",
      ),
      _SlideData(
        icon: Iconsax.edit_2,
        title: "Soul Reflection",
        subtitle: "Document your spiritual evolution\nin your private celestial journal.",
        quote: "Your journey is the destination.",
      ),
    ];

    // Total pages = slides + mood picker + assessment
    final totalPages = slides.length + 2;
    final isLastPage = currentIndex == totalPages - 1;

    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Stack(
        children: [
          // Mood-aware ambient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: PremiumTokens.moodBackgroundGradient,
              ),
            ),
          ),

          // Subtle mandala overlay
          Positioned.fill(child: PremiumUI.mandalaOverlay(opacity: 0.03)),

          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) =>
                ref.read(onboardingPageIndexProvider.notifier).state = index,
            itemCount: totalPages,
            itemBuilder: (context, index) {
              if (index < slides.length) {
                return _OnboardingSlide(data: slides[index]);
              }
              if (index == slides.length) {
                return const _MoodPickerSlide();
              }
              return const _AssessmentSlide();
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PremiumTokens.scaffoldBg.withValues(alpha: 0),
                    PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
                    PremiumTokens.scaffoldBg,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (i) {
                      final isActive = i == currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? PremiumTokens.activeAccent
                              : PremiumTokens.textPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Main CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: isLastPage
                        ? _buildJourneyButton(ref)
                        : _buildNextButton(),
                  ),

                  // Skip option
                  if (!isLastPage) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        AppHapticFeedback.lightImpact();
                        _pageController.animateToPage(
                          totalPages - 1,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Text(
                        "SKIP",
                        style: GoogleFonts.manrope(
                          color: PremiumTokens.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return PremiumUI.accentButton(
      onTap: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      borderRadius: 16,
      child: Center(
        child: Text(
          "NEXT",
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: PremiumTokens.onAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyButton(WidgetRef ref) {
    return PremiumUI.accentButton(
      onTap: () {
        final level = ref.read(selectedSpiritualityLevelProvider);
        final goal = ref.read(selectedDailyGoalProvider);
        ref
            .read(hasSeenOnboardingProvider.notifier)
            .completeOnboardingWithAssessment(
              level: level,
              dailyGoal: goal,
            );
      },
      borderRadius: 16,
      child: Center(
        child: Text(
          "BEGIN THE JOURNEY",
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: PremiumTokens.onAccent,
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE DATA
// ─────────────────────────────────────────────────────────────────────────────

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String quote;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.quote,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING SLIDE — Clean, no overlaps, proper spacing
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  final _SlideData data;

  const _OnboardingSlide({required this.data});

  Widget _buildSlideGraphic() {
    if (data.title == "Divine Wisdom") {
      return const _DivineWisdomGraphic();
    } else if (data.title == "Immersive Stillness") {
      return const _ImmersiveStillnessGraphic();
    } else if (data.title == "Soul Reflection") {
      return const _SoulReflectionGraphic();
    }
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
        border: Border.all(
          color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          data.icon,
          size: 48,
          color: PremiumTokens.activeAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          // Top spacing
          SizedBox(height: screenHeight * 0.1),

          // Logo — small, top-placed, clear on dark bg
          PremiumUI.logo(height: 40, color: PremiumTokens.activeAccent)
              .animate()
              .fadeIn(duration: 600.ms),

          SizedBox(height: screenHeight * 0.06),

          // Custom animated graphic for each slide
          _buildSlideGraphic()
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              ),

          SizedBox(height: screenHeight * 0.05),

          // Title label
          Text(
            data.title.toUpperCase(),
            style: GoogleFonts.manrope(
              color: PremiumTokens.activeAccent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              color: PremiumTokens.textPrimary,
              fontSize: 22,
              height: 1.45,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

          const SizedBox(height: 32),

          // Quote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              '"${data.quote}"',
              style: GoogleFonts.newsreader(
                color: PremiumTokens.textMuted,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),

          // Remaining space for bottom controls
          const Spacer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM SLIDE GRAPHICS
// ─────────────────────────────────────────────────────────────────────────────

class _DivineWisdomGraphic extends StatelessWidget {
  const _DivineWisdomGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient soft glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTokens.activeAccent.withValues(alpha: 0.12),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2500.ms, curve: Curves.easeInOut),

          // Outer accent spinning ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: false))
           .rotate(begin: 0, end: 1, duration: 15000.ms),

          // The Floating Scripture Card
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: PremiumTokens.surfaceCard.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.book_1,
                  size: 28,
                  color: PremiumTokens.activeAccent,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .slideY(begin: -0.05, end: 0.05, duration: 2000.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class _ImmersiveStillnessGraphic extends StatelessWidget {
  const _ImmersiveStillnessGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse wave 2
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.06),
                width: 2,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 3000.ms, curve: Curves.easeOut)
           .fadeOut(duration: 3000.ms),

          // Outer pulse wave 1
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2000.ms, curve: Curves.easeOut)
           .fadeOut(duration: 2000.ms),

          // Central Breathing Orb
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
              border: Border.all(
                color: PremiumTokens.activeAccent.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Iconsax.music_play,
                size: 24,
                color: PremiumTokens.activeAccent,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 2500.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class _SoulReflectionGraphic extends StatelessWidget {
  const _SoulReflectionGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
            ),
          ),

          // Stylized Journal page
          Container(
            width: 80,
            height: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumTokens.surfaceCard.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumTokens.borderSubtle,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (i) {
                  final widths = [40.0, 50.0, 45.0, 30.0];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      width: widths[i],
                      height: 2,
                      decoration: BoxDecoration(
                        color: PremiumTokens.textMuted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .slideY(begin: -0.04, end: 0.04, duration: 3000.ms, curve: Curves.easeInOut),

          // Floating Quill/Pen Icon
          Positioned(
            top: 25,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.activeAccent,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.edit_2,
                size: 16,
                color: PremiumTokens.onAccent,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .slideY(begin: -0.1, end: 0.1, duration: 1800.ms, curve: Curves.easeInOut)
           .slideX(begin: -0.05, end: 0.05, duration: 1800.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSESSMENT SLIDE — Clean, simple, welcoming
// ─────────────────────────────────────────────────────────────────────────────

class _AssessmentSlide extends ConsumerWidget {
  const _AssessmentSlide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedSpiritualityLevelProvider);
    final selectedGoal = ref.watch(selectedDailyGoalProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(32, screenHeight * 0.08, 32, 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          PremiumUI.logo(height: 36, color: PremiumTokens.activeAccent)
              .animate()
              .fadeIn(duration: 500.ms),

          const SizedBox(height: 32),

          // Welcoming header
          Text(
            "Welcome, Seeker",
            style: GoogleFonts.newsreader(
              color: PremiumTokens.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            "Let us personalize your journey",
            style: GoogleFonts.manrope(
              color: PremiumTokens.textMuted,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),

          // SECTION 1: Experience Level
          const _SectionLabel(text: "YOUR EXPERIENCE"),

          const SizedBox(height: 16),

          _LevelOption(
            title: "Just starting my journey",
            subtitle: "New to spiritual practice",
            icon: Iconsax.sun_1,
            value: "seeker",
            selected: selectedLevel == "seeker",
            onTap: () => ref
                .read(selectedSpiritualityLevelProvider.notifier)
                .state = "seeker",
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 10),

          _LevelOption(
            title: "I practice regularly",
            subtitle: "Consistent daily sadhana",
            icon: Iconsax.flash_1,
            value: "sadhak",
            selected: selectedLevel == "sadhak",
            onTap: () => ref
                .read(selectedSpiritualityLevelProvider.notifier)
                .state = "sadhak",
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 10),

          _LevelOption(
            title: "Dedicated to deep practice",
            subtitle: "Advanced practitioner",
            icon: Iconsax.crown,
            value: "tapasvi",
            selected: selectedLevel == "tapasvi",
            onTap: () => ref
                .read(selectedSpiritualityLevelProvider.notifier)
                .state = "tapasvi",
          ).animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 40),

          // SECTION 2: Daily Goal
          const _SectionLabel(text: "DAILY NAAM JAP GOAL"),

          const SizedBox(height: 20),

          // Goal chips in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [3, 11, 21, 108].map((goal) {
              final isSelected = selectedGoal == goal;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _GoalChip(
                  label: goal.toString(),
                  selected: isSelected,
                  onTap: () {
                    AppHapticFeedback.selectionClick();
                    ref.read(selectedDailyGoalProvider.notifier).state = goal;
                  },
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 550.ms),

          const SizedBox(height: 12),

          Text(
            "Malas per day",
            style: GoogleFonts.manrope(
              color: PremiumTokens.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ).animate().fadeIn(delay: 650.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: PremiumTokens.activeAccent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

class _LevelOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LevelOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? PremiumTokens.activeAccent.withValues(alpha: 0.1)
              : PremiumTokens.surfaceCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? PremiumTokens.activeAccent.withValues(alpha: 0.4)
                : PremiumTokens.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                    : PremiumTokens.borderSubtle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? PremiumTokens.activeAccent
                      : PremiumTokens.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: selected
                          ? PremiumTokens.textPrimary
                          : PremiumTokens.textSecondary,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: PremiumTokens.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Check
            if (selected)
              Icon(
                Iconsax.tick_circle5,
                color: PremiumTokens.activeAccent,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? PremiumTokens.activeAccent
              : PremiumTokens.surfaceCard.withValues(alpha: 0.5),
          border: Border.all(
            color: selected
                ? PremiumTokens.activeAccent
                : PremiumTokens.borderSubtle,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: selected
                  ? PremiumTokens.onAccent
                  : PremiumTokens.textSecondary,
              fontSize: selected ? 17 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOOD PICKER SLIDE — "Choose Your Vibe" (4th page before Assessment)
// ─────────────────────────────────────────────────────────────────────────────

class _MoodPickerSlide extends ConsumerWidget {
  const _MoodPickerSlide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodThemeProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, screenHeight * 0.06, 24, 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          PremiumUI.logo(height: 36, color: PremiumTokens.activeAccent)
              .animate()
              .fadeIn(duration: 500.ms),

          const SizedBox(height: 24),

          // Header
          Text(
            "Choose Your Vibe",
            style: GoogleFonts.newsreader(
              color: PremiumTokens.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            "Set the mood for your spiritual space",
            style: GoogleFonts.manrope(
              color: PremiumTokens.textMuted,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 28),

          // Mood Grid — 2 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: AppMoodTheme.values.length,
            itemBuilder: (context, index) {
              final mood = AppMoodTheme.values[index];
              final palette = AppMoodThemes.getPalette(mood);
              final isSelected = mood == currentMood;

              return _MoodCard(
                palette: palette,
                isSelected: isSelected,
                onTap: () {
                  AppHapticFeedback.mediumImpact();
                  ref.read(moodThemeProvider.notifier).setMood(mood);
                  // Also set the default accent for this mood
                  ref.read(colorThemeProvider.notifier).setTheme(palette.defaultAccent);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final AppMoodPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeAccentColor = AppColorThemes.getPalette(palette.defaultAccent).accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: palette.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? themeAccentColor
                : palette.borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeAccentColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji + check
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EmojiToIcon.getIconWidget(
                    palette.emoji,
                    size: 24,
                    color: isSelected ? themeAccentColor : palette.textMuted,
                  ),
                  if (isSelected)
                    Icon(
                      Iconsax.tick_circle5,
                      color: themeAccentColor,
                      size: 18,
                    ),
                ],
              ),
              const Spacer(),

              // Name
              Text(
                palette.name,
                style: GoogleFonts.manrope(
                  color: isSelected
                      ? themeAccentColor
                      : palette.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),

              // Gradient preview bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: palette.backgroundGradient.map((color) {
                      return Expanded(
                        child: Container(color: color),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
