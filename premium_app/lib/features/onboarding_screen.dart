import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/providers.dart';

final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController();
    final currentIndex = ref.watch(onboardingPageIndexProvider);

    final List<OnboardingData> slides = [
      OnboardingData(
        title: "Divine Wisdom",
        subtitle: "Connect with the timeless teachings of the Gita and ancient saints.",
        icon: Iconsax.book_1,
        quote: '"The soul is neither born, nor does it ever die."',
      ),
      OnboardingData(
        title: "Immersive Stillness",
        subtitle: "Experience the profound peace of Naam Jap with a meditative audio voyage.",
        icon: Iconsax.music_play,
        quote: '"In stillness, the light within reveals itself."',
      ),
      OnboardingData(
        title: "Soul Reflection",
        subtitle: "Document your spiritual evolution in your private celestial journal.",
        icon: Iconsax.edit_2,
        quote: '"Your journey is the destination."',
      ),
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
              return OnboardingSlide(data: slides[index]);
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
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 48),
                
                // CTA Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: currentIndex == slides.length - 1
                      ? PremiumUI.saffronButton(
                          text: "BEGIN THE JOURNEY",
                          onTap: () {
                            ref.read(hasSeenOnboardingProvider.notifier).completeOnboarding();
                          },
                        ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9))
                      : PremiumUI.capsuleButton(
                          text: "NEXT",
                          onTap: () {
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
                      ref.read(hasSeenOnboardingProvider.notifier).completeOnboarding();
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
  final OnboardingData data;

  const OnboardingSlide({super.key, required this.data});

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
              color: PremiumTokens.saffronGlow.withOpacity(0.05),
              border: Border.all(color: PremiumTokens.saffronGlow.withOpacity(0.1)),
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: PremiumTokens.saffronGlow,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(begin: Offset(0.5, 0.5)),
          
          const SizedBox(height: 60),
          
          // Title
          Text(
            data.title.toUpperCase(),
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
            data.subtitle,
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
              border: Border(left: BorderSide(color: PremiumTokens.saffronGlow.withOpacity(0.3), width: 2)),
            ),
            child: Text(
              data.quote,
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

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String quote;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.quote,
  });
}
