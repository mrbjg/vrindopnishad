import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Row(
                children: [
                  _buildBackButton(context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l.translate('settings'),
                      style: GoogleFonts.spectral(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      LucideIcons.settings,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                _buildSectionHeader(
                  context,
                  l.translate('appearance'),
                  LucideIcons.palette,
                ),
                const SizedBox(height: 12),

                // Dark Mode Toggle
                _buildToggleCard(
                  context,
                  l.translate('dark_mode'),
                  l.translate('dark_mode_sub'),
                  LucideIcons.moon,
                  isDark,
                  (val) {
                    HapticFeedback.lightImpact();
                    ref.read(themeProvider.notifier).toggleTheme(val);
                  },
                  gradientColors: [AppTheme.glowPurple, AppTheme.glowBlue],
                ),
                const SizedBox(height: 12),

                // Language Selector
                _buildLanguageTile(context, l),
                const SizedBox(height: 32),

                // Notifications Section
                _buildSectionHeader(
                  context,
                  l.translate('notifications'),
                  LucideIcons.bell,
                ),
                const SizedBox(height: 12),

                _buildToggleCard(
                  context,
                  l.translate('daily_wisdom'),
                  l.translate('daily_wisdom_sub'),
                  LucideIcons.sparkles,
                  _notifications,
                  (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _notifications = val);
                  },
                  gradientColors: [AppTheme.glowOrange, AppTheme.primaryColor],
                ),
                const SizedBox(height: 32),

                // Account Section
                _buildSectionHeader(
                  context,
                  l.translate('account'),
                  LucideIcons.user,
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('privacy_policy'),
                  l.translate('privacy_policy'),
                  LucideIcons.shield,
                  gradientColors: [AppTheme.glowTeal, const Color(0xFF06B6D4)],
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('terms_service'),
                  l.translate('terms_service'),
                  LucideIcons.fileText,
                  gradientColors: [AppTheme.glowBlue, const Color(0xFF6366F1)],
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('delete_account'),
                  l.translate('delete_account'),
                  LucideIcons.trash2,
                  isDestructive: true,
                ),
                const SizedBox(height: 48),

                // App Version Footer
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.glowPurple.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Sant-Vaani",
                        style: GoogleFonts.spectral(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(
          LucideIcons.arrowLeft,
          color: AppTheme.textPrimary(context),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Optimized toggle card without BackdropFilter
  Widget _buildToggleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    List<Color>? gradientColors,
  }) {
    final isDark = AppTheme.isDark(context);
    final colors =
        gradientColors ?? [AppTheme.primaryColor, AppTheme.primaryDark];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.textPrimary(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            _buildPremiumSwitch(value, onChanged, colors[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSwitch(
    bool value,
    Function(bool) onChanged,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? activeColor : Colors.grey.withOpacity(0.3),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? Icon(LucideIcons.check, size: 14, color: activeColor)
                : null,
          ),
        ),
      ),
    );
  }

  // Optimized language tile without BackdropFilter
  Widget _buildLanguageTile(BuildContext context, AppLocalization l) {
    final languageName = ref.read(languageProvider.notifier).languageName;
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: () => _showLanguageDialog(context, l),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            width: 1.5,
          ),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.glowPink, const Color(0xFFF472B6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.glowPink.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.languages,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('language'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      languageName,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.glowPink, const Color(0xFFF472B6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.globe,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l.translate('language'),
                      style: GoogleFonts.spectral(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose your preferred language",
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ...AppLanguage.values.map((lang) {
                  final isSelected = ref.watch(languageProvider) == lang;
                  String name = "";
                  String nativeName = "";
                  IconData flagIcon = LucideIcons.globe;

                  switch (lang) {
                    case AppLanguage.english:
                      name = "English";
                      nativeName = "English";
                      flagIcon = LucideIcons.globe;
                      break;
                    case AppLanguage.hindi:
                      name = "Hindi";
                      nativeName = "हिंदी";
                      flagIcon = LucideIcons.languages;
                      break;
                    case AppLanguage.sanskrit:
                      name = "Sanskrit";
                      nativeName = "संस्कृत";
                      flagIcon = LucideIcons.scroll;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(languageProvider.notifier).setLanguage(lang);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.3)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.15)
                                    : AppTheme.surfaceColor(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                flagIcon,
                                size: 20,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textMuted(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.textPrimary(context),
                                    ),
                                  ),
                                  Text(
                                    nativeName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppTheme.textMuted(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Optimized action tile without BackdropFilter
  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    bool isDestructive = false,
    List<Color>? gradientColors,
  }) {
    final isDark = AppTheme.isDark(context);
    final colors = isDestructive
        ? [const Color(0xFFEF4444), const Color(0xFFF87171)]
        : gradientColors ?? [AppTheme.primaryColor, AppTheme.primaryDark];

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Action: $title", style: GoogleFonts.outfit()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: isDestructive ? Colors.red : AppTheme.primaryColor,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.15)
                : isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            width: 1.5,
          ),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDestructive
                        ? Colors.red
                        : AppTheme.textPrimary(context),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDestructive ? Colors.red : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
