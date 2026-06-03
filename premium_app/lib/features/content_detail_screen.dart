import 'dart:ui';
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
import '../widgets/divine_ruler_picker.dart';
import '../core/localization.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import '../core/providers/reading_providers.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/personalized_feed_provider.dart';
import '../widgets/animated_effects.dart';
import 'saint_detail_screen.dart';
import 'book_detail_screen.dart';
import 'raga_detail_screen.dart';

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
  double _fontSize = 20.0; // Increased base size
  double _currentScrollOffset = 0.0;
  bool _showCompactHeader = false;
  bool _showAudioPlayer = false;
  ReadingTheme _currentTheme = ReadingTheme.divineFlow;
  // Text scale ValueNotifiers removed to prevent drag gesture blocking scroll/swipe
  double _lastScrollOffset = 0.0;
  bool _isScrollingUp = true;
  late DateTime _startTime;
  bool _hasLoggedDwellTime = false;

  late PageController _pageController;
  List<SacredContent> _siblingContents = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Resolve initial content and siblings
    final allContent = ref.read(sacredContentProvider);
    final resolvedContent = widget.content ??
        (widget.title != null ? allContent.where((c) => c.title == widget.title).firstOrNull : null);

    if (resolvedContent != null) {
      final categoryClean = resolvedContent.category;
      _siblingContents = allContent.where((c) => c.category == categoryClean).toList();
      _currentIndex = _siblingContents.indexWhere((c) => c.id == resolvedContent.id);
      if (_currentIndex == -1) {
        _siblingContents = [resolvedContent];
        _currentIndex = 0;
      }
    } else {
      _siblingContents = [];
      _currentIndex = 0;
    }

    _pageController = PageController(initialPage: _currentIndex);
    
    // Initialize theme from universal preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentTheme = ref.read(readerThemeProvider);
        });
      }
    });

    // Log reading activity for initial item
    _logReadingActivity(_currentIndex);
  }

  void _onScrollWithOffset(double offset) {
    _currentScrollOffset = offset;
    final showCompact = offset > 100;
    
    // Smart reveal logic (Threshold: 20px)
    if ((offset - _lastScrollOffset).abs() > 20) {
      final isScrollingUp = offset < _lastScrollOffset;
      if (isScrollingUp != _isScrollingUp) {
        setState(() => _isScrollingUp = isScrollingUp);
      }
      _lastScrollOffset = offset;
    }

    // Always show at the top/bottom edges
    if (offset < 50 && !_isScrollingUp) {
      setState(() => _isScrollingUp = true);
    }

    if (showCompact != _showCompactHeader) {
      setState(() => _showCompactHeader = showCompact);
    }
  }

  // Audio is now managed globally via audioProvider

  void _logReadingActivity(int index) {
    if (_siblingContents.isEmpty || index >= _siblingContents.length) return;
    final resolvedContent = _siblingContents[index];
    final logTitle = resolvedContent.title;
    final logCategory = resolvedContent.category;
    final logId = resolvedContent.id;

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted && _currentIndex == index) {
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
                backgroundColor: PremiumTokens.activeAccent.withValues(alpha: 0.8),
                content: Text(
                  "VAANI SYNC ERROR: $e",
                  style: TextStyle(color: PremiumTokens.textPrimary, fontSize: 12),
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

  void _logDwellTimeForCurrentIndex() {
    if (!_hasLoggedDwellTime && _siblingContents.isNotEmpty && _currentIndex < _siblingContents.length) {
      _hasLoggedDwellTime = true;
      final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
      final resolvedContent = _siblingContents[_currentIndex];
      ref.read(dwellTimeProvider.notifier).logDwellTime(resolvedContent.id, durationSeconds);
    }
  }

  void _onPageChanged(int index) {
    HapticFeedback.lightImpact();
    
    // Log dwell time for the page we are leaving
    _logDwellTimeForCurrentIndex();
    
    setState(() {
      _currentIndex = index;
      _currentScrollOffset = 0.0;
      _lastScrollOffset = 0.0;
      _isScrollingUp = true;
      _showCompactHeader = false;
      _startTime = DateTime.now();
      _hasLoggedDwellTime = false;
    });

    // Log reading activity for the new page
    _logReadingActivity(index);
  }

  @override
  void deactivate() {
    _logDwellTimeForCurrentIndex();
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Scale disposes removed
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
          color: PremiumTokens.activeAccent,
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
    final content = _siblingContents.isNotEmpty && _currentIndex < _siblingContents.length
        ? _siblingContents[_currentIndex]
        : (widget.content ?? (widget.title != null ? allContent.cast<SacredContent?>().firstWhere((c) => c?.title == widget.title, orElse: () => null) : null));

    if (content == null) {
      return Scaffold(
        backgroundColor: PremiumTokens.scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
      );
    }

    final displayTitle = content.title.replaceAll('\n', ', ');
    final themeData = _getThemeData();

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      body: Stack(
        children: [
          if (_currentTheme == ReadingTheme.divineFlow)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(focusModeProvider.notifier).state = !isFocusMode;
                },
                child: RepaintBoundary(
                  child: PremiumUI.masterBackground(index: 3, context: context),
                ),
              ),
            ),
          
          if (_currentTheme == ReadingTheme.sacredParchment)
             Positioned.fill(
               child: Container(
                 decoration: const BoxDecoration(
                   color: Color(0xFFF4ECD8),
                   image: DecorationImage(
                     image: CachedNetworkImageProvider('https://www.transparenttextures.com/patterns/paper-fibers.png'),
                     opacity: 0.05,
                     repeat: ImageRepeat.repeat,
                   ),
                 ),
               ),
             ),
          
          // Dismiss focus mode when tapping empty background area
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isFocusMode,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (isFocusMode) {
                    HapticFeedback.lightImpact();
                    ref.read(focusModeProvider.notifier).state = false;
                  }
                },
              ),
            ),
          ),

          // ── Scroll Content with Swipe Page Transitions ───────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _siblingContents.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, pageIndex) {
                final pageContent = _siblingContents[pageIndex];
                final pageDisplayTitle = pageContent.title.replaceAll('\n', ', ');
                final pageDisplayCategory = pageContent.category;
                
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (pageIndex == _currentIndex && 
                        notification is ScrollUpdateNotification && 
                        notification.metrics.axis == Axis.vertical) {
                      _onScrollWithOffset(notification.metrics.pixels);
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    key: PageStorageKey<String>('content_scroll_${pageContent.id}'),
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
                    ),

                    if (!isFocusMode) 
                      SliverToBoxAdapter(
                        child: PremiumUI.focusContainer(
                          isFocusMode: isFocusMode,
                          child: _buildPremiumHero(pageContent, pageDisplayTitle, pageDisplayCategory, l, themeData),
                        ),
                      ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, isFocusMode ? 64 : 24, 16, 110),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Sanskrit Card - Only visible if sanskritText is not empty
                          if (pageContent.sanskritText.trim().isNotEmpty) ...[
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: RepaintBoundary(
                                  child: _buildPremiumSanskritCard(pageContent, l, isFocusMode, themeData),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            PremiumUI.sacredDivider(color: themeData.textColor.withValues(alpha: isFocusMode ? 0.3 : 0.05)),
                            const SizedBox(height: 20),
                          ],

                          // Meaning Sections - Hidden/Simplified in Focus Mode
                          PremiumUI.focusContainer(
                            isFocusMode: isFocusMode,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: RepaintBoundary(
                                  child: Column(
                                    children: [
                                      _buildPremiumContentSection(
                                        title: l.translate('hindi_meaning'),
                                        content: pageContent.hindiMeaning,
                                        icon: Iconsax.heart,
                                        accentColor: themeData.accentColor,
                                        themeData: themeData,
                                      ),
                                      const SizedBox(height: 16),

                                      _buildPremiumContentSection(
                                        title: l.translate('english_translation'),
                                        content: pageContent.translation,
                                        icon: Iconsax.language_circle,
                                        accentColor: themeData.secondaryAccent,
                                        themeData: themeData,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Commentary remains but simplified
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: RepaintBoundary(
                                child: _buildPremiumContentSection(
                                  title: l.translate('commentary'),
                                  content: pageContent.commentary,
                                  icon: Iconsax.lamp_charge,
                                  accentColor: PremiumTokens.saffronGlow,
                                  isFocusMode: isFocusMode,
                                  themeData: themeData,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          PremiumUI.sacredDivider(color: themeData.textColor.withValues(alpha: 0.1)),
                          const SizedBox(height: 16),
                          
                          // Tags
                          Center(
                            child: Text(
                              "THEMATIC RESONANCE",
                              style: GoogleFonts.manrope(
                                color: themeData.textColor.withValues(alpha: 0.2), 
                                fontSize: 8, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 2.0
                              )
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ...(pageContent.contentTags).map((tag) => _buildTagChip("#$tag", themeData.accentColor.withValues(alpha: 0.05))),
                                ...(pageContent.audioTags).map((tag) => _buildTagChip(tag, PremiumTokens.activeAccent.withValues(alpha: 0.1), emoji: "🎧")),
                                ...(pageContent.videoTags).map((tag) => _buildTagChip(tag, PremiumTokens.activeAccent.withValues(alpha: 0.1), emoji: "🎬")),
                                ...(pageContent.imageTags).map((tag) => _buildTagChip(tag, PremiumTokens.saffronGlow.withValues(alpha: 0.1), emoji: "🖼️")),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // "More Like This" Shelf
                          _buildMoreLikeThisShelf(pageContent, themeData),

                          const SizedBox(height: 64),
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
                           const SizedBox(height: 32),
                        ]), // SliverChildListDelegate
                      ), // SliverList
                    ), // SliverPadding
                  ], // slivers
                ),
              );
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: 500.ms,
              offset: (isFocusMode && !_isScrollingUp && _currentScrollOffset > 50) 
                 ? const Offset(0, -1) 
                 : const Offset(0, 0),
              child: AnimatedOpacity(
                duration: 400.ms,
                opacity: (isFocusMode && !_isScrollingUp && _currentScrollOffset > 50) 
                   ? 0.0 
                   : 1.0,
                child: _buildPremiumHeader(content, displayTitle, isFocusMode, themeData),
              ),
            ),
          ),

          // Audio Toggle - Fades in Focus Mode unless scrolling up
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: (isFocusMode && !_isScrollingUp) 
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

  Widget _buildPremiumHero(SacredContent? content, String title, String category, AppLocalization l, _ReadingThemeData themeData) {
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
              Container(width: 20, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, themeData.accentColor.withValues(alpha: 0.5)]))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  displayCategory.toUpperCase(),
                  style: GoogleFonts.manrope(
                                                    color: themeData.accentColor.withValues(alpha: 0.8),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: isHindi ? 0.5 : 3.0,
                                                  ),
                ),
              ),
              Container(width: 20, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [themeData.accentColor.withValues(alpha: 0.5), Colors.transparent]))),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final match = ref.watch(matchPercentageProvider(content));
                return PremiumUI.resonanceBadge("$match% MATCH", fontSize: 8);
              },
            ),
          ],
          const SizedBox(height: 16),
          if (title.isNotEmpty)
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spectral(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
                height: 1.2,
              ),
            ),
          
          if (content != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (content.author != null && content.author!.isNotEmpty)
                  _buildRelationChip(
                    context: context,
                    label: content.author!,
                    icon: Iconsax.user,
                    color: PremiumTokens.saffronGlow,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SaintDetailScreen(saintName: content.author!),
                        ),
                      );
                    },
                  ),
                if (content.book != null && content.book!.isNotEmpty)
                  _buildRelationChip(
                    context: context,
                    label: content.book!,
                    icon: Iconsax.book,
                    color: themeData.accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(bookName: content.book!),
                        ),
                      );
                    },
                  ),
                if (content.raga != null && content.raga!.isNotEmpty)
                  _buildRelationChip(
                    context: context,
                    label: content.raga!,
                    icon: Iconsax.music,
                    color: themeData.secondaryAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RagaDetailScreen(ragaName: content.raga!),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelationChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = PremiumTokens.isDark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.25 : 0.15),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? color : PremiumTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(SacredContent? content, String title, bool isFocusMode, _ReadingThemeData themeData) {
    final showCompact = _showCompactHeader && !isFocusMode;
    final isParchment = _currentTheme == ReadingTheme.sacredParchment;
    
    final Widget headerContent = Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: showCompact
          ? themeData.backgroundColor.withValues(alpha: isParchment ? 0.96 : 0.8) 
          : Colors.transparent,
        borderRadius: showCompact
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            )
          : BorderRadius.zero,
        boxShadow: showCompact
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isParchment ? 0.05 : 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
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
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedOpacity(
              duration: 200.ms,
              opacity: showCompact ? 1.0 : 0.0,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
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

    if (showCompact) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: headerContent,
        ),
      );
    }
    return headerContent;
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
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      scaleFactor: 0.90,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeData.textColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: themeData.textColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: isAnimated 
          ? PremiumUI.animatedIcon(
              folder: animFolder!, 
              fileName: animFile!, 
              size: 20, 
              color: (isActive || isToggled) ? themeData.accentColor : themeData.textColor,
              isToggled: isToggled,
              resetAfterPlay: resetAfterPlay,
              onTap: onTap,
            )
          : isCustomSvg
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
    if (text.trim().isEmpty) return const SizedBox.shrink();
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            l.translate('mantra_sloka_label').toUpperCase(),
                            style: GoogleFonts.manrope(
                              color: themeData.accentColor, 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
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
            Text(
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
                    Icon(icon, color: accentColor.withValues(alpha: 0.75), size: 16),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(title);
                        return Text(
                          title.toUpperCase(),
                          style: GoogleFonts.manrope(
                            color: accentColor.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeData.textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: themeData.textColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.text, color: themeData.textColor.withValues(alpha: 0.35), size: 14),
              const SizedBox(width: 8),
              Text(
                "FONT SIZE: ${_fontSize.toInt()}",
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: themeData.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DivineRulerPicker(
            value: _fontSize,
            min: 14.0,
            max: 32.0,
            step: 1.0,
            onChanged: (val) {
              setState(() => _fontSize = val);
            },
            activeColor: themeData.accentColor,
            textColor: themeData.textColor,
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildMetadataChip(IconData icon, String label, Color accentColor) {
    ...
  }
  */

  Widget _buildTagChip(String label, Color bgColor, {String? emoji}) {
    final themeData = _getThemeData();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            EmojiToIcon.getIconWidget(
              emoji,
              size: 13,
              color: themeData.textColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: themeData.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLikeThisShelf(SacredContent pageContent, _ReadingThemeData themeData) {
    return Consumer(
      builder: (context, ref, _) {
        final similarList = ref.watch(similarContentProvider(pageContent));
        if (similarList.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "MORE LIKE THIS",
                style: GoogleFonts.manrope(
                  color: themeData.textColor.withValues(alpha: 0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: similarList.length.clamp(0, 8),
                itemBuilder: (context, i) {
                  final item = similarList[i];
                  final match = ref.watch(matchPercentageProvider(item));
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentDetailScreen(content: item),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: EdgeInsets.only(right: i < similarList.length - 1 ? 12 : 0),
                      decoration: BoxDecoration(
                        color: themeData.accentColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: themeData.accentColor.withValues(alpha: 0.12)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: PremiumUI.networkImage(url: item.imageUrl!, fit: BoxFit.cover),
                              ),
                            )
                          else
                            Container(
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: themeData.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Iconsax.book_1, size: 20, color: themeData.accentColor.withValues(alpha: 0.5)),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: themeData.textColor.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$match% match",
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: PremiumTokens.activeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
          child: const Center(
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
            color: PremiumTokens.scaffoldBg.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final audioState = ref.watch(audioProvider);
          final isCurrent = audioState.currentContent?.id == content?.id;
          final isPlaying = isCurrent && audioState.isPlaying;
          final isLoading = isCurrent && audioState.isLoading;
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
                          : const Icon(Iconsax.music_play, color: PremiumTokens.saffronGlow, size: 14),
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
                                fontWeight: FontWeight.bold,
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
                              pageBuilder: (context, animation, secondaryAnimation) => const GlobalPlayerScreen(),
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
              _buildPremiumProgressBar(audioState, themeData, content),
              const SizedBox(height: 8),
              _buildPremiumAudioTime(audioState, themeData, content),
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
                          ? CircularProgressIndicator(color: PremiumTokens.textPrimary, strokeWidth: 3)
                          : Icon(isPlaying ? Iconsax.pause : Iconsax.play, color: PremiumTokens.textPrimary, size: 28),
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
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      scaleFactor: 0.90,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: themeData.textColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: themeData.textColor.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Icon(icon, color: themeData.textColor.withValues(alpha: 0.85), size: iconSize),
        ),
      ),
    );
  }

  _ReadingThemeData _getThemeData() {
    switch (_currentTheme) {
      case ReadingTheme.divineFlow:
        return _ReadingThemeData(
          backgroundColor: PremiumTokens.scaffoldBg,
          textColor: PremiumTokens.textPrimary,
          cardColor: PremiumTokens.borderSubtle,
          accentColor: PremiumTokens.saffronGlow,
          secondaryAccent: PremiumTokens.activeAccent,
          lineHeight: 1.8,
          glassOpacity: 0.08,
          showTextShadows: PremiumTokens.isDark,
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
                    fontWeight: FontWeight.bold, 
                    color: themeData.textColor.withValues(alpha: 0.5), 
                    letterSpacing: 2
                  )
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Font Size", style: GoogleFonts.spectral(color: themeData.textColor, fontSize: 16)),
                    Text(
                      "${_fontSize.toInt()}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeData.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DivineRulerPicker(
                  value: _fontSize,
                  min: 14.0,
                  max: 32.0,
                  step: 1.0,
                  onChanged: (val) {
                    setState(() => _fontSize = val);
                    setModalState(() {});
                  },
                  activeColor: themeData.accentColor,
                  textColor: themeData.textColor,
                ),
                const SizedBox(height: 32),
                Text("Divine Backdrop", style: GoogleFonts.spectral(color: themeData.textColor, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ReadingTheme.values.map((theme) {
                    final isSelected = _currentTheme == theme;
                    // Use theme-aware background so text stays legible in light mode
                    final btnBg = isSelected
                        ? themeData.accentColor
                        : themeData.textColor.withValues(alpha: 0.08);
                    final btnText = isSelected
                        ? themeData.backgroundColor
                        : themeData.textColor.withValues(alpha: 0.75);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _currentTheme = theme);
                        setModalState(() {});
                        ref.read(readerThemeProvider.notifier).state = theme;
                      },
                      child: AnimatedContainer(
                        duration: 300.ms,
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: btnBg,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isSelected
                                ? themeData.accentColor
                                : themeData.textColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          theme.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: btnText,
                            letterSpacing: 0.8,
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

  Widget _buildPremiumProgressBar(AudioState audioState, _ReadingThemeData themeData, SacredContent? content) {
    final isCurrent = audioState.currentContent?.id == content?.id;
    final duration = isCurrent ? audioState.duration : Duration.zero;
    final position = isCurrent ? audioState.position : Duration.zero;
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
          if (isCurrent) {
            final newPos = Duration(milliseconds: (value * duration.inMilliseconds).toInt());
            ref.read(audioProvider.notifier).seek(newPos);
          }
        },
      ),
    );
  }

  Widget _buildPremiumAudioTime(AudioState audioState, _ReadingThemeData themeData, SacredContent? content) {
    final isCurrent = audioState.currentContent?.id == content?.id;
    final duration = isCurrent ? audioState.duration : Duration.zero;
    final position = isCurrent ? audioState.position : Duration.zero;

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
