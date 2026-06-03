import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/audio_provider.dart';
import 'content_detail_screen.dart';
import '../widgets/animated_effects.dart';

class SaintDetailScreen extends ConsumerWidget {
  final String saintName;

  const SaintDetailScreen({super.key, required this.saintName});

  String _getSaintAvatarUrl(String name) {
    final h = name.hashCode.abs();
    final avatars = [
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
    ];
    return avatars[h % avatars.length];
  }

  String _getSaintBio(String name) {
    return "A revered spiritual master and rasik saint whose profound realizations and emotional outpourings guide seekers on the path of divine love and surrender. Their verses capture the essence of Bhakti and inner resonance.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PremiumTokens.of(context);
    final verses = ref.watch(contentBySaintProvider(saintName));
    final avatarUrl = _getSaintAvatarUrl(saintName);
    final bio = _getSaintBio(saintName);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Aura Gradient
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 4, context: context),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Premium Glassmorphic Header / App Bar
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
                      // Full Bleed Banner Image
                      PremiumUI.networkImage(
                        url: avatarUrl,
                        fit: BoxFit.cover,
                      ),
                      // Smooth vignette/fade gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              PremiumTokens.scaffoldBg.withValues(alpha: 0.4),
                              PremiumTokens.scaffoldBg,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Saint Profile info overlay
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: PremiumTokens.saffronGlow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: PremiumTokens.saffronGlow.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: Text(
                                "REVERED SAINT",
                                style: PremiumTokens.sansStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: PremiumTokens.saffronGlow,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              saintName,
                              style: PremiumTokens.hindiAwareStyle(
                                saintName,
                                fontSize: 26,
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

              // 2. Saint Bio / Overview Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: PremiumUI.voidGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.info_circle, color: PremiumTokens.activeAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "BIOGRAPHY & INSPIRATION",
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bio,
                          style: PremiumTokens.sansStyle(
                            fontSize: 13,
                            color: PremiumTokens.textSecondary,
                          ).copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TOTAL VERSES",
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                color: PremiumTokens.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${verses.length}",
                              style: PremiumTokens.sansStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.activeAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Verses List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "SACRED COMPOSITIONS",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // 4. Verses List
              verses.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text("No compositions found for this saint."),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = verses[index];
                            return _buildVerseItemCard(context, ref, item, verses);
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

  Widget _buildVerseItemCard(BuildContext context, WidgetRef ref, SacredContent item, List<SacredContent> playlist) {
    final isPlaying = ref.watch(audioProvider.select((s) =>
      s.isPlaying && s.currentContent?.id == item.id
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          padding: EdgeInsets.zero,
          borderColor: isPlaying
              ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
              : PremiumTokens.borderSubtle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed background image
                  Positioned.fill(
                    child: PremiumUI.networkImage(
                      url: item.displayImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Ambient gradient mask
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            PremiumTokens.surfaceMain.withValues(alpha: 0.95),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.6),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.hindiAwareStyle(
                                  item.title,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: PremiumTokens.textPrimary,
                                  isSacred: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.book ?? "Sacred Scripture",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.sansStyle(
                                  fontSize: 11,
                                  color: PremiumTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PremiumUI.categoryBadge(item.category, fontSize: 8),
                            ],
                          ),
                        ),
                        // Action Buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.audioUrl != null && item.audioUrl!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  ref.read(audioProvider.notifier).playWithPlaylist(item, playlist);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPlaying
                                        ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                                        : PremiumTokens.borderSubtle.withValues(alpha: 0.4),
                                    border: Border.all(
                                      color: isPlaying
                                          ? PremiumTokens.activeAccent
                                          : PremiumTokens.borderMedium,
                                    ),
                                  ),
                                  child: Icon(
                                    isPlaying ? Iconsax.pause : Icons.play_arrow,
                                    color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
