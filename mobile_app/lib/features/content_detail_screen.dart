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
  double _fontSize = 16.0;

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Use the content's audio URL if available, otherwise use a demo
      String audioUrl = widget.content?.audioUrl ?? 
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      
      await _audioPlayer.setUrl(audioUrl);
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFFAF8F5),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 70,
                    left: 24,
                    right: 24,
                    bottom: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1E1E2E), const Color(0xFF1A1A2E)]
                          : [const Color(0xFFFFF7ED), const Color(0xFFFED7AA)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayCategory.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayTitle,
                        style: GoogleFonts.spectral(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit Text Card
                    _buildHeroTextCard(context, isDark),
                    const SizedBox(height: 28),

                    // Translation
                    _buildContentCard(
                      context,
                      title: l.translate('english_translation'),
                      content:
                          widget.content?.translation ??
                          "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
                      icon: LucideIcons.languages,
                      color: const Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Hindi Meaning
                    _buildContentCard(
                      context,
                      title: l.translate('hindi_meaning'),
                      content:
                          widget.content?.hindiMeaning ??
                          "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
                      icon: LucideIcons.heart,
                      color: const Color(0xFFEC4899),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Commentary
                    _buildContentCard(
                      context,
                      title: l.translate('commentary'),
                      content:
                          widget.content?.commentary ??
                          "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
                      icon: LucideIcons.lightbulb,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Fixed top bar
          Positioned(
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
                color: isDark
                    ? const Color(0xFF1A1A2E).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(
                    icon: LucideIcons.arrowLeft,
                    onTap: () => Navigator.pop(context),
                    isDark: isDark,
                  ),
                  Row(
                    children: [
                      // Favorites Heart Button
                      Consumer(
                        builder: (context, ref, child) {
                          final isFavorite = widget.content != null
                              ? ref.watch(
                                  isFavoriteProvider(widget.content!.id),
                                )
                              : false;
                          return _buildTopButton(
                            icon: isFavorite
                                ? LucideIcons.heartOff
                                : LucideIcons.heart,
                            onTap: _toggleFavorite,
                            isDark: isDark,
                            isActive: isFavorite,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      _buildTopButton(
                        icon: LucideIcons.share2,
                        onTap: _shareContent,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Fixed audio player
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildAudioPlayer(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({
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
              : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryColor
              : (isDark ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildHeroTextCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.glowPurple.withOpacity(0.1),
                ]
              : [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Animated breathing icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.scroll,
              size: 18,
              color: Colors.white,
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          )
          .shimmer(duration: 2.seconds, color: Colors.white30),
          const SizedBox(height: 20),
          // Animated Sanskrit text
          Text(
            widget.content?.sanskritText ??
                "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 16 + _fontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              height: 1.9,
            ),
          )
          .animate()
          .fadeIn(duration: 800.ms)
          .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          // Animated divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 1.5,
                color: AppTheme.primaryColor.withOpacity(0.3),
              )
              .animate()
              .scaleX(delay: 500.ms, begin: 0, end: 1, duration: 400.ms),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  LucideIcons.sparkles,
                  size: 12,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                ),
              ),
              Container(
                width: 20,
                height: 1.5,
                color: AppTheme.primaryColor.withOpacity(0.3),
              )
              .animate()
              .scaleX(delay: 500.ms, begin: 0, end: 1, duration: 400.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 14 + (_fontSize - 16) * 0.5,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF2D3748),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context, bool isDark) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E).withOpacity(0.98)
                : Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Controls row
              Row(
                children: [
                  // Play/Pause
                  PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPlaying
                              ? [AppTheme.glowTeal, const Color(0xFF2DD4BF)]
                              : [AppTheme.primaryColor, AppTheme.primaryDark],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isPlaying
                                        ? AppTheme.glowTeal
                                        : AppTheme.primaryColor)
                                    .withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: Colors.white,
                        size: 24,
                      )
                      .animate(target: isPlaying ? 1 : 0)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
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
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
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
              const SizedBox(height: 16),
              // Progress bar
              StreamBuilder<Duration?>(
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

                      return Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              // Font size controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Text Size",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFontButton(
                    icon: LucideIcons.minus,
                    onTap: () {
                      if (_fontSize > 12) setState(() => _fontSize -= 2);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildFontButton(
                    icon: LucideIcons.plus,
                    onTap: () {
                      if (_fontSize < 22) setState(() => _fontSize += 2);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
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
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
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
