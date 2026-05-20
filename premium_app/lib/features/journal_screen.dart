import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:premium_app/core/design_system.dart';
import 'package:premium_app/core/journal_provider.dart';
import 'package:premium_app/core/theme.dart';
import 'package:premium_app/core/color_theme_provider.dart';
import 'package:premium_app/models/journal_entry.dart';

final journalSearchProvider = StateProvider<String>((ref) => "");
final journalSearchVisibleProvider = StateProvider<bool>((ref) => false);

class EternalReflectionScreen extends ConsumerWidget {
  final bool showBackButton;

  const EternalReflectionScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            PremiumTokens.surfaceMain,
            PremiumTokens.scaffoldBg,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Stardust Background
            const Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: StardustPainter(),
                ),
              ),
            ),
            
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _JournalHeader(showBackButton: showBackButton),
                  ),
                  const SliverToBoxAdapter(
                    child: _SacredResonanceOrb(),
                  ),
                  const _JournalEntryList(),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _showEntryDialog(context, ref);
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: PremiumTokens.fabBg,
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.textMuted, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.etherealBlue.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Iconsax.add, color: PremiumTokens.textPrimary, size: 28),
          ),
        ),
      ),
    );
  }
}

class _JournalHeader extends ConsumerWidget {
  final bool showBackButton;
  const _JournalHeader({required this.showBackButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearchActive = ref.watch(journalSearchVisibleProvider);
    final searchController = TextEditingController(text: ref.read(journalSearchProvider));
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSearchActive
            ? Container(
                key: const ValueKey("search_header"),
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: PremiumTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: PremiumTokens.borderMedium),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.search_normal, color: PremiumTokens.textMuted, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: (val) => ref.read(journalSearchProvider.notifier).state = val,
                        style: PremiumTokens.sansStyle(fontSize: 14, color: PremiumTokens.textPrimary),
                        decoration: InputDecoration(
                          hintText: "Filter reflections...",
                          hintStyle: PremiumTokens.sansStyle(
                            fontSize: 14,
                            color: PremiumTokens.glassBase.withValues(alpha: 0.2),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.close_circle, color: PremiumTokens.textHint, size: 18),
                      onPressed: () {
                        ref.read(journalSearchVisibleProvider.notifier).state = false;
                        ref.read(journalSearchProvider.notifier).state = "";
                      },
                    ),
                  ],
                ),
              )
            : Row(
                key: const ValueKey("title_header"),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary, size: 24),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    Icon(Iconsax.menu, color: PremiumTokens.textPrimary, size: 24),
                  Column(
                    children: [
                      Text(
                        "SANT-VAANI",
                        style: GoogleFonts.spectral(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: PremiumTokens.textPrimary,
                        ),
                      ),
                      Text(
                        "SOUL RESONANCE",
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          color: PremiumTokens.textMuted,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Iconsax.search_normal, color: PremiumTokens.textPrimary, size: 20),
                    onPressed: () {
                      ref.read(journalSearchVisibleProvider.notifier).state = true;
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _JournalEntryList extends ConsumerWidget {
  const _JournalEntryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalProvider);
    final searchQuery = ref.watch(journalSearchProvider).toLowerCase();

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context, ref),
          );
        }

        final filteredEntries = entries.where((e) => 
          e.title.toLowerCase().contains(searchQuery) || 
          e.content.toLowerCase().contains(searchQuery)
        ).toList();

        if (filteredEntries.isEmpty && searchQuery.isNotEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                "No echoes found matching your search",
                style: TextStyle(color: PremiumTokens.textHint),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = filteredEntries[index];
                return _buildTimelineItem(
                  context: context,
                  ref: ref,
                  entry: entry,
                  isActive: index == 0,
                ).animate()
                 .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                 .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 500.ms)
                 .moveX(begin: 20, end: 0, curve: Curves.easeOutCubic);
              },
              childCount: filteredEntries.length,
            ),
          ),
        );
      },
      loading: () => SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: PremiumTokens.activeAccent))),
      error: (e, __) => SliverFillRemaining(child: Center(child: Text("Error syncing reflections: $e", style: TextStyle(color: PremiumTokens.textMuted)))),
    );
  }
}

class _SacredResonanceOrb extends StatefulWidget {
  const _SacredResonanceOrb();

