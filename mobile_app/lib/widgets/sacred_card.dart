import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animated_effects.dart';
import '../core/theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SACRED CARD - Modern content card with ॐ decoration
/// ═══════════════════════════════════════════════════════════════════════════

class SacredCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? category;
  final int? readingMinutes;
  final VoidCallback? onTap;
  final bool isHero;
  final Widget? trailing;

  const SacredCard({
    super.key,
    required this.title,
    this.subtitle,
    this.category,
    this.readingMinutes,
    this.onTap,
    this.isHero = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    if (isHero) {
      return _buildHeroCard(context, isDark);
    }
    return _buildStandardCard(context, isDark);
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.space24),
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Stack(
          children: [
            // Decorative ॐ in background
            Positioned(
              right: -20,
              top: -20,
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 120,
                  color: (isDark ? Colors.white : AppTheme.primaryColor)
                      .withOpacity(0.06),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space12,
                      vertical: AppTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : AppTheme.primaryColor)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 12,
                          color: isDark ? Colors.white : AppTheme.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Today's Wisdom",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppTheme.space16),
                // Title
                Text(
                  title,
                  style: GoogleFonts.spectral(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.space8),
                  Text(
                    subtitle!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color:
                          (isDark ? Colors.white : AppTheme.lightTextSecondary)
                              .withOpacity(0.8),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppTheme.space20),
                // Actions
                Row(
                  children: [
                    _buildHeroButton(
                      icon: LucideIcons.bookOpen,
                      label: 'Read Now',
                      isPrimary: true,
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppTheme.space12),
                    _buildHeroButton(
                      icon: LucideIcons.play,
                      label: 'Listen',
                      isPrimary: false,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeroButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: isPrimary
            ? null
            : Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isPrimary ? Colors.white : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context, bool isDark) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: AppTheme.cardDecoration(context),
        child: Row(
          children: [
            // ॐ Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Center(
                child: Text(
                  'ॐ',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (category != null) ...[
                        Text(
                          category!,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (readingMinutes != null)
                        Text(
                          '$readingMinutes min read',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Trailing or chevron
            trailing ??
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppTheme.textMuted(context),
                ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// CONTINUE READING CARD - Progress card for reading history
/// ═══════════════════════════════════════════════════════════════════════════

class ContinueReadingCard extends StatelessWidget {
  final String title;
  final String category;
  final double progress;
  final VoidCallback? onTap;

  const ContinueReadingCard({
    super.key,
    required this.title,
    required this.category,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.borderColor(context), width: 1),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category label
            Text(
              category.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            // Title
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.surfaceColor(context),
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.primaryColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SECTION HEADER - Modern section title
/// ═══════════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
