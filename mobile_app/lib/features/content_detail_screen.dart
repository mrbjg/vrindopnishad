import 'dart:io';
import 'package:flutter/material.dart';
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

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  bool _isBookmarked = false;
  bool _isPlaying = false;

  void _toggleBookmark(AppLocalization l) {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? l.translate('added_library')
              : l.translate('removed_library'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.isDark(context)
            ? AppTheme.darkCard
            : AppTheme.lightTextPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);

    final displayTitle =
        widget.content?.title ?? widget.title ?? l.translate('sacred_text');
    final displayCategory =
        widget.content?.category ?? widget.category ?? "Wisdom";

    // Get safe area padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Curved image header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 320 + topPadding,
                  decoration: BoxDecoration(
                    gradient: AppTheme.headerGradient(context),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: widget.content?.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                          child: Image.file(
                            File(widget.content!.imageUrl!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: topPadding),
                            child: Icon(
                              LucideIcons.sparkles,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                ),
                // Overlay gradient
                Container(
                  height: 320 + topPadding,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Navigation buttons - positioned with safe area
                Positioned(
                  top: topPadding + 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        LucideIcons.arrowLeft,
                        () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          _buildIconButton(
                            _isBookmarked
                                ? LucideIcons.bookmarkMinus
                                : LucideIcons.bookmark,
                            () => _toggleBookmark(l),
                          ),
                          const SizedBox(width: 12),
                          _buildIconButton(LucideIcons.share2, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content area with overlap effect
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(
                            AppTheme.isDark(context) ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          displayCategory.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        displayTitle,
                        style: GoogleFonts.spectral(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Meta info
                      Row(
                        children: [
                          _buildMetaItem(
                            context,
                            LucideIcons.clock,
                            "5 ${l.translate('min_read')}",
                          ),
                          const SizedBox(width: 20),
                          _buildMetaItem(
                            context,
                            LucideIcons.languages,
                            "3 ${l.translate('languages')}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sanskrit text
                      _buildContentSection(context, l),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
            ),
          ),
        ],
      ),
      // Audio FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _isPlaying = !_isPlaying);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isPlaying
                    ? l.translate('playing_narration')
                    : l.translate('paused'),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          _isPlaying ? LucideIcons.pauseCircle : LucideIcons.playCircle,
          color: Colors.white,
        ),
        label: Text(
          _isPlaying ? l.translate('pause') : l.translate('listen'),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted(context)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppTheme.textMuted(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, AppLocalization l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sanskrit verse
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(
                  AppTheme.isDark(context) ? 0.15 : 0.08,
                ),
                AppTheme.primaryColor.withOpacity(
                  AppTheme.isDark(context) ? 0.08 : 0.03,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
          ),
          child: Text(
            widget.content?.sanskritText ??
                "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Sections
        _buildSection(
          context,
          l.translate('english_translation'),
          widget.content?.translation ??
              "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
        ),
        _buildSection(
          context,
          l.translate('hindi_meaning'),
          widget.content?.hindiMeaning ??
              "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
        ),
        _buildSection(
          context,
          l.translate('commentary'),
          widget.content?.commentary ??
              "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary(context),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