  @override
  State<_SacredResonanceOrb> createState() => _SacredResonanceOrbState();
}

class _SacredResonanceOrbState extends State<_SacredResonanceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final activeColor = ref.watch(colorPaletteProvider).accent;
        return Column(
          children: [
            const SizedBox(height: 32),
            SizedBox(
              width: 300,
              height: 300,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner glowing core
                      Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              activeColor.withValues(alpha: 0.28),
                              activeColor.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Secondary inner core with pulse animation
                      Transform.scale(
                        scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.08),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeColor.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            gradient: RadialGradient(
                              colors: [
                                activeColor.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: activeColor.withValues(alpha: 0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Ripple Painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ResonanceRipplePainter(
                            progress: _controller.value,
                            color: activeColor,
                          ),
                        ),
                      ),
                      
                      // Floating delicate light nodes
                      ...List.generate(4, (index) {
                        final angle = (index * math.pi / 2) + (_controller.value * 2 * math.pi * (index % 2 == 0 ? 1 : -1) * 0.15);
                        final distance = 65.0 + (math.sin(_controller.value * 2 * math.pi + index) * 10);
                        return Transform.translate(
                          offset: Offset(
                            math.cos(angle) * distance,
                            math.sin(angle) * distance,
                          ),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeColor.withValues(alpha: 0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "SOUL RESONANCE",
              style: GoogleFonts.spectral(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                letterSpacing: 8,
                color: PremiumTokens.silver,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Phase of Release & Clarity",
              style: PremiumTokens.sansStyle(
                fontSize: 10,
                color: PremiumTokens.silver.withValues(alpha: 0.3),
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }
}

class _ResonanceRipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ResonanceRipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final solidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = 35.0 + (ringProgress * (maxRadius - 35.0));
      final opacity = math.sin(ringProgress * math.pi) * 0.25;

      solidPaint.color = color.withValues(alpha: opacity);
      
      if (i % 2 == 0) {
        canvas.drawCircle(center, radius, solidPaint);
      } else {
        _drawDashedCircle(canvas, center, radius, solidPaint, dashLength: 6, gapLength: 4);
      }
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final double circumference = 2 * math.pi * radius;
    final int dashCount = (circumference / (dashLength + gapLength)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * 2 * math.pi) / dashCount;
      final double sweepAngle = (dashLength / circumference) * 2 * math.pi;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ResonanceRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PremiumTokens.borderSubtle,
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          child: Icon(Iconsax.note_21, color: PremiumTokens.activeAccent, size: 64),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds),
        const SizedBox(height: 32),
        Text(
          "THE VOID IS SILENT",
          style: PremiumTokens.sansStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: PremiumTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Capture your echoes of spiritual wisdom",
          style: PremiumTokens.sansStyle(
            fontSize: 12, 
            color: PremiumTokens.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => _showEntryDialog(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: PremiumTokens.borderSubtle,
            side: BorderSide(color: PremiumTokens.borderMedium),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            "BEGIN REFLECTION",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: PremiumTokens.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTimelineItem({
  required BuildContext context,
  required WidgetRef ref,
  required JournalEntry entry,
  bool isActive = false,
}) {
    final timeStr = "${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')} ${entry.createdAt.hour >= 12 ? 'PM' : 'AM'}";
    final dateStr = "${entry.createdAt.day}/${entry.createdAt.month}";

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        ref.read(journalProvider.notifier).deleteEntry(entry.id);
        PremiumUI.showNotification(context, "Reflection released to the void");
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline indicator
            SizedBox(
              width: 12,
              child: Column(
                children: [
                  Container(
                    width: 1,
                    height: 40,
                    color: PremiumTokens.borderMedium,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.textPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.textPrimary.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: PremiumTokens.borderMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, right: 0),
                child: Transform.rotate(
                  angle: ((entry.id.hashCode % 3) - 1) * 0.02, // Subtle -1.1 to 1.1 degree rotation
                  child: GestureDetector(
                    onTap: () => _showEntryDialog(context, ref, entry: entry),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: _getNoteGradient(entry.id.hashCode),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PremiumTokens.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTokens.scaffoldBg.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      foregroundDecoration: AppTheme.lowPerformanceMode
                          ? null
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: PremiumTokens.liquidGlassRefraction,
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title.toUpperCase(),
                                  style: GoogleFonts.spectral(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 3,
                                    color: PremiumTokens.silver,
                                  ),
                                ),
                              ),
                              Text(
                                timeStr,
                                style: PremiumTokens.sansStyle(
                                  fontSize: 10,
                                  color: PremiumTokens.textHint,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            entry.content,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              color: PremiumTokens.textPrimary.withValues(alpha: 0.7),
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PremiumTokens.borderSubtle,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  dateStr,
                                  style: PremiumTokens.sansStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: PremiumTokens.silver.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Iconsax.arrow_right_1, 
                                size: 14, 
                                color: PremiumTokens.borderMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

LinearGradient _getNoteGradient(int seed) {
    final isDark = PremiumTokens.isDark;
    final gradients = isDark ? [
      // Deep Indigo
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF16163F).withValues(alpha: 0.4),
          const Color(0xFF0A0A1A).withValues(alpha: 0.6),
        ],
      ),
      // Deep Plum
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1F1235).withValues(alpha: 0.4),
          const Color(0xFF0A0A1A).withValues(alpha: 0.6),
        ],
      ),
      // Deep Teal
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF122C35).withValues(alpha: 0.4),
          const Color(0xFF0A0A1A).withValues(alpha: 0.6),
        ],
      ),
    ] : [
      // Warm Cream
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFF8F0).withValues(alpha: 0.95),
          const Color(0xFFFFF3E0).withValues(alpha: 0.9),
        ],
      ),
      // Soft Lavender
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF3E8FF).withValues(alpha: 0.95),
          const Color(0xFFEDE7F6).withValues(alpha: 0.9),
        ],
      ),
      // Sage Mist
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFE8F5E9).withValues(alpha: 0.95),
          const Color(0xFFF1F8E9).withValues(alpha: 0.9),
        ],
      ),
    ];
    return gradients[seed % gradients.length];
  }

