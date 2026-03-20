import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';
import '../../widgets/animated_effects.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  SettingsScreen({super.key});

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(),
          CustomScrollView(
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
                      style: PremiumTokens.displayStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PremiumUI.customIcon(
                      fileName: 'iconsax-chart-2-jqsol9gq-.svg',
                      color: PremiumTokens.nebulaBlue,
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
                  Iconsax.colorfilter,
                ),
                SizedBox(height: 12),

                // Dark Mode Toggle
                _buildToggleCard(
                  context,
                  l.translate('dark_mode'),
                  l.translate('dark_mode_sub'),
                  Iconsax.moon,
                  isDark,
                  (val) {
                    HapticFeedback.lightImpact();
                    ref.read(themeProvider.notifier).toggleTheme(val);
                  },
                  gradientColors: [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 12),

                // Language Selector
                _buildLanguageTile(context, l),
                const SizedBox(height: 32),

                // Notifications Section
                _buildSectionHeader(
                  context,
                  l.translate('notifications'),
                  Iconsax.notification,
                ),
                const SizedBox(height: 12),

                _buildToggleCard(
                  context,
                  l.translate('daily_wisdom'),
                  l.translate('daily_wisdom_sub'),
                  Iconsax.magic_star,
                  _notifications,
                  (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _notifications = val);
                  },
                  gradientColors: [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 32),

                // Account Section
                _buildSectionHeader(
                  context,
                  l.translate('account'),
                  Iconsax.user,
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('privacy_policy'),
                  l.translate('privacy_policy'),
                  Iconsax.shield_tick,
                  gradientColors: [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('terms_service'),
                  l.translate('terms_service'),
                  Iconsax.document,
                  gradientColors: [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('delete_account'),
                  l.translate('delete_account'),
                  Iconsax.trash,
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
                              PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                              PremiumTokens.nebulaBlue.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PremiumUI.animatedIcon(
                          folder: 'Heart',
                          fileName: 'heart.json',
                          color: PremiumTokens.nebulaBlue,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Sant-Vaani",
                        style: GoogleFonts.spectral(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white38,
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
    ],
  ),
);
}

  Widget _buildBackButton(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: PremiumUI.animatedIcon(
          folder: 'Chevron-left',
          fileName: 'chevron-left.json',
          size: 20,
          color: Colors.white,
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
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: PremiumTokens.nebulaBlue),
          ),
          SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: PremiumTokens.nebulaBlue,
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
    final colors =
        gradientColors ?? [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
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
                    color: colors[0].withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
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
                    style: PremiumTokens.displayStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: PremiumTokens.sansStyle(
                      fontSize: 13,
                      color: Colors.white38,
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
          color: value ? activeColor : Colors.grey.withValues(alpha: 0.3),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 250),
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
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? Icon(Iconsax.tick_circle, size: 14, color: activeColor)
                : null,
          ),
        ),
      ),
    );
  }

  // Optimized language tile without BackdropFilter
  Widget _buildLanguageTile(BuildContext context, AppLocalization l) {
    return PressableScale(
      onTap: () => _showLanguageDialog(context, l),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: PremiumTokens.nebulaGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTokens.nebulaBlue.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.language_circle,
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
                      style: PremiumTokens.displayStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.read(languageProvider.notifier).languageName,
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: PremiumTokens.nebulaBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalization l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
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
                      color: Colors.white38.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: PremiumTokens.nebulaGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Iconsax.global,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l.translate('language'),
                      style: PremiumTokens.displayStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose your preferred language",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ...AppLanguage.values.map((lang) {
                  final isSelected = ref.watch(languageProvider) == lang;
                  String name = "";
                  String nativeName = "";
                  IconData flagIcon = Iconsax.global;

                  switch (lang) {
                    case AppLanguage.english:
                      name = "English";
                      nativeName = "English";
                      flagIcon = Iconsax.global;
                      break;
                    case AppLanguage.hindi:
                      name = "Hindi";
                      nativeName = "हिंदी";
                      flagIcon = Iconsax.language_circle;
                      break;
                    case AppLanguage.sanskrit:
                      name = "Sanskrit";
                      nativeName = "संस्कृत";
                      flagIcon = Iconsax.document_text;
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
                              ? PremiumTokens.nebulaBlue.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? PremiumTokens.nebulaBlue.withValues(alpha: 0.3)
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
                                    ? PremiumTokens.nebulaBlue.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                flagIcon,
                                size: 20,
                                color: isSelected
                                    ? PremiumTokens.nebulaBlue
                                    : Colors.white38,
                              ),
                            ),
                            SizedBox(width: 16),
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
                                          ? PremiumTokens.nebulaBlue
                                          : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    nativeName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: PremiumTokens.nebulaBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.tick_circle,
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
    final colors = isDestructive
        ? [const Color(0xFFEF4444), const Color(0xFFF87171)]
        : gradientColors ?? [PremiumTokens.nebulaBlue, PremiumTokens.nebulaBlue.withValues(alpha: 0.8)];

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        PremiumUI.showNotification(
          context, 
          "Action: $title",
          icon: icon,
          color: isDestructive ? Colors.red : PremiumTokens.nebulaBlue,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
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
                      color: colors[0].withValues(alpha: 0.4),
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
                        : Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: isDestructive ? Colors.red : PremiumTokens.nebulaBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
