import 'package:premium_app/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../core/spirituality_engine.dart';
import '../core/color_theme_provider.dart';
import '../core/ambient_audio_provider.dart';
import '../core/journal_provider.dart';
import '../models/daily_motivation.dart';

class DailyMotivationScreen extends ConsumerStatefulWidget {
  const DailyMotivationScreen({super.key});

  @override
  ConsumerState<DailyMotivationScreen> createState() => _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends ConsumerState<DailyMotivationScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _reflectionController = TextEditingController();
  bool _isSavingReflection = false;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    // Sync system status and navigation bar overlay style
    PremiumUI.setSacredStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _openSoundscapeSelector(BuildContext context, AppColorPalette colorPalette) {
    final audioNotifier = ref.read(ambientAudioProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeState = ref.watch(ambientAudioProvider);

            return PremiumUI.glassCard(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              borderRadius: 32,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MEDITATION AMBIENT',
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: colorPalette.accent,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Iconsax.close_circle,
                            color: PremiumTokens.textMuted, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select a sacred loop to play in the background during your daily contemplation.',
                    style: GoogleFonts.spectral(
                      fontSize: 14,
                      color: PremiumTokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List of soundscapes
                  Column(
                    children: AmbientAudioNotifier.soundscapes.map((scape) {
                      final isSelected = activeState.currentSoundscape?.id == scape.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () async {
                            AppHapticFeedback.selectionClick();
                            await audioNotifier.selectSoundscape(scape);
                            setModalState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorPalette.accent.withValues(alpha: 0.08)
                                  : PremiumTokens.surfaceMain.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? colorPalette.accent.withValues(alpha: 0.4)
                                    : colorPalette.accent.withValues(alpha: 0.08),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  scape.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    scape.name,
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: PremiumTokens.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected && activeState.isPlaying)
                                  Icon(Iconsax.music_play5,
                                      color: colorPalette.accent, size: 18)
                                else if (isSelected && activeState.isLoading)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorPalette.accent,
                                    ),
                                  )
                                else if (isSelected)
                                  Icon(Iconsax.music_play,
                                      color: colorPalette.accent, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Volume Slider
                  Row(
                    children: [
                      Icon(Iconsax.volume_low, color: PremiumTokens.textMuted, size: 18),
                      Expanded(
                        child: Slider(
                          value: activeState.volume,
                          activeColor: colorPalette.accent,
                          inactiveColor: colorPalette.accent.withValues(alpha: 0.15),
                          onChanged: (val) {
                            audioNotifier.setVolume(val);
                            setModalState(() {});
                          },
                        ),
                      ),
                      Icon(Iconsax.volume_high, color: PremiumTokens.textMuted, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  Future<void> _saveReflection() async {
    final text = _reflectionController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSavingReflection = true;
    });

    try {
      AppHapticFeedback.mediumImpact();
      await ref.read(journalProvider.notifier).addEntry(
            'Contemplation: Daily Motivation',
            text,
            moonPhase: 'reflection',
          );

      if (mounted) {
        _reflectionController.clear();
        PremiumUI.showNotification(
          context,
          'Contemplation saved to your journal!',
          icon: Iconsax.edit_2,
          color: ref.read(colorPaletteProvider).accent,
        );
      }
    } catch (e) {
      if (mounted) {
        PremiumUI.showNotification(
          context,
          'Error saving contemplation: $e',
          icon: Iconsax.info_circle,
          color: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingReflection = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = ref.watch(colorPaletteProvider);
    final motivationAsync = ref.watch(dailyMotivationProvider);
    final contextMotivation = ref.watch(contextualMotivationProvider);
    final levelTier = ref.watch(spiritualityLevelProvider);
    final audioState = ref.watch(ambientAudioProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ambient Immersive Background
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 0, context: context),
          ),

          // Glowing Floating Orbs (Sensory Visual Depth)
          const Positioned.fill(
            child: _DriftingAuricOrbs(),
          ),

          // Scrollable Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Premium Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: PremiumUI.glassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 14,
                          child: Icon(
                            Iconsax.arrow_left_2,
                            color: PremiumTokens.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'DAILY CONTEMPLATION',
                        style: PremiumTokens.sansStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: colorPalette.accent,
                        ),
                      ),
                      const Spacer(),
                      // Meditative Audio Pill (Top Right)
                      GestureDetector(
                        onTap: () => _openSoundscapeSelector(context, colorPalette),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: audioState.isPlaying
                                ? Border.all(
                                    color: colorPalette.accent.withValues(alpha: 0.5),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: PremiumUI.glassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            borderRadius: 100,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (audioState.isPlaying)
                                  _SoundwaveAnimation(color: colorPalette.accent)
                                else
                                  Icon(Iconsax.music,
                                      color: PremiumTokens.textSecondary, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  audioState.isPlaying
                                      ? (audioState.currentSoundscape?.name ?? 'Meditating')
                                      : 'AMBIENT',
                                  style: PremiumTokens.sansStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: audioState.isPlaying
                                        ? colorPalette.accentLight
                                        : PremiumTokens.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      MediaQuery.of(context).padding.bottom + 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mindfulness Guided Breathing Guide
                        const _MindfulBreathingBubble(),

                        const SizedBox(height: 28),

                        // Carousel Segment (PageView Cards)
                        SizedBox(
                          height: 280,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (idx) {
                              setState(() {
                                _currentCardIndex = idx;
                              });
                            },
                            children: [
                              // Slide 1: Today's Contextual Insight
                              _buildInsightCard(contextMotivation),
                              // Slide 2: Sacred Scripture Quote
                              _buildQuoteCard(motivationAsync, colorPalette),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Dots Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (idx) {
                            final isActive = _currentCardIndex == idx;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: isActive ? 18 : 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? colorPalette.accent
                                    : PremiumTokens.textMuted.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 28),

                        // Direct Reflections Journaling Input
                        Text(
                          'CAPTURE YOUR REFLECTIONS',
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: PremiumTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PremiumUI.glassCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _reflectionController,
                                maxLines: 3,
                                minLines: 2,
                                style: GoogleFonts.spectral(
                                  fontSize: 15,
                                  color: PremiumTokens.textPrimary,
                                  height: 1.4,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'How does this sacred wisdom relate to your path today? Jot down your notes...',
                                  hintStyle: GoogleFonts.spectral(
                                    color: PremiumTokens.textMuted,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: _isSavingReflection ? null : _saveReflection,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isSavingReflection
                                            ? PremiumTokens.textMuted.withValues(alpha: 0.2)
                                            : colorPalette.accent,
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: _isSavingReflection
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: colorPalette.accent.withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                )
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isSavingReflection)
                                            const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          else
                                            const Icon(Iconsax.edit_2,
                                                color: Colors.white, size: 13),
                                          const SizedBox(width: 8),
                                          Text(
                                            'SAVE JOURNAL',
                                            style: PremiumTokens.sansStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Action Buttons: Share & Level Profile Info
                        Row(
                          children: [
                            // Share Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  AppHapticFeedback.mediumImpact();
                                  final m = ref.read(dailyMotivationProvider).value;
                                  final text = m != null
                                      ? '"${m.content}" ${m.source != null ? '— ${m.source}' : ''}\n\nShared via VrindaVaani'
                                      : '"$contextMotivation"\n\nShared via VrindaVaani';
                                  await SharePlus.instance.share(ShareParams(text: text));
                                },
                                child: PremiumUI.glassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  borderRadius: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.share,
                                          color: colorPalette.accent, size: 16),
                                      const SizedBox(width: 10),
                                      Text(
                                        'SHARE WISDOM',
                                        style: PremiumTokens.sansStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                          color: PremiumTokens.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Spiritual Path Level Description
                        PremiumUI.glassCard(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorPalette.accent.withValues(
                                          alpha: PremiumTokens.isDark ? 0.15 : 0.08),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: colorPalette.accent.withValues(
                                            alpha: PremiumTokens.isDark ? 0.3 : 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      SpiritualityEngine.levelTitle(levelTier),
                                      style: PremiumTokens.sansStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: PremiumTokens.isDark
                                            ? colorPalette.accentLight
                                            : colorPalette.accent,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'YOUR PATH',
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: PremiumTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                SpiritualityEngine.levelDescription(levelTier),
                                style: GoogleFonts.spectral(
                                  fontSize: 14.5,
                                  color: PremiumTokens.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Cards layout builder
  Widget _buildInsightCard(String text) {
    return PremiumUI.etherealCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.sun_15, color: PremiumTokens.saffronGlow, size: 36)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spectral(
                    fontSize: 17.5,
                    color: PremiumTokens.textPrimary,
                    fontWeight: FontWeight.w300,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TODAY\'S INSIGHT (SWIPE ➔)',
            style: PremiumTokens.sansStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: PremiumTokens.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
      AsyncValue<DailyMotivation?> motivationAsync, AppColorPalette colorPalette) {
    return motivationAsync.when(
      data: (motivation) {
        if (motivation == null) {
          return PremiumUI.etherealCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 28,
            child: Center(
              child: Text(
                'Empty your mind, find silence in your heart. Deepen your practice.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: PremiumTokens.textPrimary,
                ),
              ),
            ),
          );
        }

        return PremiumUI.etherealCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.quote_up5, color: colorPalette.accent, size: 28),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          motivation.content,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spectral(
                            fontSize: 17,
                            color: PremiumTokens.textPrimary,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (motivation.source != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            '— ${motivation.source}',
                            style: PremiumTokens.sansStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colorPalette.accent,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SACRED SCRIPTURE (SWIPE ➔)',
                style: PremiumTokens.sansStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => PremiumUI.glassCard(
        borderRadius: 28,
        child: Center(
          child: CircularProgressIndicator(color: colorPalette.accent),
        ),
      ),
      error: (e, _) => PremiumUI.glassCard(
        borderRadius: 28,
        child: Center(
          child: Text(
            'Failed to load quote. Meditate in silence.',
            style: GoogleFonts.spectral(color: PremiumTokens.textMuted),
          ),
        ),
      ),
    );
  }
}

// Drifting Background Orbs
class _DriftingAuricOrbs extends ConsumerStatefulWidget {
  const _DriftingAuricOrbs();

  @override
  ConsumerState<_DriftingAuricOrbs> createState() => _DriftingAuricOrbsState();
}

class _DriftingAuricOrbsState extends ConsumerState<_DriftingAuricOrbs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = ref.watch(colorPaletteProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          children: [
            // Top Orb
            Positioned(
              top: -50 + (val * 80),
              right: -30 - (val * 60),
              width: 250,
              height: 250,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorPalette.accent.withValues(alpha: 0.12),
                      colorPalette.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Orb
            Positioned(
              bottom: 100 - (val * 100),
              left: -80 + (val * 70),
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumTokens.saffronGlow.withValues(alpha: 0.08),
                      PremiumTokens.saffronGlow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Micro Soundwave animation bars
class _SoundwaveAnimation extends StatefulWidget {
  final Color color;
  const _SoundwaveAnimation({required this.color});

  @override
  State<_SoundwaveAnimation> createState() => _SoundwaveAnimationState();
}

class _SoundwaveAnimationState extends State<_SoundwaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return SizedBox(
          width: 14,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (idx) {
              // Custom sine offsets for natural organic wave feel
              final hFactor = 0.3 + 0.7 * (0.5 + 0.5 * idx * val).clamp(0.1, 1.0);
              return Container(
                width: 2,
                height: 12 * hFactor,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Mindfulness Breathing Bubble
class _MindfulBreathingBubble extends ConsumerStatefulWidget {
  const _MindfulBreathingBubble();

  @override
  ConsumerState<_MindfulBreathingBubble> createState() => _MindfulBreathingBubbleState();
}

class _MindfulBreathingBubbleState extends ConsumerState<_MindfulBreathingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _breatheText = 'Breathe In...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breatheText = 'Breathe Out...';
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breatheText = 'Breathe In...';
        });
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = ref.watch(colorPaletteProvider);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: PremiumTokens.surfaceMain.withValues(alpha: 0.3),
          border: Border.all(
            color: colorPalette.accent.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'MINDFULNESS PREPARATION',
              style: PremiumTokens.sansStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: colorPalette.accent,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = 1.0 + (_controller.value * 0.45);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorPalette.accent.withValues(alpha: 0.25),
                          colorPalette.accent.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: colorPalette.accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorPalette.accent.withValues(alpha: 0.15),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Iconsax.sun_1,
                        color: colorPalette.accent,
                        size: 24,
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 12.seconds),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              _breatheText,
              style: GoogleFonts.spectral(
                fontSize: 16,
                color: PremiumTokens.textPrimary,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
