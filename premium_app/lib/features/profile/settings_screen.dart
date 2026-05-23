import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';
import '../../core/providers/reading_providers.dart';
import '../../core/auth_provider.dart';
import '../../core/color_theme_provider.dart';
import '../../core/mood_theme_provider.dart';
import '../../widgets/animated_effects.dart';
import 'package:flutter/services.dart';

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
    ref.watch(colorPaletteProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(context),
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
                      color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PremiumUI.customIcon(
                      fileName: 'iconsax-chart-2-jqsol9gq-.svg',
                      color: PremiumTokens.activeAccent,
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
                const SizedBox(height: 12),

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
                  gradientColors: [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 16),

                // Custom Color Theme Picker
                _buildColorThemePicker(context),
                const SizedBox(height: 16),

                // Mood Theme Picker
                _buildMoodThemePicker(context),
                const SizedBox(height: 16),

                if (isDark) ...[
                  _buildToggleCard(
                    context,
                    "AMOLED True Dark",
                    "Pure pitch black theme for battery saving",
                    Iconsax.setting_3,
                    ref.watch(trueDarkEnabledProvider),
                    (val) {
                      HapticFeedback.lightImpact();
                      ref.read(trueDarkEnabledProvider.notifier).toggle(val);
                    },
                    gradientColors: [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)],
                  ),
                  const SizedBox(height: 16),
                ],

                // Divine Icon Status Card
                _buildDivineIconStatus(context),
                const SizedBox(height: 12),

                _buildToggleCard(
                  context,
                  "Dynamic App Icon",
                  "Evolve icon based on daily milestones",
                  Iconsax.magicpen,
                  ref.watch(dynamicIconEnabledProvider),
                  (val) async {
                    HapticFeedback.mediumImpact();
                    final user = ref.read(authServiceProvider).currentUser;
                    if (user != null) {
                      /* 
                      await ref.read(statsServiceProvider).updateStats(user.uid, {
                        'dynamic_icon_enabled': val,
                      });
                      */
                      // Update the local provider state immediately
                      ref.read(dynamicIconEnabledProvider.notifier).state = val;
                      
                      PremiumUI.showNotification(
                        context, 
                        val ? "Divine Evolution active" : "Classic Vaults restored",
                        icon: Iconsax.magicpen,
                      );
                    }
                  },
                  gradientColors: [PremiumTokens.saffronGlow, Colors.orange],
                ),
                const SizedBox(height: 16),

                // Reader Theme Section
                _buildSectionHeader(
                  context,
                  l.translate('reader_theme'),
                  Iconsax.book,
                ),
                const SizedBox(height: 12),
                _buildReaderThemeSelector(context, l),
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
                  gradientColors: [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)],
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
                  gradientColors: [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)],
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  l.translate('terms_service'),
                  l.translate('terms_service'),
                  Iconsax.document,
                  gradientColors: [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)],
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
                              PremiumTokens.activeAccent.withValues(alpha: 0.1),
                              PremiumTokens.activeAccent.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PremiumUI.animatedIcon(
                          folder: 'Heart',
                          fileName: 'heart.json',
                          color: PremiumTokens.activeAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Sant-Vaani",
                        style: GoogleFonts.spectral(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: PremiumTokens.textMuted,
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
      onTap: () {}, // Handled by animatedIcon onTap
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PremiumTokens.borderSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PremiumTokens.borderMedium,
          ),
        ),
        child: PremiumUI.animatedIcon(
          folder: 'Chevron-left',
          fileName: 'chevron-left.json',
          size: 20,
          color: PremiumTokens.textPrimary,
          onTap: () => Navigator.pop(context),
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
              color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: PremiumTokens.activeAccent),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: PremiumTokens.activeAccent,
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
        gradientColors ?? [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)];

    return Container(
      decoration: BoxDecoration(
        color: PremiumTokens.borderSubtle,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: PremiumTokens.borderSubtle,
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
              child: Icon(icon, color: PremiumTokens.onAccent, size: 20),
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
                      color: PremiumTokens.textMuted,
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
          color: value ? activeColor : PremiumTokens.textMuted.withValues(alpha: 0.3),
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: PremiumTokens.textPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.scaffoldBg.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
          color: PremiumTokens.borderSubtle,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: PremiumTokens.borderSubtle,
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
                  gradient: PremiumTokens.activeGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTokens.activeAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.language_circle,
                  color: PremiumTokens.textPrimary,
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
                        color: PremiumTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: PremiumTokens.activeAccent,
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
          color: PremiumTokens.sheetBgTop,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: PremiumTokens.borderMedium,
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
                      color: PremiumTokens.textMuted.withValues(alpha: 0.3),
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
                        gradient: PremiumTokens.activeGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Iconsax.global,
                        color: PremiumTokens.textPrimary,
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
                    color: PremiumTokens.textMuted,
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
                              ? PremiumTokens.activeAccent.withValues(alpha: 0.1)
                              : PremiumTokens.borderSubtle,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
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
                                    ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                                    : PremiumTokens.borderSubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                flagIcon,
                                size: 20,
                                color: isSelected
                                    ? PremiumTokens.activeAccent
                                    : PremiumTokens.textMuted,
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
                                          ? PremiumTokens.activeAccent
                                          : PremiumTokens.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    nativeName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: PremiumTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: PremiumTokens.activeAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.tick_circle,
                                  color: PremiumTokens.textPrimary,
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
        : gradientColors ?? [PremiumTokens.activeAccent, PremiumTokens.activeAccent.withValues(alpha: 0.8)];

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        PremiumUI.showNotification(
          context, 
          "Action: $title",
          icon: icon,
          color: isDestructive ? Colors.red : PremiumTokens.activeAccent,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTokens.borderSubtle,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.15)
                : PremiumTokens.borderSubtle,
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
                child: Icon(icon, color: PremiumTokens.onAccent, size: 20),
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
                        : PremiumTokens.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: isDestructive ? Colors.red : PremiumTokens.activeAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReaderThemeSelector(BuildContext context, AppLocalization l) {
    final currentTheme = ref.watch(readerThemeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumTokens.borderSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            context,
            ReadingTheme.divineFlow,
            "Divine",
            currentTheme == ReadingTheme.divineFlow,
            PremiumTokens.saffronGlow,
          ),
          const SizedBox(width: 8),
          _buildThemeOption(
            context,
            ReadingTheme.sacredParchment,
            "Parchment",
            currentTheme == ReadingTheme.sacredParchment,
            const Color(0xFF9E5622),
          ),
          const SizedBox(width: 8),
          _buildThemeOption(
            context,
            ReadingTheme.voidFocus,
            "Void",
            currentTheme == ReadingTheme.voidFocus,
            PremiumTokens.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ReadingTheme theme,
    String label,
    bool isSelected,
    Color accentColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(readerThemeProvider.notifier).state = theme;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor.withValues(alpha: 0.3) : PremiumTokens.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Icon(
                  isSelected ? Iconsax.tick_circle5 : Iconsax.stop,
                  size: 16,
                  color: isSelected ? accentColor : PremiumTokens.textHint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? accentColor : PremiumTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivineIconStatus(BuildContext context) {
    final japState = ref.watch(naamJapStateProvider);
    final totalMalas = japState.total ~/ 108;
    final todayMalas = japState.today ~/ 108;

    String levelName = "Starter";
    String nextUnlock = "Reach 21 Malas today for Radiant";
    IconData icon = Iconsax.star_1;
    Color color = PremiumTokens.textPrimary60;

    if (totalMalas >= 1008) {
      levelName = "Divine Level";
      nextUnlock = "Supreme Spiritual Focus attained";
      icon = Iconsax.crown;
      color = PremiumTokens.saffronGlow;
    } else if (totalMalas >= 108) {
      levelName = "Golden Level";
      nextUnlock = "${1008 - totalMalas} Malas left for Divine";
      icon = Iconsax.magicpen;
      color = Colors.amber;
    } else if (todayMalas >= 21) {
      levelName = "Radiant Level";
      nextUnlock = "${108 - totalMalas} Total Malas for Golden";
      icon = Iconsax.sun_1;
      color = PremiumTokens.activeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "App Icon: $levelName",
                  style: PremiumTokens.displayStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextUnlock,
                  style: PremiumTokens.sansStyle(
                    fontSize: 12,
                    color: PremiumTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR THEME PICKER — Beautiful palette selector
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildColorThemePicker(BuildContext context) {
    final currentTheme = ref.watch(colorThemeProvider);
    final currentPalette = AppColorThemes.getPalette(currentTheme);

    return PressableScale(
      onTap: () => _showColorThemeSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTokens.borderSubtle,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: currentPalette.accent.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [currentPalette.accent, currentPalette.accentDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: currentPalette.glow.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(Iconsax.colorfilter, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Color Theme",
                          style: PremiumTokens.displayStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentPalette.name,
                          style: PremiumTokens.sansStyle(
                            fontSize: 13,
                            color: currentPalette.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.arrow_right_3,
                      size: 18,
                      color: currentPalette.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini palette preview row
              Row(
                children: AppColorTheme.values.map((theme) {
                  final palette = AppColorThemes.getPalette(theme);
                  final isActive = theme == currentTheme;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(colorThemeProvider.notifier).setTheme(theme);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [palette.accent, palette.accentDark],
                          ),
                          borderRadius: BorderRadius.circular(isActive ? 10 : 6),
                          border: isActive ? Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2,
                          ) : null,
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: palette.glow.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ] : null,
                        ),
                        child: isActive
                            ? const Icon(Iconsax.tick_circle5, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorThemeSheet(BuildContext context) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final selected = ref.watch(colorThemeProvider);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PremiumTokens.sheetBgTop,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: PremiumTokens.borderMedium),
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
                          color: PremiumTokens.textMuted.withValues(alpha: 0.3),
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
                            gradient: PremiumTokens.activeGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Iconsax.colorfilter, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Color Theme",
                          style: PremiumTokens.displayStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose a color palette for your spiritual experience",
                      style: GoogleFonts.outfit(
                        color: PremiumTokens.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...AppColorTheme.values.map((theme) {
                      final palette = AppColorThemes.getPalette(theme);
                      final isSelected = theme == selected;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PressableScale(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(colorThemeProvider.notifier).setTheme(theme);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? palette.accent.withValues(alpha: 0.1)
                                  : PremiumTokens.borderSubtle,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? palette.accent.withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: palette.glow.withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        spreadRadius: -4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Gradient orb preview
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [palette.accentLight, palette.accentDark],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: palette.glow.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: -4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      palette.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        palette.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 16,
                                          color: isSelected
                                              ? palette.accent
                                              : PremiumTokens.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Mini color swatches
                                      Row(
                                        children: [
                                          _swatch(palette.accent),
                                          _swatch(palette.accentLight),
                                          _swatch(palette.accentDark),
                                          _swatch(palette.glow.withValues(alpha: 0.6)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: palette.accent,
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
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOOD THEME PICKER — Immersive atmosphere selector
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMoodThemePicker(BuildContext context) {
    final currentMood = ref.watch(moodThemeProvider);
    final currentPalette = AppMoodThemes.getPalette(currentMood);

    return PressableScale(
      onTap: () => _showMoodThemeSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTokens.borderSubtle,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
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
                    colors: currentPalette.backgroundGradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PremiumTokens.borderMedium),
                ),
                child: Text(currentPalette.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mood Theme",
                      style: PremiumTokens.displayStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPalette.name,
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        color: PremiumTokens.activeAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: PremiumTokens.activeAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final selected = ref.watch(moodThemeProvider);
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PremiumTokens.sheetBgTop,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: PremiumTokens.borderMedium),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: PremiumTokens.textMuted.withValues(alpha: 0.3),
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
                          gradient: PremiumTokens.activeGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Iconsax.cloud, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Mood Theme",
                        style: PremiumTokens.displayStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose an atmosphere for your spiritual space",
                    style: GoogleFonts.outfit(
                      color: PremiumTokens.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final double screenWidth = MediaQuery.of(context).size.width;
                        final int crossAxisCount = screenWidth < 480 ? 1 : 2;
                        final double childAspectRatio = screenWidth < 480 
                            ? (screenWidth - 48) / 84
                            : 1.3;

                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: AppMoodTheme.values.length,
                          itemBuilder: (context, index) {
                            final mood = AppMoodTheme.values[index];
                            final palette = AppMoodThemes.getPalette(mood);
                            final isSelected = mood == selected;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                ref.read(moodThemeProvider.notifier).setMood(mood);
                                ref.read(colorThemeProvider.notifier).setTheme(palette.defaultAccent);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? PremiumTokens.activeAccent.withValues(alpha: 0.1)
                                      : PremiumTokens.borderSubtle,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? PremiumTokens.activeAccent.withValues(alpha: 0.5)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                                            blurRadius: 20,
                                            spreadRadius: -4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: crossAxisCount == 1
                                      ? Row(
                                          children: [
                                            Text(palette.emoji, style: const TextStyle(fontSize: 24)),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    palette.name,
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                      fontSize: 15,
                                                      color: isSelected
                                                          ? PremiumTokens.activeAccent
                                                          : PremiumTokens.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    palette.nameHi,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: PremiumTokens.textMuted,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(3),
                                                    child: SizedBox(
                                                      height: 4,
                                                      child: Row(
                                                        children: palette.backgroundGradient.map((c) {
                                                          return Expanded(child: Container(color: c));
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            if (isSelected)
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: PremiumTokens.activeAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Iconsax.tick_circle,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(palette.emoji, style: const TextStyle(fontSize: 22)),
                                                if (isSelected)
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: PremiumTokens.activeAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Iconsax.tick_circle,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Text(
                                              palette.name,
                                              style: GoogleFonts.outfit(
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                fontSize: 14,
                                                color: isSelected
                                                    ? PremiumTokens.activeAccent
                                                    : PremiumTokens.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              palette.nameHi,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: PremiumTokens.textMuted,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: SizedBox(
                                                height: 6,
                                                child: Row(
                                                  children: palette.backgroundGradient.map((c) {
                                                    return Expanded(child: Container(color: c));
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
    );
  }
}
