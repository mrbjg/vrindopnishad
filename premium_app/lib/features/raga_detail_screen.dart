import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/audio_provider.dart';
import 'content_detail_screen.dart';
import '../widgets/animated_effects.dart';

class RagaDetailScreen extends ConsumerWidget {
  final String ragaName;

  const RagaDetailScreen({super.key, required this.ragaName});

  String _getRagaCoverUrl(String name) {
    final h = name.hashCode.abs();
    final covers = [
      'https://images.unsplash.com/photo-1615412727883-f8a6797f883a?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1545127398-14699f92334b?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80',
    ];
    return covers[h % covers.length];
  }

  Map<String, String> _getRagaDetails(String name) {
    final lower = name.toLowerCase().trim();
    if (lower.contains('yaman')) {
      return {
        'time': 'Evening (6 PM - 9 PM)',
        'mood': 'Peace & Devotional Love (Shringar)',
        'deity': 'Krishna / Shiva',
      };
    } else if (lower.contains('bhairavi')) {
      return {
        'time': 'Morning / Concluding (Anytime)',
        'mood': 'Compassion, Peace & Farewell (Karuna)',
        'deity': 'Radha / Durga',
      };
    } else if (lower.contains('bhairav')) {
      return {
        'time': 'Early Morning (3 AM - 6 AM)',
        'mood': 'Veneration & Transcendence (Bhakti)',
        'deity': 'Lord Shiva',
      };
    } else if (lower.contains('darbari')) {
      return {
        'time': 'Late Night (9 PM - 12 AM)',
        'mood': 'Majesty, Gravity & Deep Devotion',
        'deity': 'Krishna',
      };
    } else if (lower.contains('sarang') || lower.contains('vrindavani')) {
      return {
        'time': 'Afternoon (12 PM - 3 PM)',
        'mood': 'Bright devotion, Joy & Yearning',
        'deity': 'Krishna',
      };
    } else if (lower.contains('desh')) {
      return {
        'time': 'Night (9 PM - 12 AM)',
        'mood': 'Joyous Yearning (Shringar)',
        'deity': 'Krishna / Radha',
      };
    } else {
      return {
        'time': 'Anytime (Spiritual Prahar)',
        'mood': 'Meditative Chanting & Transcendental Peace',
        'deity': 'Divine Tradition',
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PremiumTokens.of(context);
    final verses = ref.watch(contentByRagaProvider(ragaName));
    final coverUrl = _getRagaCoverUrl(ragaName);
    final details = _getRagaDetails(ragaName);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 5, context: context),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Spotify-Style Header Banner
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: PremiumTokens.scaffoldBg.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: PremiumTokens.borderSubtle),
                  ),
                  child: IconButton(
                    icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PremiumUI.networkImage(
                        url: coverUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              PremiumTokens.scaffoldBg.withValues(alpha: 0.3),
                              PremiumTokens.scaffoldBg,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.25), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.music5, size: 10, color: PremiumTokens.activeAccentLight),
                                  const SizedBox(width: 4),
                                  Text(
                                    "CLASSICAL INDOLOGY RAGA",
                                    style: PremiumTokens.sansStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: PremiumTokens.activeAccentLight,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ragaName,
                              style: PremiumTokens.hindiAwareStyle(
                                ragaName,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textPrimary,
                                isSacred: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Raga Audio Information Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: PremiumUI.voidGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.music_play, color: PremiumTokens.activeAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "RAGA PROPERTIES",
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPropertyRow("Time of Singing (Prahar)", details['time']!, Iconsax.clock),
                        const Divider(height: 24),
                        _buildPropertyRow("Emotional Tone (Rasa)", details['mood']!, Iconsax.mask),
                        const Divider(height: 24),
                        _buildPropertyRow("Resonating Deity", details['deity']!, Iconsax.sun_1),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Audio Tracks Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RESONATING VERSES & BHAJANS",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: PremiumTokens.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "${verses.length} Tracks",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Verses List (Playlist format)
              verses.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text("No tracks found in this raga."),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = verses[index];
                            return _buildPlaylistTrackItem(context, ref, item, verses);
                          },
                          childCount: verses.length,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: PremiumTokens.textMuted, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: PremiumTokens.sansStyle(
                  fontSize: 9,
                  color: PremiumTokens.textMuted,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: PremiumTokens.sansStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PremiumTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistTrackItem(BuildContext context, WidgetRef ref, SacredContent item, List<SacredContent> playlist) {
    final isPlaying = ref.watch(audioProvider.select((s) =>
      s.isPlaying && s.currentContent?.id == item.id
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentDetailScreen(content: item),
            ),
          );
        },
        child: PremiumUI.relicStaticCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderColor: isPlaying
              ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
              : PremiumTokens.borderSubtle,
          child: Row(
            children: [
              // Cover Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: PremiumUI.networkImage(
                  url: item.displayImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Track Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumTokens.hindiAwareStyle(
                        item.title,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                        isSacred: true,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.author ?? "Unknown Saint",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        color: PremiumTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play/Pause Action
              if (item.audioUrl != null && item.audioUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    ref.read(audioProvider.notifier).playWithPlaylist(item, playlist);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying
                          ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                          : PremiumTokens.borderSubtle,
                    ),
                    child: Icon(
                      isPlaying ? Iconsax.pause : Icons.play_arrow,
                      color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
