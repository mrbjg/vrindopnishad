import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/audio_provider.dart';
import '../core/stats_provider.dart';
import 'global_player_screen.dart';
import '../core/favorites_provider.dart';
import '../widgets/share_content_widget.dart';
import '../core/localization.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import '../core/providers/reading_providers.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';



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
  double _fontSize = 20.0; // Increased base size
  final ScrollController _scrollController = ScrollController();
  bool _showCompactHeader = false;
  bool _showAudioPlayer = false;
  ReadingTheme _currentTheme = ReadingTheme.divineFlow;
  final ValueNotifier<double> _sanskritScale = ValueNotifier<double>(1.0);
  final ValueNotifier<double> _hindiScale = ValueNotifier<double>(1.0);
  final ValueNotifier<double> _englishScale = ValueNotifier<double>(1.0);
  final ValueNotifier<double> _commentaryScale = ValueNotifier<double>(1.0);
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize theme from universal preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentTheme = ref.read(readerThemeProvider);
        });
      }
    });

    // Log reading activity to capture this session in history
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted) {
        // Robust content resolution for history tracking
        final allContent = ref.read(sacredContentProvider);
        final resolvedContent = widget.content ?? 
          (widget.title != null ? allContent.where((c) => c.title == widget.title).firstOrNull : null);
        
        final logTitle = resolvedContent?.title ?? widget.title ?? 'Sacred Text';
        final logCategory = resolvedContent?.category ?? widget.category ?? 'Divine';
        final logId = resolvedContent?.id ?? logTitle;

        try {
          await ref.read(userStatsProvider.notifier).recordReading(
            context,
            logId,
            title: logTitle,
            category: logCategory,
          );
        } catch (e) {
             debugPrint("History Sync Error: $e");
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                   content: Text(
                     "VAANI SYNC ERROR: $e",
                     style: const TextStyle(color: Colors.white, fontSize: 12),
                   ),
                   behavior: SnackBarBehavior.floating,
                   duration: const Duration(seconds: 5),
                 ),
               );
             }
        }
      }
    });
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
    _sanskritScale.dispose();
    _hindiScale.dispose();
    _englishScale.dispose();
    _commentaryScale.dispose();
    super.dispose();
  }

  Future<void> _toggleFavoriteResolved(SacredContent? content) async {
    if (content == null) return;
    HapticFeedback.lightImpact();
    try {
      await ref
          .read(favoritesProvider.notifier)
          .toggleFavorite(content.id);
    } catch (e) {
      if (mounted) {
        PremiumUI.showNotification(
          context, 
          'Error: $e',
          icon: Iconsax.info_circle,
          color: Colors.redAccent,
        );
      }
    }
  }

  void _shareContentResolved(SacredContent? content) {
    if (content == null) return;
    HapticFeedback.lightImpact();
    ShareContentHelper.shareAsImage(context, content);
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final isFocusMode = ref.watch(focusModeProvider);
    final l = AppLocalization(currentLanguage);

    final allContent = ref.watch(sacredContentProvider);
    final content = widget.content ?? 
      (widget.title != null ? allContent.cast<SacredContent?>().firstWhere((c) => c?.title == widget.title, orElse: () => null) : null);

    final displayTitle =
        (content?.title ?? widget.title ?? "Sacred Text")
            .replaceAll('\n', ', ');
    final displayCategory =
        content?.category ?? widget.category ?? "Wisdom";

    // If no content is found and no title/category provided, we are effectively in a dead state
    if (content == null && widget.title == null && widget.content == null) {
      return Scaffold(
        backgroundColor: PremiumTokens.voidBlack,
        body: Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue)),
      );
    }

    final themeData = _getThemeData();

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      body: Stack(
        children: [
          if (_currentTheme == ReadingTheme.divineFlow)
            Positioned.fill(
              child: RepaintBoundary(
                child: PremiumUI.masterBackground(index: 3),
              ),
            ),
          
          if (_currentTheme == ReadingTheme.sacredParchment)
             Positioned.fill(
               child: Container(
                 decoration: BoxDecoration(
                   color: const Color(0xFFF4ECD8),
                   image: DecorationImage(
                     image: const CachedNetworkImageProvider('https://www.transparenttextures.com/patterns/paper-fibers.png'),
                     opacity: 0.05,
                     repeat: ImageRepeat.repeat,
                   ),
                 ),
               ),
             ),
          
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
              ),

              if (!isFocusMode) 
                SliverToBoxAdapter(
                  child: PremiumUI.focusContainer(
                    isFocusMode: isFocusMode,
                    child: _buildPremiumHero(displayTitle, displayCategory, l, themeData),
                  ),
                ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, isFocusMode ? 100 : 32, 20, 200),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit Card - Always visible but styled for focus
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: RepaintBoundary(
                          child: GestureDetector(
                            onScaleStart: (details) => _baseScale = _sanskritScale.value,
                            onScaleUpdate: (details) => _sanskritScale.value = (_baseScale * details.scale).clamp(0.5, 3.0),
                            child: ValueListenableBuilder<double>(
                              valueListenable: _sanskritScale,
                              builder: (context, scale, child) {
                                return _buildPremiumSanskritCard(content, l, isFocusMode, themeData, scale: scale);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    PremiumUI.sacredDivider(color: themeData.textColor.withValues(alpha: isFocusMode ? 0.3 : 0.05)),
                    const SizedBox(height: 32),

                    // Meaning Sections - Hidden/Simplified in Focus Mode
                    PremiumUI.focusContainer(
                      isFocusMode: isFocusMode,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                        child: RepaintBoundary(
                          child: Column(
                            children: [
                                GestureDetector(
                                  onScaleStart: (details) => _baseScale = _hindiScale.value,
                                  onScaleUpdate: (details) => _hindiScale.value = (_baseScale * details.scale).clamp(0.5, 3.0),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: _hindiScale,
                                    builder: (context, scale, child) {
                                      return _buildPremiumContentSection(
                                        title: l.translate('hindi_meaning'),
                                        content: content?.hindiMeaning ?? "",
                                        icon: Iconsax.heart,
                                        accentColor: themeData.accentColor,
                                        themeData: themeData,
                                        currentScale: scale,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),

                                GestureDetector(
                                  onScaleStart: (details) => _baseScale = _englishScale.value,
                                  onScaleUpdate: (details) => _englishScale.value = (_baseScale * details.scale).clamp(0.5, 3.0),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: _englishScale,
                                    builder: (context, scale, child) {
                                      return _buildPremiumContentSection(
                                        title: l.translate('english_translation'),
                                        content: content?.translation ?? "",
                                        icon: Iconsax.language_circle,
                                        accentColor: themeData.secondaryAccent,
                                        themeData: themeData,
                                        currentScale: scale,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Commentary remains but simplified
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: RepaintBoundary(
                          child: GestureDetector(
                            onScaleStart: (details) => _baseScale = _commentaryScale.value,
                            onScaleUpdate: (details) => _commentaryScale.value = (_baseScale * details.scale).clamp(0.5, 3.0),
                            child: ValueListenableBuilder<double>(
                              valueListenable: _commentaryScale,
                              builder: (context, scale, child) {
                                return _buildPremiumContentSection(
                                  title: l.translate('commentary'),
                                  content: content?.commentary ?? "",
                                  icon: Iconsax.lamp_charge,
                                  accentColor: PremiumTokens.saffronGlow,
                                  isFocusMode: isFocusMode,
                                  themeData: themeData,
                                  currentScale: scale,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    PremiumUI.focusContainer(
                      isFocusMode: isFocusMode,
                      child: Center(child: _buildPremiumFontControls(themeData)),
                    ),
                    
                    const SizedBox(height: 48),
                    RepaintBoundary(
                      child: Center(
                        child: AppTheme.lowPerformanceMode 
                          ? Text("ॐ", style: GoogleFonts.spectral(fontSize: 48, color: themeData.textColor.withValues(alpha: 0.2)))
                          : Text("ॐ", style: GoogleFonts.spectral(fontSize: 48, color: themeData.textColor))
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

          // Floating Header - Fades away in focus mode unless at the very top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: 400.ms,
              opacity: isFocusMode ? (_scrollController.hasClients && _scrollController.offset < 50 ? 1.0 : 0.0) : 1.0,
              child: _buildPremiumHeader(content, displayTitle, isFocusMode, themeData),
            ),
          ),

          // Audio Toggle - Fades in Focus Mode
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: isFocusMode 
              ? const SizedBox.shrink() 
              : PremiumUI.focusContainer(
                  isFocusMode: isFocusMode,
                  child: AnimatedSwitcher(
                    duration: 300.ms,
                    child: _showAudioPlayer
                        ? _buildPremiumAudioPlayer(content)
                        : _buildAudioFloatingToggle(),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(String title, String category, AppLocalization l, _ReadingThemeData themeData) {
    // Try to localize category if it matches a key
    final localizedCategory = l.translate(category.toLowerCase());
    final displayCategory = localizedCategory != category.toLowerCase() ? localizedCategory : category;
    final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(displayCategory);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, PremiumTokens.saffronGlow.withValues(alpha: 0.5)]))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  displayCategory.toUpperCase(),
                  style: GoogleFonts.manrope(
                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: isHindi ? 0.5 : 3.0,
                  ),
                ),
              ),
              Container(width: 20, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [PremiumTokens.saffronGlow.withValues(alpha: 0.5), Colors.transparent]))),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(SacredContent? content, String title, bool isFocusMode, _ReadingThemeData themeData) {
    return Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: (_showCompactHeader && !isFocusMode) 
            ? themeData.backgroundColor.withValues(alpha: 0.85) 
            : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: (_showCompactHeader && !isFocusMode) 
                ? themeData.textColor.withValues(alpha: 0.1) 
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
              isToggled: false,
              isAnimated: true,
              animFolder: 'Chevron-left',
              animFile: 'chevron-left.json',
              themeData: themeData,
            ),
            SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: (_showCompactHeader && !isFocusMode) ? 1.0 : 0.0,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(color: themeData.textColor, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Reading Settings
             _buildHeaderCircleButton(
              Iconsax.setting_2, 
              () => _showReadingSettings(context),
              isActive: false,
              isAnimated: false, // Standard icon to fix "Un ab" artifact
              themeData: themeData,
            ),
            const SizedBox(width: 8),
            // Focus Mode Toggle
            _buildHeaderCircleButton(
              null,
              () {
                HapticFeedback.mediumImpact();
                ref.read(focusModeProvider.notifier).state = !isFocusMode;
              },
              isActive: isFocusMode,
              isToggled: isFocusMode,
              isAnimated: true,
              resetAfterPlay: false,
              animFolder: 'Visibility V2',
              animFile: 'visibilityV2.json',
              themeData: themeData,
            ),
            const SizedBox(width: 8),
            PremiumUI.focusContainer(
              isFocusMode: isFocusMode,
              child: Row(mainAxisSize: MainAxisSize.min,
                children: [
                   _buildHeaderCircleButton(
                    null,
                    () => _toggleFavoriteResolved(content),
                    isToggled: content != null && ref.watch(isFavoriteProvider(content.id)),
                    isAnimated: true,
                    resetAfterPlay: false,
                    animFolder: 'Heart',
                    animFile: 'heart.json',
                    themeData: themeData,
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderCircleButton(
                    null, 
                    () => _shareContentResolved(content),
                    isCustomSvg: true,
                    svgFile: 'iconsax-ai-send-message-m26q6m1j-.svg',
                    themeData: themeData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildHeaderCircleButton(
    IconData? icon, 
    VoidCallback onTap, {
    bool isActive = false,
    bool isAnimated = false,
    bool isToggled = false,
    String? animFolder,
    String? animFile,
    bool isCustomSvg = false,
    String? svgFile,
    bool resetAfterPlay = true,
    required _ReadingThemeData themeData,
  }) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      opacity: themeData.glassOpacity * 1.5,
      child: isAnimated 
        ? PremiumUI.animatedIcon(
            folder: animFolder!, 
            fileName: animFile!, 
            size: 20, 
            color: (isActive || isToggled) ? themeData.accentColor : themeData.textColor,
            isToggled: isToggled,
            resetAfterPlay: resetAfterPlay,
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
                  color: (isActive || isToggled) ? themeData.accentColor : themeData.textColor,
                )
              : Icon(icon, color: (isActive || isToggled) ? themeData.accentColor : themeData.textColor, size: 20),
          ),
    );
  }

  Widget _buildPremiumSanskritCard(SacredContent? content, AppLocalization l, bool isFocusMode, _ReadingThemeData themeData, {double scale = 1.0}) {
    final text = content?.sanskritText ?? "";
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: 500.ms,
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(isFocusMode ? 32 : 28),
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: themeData.textColor.withValues(alpha: isFocusMode ? 0.1 : 0.05),
            width: 0.5,
          ),
          boxShadow: isFocusMode ? [
            BoxShadow(
              color: themeData.accentColor.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 10,
            )
          ] : [],
        ),
        child: Column(
          children: [
            if (!isFocusMode)
              PremiumUI.focusContainer(
                isFocusMode: isFocusMode,
                child: Builder(
                  builder: (context) {
                    final isHindiLabel = RegExp(r'[\u0900-\u097F]').hasMatch(l.translate('mantra_sloka_label'));
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeData.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l.translate('mantra_sloka_label').toUpperCase(),
                            style: GoogleFonts.manrope(
                              color: themeData.accentColor, 
                              fontSize: 10, 
                              fontWeight: FontWeight.w900, 
                              letterSpacing: isHindiLabel ? 0.5 : 2.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (!isFocusMode) const SizedBox(height: 24),
            SelectableText(
              _formatSacredText(text),
              textAlign: TextAlign.center,
              style: PremiumTokens.lailaStyle(
                fontSize: (_fontSize + (isFocusMode ? 10 : 6)) * scale,
                color: themeData.textColor.withValues(alpha: 0.95),
                fontWeight: FontWeight.bold,
              ).copyWith(
                height: 1.6,
                shadows: themeData.showTextShadows ? [
                  Shadow(
                    color: themeData.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ] : [],
              ),
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
    required _ReadingThemeData themeData,
    bool isFocusMode = false,
    double currentScale = 1.0,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: Container( // Changed from glassCard to a simpler container for borderless feel
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: isFocusMode ? 36 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centered for better flow
          children: [
            if (!isFocusMode)
              PremiumUI.focusContainer(
                isFocusMode: isFocusMode,
                child: Column(
                  children: [
                    Icon(icon, color: accentColor.withValues(alpha: 0.4), size: 16),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(title);
                        return Text(
                          title.toUpperCase(),
                          style: GoogleFonts.manrope(
                            color: accentColor.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: isHindi ? 0.5 : 2.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 40,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, accentColor.withValues(alpha: 0.2), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isFocusMode) const SizedBox(height: 24),
            Text(
              _formatSacredText(content),
              textAlign: TextAlign.center, // Centered for reading focus
              style: PremiumTokens.soulStyle( // Use Newsreader for body
                fontSize: (isFocusMode ? _fontSize + 3 : _fontSize) * currentScale,
                color: themeData.textColor.withValues(alpha: isFocusMode ? 0.95 : 0.85),
                fontWeight: FontWeight.normal,
              ).copyWith(
                height: themeData.lineHeight,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFontControls(_ReadingThemeData themeData) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.text, color: themeData.textColor.withValues(alpha: 0.24), size: 16),
          const SizedBox(width: 16),
          _buildFontToolButton(Iconsax.minus, () {
            if (_fontSize > 14) setState(() => _fontSize -= 2);
          }, themeData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("${_fontSize.toInt()}", style: GoogleFonts.outfit(color: themeData.textColor, fontWeight: FontWeight.bold)),
          ),
          _buildFontToolButton(Iconsax.add, () {
            if (_fontSize < 32) setState(() => _fontSize += 2);
          }, themeData),
        ],
      ),
    );
  }

  Widget _buildFontToolButton(IconData icon, VoidCallback onTap, _ReadingThemeData themeData) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: themeData.textColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: themeData.textColor, size: 14),
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
            border: Border.all(color: PremiumTokens.saffronGlow.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: Icon(Iconsax.music5, color: PremiumTokens.saffronGlow, size: 24), // Filled music icon for 'Soul Orb'
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildPremiumAudioPlayer(SacredContent? content) {
    return Container( // Changed from glassCard to a more organic, borderless design
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getThemeData().backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final audioState = ref.watch(audioProvider);
          final isPlaying = audioState.isPlaying;
          final isLoading = audioState.isLoading;
          final themeData = _getThemeData();
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
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
                                color: themeData.textColor.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              content?.title ?? "Sacred Verse",
                              style: GoogleFonts.outfit(
                                color: themeData.textColor,
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
                ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => GlobalPlayerScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeData.textColor.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.maximize_4, color: themeData.textColor, size: 16),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showAudioPlayer = false),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeData.textColor.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.arrow_down_1, color: themeData.textColor, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Slider
              _buildPremiumProgressBar(audioState, themeData),
              const SizedBox(height: 8),
              _buildPremiumAudioTime(audioState, themeData),
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
                      if (content != null) {
                        ref.read(audioProvider.notifier).play(content);
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
                            color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
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
    final themeData = _getThemeData();
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: themeData.textColor.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: themeData.textColor.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: themeData.textColor.withValues(alpha: 0.7), size: iconSize),
      ),
    );
  }

  _ReadingThemeData _getThemeData() {
    switch (_currentTheme) {
      case ReadingTheme.divineFlow:
        return _ReadingThemeData(
          backgroundColor: Colors.black,
          textColor: Colors.white,
          cardColor: Colors.white.withValues(alpha: 0.08),
          accentColor: PremiumTokens.saffronGlow,
          secondaryAccent: Colors.blueAccent,
          lineHeight: 1.8,
          glassOpacity: 0.08,
          showTextShadows: true,
        );
      case ReadingTheme.sacredParchment:
        return _ReadingThemeData(
          backgroundColor: const Color(0xFFF4ECD8),
          textColor: const Color(0xFF2D2417),
          cardColor: const Color(0xFFE8DCC4), // Slightly darker for better card identification
          accentColor: const Color(0xFF9E5622), // Richer sienna
          secondaryAccent: const Color(0xFF5D7A52), // Muted forest green
          lineHeight: 2.0,
          glassOpacity: 0.05,
          showTextShadows: false,
        );
      case ReadingTheme.voidFocus:
        return _ReadingThemeData(
          backgroundColor: const Color(0xFF0A0A0A),
          textColor: const Color(0xFFE0E0E0),
          cardColor: const Color(0xFF1A1A1A),
          accentColor: const Color(0xFF8A2BE2), // Amethyst purple
          secondaryAccent: const Color(0xFF00CED1), // Dark turquoise
          lineHeight: 1.7,
          glassOpacity: 0.1,
          showTextShadows: false,
        );
    }
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final themeData = _getThemeData();
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: themeData.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: themeData.textColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("READING SETTINGS", 
                  style: GoogleFonts.manrope(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: themeData.textColor.withValues(alpha: 0.5), 
                    letterSpacing: 2
                  )
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Font Size", style: GoogleFonts.spectral(color: themeData.textColor, fontSize: 16)),
                    // Pass the modal state setter if needed, but since Font Controls use parent setState,
                    // we need to make sure they also trigger this modal rebuild.
                    PremiumUI.glassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      borderRadius: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.text, color: themeData.textColor.withValues(alpha: 0.24), size: 16),
                          const SizedBox(width: 16),
                          _buildFontToolButton(Iconsax.minus, () {
                            if (_fontSize > 14) {
                              setState(() => _fontSize -= 2);
                              setModalState(() {});
                            }
                          }, themeData),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("${_fontSize.toInt()}", style: GoogleFonts.outfit(color: themeData.textColor, fontWeight: FontWeight.bold)),
                          ),
                          _buildFontToolButton(Iconsax.add, () {
                            if (_fontSize < 32) {
                              setState(() => _fontSize += 2);
                              setModalState(() {});
                            }
                          }, themeData),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text("Divine Backdrop", style: GoogleFonts.spectral(color: themeData.textColor, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ReadingTheme.values.map((theme) {
                    final isSelected = _currentTheme == theme;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _currentTheme = theme);
                        setModalState(() {});
                        // Update universal preference
                        ref.read(readerThemeProvider.notifier).state = theme;
                      },
                      child: AnimatedContainer(
                        duration: 300.ms,
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? PremiumTokens.nebulaBlue : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          theme.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 10, 
                            fontWeight: FontWeight.w800, 
                            color: isSelected ? Colors.white : themeData.textColor.withValues(alpha: 0.6)
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumProgressBar(AudioState audioState, _ReadingThemeData themeData) {
    final duration = audioState.duration;
    final position = audioState.position;
    final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: themeData.accentColor,
        inactiveTrackColor: themeData.textColor.withValues(alpha: 0.1),
        thumbColor: themeData.textColor,
        overlayColor: themeData.accentColor.withValues(alpha: 0.2),
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

  Widget _buildPremiumAudioTime(AudioState audioState, _ReadingThemeData themeData) {
    final duration = audioState.duration;
    final position = audioState.position;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatDuration(position), style: GoogleFonts.outfit(color: themeData.textColor.withValues(alpha: 0.38), fontSize: 10)),
        Text(_formatDuration(duration), style: GoogleFonts.outfit(color: themeData.textColor.withValues(alpha: 0.38), fontSize: 10)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  String _formatSacredText(String text) {
    if (text.isEmpty) return "";
    // Split by । or , and join with newline for poetic flow
    // We add newline after punctuation and then clean up double newlines/spaces
    return text
        .replaceAll('।', '।\n')
        .replaceAll(', ', ',\n')
        .replaceAll(',', ',\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');
  }
}

class _ReadingThemeData {
  final Color backgroundColor;
  final Color textColor;
  final Color cardColor;
  final Color accentColor;
  final Color secondaryAccent;
  final double lineHeight;
  final double glassOpacity;
  final bool showTextShadows;

  _ReadingThemeData({
    required this.backgroundColor,
    required this.textColor,
    required this.cardColor,
    required this.accentColor,
    required this.secondaryAccent,
    required this.lineHeight,
    required this.glassOpacity,
    required this.showTextShadows,
  });
}
