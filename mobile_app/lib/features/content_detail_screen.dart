import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';

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

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isBookmarked = false;
  bool _isPlaying = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleBookmark(AppLocalization l) {
    HapticFeedback.lightImpact();
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isBookmarked ? LucideIcons.bookmark : LucideIcons.bookmarkMinus,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _isBookmarked
                  ? l.translate('added_library')
                  : l.translate('removed_library'),
              style: GoogleFonts.outfit(),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.primaryColor,
        margin: const EdgeInsets.all(20),
      ),
    );
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

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Curved Header with Glassmorphism
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Background gradient with image
                Container(
                  height: 340 + topPadding,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1A1A2E),
                              const Color(0xFF16213E),
                              AppTheme.glowPurple.withOpacity(0.4),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFEF3C7),
                              const Color(0xFFFBD38D),
                              AppTheme.primaryColor,
                            ],
                          ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(56),
                      bottomRight: Radius.circular(56),
                    ),
                  ),
                  child: widget.content?.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(56),
                            bottomRight: Radius.circular(56),
                          ),
                          child: Image.file(
                            File(widget.content!.imageUrl!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Stack(
                          children: [
                            // Decorative elements
                            Positioned(
                              top: -40,
                              right: -40,
                              child:
                                  Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.15),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      )
                                      .animate(onPlay: (c) => c.repeat())
                                      .shimmer(
                                        duration: 3000.ms,
                                        color: Colors.white24,
                                      ),
                            ),
                            Positioned(
                              bottom: 80,
                              left: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.glowPink.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Center icon
                            Center(
                              child:
                                  Padding(
                                        padding: EdgeInsets.only(
                                          top: topPadding,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Icon(
                                            LucideIcons.sparkles,
                                            size: 48,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.05, 1.05),
                                        duration: 2000.ms,
                                      ),
                            ),
                          ],
                        ),
                ),
                // Dark overlay gradient
                Container(
                  height: 340 + topPadding,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(56),
                      bottomRight: Radius.circular(56),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Navigation bar with glass buttons
                Positioned(
                  top: topPadding + 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassIconButton(
                        LucideIcons.arrowLeft,
                        () => Navigator.pop(context),
                      ).animate().fadeIn().slideX(begin: -0.2),
                      Row(
                        children: [
                          _buildGlassIconButton(
                            _isBookmarked
                                ? LucideIcons.bookmarkMinus
                                : LucideIcons.bookmark,
                            () => _toggleBookmark(l),
                            isActive: _isBookmarked,
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(width: 12),
                          _buildGlassIconButton(LucideIcons.share2, () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.share2,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Sharing...",
                                      style: GoogleFonts.outfit(),
                                    ),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: AppTheme.glowBlue,
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                          }).animate().fadeIn(delay: 150.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Card with overlap effect
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category badge
                            Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withOpacity(0.2),
                                        AppTheme.primaryColor.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.folder,
                                        size: 14,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        displayCategory.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideX(begin: -0.1),
                            const SizedBox(height: 20),
                            // Title
                            Text(
                              displayTitle,
                              style: GoogleFonts.spectral(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary(context),
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 250.ms),
                            const SizedBox(height: 16),
                            // Meta info row
                            Row(
                              children: [
                                _buildMetaChip(
                                  context,
                                  LucideIcons.clock,
                                  "5 ${l.translate('min_read')}",
                                ),
                                const SizedBox(width: 12),
                                _buildMetaChip(
                                  context,
                                  LucideIcons.languages,
                                  "3 ${l.translate('languages')}",
                                ),
                              ],
                            ).animate().fadeIn(delay: 300.ms),
                            const SizedBox(height: 36),
                            // Content sections
                            _buildContentSection(context, l),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            ),
          ),
        ],
      ),
      // Premium Floating Audio Button
      floatingActionButton: _buildPremiumAudioFab(context, l, isDark),
    );
  }

  Widget _buildGlassIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return PressableScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.25),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String text) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted(context)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sanskrit verse with premium styling
        Container(
          width: double.infinity,
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
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              // Decorative top icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.scroll,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.content?.sanskritText ??
                    "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  height: 1.9,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
        const SizedBox(height: 36),
        // Translation sections
        _buildSection(
          context,
          l.translate('english_translation'),
          widget.content?.translation ??
              "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
          LucideIcons.globe,
          [AppTheme.glowBlue, const Color(0xFF60A5FA)],
          400,
        ),
        _buildSection(
          context,
          l.translate('hindi_meaning'),
          widget.content?.hindiMeaning ??
              "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
          LucideIcons.languages,
          [AppTheme.glowPink, const Color(0xFFF472B6)],
          450,
        ),
        _buildSection(
          context,
          l.translate('commentary'),
          widget.content?.commentary ??
              "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
          LucideIcons.messageSquare,
          [AppTheme.glowTeal, const Color(0xFF2DD4BF)],
          500,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    List<Color> gradientColors,
    int delayMs,
  ) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textSecondary(context),
                  height: 1.8,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delayMs))
        .slideX(begin: 0.03);
  }

  Widget _buildPremiumAudioFab(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return PressableScale(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _isPlaying = !_isPlaying);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      _isPlaying ? LucideIcons.play : LucideIcons.pause,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isPlaying
                          ? l.translate('playing_narration')
                          : l.translate('paused'),
                      style: GoogleFonts.outfit(),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: _isPlaying
                    ? AppTheme.glowTeal
                    : AppTheme.primaryColor,
                margin: const EdgeInsets.all(20),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPlaying
                    ? [AppTheme.glowTeal, const Color(0xFF2DD4BF)]
                    : [AppTheme.primaryColor, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color:
                      (_isPlaying ? AppTheme.glowTeal : AppTheme.primaryColor)
                          .withOpacity(0.4 + _pulseController.value * 0.2),
                  blurRadius: 24 + _pulseController.value * 8,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying ? LucideIcons.pauseCircle : LucideIcons.playCircle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _isPlaying ? l.translate('pause') : l.translate('listen'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