void _showEntryDialog(BuildContext context, WidgetRef ref, {JournalEntry? entry}) {
    final titleController = TextEditingController(text: entry?.title);
    final contentController = TextEditingController(text: entry?.content);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: PremiumTokens.sheetBgTop,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: PremiumTokens.borderMedium),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTokens.etherealBlue.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  foregroundDecoration: AppTheme.lowPerformanceMode
                      ? null
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: PremiumTokens.liquidGlassRefraction,
                        ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PremiumUI.silverText(
                        entry == null ? "ASCEND TO THOUGHT" : "REFINE REFLECTION",
                        style: GoogleFonts.spectral(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: titleController,
                        style: TextStyle(color: PremiumTokens.textPrimary, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: "Title of Enlightenment",
                          hintStyle: TextStyle(color: PremiumTokens.glassBase.withValues(alpha: 0.2)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.borderSubtle)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.textPrimary)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: contentController,
                        maxLines: 8,
                        style: GoogleFonts.manrope(color: PremiumTokens.textSecondary, fontSize: 15, height: 1.6),
                        decoration: InputDecoration(
                          hintText: "Descend into your thoughts...",
                          hintStyle: TextStyle(color: PremiumTokens.glassBase.withValues(alpha: 0.2)),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: PremiumTokens.borderSubtle),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text("CLOSE", style: TextStyle(color: PremiumTokens.textMuted, letterSpacing: 2)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final title = titleController.text.trim();
                                final content = contentController.text.trim();
                                if (title.isNotEmpty) {
                                  if (entry == null) {
                                    ref.read(journalProvider.notifier).addEntry(title, content);
                                  } else {
                                    ref.read(journalProvider.notifier).updateEntry(entry.id, title: title, content: content);
                                  }
                                  Navigator.pop(ctx);
                                  HapticFeedback.mediumImpact();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PremiumTokens.surfaceMain,
                                side: BorderSide(color: PremiumTokens.textMuted),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(entry == null ? "ASCEND" : "SAVE", style: TextStyle(color: PremiumTokens.textPrimary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate(delay: (animation.value * 0).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 450.ms).moveY(begin: 30, end: 0);
      },
    );
  }


class StardustPainter extends CustomPainter {
  const StardustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sizeStar = random.nextDouble() * 1.8;
      final opacity = random.nextDouble() * 0.3 + 0.1;
      
      paint.color = PremiumTokens.textPrimary.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), sizeStar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StardustPainter oldDelegate) => false;
}
