import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../core/design_system.dart';
import '../core/audio_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/favorites_provider.dart';
import '../widgets/share_content_widget.dart';
import '../core/localization.dart';
import '../core/providers.dart';
import '../widgets/animated_effects.dart';
import 'package:flutter/services.dart';

class ContentDetailScreen extends ConsumerStatefulWidget {
  final SacredContent? content;
  final String? title;
  final String? category;

  ContentDetailScreen({
    super.key,
    this.content,
    this.title,
    this.category,
  });

  @override
  ConsumerState<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();
  bool _showCompactHeader = false;
  bool _showAudioPlayer = false;

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showCompact = _scrollController.offset > 100;
    if (showCompact != _showCompactHeader) {
      setState(() => _showCompactHeader = showCompact);
    }
  }

  // Audio is now managed globally via audioProvider

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (widget.content == null) return;
    HapticFeedback.lightImpact();
    try {
      await ref
          .read(favoritesProvider.notifier)
          .toggleFavorite(widget.content!.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _shareContent() {
    if (widget.content == null) return;
    HapticFeedback.lightImpact();
    ShareContentHelper.shareAsImage(context, widget.content!);
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final isFocusMode = ref.watch(focusModeProvider);
    final l = AppLocalization(currentLanguage);

    final displayTitle =
        (widget.content?.title ?? widget.title ?? l.translate('sacred_text'))
            .replaceAll('\n', ', ');
    final displayCategory =
        widget.content?.category ?? widget.category ?? "Wisdom";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 3)), // Ethereal Depth
          
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
              ),

              SliverToBoxAdapter(
                child: PremiumUI.focusContainer(
                  isFocusMode: isFocusMode,
                  child: _buildPremiumHero(displayTitle, displayCategory),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, isFocusMode ? 100 : 32, 20, 200),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit Card - Always visible but styled for focus
                    _buildPremiumSanskritCard(l, isFocusMode),
                    
                    const SizedBox(height: 32),
                    PremiumUI.sacredDivider(color: Colors.white.withOpacity(isFocusMode ? 0.3 : 0.05)),
                    const SizedBox(height: 32),

                    // Meaning Sections - Hidden/Simplified in Focus Mode
                    PremiumUI.focusContainer(
                      isFocusMode: isFocusMode,
                      child: Column(
                        children: [
                          _buildPremiumContentSection(
                            title: l.translate('hindi_meaning'),
                            content: widget.content?.hindiMeaning ?? "",
                            icon: Iconsax.heart,
                            accentColor: Colors.redAccent,
                          ),
                          const SizedBox(height: 16),

                          _buildPremiumContentSection(
                            title: l.translate('english_translation'),
                            content: widget.content?.translation ?? "",
                            icon: Iconsax.language_circle,
                            accentColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Commentary remains but simplified
                    _buildPremiumContentSection(
                      title: l.translate('commentary'),
                      content: widget.content?.commentary ?? "",
                      icon: Iconsax.lamp_charge,
                      accentColor: PremiumTokens.saffronGlow,
                      isFocusMode: isFocusMode,
                    ),
                    const SizedBox(height: 32),

                    PremiumUI.focusContainer(
                      isFocusMode: isFocusMode,
                      child: Center(child: _buildPremiumFontControls()),
                    ),
                    
                    const SizedBox(height: 48),
                    RepaintBoundary(
                      child: Center(
                        child: Text("ॐ", style: GoogleFonts.spectral(fontSize: 48, color: Colors.white))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 2.seconds)
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 3.seconds)
                          .blur(begin: const Offset(0, 0), end: const Offset(2, 2), duration: 3.seconds)
                          .custom(builder: (c, v, child) => Opacity(opacity: 0.1 + (v * 0.1), child: child)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Header
          _buildPremiumHeader(displayTitle, isFocusMode),

          // Audio Toggle - Fades in Focus Mode
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: PremiumUI.focusContainer(
              isFocusMode: isFocusMode,
              child: AnimatedSwitcher(
                duration: 300.ms,
                child: _showAudioPlayer
                    ? _buildPremiumAudioPlayer()
                    : _buildAudioFloatingToggle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(String title, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTokens.saffronGlow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PremiumTokens.saffronGlow.withOpacity(0.2)),
            ),
            child: Text(
              category.toUpperCase(),
              style: GoogleFonts.outfit(
                color: PremiumTokens.saffronGlow,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(String title, bool isFocusMode) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: (_showCompactHeader && !isFocusMode) 
            ? const Color(0xFF03030F).withOpacity(0.85) 
            : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: (_showCompactHeader && !isFocusMode) 
                ? Colors.white.withOpacity(0.1) 
                : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildHeaderCircleButton(
              null, 
              () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(200.ms); // Allow pulse to be seen
                if (mounted) Navigator.pop(context);
              },
              isAnimated: true,
              animFolder: 'Chevron-left',
              animFile: 'chevron-left.json',
            ),
            SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: (_showCompactHeader && !isFocusMode) ? 1.0 : 0.0,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Focus Mode Toggle
            _buildHeaderCircleButton(
              null,
              () {
                HapticFeedback.mediumImpact();
                ref.read(focusModeProvider.notifier).state = !isFocusMode;
              },
              isActive: isFocusMode,
              isAnimated: true,
              animFolder: 'Visibility V2',
              animFile: 'visibilityV2.json',
            ),
            const SizedBox(width: 8),
            PremiumUI.focusContainer(
              isFocusMode: isFocusMode,
              child: Row(
                children: [
                  _buildHeaderCircleButton(
                    null,
                    _toggleFavorite,
                    isActive: widget.content != null && ref.watch(isFavoriteProvider(widget.content!.id)),
                    isAnimated: true,
                    animFolder: 'Heart',
                    animFile: 'heart.json',
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderCircleButton(
                    null, 
                    _shareContent,
                    isCustomSvg: true,
                    svgFile: 'iconsax-ai-send-message-m26q6m1j-.svg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCircleButton(
    IconData? icon, 
    VoidCallback onTap, {
    bool isActive = false,
    bool isAnimated = false,
    String? animFolder,
    String? animFile,
    bool isCustomSvg = false,
    String? svgFile,
  }) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      child: isAnimated 
        ? PremiumUI.animatedIcon(
            folder: animFolder!, 
            fileName: animFile!, 
            size: 20, 
            color: isActive ? PremiumTokens.saffronGlow : Colors.white,
            resetAfterPlay: !isActive,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
          )
        : InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: isCustomSvg
              ? PremiumUI.customIcon(
                  fileName: svgFile!,
                  size: 20,
                  color: isActive ? PremiumTokens.saffronGlow : Colors.white,
                )
              : Icon(icon, color: isActive ? PremiumTokens.saffronGlow : Colors.white, size: 20),
          ),
    );
  }

  Widget _buildPremiumSanskritCard(AppLocalization l, bool isFocusMode) {
    final text = widget.content?.sanskritText ?? "";
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: 500.ms,
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(isFocusMode ? 32 : 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isFocusMode ? 0.04 : 0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(isFocusMode ? 0.1 : 0.05),
            width: 0.5,
          ),
          boxShadow: isFocusMode ? [
            BoxShadow(
              color: PremiumTokens.saffronGlow.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 10,
            )
          ] : [],
        ),
        child: Column(
          children: [
            PremiumUI.focusContainer(
              isFocusMode: isFocusMode,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: PremiumTokens.saffronGlow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "MANTRA / SLOKA",
                      style: GoogleFonts.outfit(
                        color: PremiumTokens.saffronGlow, 
                        fontSize: 10, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isFocusMode) const SizedBox(height: 24),
            SelectableText(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.spectral(
                fontSize: _fontSize + (isFocusMode ? 10 : 6),
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.bold,
                height: 1.6,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    color: PremiumTokens.saffronGlow.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              duration: 3.seconds,
              color: Colors.white.withOpacity(0.1),
              blendMode: BlendMode.srcOver,
            )
            .scale(
              duration: 4.seconds,
              begin: const Offset(1, 1),
              end: const Offset(1.02, 1.02),
              curve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContentSection({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
    bool isFocusMode = false,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: PremiumUI.glassCard(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: isFocusMode ? 36 : 24),
        opacity: isFocusMode ? 0.04 : 0.08,
        blur: isFocusMode ? 25 : 18,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumUI.focusContainer(
              isFocusMode: isFocusMode,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 14),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: accentColor, 
                      fontSize: 11, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            if (!isFocusMode) const SizedBox(height: 20),
            Text(
              content,
              style: GoogleFonts.outfit(
                fontSize: isFocusMode ? _fontSize + 3 : _fontSize,
                color: Colors.white.withOpacity(isFocusMode ? 0.95 : 0.85),
                height: 1.7,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFontControls() {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.text, color: Colors.white24, size: 16),
          const SizedBox(width: 16),
          _buildFontToolButton(Iconsax.minus, () {
            if (_fontSize > 14) setState(() => _fontSize -= 2);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("${_fontSize.toInt()}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _buildFontToolButton(Iconsax.add, () {
            if (_fontSize < 32) setState(() => _fontSize += 2);
          }),
        ],
      ),
    );
  }

  Widget _buildFontToolButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildAudioFloatingToggle() {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showAudioPlayer = true);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: PremiumTokens.saffronPremiumGradient,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: PremiumTokens.saffronGlow.withOpacity(0.3), blurRadius: 20)],
          ),
          child: Icon(Iconsax.music, color: Colors.white, size: 24),
        ),
      ),
    ).animate().scale();
  }

  Widget _buildPremiumAudioPlayer() {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      blur: 30,
      opacity: 0.15,
      child: Consumer(
        builder: (context, ref, child) {
          final audioState = ref.watch(audioProvider);
          final isPlaying = audioState.isPlaying;
          final isLoading = audioState.isLoading;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PremiumTokens.saffronGlow.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: isLoading 
                          ? const SizedBox(
                              width: 14, 
                              height: 14, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: PremiumTokens.saffronGlow)
                            )
                          : Icon(Iconsax.music_play, color: PremiumTokens.saffronGlow, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoading ? "PREPARING DIVINE VIBRATIONS..." : "DIVINE RECITATION",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              widget.content?.title ?? "Sacred Verse",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showAudioPlayer = false),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.arrow_down_1, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Slider
              _buildPremiumProgressBar(audioState),
              const SizedBox(height: 8),
              _buildPremiumAudioTime(audioState),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlayerCircleButton(
                    Iconsax.backward_10_seconds, 
                    () => ref.read(audioProvider.notifier).skipBackward(),
                    size: 40,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (widget.content != null) {
                        ref.read(audioProvider.notifier).play(widget.content!);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        gradient: PremiumTokens.saffronPremiumGradient,
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTokens.saffronGlow.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : Icon(isPlaying ? Iconsax.pause : Iconsax.play, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _buildPlayerCircleButton(
                    Iconsax.forward_10_seconds, 
                    () => ref.read(audioProvider.notifier).skipForward(),
                    size: 40,
                    iconSize: 18,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerCircleButton(IconData icon, VoidCallback onTap, {double size = 44, double iconSize = 20}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white70, size: iconSize),
      ),
    );
  }

  Widget _buildPremiumProgressBar(AudioState audioState) {
    final duration = audioState.duration;
    final position = audioState.position;
    final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
    
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: PremiumTokens.saffronGlow,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
        thumbColor: Colors.white,
        overlayColor: PremiumTokens.saffronGlow.withOpacity(0.2),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final newPos = Duration(milliseconds: (value * duration.inMilliseconds).toInt());
          ref.read(audioProvider.notifier).seek(newPos);
        },
      ),
    );
  }

  Widget _buildPremiumAudioTime(AudioState audioState) {
    final duration = audioState.duration;
    final position = audioState.position;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatDuration(position), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
        Text(_formatDuration(duration), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}
