import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../../core/color_theme_provider.dart';
import '../../core/mood_theme_provider.dart';
import '../../core/providers.dart';

class SeekerUser {
  final String id;
  final String displayName;
  final String username;
  final String avatarUrl;
  final AppMoodTheme activeMood;
  final int japCount;
  final String bio;
  final bool isOnline;
  final int dailyMalaGoal;
  final int streakCount;
  final int shlokasRead;
  final String spiritualityLevel;
  final int readingMinutes;
  final bool shareStats;

  const SeekerUser({
    required this.id,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.activeMood,
    required this.japCount,
    required this.bio,
    this.isOnline = false,
    required this.dailyMalaGoal,
    required this.streakCount,
    required this.shlokasRead,
    required this.spiritualityLevel,
    required this.readingMinutes,
    required this.shareStats,
  });
}

class FindFriendsScreen extends ConsumerStatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  ConsumerState<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends ConsumerState<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedMoodFilter = "all";

  // List of mock seekers with extended sadhana stats and sharing preferences
  final List<SeekerUser> _mockSeekers = const [
    SeekerUser(
      id: "gopal_das",
      displayName: "Gopal Das",
      username: "gopal_das",
      avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
      activeMood: AppMoodTheme.sereneDawn,
      japCount: 10008,
      bio: "Chant the Holy Name, and the heart will mirror the sky of pure devotion.",
      isOnline: true,
      dailyMalaGoal: 16,
      streakCount: 24,
      shlokasRead: 48,
      readingMinutes: 180,
      spiritualityLevel: "Sadhak",
      shareStats: true,
    ),
    SeekerUser(
      id: "sita_ram",
      displayName: "Sita Ram",
      username: "sita_ram",
      avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
      activeMood: AppMoodTheme.waterfallBlue,
      japCount: 5420,
      bio: "Every breath is a sacred gift; offer it in loving remembrance at the Lotus Feet.",
      isOnline: true,
      dailyMalaGoal: 11,
      streakCount: 8,
      shlokasRead: 12,
      readingMinutes: 45,
      spiritualityLevel: "Seeker",
      shareStats: true,
    ),
    SeekerUser(
      id: "braj_gopi",
      displayName: "Braj Gopi",
      username: "braj_gopi",
      avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80",
      activeMood: AppMoodTheme.monsoonGreen,
      japCount: 12800,
      bio: "In the dust of Sri Vrindavan, find the eternal footprints of the Divine Couple.",
      isOnline: false,
      dailyMalaGoal: 21,
      streakCount: 42,
      shlokasRead: 108,
      readingMinutes: 320,
      spiritualityLevel: "Tapasvi",
      shareStats: true,
    ),
    SeekerUser(
      id: "anand_d",
      displayName: "Anand Das",
      username: "anand_d",
      avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
      activeMood: AppMoodTheme.forestHaven,
      japCount: 8240,
      bio: "Humility is the vessel, devotion is the nectar. Empty yourself to be filled.",
      isOnline: true,
      dailyMalaGoal: 11,
      streakCount: 14,
      shlokasRead: 25,
      readingMinutes: 90,
      spiritualityLevel: "Seeker",
      shareStats: false, // Private Seeker
    ),
    SeekerUser(
      id: "radha_premi",
      displayName: "Radha Premi",
      username: "radha_premi",
      avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
      activeMood: AppMoodTheme.midnightVoid,
      japCount: 18400,
      bio: "Always seeking the dust of Vrindavan and the resonance of kirtan.",
      isOnline: false,
      dailyMalaGoal: 32,
      streakCount: 65,
      shlokasRead: 144,
      readingMinutes: 420,
      spiritualityLevel: "Tapasvi",
      shareStats: true,
    ),
    SeekerUser(
      id: "krishna_sevak",
      displayName: "Krishna Sevak",
      username: "k_sevak",
      avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d",
      activeMood: AppMoodTheme.cloudyCalm,
      japCount: 3100,
      bio: "Offering service and devotion to the holy Dhama.",
      isOnline: true,
      dailyMalaGoal: 8,
      streakCount: 5,
      shlokasRead: 8,
      readingMinutes: 30,
      spiritualityLevel: "Seeker",
      shareStats: true,
    ),
    SeekerUser(
      id: "madhav_das",
      displayName: "Madhav Das",
      username: "madhav_d",
      avatarUrl: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7",
      activeMood: AppMoodTheme.mountainPeak,
      japCount: 6500,
      bio: "Meditating in silence, listening to the eternal sound of Sant-Vaani.",
      isOnline: false,
      dailyMalaGoal: 11,
      streakCount: 11,
      shlokasRead: 20,
      readingMinutes: 75,
      spiritualityLevel: "Sadhak",
      shareStats: false, // Private Seeker
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Calculate spiritual resonance between user's active mood and seeker's mood
  int _calculateResonance(AppMoodTheme userMood, AppMoodTheme seekerMood, int japCount) {
    if (userMood == seekerMood) {
      // Direct mood match
      return 95 + (math.min(japCount, 15000) ~/ 3000);
    }
    
    // Check if moods share the same brightness vibe (light/dark base)
    final userPalette = AppMoodThemes.palettes[userMood];
    final seekerPalette = AppMoodThemes.palettes[seekerMood];
    
    if (userPalette != null && seekerPalette != null) {
      if (userPalette.brightness == seekerPalette.brightness) {
        return 80 + (math.min(japCount, 10000) ~/ 1000);
      }
    }

    return 70 + (math.min(japCount, 8000) ~/ 800);
  }

  @override
  Widget build(BuildContext context) {
    PremiumTokens.of(context);
    // Read user's active mood and palette details
    final userMood = ref.watch(moodThemeProvider);
    ref.watch(colorPaletteProvider);

    // Compute matching seekers list
    final filteredSeekers = _mockSeekers.where((seeker) {
      final matchesSearch = seeker.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          seeker.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          seeker.bio.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedMoodFilter == "all") return true;
      if (_selectedMoodFilter == "match") return seeker.activeMood == userMood;
      if (_selectedMoodFilter == "online") return seeker.isOnline;

      return seeker.activeMood.name.toLowerCase() == _selectedMoodFilter.toLowerCase();
    }).toList();

    // Sort seekers by resonance score descending
    final sortedSeekers = filteredSeekers.map((seeker) {
      final score = _calculateResonance(userMood, seeker.activeMood, seeker.japCount);
      return MapEntry(seeker, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(context),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text(
                  "SANGAT SEEKERS",
                  style: PremiumTokens.displayStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: PremiumUI.animatedIcon(
                    folder: 'Chevron-left',
                    fileName: 'chevron-left.json',
                    size: 20,
                    color: PremiumTokens.activeAccent,
                    onTap: () => Navigator.pop(context),
                  ),
                  onPressed: () {},
                ),
              ),

              // Search bar & Header Vibe intro
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find Your Spiritual Circle",
                        style: PremiumTokens.sansStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Search seekers by name, bio, or vibe...",
                          hintStyle: PremiumTokens.sansStyle(
                            color: PremiumTokens.isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12.5,
                          ),
                          prefixIcon: Icon(Iconsax.search_normal, color: PremiumTokens.isDark ? Colors.white38 : Colors.black38, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: PremiumTokens.activeAccent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildFilterChip("All Sangat", "all"),
                            _buildFilterChip("Vibe Matches", "match", emoji: "🌅"),
                            _buildFilterChip("Chanting Now", "online", emoji: "🟢"),
                            _buildFilterChip("Forest Haven", AppMoodTheme.forestHaven.name, emoji: "🌲"),
                            _buildFilterChip("Dawn Serenity", AppMoodTheme.sereneDawn.name, emoji: "🌅"),
                            _buildFilterChip("Monsoon Vibe", AppMoodTheme.monsoonGreen.name, emoji: "🌿"),
                            _buildFilterChip("Midnight Space", AppMoodTheme.midnightVoid.name, emoji: "🌑"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (sortedSeekers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.user_search, color: PremiumTokens.textMuted, size: 48),
                          const SizedBox(height: 14),
                          Text(
                            "No Spiritual Friends Found",
                            style: PremiumTokens.displayStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Try searching with another spiritual vibe or keyword.",
                            style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = sortedSeekers[index];
                        final seeker = entry.key;
                        final resonance = entry.value;
                        final isVibeMatch = seeker.activeMood == userMood;
                        final palette = AppMoodThemes.palettes[seeker.activeMood];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: () {
                              AppHapticFeedback.mediumImpact();
                              _showSadhanaCardSheet(context, seeker);
                            },
                            child: PremiumUI.relicStaticCard(
                              padding: EdgeInsets.zero,
                              borderColor: isVibeMatch
                                  ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                                  : PremiumTokens.borderSubtle,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                  // 1. Full-bleed seeker avatar as ambient background
                                  Positioned.fill(
                                    child: PremiumUI.networkImage(
                                      url: seeker.avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // 2. Strong adaptive gradient overlay for legibility
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            PremiumTokens.surfaceMain.withValues(alpha: 0.55),
                                            PremiumTokens.surfaceMain.withValues(alpha: 0.88),
                                            PremiumTokens.surfaceMain.withValues(alpha: 0.97),
                                          ],
                                          stops: const [0.0, 0.35, 0.7],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 3. Card content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Profile Avatar with Status Ring
                                            Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: isVibeMatch
                                                        ? PremiumTokens.activeGradient
                                                        : LinearGradient(
                                                            colors: [
                                                              palette?.scaffoldBg ?? Colors.white24,
                                                              PremiumTokens.activeAccent.withValues(alpha: 0.5),
                                                            ],
                                                          ),
                                                  ),
                                                  child: Container(
                                                    width: 46,
                                                    height: 46,
                                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(23),
                                                      child: PremiumUI.networkImage(url: seeker.avatarUrl, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ),
                                                if (seeker.isOnline)
                                                  Positioned(
                                                    bottom: 1,
                                                    right: 1,
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: Colors.greenAccent,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: PremiumTokens.surfaceMain, width: 2),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        seeker.displayName,
                                                        style: PremiumTokens.displayStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        "@${seeker.username}",
                                                        style: PremiumTokens.sansStyle(
                                                          color: PremiumTokens.textMuted,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: (palette?.scaffoldBg ?? Colors.white12).withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(
                                                            color: (palette?.borderColor ?? Colors.white12).withValues(alpha: 0.2),
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            EmojiToIcon.getIconWidget(
                                                              palette?.emoji ?? '✨',
                                                              size: 10,
                                                              color: PremiumTokens.textSecondary,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              palette?.name ?? seeker.activeMood.name,
                                                              style: PremiumTokens.sansStyle(
                                                                color: PremiumTokens.textSecondary,
                                                                fontSize: 9,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "•  ${seeker.japCount.toString()} Japs",
                                                        style: PremiumTokens.sansStyle(
                                                          color: PremiumTokens.textMuted,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Vibe Match indicator badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: isVibeMatch
                                                    ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                                                    : PremiumTokens.surfaceMain.withValues(alpha: 0.4),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isVibeMatch
                                                      ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                                                      : PremiumTokens.borderSubtle,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "$resonance%",
                                                    style: PremiumTokens.displayStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w900,
                                                      color: isVibeMatch ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Resonance",
                                                    style: PremiumTokens.sansStyle(
                                                      fontSize: 6.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: PremiumTokens.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          seeker.bio,
                                          style: PremiumTokens.sansStyle(
                                            fontSize: 12,
                                            color: PremiumTokens.textSecondary,
                                          ).copyWith(height: 1.4),
                                        ),
                                        const SizedBox(height: 14),
                                        // Actions
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  AppHapticFeedback.mediumImpact();
                                                  _showJointChantSheet(context, seeker);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: PremiumTokens.isDark ? Colors.white12 : Colors.black12,
                                                  ),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Iconsax.heart5, color: PremiumTokens.activeAccent, size: 14),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "Chant Together",
                                                      style: PremiumTokens.sansStyle(
                                                        color: PremiumTokens.textPrimary,
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  AppHapticFeedback.lightImpact();
                                                  // Redirect to Journal tab (Index 3)
                                                  ref.read(navigationIndexProvider.notifier).state = 3;
                                                  // Close Find Seekers Screen
                                                  Navigator.pop(context);
                                                  
                                                  // Show quick guide message
                                                  Future.delayed(const Duration(milliseconds: 300), () {
                                                    if (context.mounted) {
                                                      PremiumUI.showNotification(
                                                        context,
                                                        "Sangat Chat: Say Hari Om to ${seeker.displayName}!",
                                                        icon: Iconsax.message_2,
                                                      );
                                                    }
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: PremiumTokens.activeAccent.withValues(alpha: 0.15),
                                                  foregroundColor: PremiumTokens.activeAccent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Iconsax.message_21, color: PremiumTokens.activeAccent, size: 14),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "Message",
                                                      style: PremiumTokens.sansStyle(
                                                        color: PremiumTokens.activeAccent,
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        );
                      },
                      childCount: sortedSeekers.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {String? emoji}) {
    final isSelected = _selectedMoodFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          AppHapticFeedback.lightImpact();
          setState(() {
            _selectedMoodFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? PremiumTokens.activeAccent.withValues(alpha: 0.18)
                : PremiumTokens.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? PremiumTokens.activeAccent.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                EmojiToIcon.getIconWidget(
                  emoji,
                  size: 14,
                  color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Interactive popup sheet to simulate joining a chant session with a seeker
  void _showJointChantSheet(BuildContext context, SeekerUser seeker) {
    int localCount = 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "JOINT RESONANCE CHANT",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: PremiumTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Icon(Iconsax.user, size: 24, color: PremiumTokens.textMuted),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Iconsax.heart5, color: PremiumTokens.activeAccent, size: 20),
                      const SizedBox(width: 10),
                      // Friend Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: PremiumUI.networkImage(url: seeker.avatarUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Chanting with ${seeker.displayName}",
                    style: PremiumTokens.displayStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sync your breath. Tap the sacred bead to chant.",
                    style: PremiumTokens.sansStyle(
                      color: PremiumTokens.textMuted,
                      fontSize: 11.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Sacred Bead Button
                  GestureDetector(
                    onTap: () {
                      AppHapticFeedback.lightImpact();
                      setSheetState(() {
                        localCount++;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            PremiumTokens.activeAccent,
                            PremiumTokens.activeAccent.withValues(alpha: 0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        localCount.toString(),
                        style: PremiumTokens.displayStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.onAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        PremiumUI.showNotification(
                          context,
                          "Completed joint kirtan of $localCount counts with ${seeker.displayName}!",
                          icon: Iconsax.heart,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumTokens.activeAccent,
                        foregroundColor: PremiumTokens.onAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "DONE & SHARE MERIT",
                        style: PremiumTokens.sansStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.onAccent,
                        ),
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

  void _showSadhanaCardSheet(BuildContext context, SeekerUser seeker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final mySharingEnabled = ref.watch(shareStatsEnabledProvider);
            final palette = AppMoodThemes.palettes[seeker.activeMood];

            return Container(
              decoration: BoxDecoration(
                color: PremiumTokens.sheetBgTop,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: PremiumTokens.borderSubtle),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!mySharingEnabled) ...[
                    // Current user has disabled sharing
                    const Icon(Iconsax.eye_slash5, color: Colors.orangeAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "MUTUAL SHARING REQUIRED",
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "To see others' Naam Jap & Sadhana stats, you must enable sharing your own statistics first. Let's practice spiritual transparency together.",
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        color: PremiumTokens.textSecondary,
                      ).copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          AppHapticFeedback.mediumImpact();
                          ref.read(shareStatsEnabledProvider.notifier).toggle(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTokens.activeAccent,
                          foregroundColor: PremiumTokens.onAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "ENABLE SHARING & REVEAL",
                          style: PremiumTokens.sansStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ] else if (!seeker.shareStats) ...[
                    // Seeker has disabled sharing
                    Icon(Iconsax.security_safe5, color: PremiumTokens.textMuted, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "SADHAN IS PRIVATE",
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: PremiumTokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${seeker.displayName} has chosen to keep their spiritual progress private. Respecting every seeker's personal and quiet reflection.",
                      style: PremiumTokens.sansStyle(
                        fontSize: 13,
                        color: PremiumTokens.textSecondary,
                      ).copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: PremiumTokens.borderMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "CLOSE",
                          style: PremiumTokens.sansStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Detailed statistics view
                    Row(
                      children: [
                        // Seeker Profile Image with Aura
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette?.borderColor ?? PremiumTokens.activeAccent,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: PremiumUI.networkImage(url: seeker.avatarUrl, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                seeker.displayName,
                                style: PremiumTokens.displayStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "@${seeker.username}",
                                style: PremiumTokens.sansStyle(
                                  color: PremiumTokens.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Vibe Match indicator badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: PremiumTokens.activeAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            seeker.spiritualityLevel.toUpperCase(),
                            style: PremiumTokens.sansStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: PremiumTokens.activeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sadhana Stats Dashboard
                    Text(
                      "DAILY SADHANA CARD",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: PremiumTokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grid of stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PremiumTokens.borderSubtle.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PremiumTokens.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSadhanCell(
                                Iconsax.music_play,
                                "Naam Jap",
                                "${(seeker.japCount / 108).toStringAsFixed(1)} Malas",
                                "${seeker.japCount} total chants",
                              ),
                              Container(width: 1, height: 40, color: PremiumTokens.borderSubtle),
                              _buildSadhanCell(
                                Iconsax.book_1,
                                "Daily Sadhan",
                                "${seeker.shlokasRead} Shlokas",
                                "${seeker.readingMinutes} mins study",
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: PremiumTokens.borderSubtle, height: 0.5),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSadhanCell(
                                Iconsax.status_up,
                                "Activity Streak",
                                "${seeker.streakCount} Days",
                                "Consecutive days active",
                              ),
                              Container(width: 1, height: 40, color: PremiumTokens.borderSubtle),
                              _buildSadhanCell(
                                Iconsax.heart,
                                "Daily Mala Goal",
                                "${seeker.dailyMalaGoal} Malas",
                                "Target chanting goal",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add Friend + Close Actions
                    _SadhanaCardActions(seeker: seeker),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSadhanCell(IconData icon, String label, String value, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: PremiumTokens.activeAccent),
              const SizedBox(width: 6),
              Text(
                label,
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: PremiumTokens.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: PremiumTokens.sansStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: PremiumTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: PremiumTokens.sansStyle(
              fontSize: 9,
              color: PremiumTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful action row for the Sadhana Card sheet — "Add Friend" toggle + "Close"
class _SadhanaCardActions extends StatefulWidget {
  final SeekerUser seeker;
  const _SadhanaCardActions({required this.seeker});

  @override
  State<_SadhanaCardActions> createState() => _SadhanaCardActionsState();
}

class _SadhanaCardActionsState extends State<_SadhanaCardActions> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    PremiumTokens.of(context);
    return Row(
      children: [
        // Add Friend Button
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _requested
                ? OutlinedButton.icon(
                    key: const ValueKey('sent'),
                    onPressed: () {
                      AppHapticFeedback.lightImpact();
                      setState(() => _requested = false);
                      PremiumUI.showNotification(
                        context,
                        "Friend request to ${widget.seeker.displayName} withdrawn.",
                        icon: Iconsax.user_remove,
                      );
                    },
                    icon: Icon(Iconsax.tick_circle5, size: 16, color: PremiumTokens.activeAccent),
                    label: Text(
                      "REQUEST SENT",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: PremiumTokens.activeAccent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: PremiumTokens.activeAccent.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  )
                : ElevatedButton.icon(
                    key: const ValueKey('add'),
                    onPressed: () {
                      AppHapticFeedback.mediumImpact();
                      setState(() => _requested = true);
                      PremiumUI.showNotification(
                        context,
                        "Friend request sent to ${widget.seeker.displayName}! 🙏",
                        icon: Iconsax.user_add,
                      );
                    },
                    icon: Icon(Iconsax.user_add, size: 16, color: PremiumTokens.onAccent),
                    label: Text(
                      "ADD FRIEND",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: PremiumTokens.onAccent,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumTokens.activeAccent,
                      foregroundColor: PremiumTokens.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        // Close Button
        SizedBox(
          width: 56,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PremiumTokens.borderMedium),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.zero,
            ),
            child: Icon(Iconsax.close_circle, size: 18, color: PremiumTokens.textMuted),
          ),
        ),
      ],
    );
  }
}
