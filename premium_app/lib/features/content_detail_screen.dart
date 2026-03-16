import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../core/design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/favorites_provider.dart';
import '../widgets/share_content_widget.dart';
import '../core/localization.dart';
import '../core/providers.dart';
import '../widgets/animated_effects.dart';
import 'package:flutter/services.dart';

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
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();
  bool _showCompactHeader = false;
  bool _showAudioPlayer = false;

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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
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

    final displayTitle =
        (widget.content?.title ?? widget.title ?? l.translate('sacred_text'))
            .replaceAll('\n', ', ');
    final displayCategory =
        widget.content?.category ?? widget.category ?? "Wisdom";

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedSacredBackground()),
          
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + 80),
              ),

              SliverToBoxAdapter(
                child: _buildPremiumHero(displayTitle, displayCategory),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 200),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sanskrit Card
                    _buildPremiumSanskritCard(l),
                    const SizedBox(height: 24),

                    // Meaning Sections
                    _buildPremiumContentSection(
                      title: l.translate('hindi_meaning'),
                      content: widget.content?.hindiMeaning ?? "",
                      icon: Iconsax.heart,
                      accentColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),

                    _buildPremiumContentSection(
                      title: l.translate('english_translation'),
                      content: widget.content?.translation ?? "",
                      icon: Iconsax.language_circle,
                      accentColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),

                    _buildPremiumContentSection(
                      title: l.translate('commentary'),
                      content: widget.content?.commentary ?? "",
                      icon: Iconsax.lamp_charge,
                      accentColor: PremiumTokens.saffronGlow,
                    ),
                    const SizedBox(height: 32),

                    Center(child: _buildPremiumFontControls()),
                    
                    const SizedBox(height: 48),
                    Center(
                      child: Opacity(
                        opacity: 0.2,
                        child: Text("ॐ", style: GoogleFonts.spectral(fontSize: 48, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Header
          _buildPremiumHeader(displayTitle),

          // Audio Toggle
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: AnimatedSwitcher(
              duration: 300.ms,
              child: _showAudioPlayer
                  ? _buildPremiumAudioPlayer()
                  : _buildAudioFloatingToggle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(String title, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PremiumTokens.saffronGlow.withValues(alpha: 0.2)),
            ),
            child: Text(
              category.toUpperCase(),
              style: GoogleFonts.outfit(
                color: PremiumTokens.saffronGlow,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(String title) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: _showCompactHeader ? PremiumTokens.charcoal.withValues(alpha: 0.9) : Colors.transparent,
        ),
        child: Row(
          children: [
            _buildHeaderCircleButton(Iconsax.arrow_left, () => Navigator.pop(context)),
            SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: 200.ms,
                opacity: _showCompactHeader ? 1.0 : 0.0,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildHeaderCircleButton(
              widget.content != null && ref.watch(isFavoriteProvider(widget.content!.id))
                  ? Iconsax.heart5
                  : Iconsax.heart,
              _toggleFavorite,
              isActive: widget.content != null && ref.watch(isFavoriteProvider(widget.content!.id)),
            ),
            const SizedBox(width: 8),
            _buildHeaderCircleButton(Iconsax.send_2, _shareContent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCircleButton(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 14,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Icon(icon, color: isActive ? PremiumTokens.saffronGlow : Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPremiumSanskritCard(AppLocalization l) {
    final text = widget.content?.sanskritText ?? "";
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MANTRA / SLOKA",
                style: GoogleFonts.outfit(color: PremiumTokens.saffronGlow, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.mediumImpact();
                },
                icon: const Icon(Iconsax.copy, color: Colors.white38, size: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          SelectableText(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.spectral(
              fontSize: _fontSize + 4,
              color: PremiumTokens.saffronGlow,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContentSection({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            content,
            style: GoogleFonts.outfit(
              fontSize: _fontSize,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFontControls() {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.text, color: Colors.white24, size: 16),
          const SizedBox(width: 16),
          _buildFontToolButton(Iconsax.minus, () {
            if (_fontSize > 14) setState(() => _fontSize -= 2);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("${_fontSize.toInt()}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _buildFontToolButton(Iconsax.add, () {
            if (_fontSize < 32) setState(() => _fontSize += 2);
          }),
        ],
      ),
    );
  }

  Widget _buildFontToolButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 14),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: PremiumTokens.saffronPremiumGradient,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: PremiumTokens.saffronGlow.withValues(alpha: 0.3), blurRadius: 20)],
          ),
          child: const Icon(Iconsax.music, color: Colors.white, size: 24),
        ),
      ),
    ).animate().scale();
  }

  Widget _buildPremiumAudioPlayer() {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<PlayerState>(
        stream: _audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final isPlaying = snapshot.data?.playing ?? false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.music_play, color: PremiumTokens.saffronGlow, size: 16),
                      const SizedBox(width: 12),
                      Text("Divine Recitation", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showAudioPlayer = false),
                    icon: const Icon(Iconsax.arrow_down_1, color: Colors.white38, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => isPlaying ? _audioPlayer.pause() : _audioPlayer.play(),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PremiumTokens.saffronPremiumGradient),
                      child: Icon(isPlaying ? Iconsax.pause : Iconsax.play, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPremiumProgressBar(),
                        const SizedBox(height: 8),
                        _buildPremiumAudioTime(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumProgressBar() {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.durationStream,
      builder: (context, dSnap) {
        final duration = dSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, pSnap) {
            final position = pSnap.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
            return Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(decoration: const BoxDecoration(color: PremiumTokens.saffronGlow, borderRadius: BorderRadius.all(Radius.circular(2)))),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumAudioTime() {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.durationStream,
      builder: (context, dSnap) {
        final duration = dSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, pSnap) {
            final position = pSnap.data ?? Duration.zero;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                Text(_formatDuration(duration), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}
