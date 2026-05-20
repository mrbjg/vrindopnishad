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

    final List<_SlideData> slides = [
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
                    Colors.transparent,
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
                        HapticFeedback.lightImpact();
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
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: PremiumTokens.activeAccent.withValues(alpha: 0.15),
        foregroundColor: PremiumTokens.activeAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Text(
        "NEXT",
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildJourneyButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        final level = ref.read(selectedSpiritualityLevelProvider);
        final goal = ref.read(selectedDailyGoalProvider);
        ref
            .read(hasSeenOnboardingProvider.notifier)
            .completeOnboardingWithAssessment(
              level: level,
              dailyGoal: goal,
            );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: PremiumTokens.activeAccent,
        foregroundColor: PremiumTokens.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: PremiumTokens.activeAccent.withValues(alpha: 0.4),
      ),
      child: Text(
        "BEGIN THE JOURNEY",
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
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

          // Icon with accent ring
          Container(
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
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
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
          _SectionLabel(text: "YOUR EXPERIENCE"),

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
          _SectionLabel(text: "DAILY NAAM JAP GOAL"),

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
                    HapticFeedback.selectionClick();
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
        HapticFeedback.selectionClick();
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
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
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
                  HapticFeedback.mediumImpact();
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? PremiumTokens.activeAccent.withValues(alpha: 0.1)
              : PremiumTokens.surfaceCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? PremiumTokens.activeAccent.withValues(alpha: 0.5)
                : PremiumTokens.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
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
                  Text(palette.emoji, style: const TextStyle(fontSize: 24)),
                  if (isSelected)
                    Icon(
                      Iconsax.tick_circle5,
                      color: PremiumTokens.activeAccent,
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
                      ? PremiumTokens.activeAccent
                      : PremiumTokens.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
