import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/favorites_provider.dart';
import '../widgets/share_content_widget.dart';
import '../widgets/animated_effects.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CONTENT DETAIL SCREEN - Immersive Reading Experience
/// Modern, minimal, distraction-free reading with sticky audio
/// ═══════════════════════════════════════════════════════════════════════════

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
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();
  bool _showCompactHeader = false;
  bool _showAudioPlayer = false; // Audio player hidden by default

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showCompact = _scrollController.offset > 100;
    if (showCompact != _showCompactHeader) {
      setState(() => _showCompactHeader = showCompact);
    }
  }

  Future<void> _initAudio() async {
    try {
      String audioUrl =
          widget.content?.audioUrl ??
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      await _audioPlayer.setUrl(audioUrl);
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
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
        (widget.content?.title ?? widget.title ?? l.translate('sacred_text'))
            .replaceAll('\n', ', ');
    final displayCategory =
        widget.content?.category ?? widget.category ?? "Wisdom";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top spacing for header
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 60,
                ),
              ),

              // Hero section with title
              SliverToBoxAdapter(
                child: _buildHeroSection(
                  context,
                  displayTitle,
                  displayCategory,
                  isDark,
                ),
              ),

              // Content sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.space20,
                  AppTheme.space24,
                  AppTheme.space20,
                  200,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Sanskrit Text Card - Hero
                    _buildSanskritCard(context, isDark, l),
                    const SizedBox(height: AppTheme.space24),

                    // 2. Hindi Meaning Card (Priority 2)
                    _buildContentCard(
                      context,
                      title: l.translate('hindi_meaning'),
                      content:
                          widget.content?.hindiMeaning ??
                          "तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।",
                      icon: Iconsax.heart,
                      color: AppTheme.lotusRose,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppTheme.space16),

                    // 3. Translation Card (English - Priority 3)
                    _buildContentCard(
                      context,
                      title: l.translate('english_translation'),
                      content:
                          widget.content?.translation ??
                          "You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
                      icon: Iconsax.language_circle,
                      color: AppTheme.peacockBlue,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppTheme.space16),

                    // 4. Commentary Card
                    _buildContentCard(
                      context,
                      title: l.translate('commentary'),
                      content:
                          widget.content?.commentary ??
                          "This shloka is the cornerstone of Karma Yoga. It teaches us to focus on the effort rather than the outcome.",
                      icon: Iconsax.lamp_charge,
                      color: AppTheme.sereneTeal,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppTheme.space32),

                    // Font Controls & End Decoration
                    Center(child: _buildFontControls(isDark)),
                    const SizedBox(height: AppTheme.space32),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: AppTheme.textMuted(context).withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "END OF VERSE",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 1,
                            color: AppTheme.textMuted(context).withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Header
          _buildFloatingHeader(context, displayTitle, isDark),

          // --- Collapsible Audio Section ---
          Positioned(
            left: AppTheme.space16,
            right: AppTheme.space16,
            bottom: AppTheme.space20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _showAudioPlayer
                  ? _buildAudioPlayer(context, isDark)
                  : _buildAudioFloatingToggle(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPACT AUDIO TOGGLE ---
  Widget _buildAudioFloatingToggle(BuildContext context, bool isDark) {
    return Align(
      alignment: Alignment.bottomRight,
      child: PressableScale(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showAudioPlayer = true);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient(context),
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
          ),
          child: const Icon(Iconsax.music, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSection(
    BuildContext context,
    String title,
    String category,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative ॐ
          Center(
            child:
                Text(
                      'ॐ',
                      style: TextStyle(
                        fontSize: 48,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        fontWeight: FontWeight.w300,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 3.seconds,
                    ),
          ),
          const SizedBox(height: AppTheme.space16),
          // Category badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space12,
                vertical: AppTheme.space4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          ),
          const SizedBox(height: AppTheme.space12),
          // Title
          Center(
            child:
                Text(
                      title.replaceAll('\n', ', '),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spectral(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                        height: 1.3,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLOATING HEADER - Minimal & clean
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFloatingHeader(BuildContext context, String title, bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: _showCompactHeader
              ? (isDark ? AppTheme.darkCard : AppTheme.lightCard).withOpacity(
                  0.95,
                )
              : Colors.transparent,
          boxShadow: _showCompactHeader
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Back button
            _buildHeaderButton(
              icon: Iconsax.arrow_left,
              onTap: () => Navigator.pop(context),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            // Title (shown when scrolled)
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showCompactHeader ? 1.0 : 0.0,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Action buttons
            Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final isFavorite = widget.content != null
                        ? ref.watch(isFavoriteProvider(widget.content!.id))
                        : false;
                    return _buildHeaderButton(
                      icon: isFavorite ? Iconsax.heart_remove : Iconsax.heart,
                      onTap: _toggleFavorite,
                      isDark: isDark,
                      isActive: isFavorite,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Iconsax.send_2,
                  onTap: _shareContent,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
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
              : AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.borderColor(context), width: 1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.textSecondary(context),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SANSKRIT CARD - Large, beautiful typography with copy
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSanskritCard(
    BuildContext context,
    bool isDark,
    AppLocalization l,
  ) {
    final sanskritText =
        widget.content?.sanskritText ??
        "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥";

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryColor.withOpacity(0.12),
                  AppTheme.sacredViolet.withOpacity(0.08),
                ]
              : [
                  AppTheme.primaryColor.withOpacity(0.08),
                  AppTheme.lightSurface,
                ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with icon and actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient(context),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                ),
                child: const Icon(
                  Iconsax.document_text,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('sanskrit_text').toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Original verse',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Copy button
              PressableScale(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: sanskritText));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text('${l.translate('sanskrit_text')} copied!'),
                        ],
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.copy,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          // Decorative divider
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          // Sanskrit Text - selectable
          SelectableText(
            sanskritText.replaceAll('\\n', '\n'),
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: _fontSize + 4,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              height: 2.0,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppTheme.space20),
          // Decorative footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'ॐ',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT CARD - Interactive Translation, meaning, commentary
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        bool isExpanded = true;
        bool isCopied = false;

        return Container(
          padding: const EdgeInsets.all(AppTheme.space20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with actions
              Row(
                children: [
                  // Icon badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to copy',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Copy button
                      _buildCardAction(
                        icon: isCopied ? Iconsax.tick_circle : Iconsax.copy,
                        color: isCopied ? AppTheme.success : color,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: content));
                          HapticFeedback.mediumImpact();
                          setCardState(() => isCopied = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) {
                              setCardState(() => isCopied = false);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Iconsax.tick_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text('$title copied!'),
                                ],
                              ),
                              backgroundColor: color,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space16),
              // Gradient divider
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.5),
                      color.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              // Content with tap to copy
              GestureDetector(
                onDoubleTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          const Text('Text copied!'),
                        ],
                      ),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: SelectableText(
                  content.replaceAll('\\n', '\n'),
                  style: GoogleFonts.outfit(
                    fontSize: _fontSize - 2,
                    color: AppTheme.textPrimary(context),
                    height: 1.8,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUDIO PLAYER - Sticky bottom player
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAudioPlayer(BuildContext context, bool isDark) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context).withOpacity(0.98),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderColor(
                context,
              ).withOpacity(isDark ? 0.3 : 1.0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Sanskrit Recitation + Minimize
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.music_play,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPlaying
                            ? "Playing Recitation"
                            : "Sanskrit Recitation",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showAudioPlayer = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted(context).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.arrow_down_1,
                        size: 18,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Controls row
              Row(
                children: [
                  // Play/Pause button
                  PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPlaying
                              ? [AppTheme.sereneTeal, const Color(0xFF14B8A6)]
                              : [AppTheme.primaryColor, AppTheme.primaryDark],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow(
                          isPlaying
                              ? AppTheme.sereneTeal
                              : AppTheme.primaryColor,
                        ),
                      ),
                      child: Icon(
                        isPlaying ? Iconsax.pause : Iconsax.play,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Progress & Time
                  Expanded(
                    child: Column(
                      children: [
                        _buildProgressBar(isDark),
                        const SizedBox(height: 8),
                        StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (context, durationSnap) {
                            final duration = durationSnap.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, positionSnap) {
                                final position =
                                    positionSnap.data ?? Duration.zero;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: AppTheme.textMuted(context),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: AppTheme.textMuted(context),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skip controls
                  _buildSmallButton(
                    icon: Iconsax.previous,
                    onTap: () => _audioPlayer.seek(
                      _audioPlayer.position - const Duration(seconds: 10),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSmallButton(
                    icon: Iconsax.next,
                    onTap: () => _audioPlayer.seek(
                      _audioPlayer.position + const Duration(seconds: 10),
                    ),
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

  Widget _buildProgressBar(bool isDark) {
    return StreamBuilder<Duration?>(
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

            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: Stack(
                children: [
                  Container(height: 4, color: AppTheme.surfaceColor(context)),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFontControls(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.text, size: 14, color: AppTheme.textMuted(context)),
          const SizedBox(width: 12),
          _buildFontButton(
            icon: Iconsax.minus,
            onTap: () {
              if (_fontSize > 14) setState(() => _fontSize -= 2);
            },
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${_fontSize.toInt()}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          _buildFontButton(
            icon: Iconsax.add,
            onTap: () {
              if (_fontSize < 26) setState(() => _fontSize += 2);
            },
            isDark: isDark,
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textSecondary(context)),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, size: 14, color: AppTheme.textSecondary(context)),
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
