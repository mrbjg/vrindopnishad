import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  bool _isBookmarked = false;
  bool _isPlaying = false;
  double _fontSize = 16.0;

  void _toggleBookmark(AppLocalization l) {
    HapticFeedback.lightImpact();
    setState(() => _isBookmarked = !_isBookmarked);
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
              // Header with gradient and title
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
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
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
                      // Title
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit/Original Text - Hero section
                    _buildHeroTextCard(context, isDark),
                    const SizedBox(height: 28),

                    // Translation card
                    _buildContentCard(
                      context,
                      title: l.translate('english_translation'),
                      content:
                          widget.content?.translation ??
                          "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
                      icon: LucideIcons.languages,
                      gradientColors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF60A5FA),
                      ],
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Hindi Meaning card
                    _buildContentCard(
                      context,
                      title: l.translate('hindi_meaning'),
                      content:
                          widget.content?.hindiMeaning ??
                          "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
                      icon: LucideIcons.heart,
                      gradientColors: [
                        const Color(0xFFEC4899),
                        const Color(0xFFF472B6),
                      ],
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Commentary card
                    _buildContentCard(
                      context,
                      title: l.translate('commentary'),
                      content:
                          widget.content?.commentary ??
                          "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
                      icon: LucideIcons.lightbulb,
                      gradientColors: [
                        const Color(0xFF10B981),
                        const Color(0xFF34D399),
                      ],
                      isDark: isDark,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Fixed glass top bar with rounded corners
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 12,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A2E).withOpacity(0.85)
                        : Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassButton(
                        icon: LucideIcons.arrowLeft,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      Row(
                        children: [
                          _buildGlassButton(
                            icon: _isBookmarked
                                ? LucideIcons.bookmarkMinus
                                : LucideIcons.bookmark,
                            onTap: () => _toggleBookmark(l),
                            isDark: isDark,
                            isActive: _isBookmarked,
                          ),
                          const SizedBox(width: 10),
                          _buildGlassButton(
                            icon: LucideIcons.share2,
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fixed glass audio player at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildFloatingAudioPlayer(context, l, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : Colors.white.withOpacity(isDark ? 0.08 : 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryColor.withOpacity(0.4)
                    : Colors.white.withOpacity(isDark ? 0.15 : 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTextCard(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.primaryColor.withOpacity(0.18),
                      AppTheme.glowPurple.withOpacity(0.12),
                    ]
                  : [
                      AppTheme.primaryColor.withOpacity(0.12),
                      AppTheme.primaryColor.withOpacity(0.06),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(isDark ? 0.25 : 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Decorative top ornament
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.scroll,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Sanskrit text
              Text(
                widget.content?.sanskritText ??
                    "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  fontSize: 16 + _fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  height: 1.9,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 20),
              // Decorative divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryColor.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      LucideIcons.sparkles,
                      size: 12,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.06 : 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: gradientColors[0],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Content text
              Text(
                content,
                style: GoogleFonts.outfit(
                  fontSize: 14 + (_fontSize - 16) * 0.5,
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF2D3748),
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAudioPlayer(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Play button
              PressableScale(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isPlaying = !_isPlaying);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPlaying
                          ? [AppTheme.glowTeal, const Color(0xFF2DD4BF)]
                          : [AppTheme.primaryColor, AppTheme.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isPlaying
                                    ? AppTheme.glowTeal
                                    : AppTheme.primaryColor)
                                .withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlaying ? "Now Playing" : "Listen",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Sanskrit Narration",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Font controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildFontButton(
                      icon: LucideIcons.minus,
                      onTap: () {
                        if (_fontSize > 12) {
                          setState(() => _fontSize -= 2);
                        }
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    _buildFontButton(
                      icon: LucideIcons.plus,
                      onTap: () {
                        if (_fontSize < 22) {
                          setState(() => _fontSize += 2);
                        }
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
