import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/stats_provider.dart';

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen> {
  bool _isImmersive = false;

  @override
  Widget build(BuildContext context) {
    final japState = ref.watch(naamJapStateProvider);
    final stats = ref.watch(userStatsProvider).value;
    final isFocusMode = ref.watch(focusModeProvider);
    
    // Calculation: Integer Malas (cycles) + Completed Beads
    final int todayJaps = japState.today;
    final double todayMalas = todayJaps / 108;
    final double highestMalas = (stats?.highestDailyJaps ?? 0) / 108;
    
    final int count = japState.total;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(naamJapStateProvider.notifier).increment(context);
        },
        child: Stack(
          children: [
            // Ethereal Background
            Positioned.fill(child: PremiumUI.masterBackground(index: 2)),
            
            if (!_isImmersive)
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context, isFocusMode),
                      
                      const SizedBox(height: 20),
                      
                      // Professional Counter Display
                      _buildProfessionalCounter(count),
                      
                      const SizedBox(height: 20),
                      
                      // Interaction Area
                      _buildInteractionArea(count, isFocusMode),
                      
                      const SizedBox(height: 40),
                      
                      // Session Stats
                      _buildSessionStats(
                        isFocusMode, 
                        todayMalas,
                        highestMalas,
                        dailyGoal: stats?.dailyMalaGoal ?? 11,
                      ),
                      
                      const SizedBox(height: 140), // Spacing for Navbar + MiniPlayer
                    ],
                  ),
                ),
              ),

            if (_isImmersive)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfessionalCounter(count, simplified: true),
                    const SizedBox(height: 24),
                    Text(
                      "TAP ANYWHERE TO JAP",
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .fadeIn(duration: 1.seconds)
                     .fadeOut(delay: 2.seconds, duration: 1.seconds),
                  ],
                ),
              ),

            if (_isImmersive)
              Positioned(
                top: 50,
                left: 24, // User asked for top corner, usually back is top left or right
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isImmersive = false);
                  },
                  child: PremiumUI.glassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 16,
                    child: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isFocusMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                ref.read(navigationIndexProvider.notifier).state = 0;
              }
            },
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 14,
              child: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 20),
            ),
          ),
          
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              setState(() => _isImmersive = true);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "VOID JAP",
                  style: PremiumTokens.sansStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: PremiumTokens.celestialSilver,
                  ),
                ),
                Text(
                  "TAP TO IMMERSE",
                  style: PremiumTokens.sansStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isImmersive = true);
                },
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  child: const Icon(Iconsax.maximize_1, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showMalaHistorySheet(context);
                },
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  child: const Icon(Iconsax.clock, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCounter(int totalCount, {bool simplified = false}) {
    // Mathematical correction for Mala / Bead display
    final int completedMalas = totalCount ~/ 108;
    final int currentBead = totalCount == 0 ? 0 : (totalCount - 1) % 108 + 1;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Breathing Aura
            Animate(
              onPlay: (c) => c.repeat(reverse: true),
              effects: [
                ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
              ],
              child: Container(
                width: simplified ? 300 : 250,
                height: simplified ? 300 : 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumTokens.celestialSilver.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Glass Disk with dynamic number
            Container(
              width: simplified ? 240 : 200,
              height: simplified ? 240 : 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.02),
                border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Animate(
                  key: ValueKey(totalCount), // Triggers animation on every increment
                  effects: [
                    ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 150.ms, curve: Curves.easeOutCubic),
                    CustomEffect(
                      duration: 150.ms,
                      builder: (context, value, child) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTokens.celestialSilver.withValues(alpha: 0.1 * value),
                              blurRadius: 40 * value,
                              spreadRadius: 2 * value,
                            )
                          ],
                        ),
                        child: child,
                      ),
                    ),
                  ],
                  child: Text(
                    currentBead.toString(),
                    style: GoogleFonts.spectral(
                      fontSize: simplified ? 96 : 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: PremiumTokens.celestialSilver.withValues(alpha: 0.3), blurRadius: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!simplified) ...[
          const SizedBox(height: 16),
          // Continuous Status Display
          Animate(
            key: ValueKey(completedMalas),
            effects: [FadeEffect(duration: 400.ms), const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero)],
            child: Text(
              "MALA $completedMalas • BEAD $currentBead",
              style: PremiumTokens.sansStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: PremiumTokens.celestialSilver.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "TOTAL CHANTS: $totalCount",
            style: PremiumTokens.sansStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white38,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInteractionArea(int count, bool isFocusMode) {
    return PremiumUI.focusContainer(
      isFocusMode: isFocusMode,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(naamJapStateProvider.notifier).increment(context);
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumTokens.voidIndigo,
                    PremiumTokens.voidPure,
                  ],
                ),
                border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.celestialSilver.withValues(alpha: 0.05),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: RepaintBoundary(
                  child: SvgPicture.asset(
                    'assets/shriJiMukut.svg',
                    width: 54,
                    height: 54,
                    colorFilter: const ColorFilter.mode(
                      Colors.white, 
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            "Tap to chant",
            style: PremiumTokens.sansStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats(bool isFocusMode, double todayMalas, double highestMalas, {int dailyGoal = 0}) {
    // Format: Show integer if it's a whole number, otherwise show 1 decimal
    String formatMala(double value) {
      if (value == value.toInt().toDouble()) {
        return value.toInt().toString();
      }
      return value.toStringAsFixed(1);
    }

    return PremiumUI.focusContainer(
      isFocusMode: isFocusMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: PremiumUI.glassCard(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          borderRadius: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatItem("TODAY MALA", formatMala(todayMalas), PremiumTokens.celestialSilver)),
              Container(width: 1, height: 30, color: Colors.white10),
              Expanded(child: _buildStatItem("GOAL", dailyGoal.toString(), PremiumTokens.celestialSilver.withValues(alpha: 0.5))),
              Container(width: 1, height: 30, color: Colors.white10),
              Expanded(child: _buildStatItem("HIGHEST", formatMala(highestMalas), PremiumTokens.celestialSilver.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color accent) {
    return Column(
      children: [
        Text(
          label,
          style: PremiumTokens.sansStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PremiumTokens.sansStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent),
        ),
      ],
    );
  }

  void _showMalaHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MalaHistorySheet(),
    );
  }
}

class _MalaHistorySheet extends ConsumerStatefulWidget {
  const _MalaHistorySheet();

  @override
  ConsumerState<_MalaHistorySheet> createState() => _MalaHistorySheetState();
}

class _MalaHistorySheetState extends ConsumerState<_MalaHistorySheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(japHistoryProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumTokens.voidIndigo.withValues(alpha: 0.95),
            PremiumTokens.voidBlack,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "MALA HISTORY",
            style: PremiumTokens.sansStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Ethereal TabBar
          TabBar(
            controller: _tabController,
            indicatorColor: PremiumTokens.celestialSilver,
            dividerColor: Colors.transparent,
            labelStyle: PremiumTokens.sansStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
            unselectedLabelColor: PremiumTokens.celestialSilver.withValues(alpha: 0.2),
            tabs: const [
              Tab(text: "DAILY"),
              Tab(text: "WEEKLY"),
              Tab(text: "YEARLY"),
            ],
          ),
          
          Expanded(
            child: historyAsync.when(
              data: (history) => TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryContent(history, "daily"),
                  _buildHistoryContent(history, "weekly"),
                  _buildHistoryContent(history, "yearly"),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue)),
              error: (e, _) => const Center(child: Text("Error loading history", style: TextStyle(color: Colors.white54))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(List<Map<String, dynamic>> history, String timeframe) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.radar, color: Colors.white10, size: 64),
            const SizedBox(height: 16),
            Text(
              "No sacred history found yet",
              style: PremiumTokens.sansStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Process History
    final now = DateTime.now();
    double totalMalas = 0;
    int peakCount = 0;
    final Map<String, int> groupedData = {};

    for (var entry in history) {
      final count = entry['count'] as int;
      final createdAt = DateTime.parse(entry['created_at'] as String);
      totalMalas += count / 108;
      if (count > peakCount) peakCount = count;

      String key = "";
      if (timeframe == "daily") {
        // If it's today, show hourly. Otherwise group by day of the week.
        if (now.difference(createdAt).inDays < 1 && now.day == createdAt.day) {
          final hour = createdAt.hour;
          key = "$hour:00";
          groupedData[key] = (groupedData[key] ?? 0) + count;
        } else if (now.difference(createdAt).inDays < 7) {
          key = "${createdAt.day}/${createdAt.month}";
          groupedData[key] = (groupedData[key] ?? 0) + count;
        }
      } else if (timeframe == "weekly") {
        // Last 4 weeks
        final weekNum = (createdAt.day / 7).ceil();
        key = "W$weekNum";
        groupedData[key] = (groupedData[key] ?? 0) + count;
      } else {
        // Last 12 months
        key = "${createdAt.month}/${createdAt.year}";
        groupedData[key] = (groupedData[key] ?? 0) + count;
      }
    }

    // Prepare chart data (max 7 bars for visibility)
    final entries = groupedData.entries.toList();
    final chartValues = entries.map((e) => e.value.toDouble()).toList();
    if (chartValues.isEmpty) chartValues.add(0);
    final maxValue = chartValues.reduce((a, b) => a > b ? a : b);
    
    // Unique days counts for average
    final uniqueDays = history.map((e) => DateTime.parse(e['created_at']).toIso8601String().split('T')[0]).toSet().length;
    final dailyAvg = uniqueDays > 0 ? (totalMalas / uniqueDays) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PremiumUI.etherealCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            glowColor: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeframe.toUpperCase(),
                      style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Icon(Iconsax.status_up, color: PremiumTokens.celestialSilver, size: 20),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: chartValues.map((v) => _buildMiniBar(maxValue > 0 ? v / maxValue : 0)).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryItem("Total Malas", totalMalas.toStringAsFixed(1), PremiumTokens.celestialSilver),
          const SizedBox(height: 12),
          _buildSummaryItem("Daily Average", dailyAvg.toStringAsFixed(1), Colors.white70),
          const SizedBox(height: 12),
          _buildSummaryItem("Peak Milestone", "$peakCount Chants", PremiumTokens.celestialSilver.withValues(alpha: 0.7)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    // Map labels to relevant sacred icons
    String emoji = '✨';
    if (label.contains('Total')) emoji = '📿';
    if (label.contains('Average')) emoji = '📊';
    if (label.contains('Peak')) emoji = '🏆';

    return PremiumUI.etherealCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 20,
      glowColor: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: EmojiToIcon.getIconWidget(emoji, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: PremiumTokens.sansStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 2),
                PremiumUI.silverText(
                  value,
                  style: PremiumTokens.sansStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, color: Colors.white10, size: 16),
        ],
      ),
    );
  }

  Widget _buildMiniBar(double heightFactor) {
    return Container(
      width: 12,
      height: 120 * heightFactor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            PremiumTokens.celestialSilver.withValues(alpha: 0.05),
            PremiumTokens.celestialSilver.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
