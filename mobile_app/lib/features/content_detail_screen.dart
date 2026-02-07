import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/favorites_provider.dart';
import '../widgets/share_content_widget.dart';
import '../widgets/animated_effects.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CONTENT DETAIL SCREEN - Immersive Reading Experience
/// Modern, minimal, distraction-free reading with sticky audio
/// ═══════════════════════════════════════════════════════════════════════════

class ContentDetailScreen extends ConsumerStatefulWidget {
  final SacredContent? content;
  final String? title;
  final String? category;

  const ContentDetailScreen({
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

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showCompact = _scrollController.offset > 100;
    if (showCompact != _showCompactHeader) {
      setState(() => _showCompactHeader = showCompact);
    }
  }

  Future<void> _initAudio() async {
    try {
      String audioUrl =
          widget.content?.audioUrl ??
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      await _audioPlayer.setUrl(audioUrl);
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
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
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    final displayTitle =
        widget.content?.title ?? widget.title ?? l.translate('sacred_text');
    final displayCategory =
        widget.content?.category ?? widget.category ?? "Wisdom";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top spacing for header
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 60,
                ),
              ),

              // Hero section with title
              SliverToBoxAdapter(
                child: _buildHeroSection(
                  context,
                  displayTitle,
                  displayCategory,
                  isDark,
                ),
              ),

              // Content sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.space20,
                  AppTheme.space24,
                  AppTheme.space20,
                  200,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit Text Card - Hero
                    _buildSanskritCard(context, isDark, l),
                    const SizedBox(height: AppTheme.space20),

                    // Translation Card
                    _buildContentCard(
                      context,
                      title: l.translate('english_translation'),
                      content:
                          widget.content?.translation ??
                          "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
                      icon: LucideIcons.languages,
                      color: AppTheme.peacockBlue,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppTheme.space16),

                    // Hindi Meaning Card
                    _buildContentCard(
                      context,
                      title: l.translate('hindi_meaning'),
                      content:
                          widget.content?.hindiMeaning ??
                          "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
                      icon: LucideIcons.heart,
                      color: AppTheme.lotusRose,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppTheme.space16),

                    // Commentary Card
                    _buildContentCard(
                      context,
                      title: l.translate('commentary'),
                      content:
                          widget.content?.commentary ??
                          "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
                      icon: LucideIcons.lightbulb,
                      color: AppTheme.sereneTeal,
                      isDark: isDark,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Header
          _buildFloatingHeader(context, displayTitle, isDark),

          // Sticky Audio Player
          Positioned(
            left: AppTheme.space16,
            right: AppTheme.space16,
            bottom: AppTheme.space20,
            child: _buildAudioPlayer(context, isDark),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSection(
    BuildContext context,
    String title,
    String category,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative ॐ
          Center(
            child:
                Text(
                      'ॐ',
                      style: TextStyle(
                        fontSize: 48,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        fontWeight: FontWeight.w300,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 3.seconds,
                    ),
          ),
          const SizedBox(height: AppTheme.space16),
          // Category badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space12,
                vertical: AppTheme.space4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          ),
          const SizedBox(height: AppTheme.space12),
          // Title
          Center(
            child:
                Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spectral(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                        height: 1.3,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLOATING HEADER - Minimal & clean
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFloatingHeader(BuildContext context, String title, bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: _showCompactHeader
              ? (isDark ? AppTheme.darkCard : AppTheme.lightCard).withOpacity(
                  0.95,
                )
              : Colors.transparent,
          boxShadow: _showCompactHeader
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Back button
            _buildHeaderButton(
              icon: LucideIcons.arrowLeft,
              onTap: () => Navigator.pop(context),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            // Title (shown when scrolled)
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showCompactHeader ? 1.0 : 0.0,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Action buttons
            Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final isFavorite = widget.content != null
                        ? ref.watch(isFavoriteProvider(widget.content!.id))
                        : false;
                    return _buildHeaderButton(
                      icon: isFavorite
                          ? LucideIcons.heartOff
                          : LucideIcons.heart,
                      onTap: _toggleFavorite,
                      isDark: isDark,
                      isActive: isFavorite,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: LucideIcons.share2,
                  onTap: _shareContent,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withOpacity(0.15)
              : AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.borderColor(context), width: 1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.textSecondary(context),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SANSKRIT CARD - Large, beautiful typography
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSanskritCard(
    BuildContext context,
    bool isDark,
    AppLocalization l,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryColor.withOpacity(0.08),
                  AppTheme.sacredViolet.withOpacity(0.06),
                ]
              : [
                  AppTheme.primaryColor.withOpacity(0.05),
                  AppTheme.lightSurface,
                ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient(context),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                ),
                child: const Icon(
                  LucideIcons.scroll,
                  size: 20,
                  color: Colors.white,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 2.seconds,
              ),
          const SizedBox(height: AppTheme.space20),
          // Sanskrit Text
          Text(
            widget.content?.sanskritText ??
                "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: _fontSize + 2,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              height: 2.0,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppTheme.space16),
          // Decorative divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  LucideIcons.sparkles,
                  size: 14,
                  color: AppTheme.primaryColor.withOpacity(0.4),
                ),
              ),
              Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT CARD - Translation, meaning, commentary
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          Divider(color: AppTheme.borderColor(context), height: 1),
          const SizedBox(height: AppTheme.space16),
          // Content
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: _fontSize - 2,
              color: AppTheme.textSecondary(context),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUDIO PLAYER - Sticky bottom player
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAudioPlayer(BuildContext context, bool isDark) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return Container(
          padding: const EdgeInsets.all(AppTheme.space20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context).withOpacity(0.98),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: AppTheme.borderColor(context), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Controls row
              Row(
                children: [
                  // Play/Pause button
                  PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPlaying
                              ? [AppTheme.sereneTeal, const Color(0xFF14B8A6)]
                              : [AppTheme.primaryColor, AppTheme.primaryDark],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow(
                          isPlaying
                              ? AppTheme.sereneTeal
                              : AppTheme.primaryColor,
                        ),
                      ),
                      child: Icon(
                        isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPlaying ? "Now Playing" : "Sanskrit Recitation",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (context, durationSnap) {
                            final duration = durationSnap.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, positionSnap) {
                                final position =
                                    positionSnap.data ?? Duration.zero;
                                return Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textMuted(context),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Skip controls
                  _buildSmallButton(
                    icon: LucideIcons.skipBack,
                    onTap: () => _audioPlayer.seek(
                      _audioPlayer.position - const Duration(seconds: 10),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildSmallButton(
                    icon: LucideIcons.skipForward,
                    onTap: () => _audioPlayer.seek(
                      _audioPlayer.position + const Duration(seconds: 10),
                    ),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space16),
              // Progress bar
              _buildProgressBar(isDark),
              const SizedBox(height: AppTheme.space12),
              // Font size controls
              _buildFontControls(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.durationStream,
      builder: (context, durationSnap) {
        final duration = durationSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: Stack(
                children: [
                  Container(height: 6, color: AppTheme.surfaceColor(context)),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFontControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Text Size",
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted(context),
          ),
        ),
        const SizedBox(width: 12),
        _buildFontButton(
          icon: LucideIcons.minus,
          onTap: () {
            if (_fontSize > 14) setState(() => _fontSize -= 2);
          },
          isDark: isDark,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${_fontSize.toInt()}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ),
        _buildFontButton(
          icon: LucideIcons.plus,
          onTap: () {
            if (_fontSize < 26) setState(() => _fontSize += 2);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textSecondary(context)),
      ),
    );
  }

  Widget _buildFontButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, size: 14, color: AppTheme.textSecondary(context)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
