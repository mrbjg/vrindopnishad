import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/stats_provider.dart';
import '../core/color_theme_provider.dart';
import '../widgets/animated_effects.dart';

class NaamJapScreen extends ConsumerStatefulWidget {
  const NaamJapScreen({super.key});

  @override
  ConsumerState<NaamJapScreen> createState() => _NaamJapScreenState();
}

class _NaamJapScreenState extends ConsumerState<NaamJapScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isImmersive = false;
  late final AudioPlayer _ambiencePlayer;
  bool _isAudioPlaying = false;
  String _selectedAmbiance = 'None';

  final Map<String, String> _ambianceTracks = {
    'None': '',
    'Sacred Drone': 'https://actions.google.com/sounds/v1/ambiences/wind_constant.ogg',
    'Flowing Ganges': 'https://actions.google.com/sounds/v1/ambiences/river_flowing.ogg',
    'Temple Chimes': 'https://actions.google.com/sounds/v1/ambiences/morning_birds.ogg',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ambiencePlayer = AudioPlayer();
    _ambiencePlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _ambiencePlayer.dispose();
    super.dispose();
  }

  Future<void> _playAmbiance(String key) async {
    final url = _ambianceTracks[key]!;
    if (url.isEmpty) {
      await _ambiencePlayer.stop();
      setState(() {
        _selectedAmbiance = 'None';
        _isAudioPlaying = false;
      });
      return;
    }

    try {
      setState(() {
        _selectedAmbiance = key;
        _isAudioPlaying = true;
      });
      await _ambiencePlayer.setUrl(url);
      await _ambiencePlayer.play();
    } catch (e) {
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  void _showAmbianceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumTokens.sheetBgTop,
                PremiumTokens.sheetBgBottom,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTokens.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "SELECT AMBIANCE",
                style: PremiumTokens.sansStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: PremiumTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ..._ambianceTracks.keys.map((key) {
                final isSelected = _selectedAmbiance == key;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      key,
                      style: PremiumTokens.sansStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Iconsax.tick_circle, color: PremiumTokens.activeAccent)
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setSheetState(() => _selectedAmbiance = key);
                      _playAmbiance(key);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final japState = ref.watch(naamJapStateProvider);
    final stats = ref.watch(userStatsProvider).value;
    final isFocusMode = ref.watch(focusModeProvider);
    
    // Calculation: Integer Malas (cycles) + Completed Beads
    final int todayJaps = japState.today;
    final double todayMalas = todayJaps / 108;
    final double highestMalas = (stats?.highestDailyJaps ?? 0) / 108;
    
    final int count = japState.total;

    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final int nextCount = count + 1;
          if (nextCount > 0 && nextCount % 108 == 0) {
            // High-fidelity physical vibration sequence on completing 108 chants
            HapticFeedback.heavyImpact();
            Future.delayed(const Duration(milliseconds: 120), () => HapticFeedback.heavyImpact());
            Future.delayed(const Duration(milliseconds: 240), () => HapticFeedback.heavyImpact());
          } else {
            HapticFeedback.lightImpact();
          }
          ref.read(naamJapStateProvider.notifier).increment(context);
        },
        child: Stack(
          children: [
            // Ethereal Background
            Positioned.fill(child: PremiumUI.masterBackground(index: 2, context: context)),
            
            if (!_isImmersive)
              SafeArea(
                bottom: false,
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
                      
                      const SizedBox(height: 180), // Spacing for Navbar + MiniPlayer
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
                        color: PremiumTokens.textMuted,
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
                child: PressableScale(
                  onTap: () {
                    setState(() => _isImmersive = false);
                  },
                  child: PremiumUI.glassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 16,
                    child: Icon(Iconsax.arrow_left_2, color: PremiumTokens.textPrimary, size: 24),
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
          PressableScale(
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
              child: Icon(Iconsax.arrow_left_2, color: PremiumTokens.textPrimary, size: 20),
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
          
          PressableScale(
            onTap: () {
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
                    color: PremiumTokens.textPrimary,
                  ),
                ),
                Text(
                  "TAP TO IMMERSE",
                  style: PremiumTokens.sansStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: PremiumTokens.glassBase.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              PressableScale(
                onTap: () {
                  setState(() => _isImmersive = true);
                },
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  child: Icon(Iconsax.maximize_1, color: PremiumTokens.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              PressableScale(
                onTap: () {
                  _showAmbianceSheet(context);
                },
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  child: Icon(
                    _isAudioPlaying ? Iconsax.volume_high : Iconsax.volume_cross,
                    color: _isAudioPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PressableScale(
                onTap: () {
                  _showMalaHistorySheet(context);
                },
                child: PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  child: Icon(Iconsax.clock, color: PremiumTokens.textPrimary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCounter(int totalCount, {bool simplified = false}) {
    final int completedMalas = totalCount ~/ 108;
    final int currentBead = totalCount == 0 ? 0 : (totalCount - 1) % 108 + 1;
    final double progress = (currentBead / 108).clamp(0.0, 1.0);
    final palette = ref.watch(colorPaletteProvider);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer breathing glow aura
            Animate(
              onPlay: (c) => c.repeat(reverse: true),
              effects: [
                ScaleEffect(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.16, 1.16),
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),
              ],
              child: Container(
                width: simplified ? 310 : 262,
                height: simplified ? 310 : 262,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.glow.withValues(alpha: 0.20),
                      palette.glow.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Progress arc ring
            SizedBox(
              width: simplified ? 270 : 226,
              height: simplified ? 270 : 226,
              child: CustomPaint(
                painter: _ChantArcPainter(
                  progress: progress,
                  accent: palette.accent,
                  glow: palette.glow,
                  completedMalas: completedMalas,
                ),
              ),
            ),

            // Inner glass disc
            Container(
              width: simplified ? 224 : 186,
              height: simplified ? 224 : 186,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.surfaceMain.withValues(alpha: 0.72),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.glow.withValues(alpha: 0.22),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Animate(
                  key: ValueKey(totalCount),
                  effects: [
                    ScaleEffect(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.13, 1.13),
                      duration: 140.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentBead.toString(),
                        style: GoogleFonts.spectral(
                          fontSize: simplified ? 88 : 68,
                          fontWeight: FontWeight.w200,
                          color: PremiumTokens.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      if (currentBead > 0)
                        Text(
                          "of 108",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            color: palette.accent.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!simplified) ...[
          const SizedBox(height: 20),
          Animate(
            key: ValueKey(completedMalas),
            effects: [FadeEffect(duration: 400.ms), const SlideEffect(begin: Offset(0, 0.2), end: Offset.zero)],
            child: Text(
              "MALA $completedMalas • BEAD $currentBead",
              style: PremiumTokens.sansStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: PremiumTokens.textSecondary,
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
              color: PremiumTokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInteractionArea(int count, bool isFocusMode) {
    final palette = ref.watch(colorPaletteProvider);
    return PremiumUI.focusContainer(
      isFocusMode: isFocusMode,
      child: Column(
        children: [
          // Glowing gradient chant button
          PressableScale(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(naamJapStateProvider.notifier).increment(context);
            },
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.accent, palette.accentDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.glow.withValues(alpha: 0.55),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: palette.glow.withValues(alpha: 0.20),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: RepaintBoundary(
                  child: SvgPicture.asset(
                    'assets/shriJiMukut.svg',
                    width: 52,
                    height: 52,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().scale(duration: 700.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          // Pulsing hint label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.accent.withValues(alpha: 0.7),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scaleXY(end: 1.5, duration: 1.2.seconds),
              const SizedBox(width: 8),
              Text(
                "Tap to chant",
                style: PremiumTokens.sansStyle(
                  fontSize: 12,
                  color: PremiumTokens.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
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
              Expanded(child: _buildStatItem("TODAY MALA", formatMala(todayMalas), PremiumTokens.accentSilver)),
              Container(width: 1, height: 30, color: PremiumTokens.borderSubtle),
              Expanded(child: _buildStatItem("GOAL", dailyGoal.toString(), PremiumTokens.textSecondary)),
              Container(width: 1, height: 30, color: PremiumTokens.borderSubtle),
              Expanded(child: _buildStatItem("HIGHEST", formatMala(highestMalas), PremiumTokens.textSecondary)),
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
          style: PremiumTokens.sansStyle(fontSize: 8, fontWeight: FontWeight.w900, color: PremiumTokens.textMuted, letterSpacing: 1),
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
            PremiumTokens.sheetBgTop,
            PremiumTokens.sheetBgBottom,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PremiumTokens.textHint,
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
              color: PremiumTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Ethereal TabBar
          TabBar(
            controller: _tabController,
            indicatorColor: PremiumTokens.accentSilver,
            dividerColor: Colors.transparent,
            labelStyle: PremiumTokens.sansStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
            unselectedLabelColor: PremiumTokens.textMuted,
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
              loading: () => Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent)),
              error: (e, _) => Center(child: Text("Error loading history", style: TextStyle(color: PremiumTokens.textMuted))),
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
            Icon(Iconsax.radar, color: PremiumTokens.borderSubtle, size: 64),
            const SizedBox(height: 16),
            Text(
              "No sacred history found yet",
              style: PremiumTokens.sansStyle(color: PremiumTokens.textHint, fontSize: 13),
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
            glowColor: PremiumTokens.textMuted,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeframe.toUpperCase(),
                      style: PremiumTokens.sansStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PremiumTokens.textPrimary),
                    ),
                    Icon(Iconsax.status_up, color: PremiumTokens.textPrimary, size: 20),
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
          _buildSummaryItem("Total Malas", totalMalas.toStringAsFixed(1), PremiumTokens.accentSilver),
          const SizedBox(height: 12),
          _buildSummaryItem("Daily Average", dailyAvg.toStringAsFixed(1), PremiumTokens.textSecondary),
          const SizedBox(height: 12),
          _buildSummaryItem("Peak Milestone", "$peakCount Chants", PremiumTokens.textSecondary),
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
                    color: PremiumTokens.textMuted,
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
          Icon(Iconsax.arrow_right_3, color: PremiumTokens.borderSubtle, size: 16),
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
            PremiumTokens.textMuted,
            PremiumTokens.textMuted,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Draws a glowing progress arc ring around the chant counter disc.
class _ChantArcPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final Color glow;
  final int completedMalas;

  _ChantArcPainter({
    required this.progress,
    required this.accent,
    required this.glow,
    required this.completedMalas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const startAngle = -math.pi / 2; // top

    // Track ring (dim background)
    final trackPaint = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Glow layer
    final glowPaint = Paint()
      ..color = glow.withValues(alpha: 0.25)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    // Solid arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi * progress,
        colors: [accent.withValues(alpha: 0.6), accent],
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      arcPaint,
    );

    // Dot at tip of arc
    if (progress > 0.01) {
      final tipAngle = startAngle + 2 * math.pi * progress;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(tipX, tipY), 5, dotPaint);
      final dotGlowPaint = Paint()
        ..color = glow.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(tipX, tipY), 7, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(_ChantArcPainter old) =>
      old.progress != progress || old.accent != accent || old.completedMalas != completedMalas;
}

