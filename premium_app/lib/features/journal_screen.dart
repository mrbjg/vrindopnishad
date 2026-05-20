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
                    child: _AtomicResonanceOrb(),
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

class _AtomicResonanceOrb extends StatelessWidget {
  const _AtomicResonanceOrb();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        RepaintBoundary(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                  // --- CELESTIAL CHRONOS SYSTEM ---
                  
                  // 1. Distant Galactic Dust (Base Atmosphere)
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.12),
                          blurRadius: 100,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 10.seconds),

                  // 1.5 Outer Dotted Orbit (Slow & Shimmering) [NEW]
                  RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(340, 340),
                      painter: CelestialRingPainter(
                        color: PremiumTokens.textPrimary,
                        thickness: 1.0,
                        isDotted: true,
                        dotCount: 40,
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                     .rotate(duration: 60.seconds),
                  ),
    
                  // 2. Atomic Shell Orbits (Elliptical Paths) [NEW]
                  ...List.generate(3, (i) => CustomPaint(
                    size: const Size(260, 260),
                    painter: AtomicOrbitPainter(
                      color: PremiumTokens.borderSubtle,
                      radius: 120,
                      rotation: i * math.pi / 3, // 0, 60, 120 degrees
                    ),
                  )),

                  // 3. The Dense Clustered Nucleus (Protons & Neutrons) [UPGRADED]
                  ...List.generate(7, (i) => Positioned(
                    left: 153 + (math.cos(i * 2 * math.pi / 7) * 8),
                    top: 153 + (math.sin(i * 2 * math.pi / 7) * 8),
                    child: Container(
                      width: i % 2 == 0 ? 14 : 12,
                      height: i % 2 == 0 ? 14 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: [
                              PremiumTokens.glassBase.withValues(alpha: 0.2), 
                              const Color(0xFF1E3A8A).withValues(alpha: 0.4), 
                              const Color(0xFF0F766E).withValues(alpha: 0.3),
                              const Color(0xFF3B82F6).withValues(alpha: 0.2),
                              const Color(0xFF14B8A6).withValues(alpha: 0.2),
                              PremiumTokens.borderMedium,
                              const Color(0xFF4F46E5).withValues(alpha: 0.3),
                            ][i % 7],
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                        gradient: RadialGradient(
                          colors: [
                            [
                              PremiumTokens.textPrimary, 
                              const Color(0xFF3B82F6), 
                              const Color(0xFF0D9488),
                              const Color(0xFF60A5FA),
                              const Color(0xFF2DD4BF),
                              PremiumTokens.textPrimary,
                              const Color(0xFF818CF8),
                            ][i % 7],
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: (1.2 + (i * 0.4)).seconds, curve: Curves.easeInOutSine)
                     .move(begin: const Offset(-3, -3), end: const Offset(3, 3), duration: (1.8 + (i * 0.2)).seconds, curve: Curves.easeInOutQuad),
                  )),

                  // 4. Electrons (Orbital Resonances) [HIGH VELOCITY]
                  _buildElectron(
                    radius: 120,
                    bodySize: 7.0, // Larger
                    color: PremiumTokens.textPrimary,
                    glowColor: PremiumTokens.textPrimary, // All white
                    duration: 1.25.seconds, // Much faster
                    rotation: 0,
                  ),
                  _buildElectron(
                    radius: 120,
                    bodySize: 6.5,
                    color: PremiumTokens.textPrimary,
                    glowColor: PremiumTokens.textPrimary,
                    duration: 1.5.seconds,
                    beginAngle: 2.1,
                    rotation: math.pi / 3, // 60 deg
                  ),
                  _buildElectron(
                    radius: 120,
                    bodySize: 6.0,
                    color: PremiumTokens.textPrimary,
                    glowColor: PremiumTokens.textPrimary,
                    duration: 1.85.seconds,
                    beginAngle: 4.5,
                    rotation: 2 * math.pi / 3, // 120 deg
                  ),
                  
                  // 5. The Core Singularity (Base Glow)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "SOUL RESONANCE",
          style: GoogleFonts.spectral(
            fontSize: 28,
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

Widget _buildElectron({
  required double radius,
  required double bodySize,
  required Color color,
  required Color glowColor,
  required Duration duration,
  double beginAngle = 0.0,
  double rotation = 0.0,
  double eccentricity = 0.35,
}) {
    return SizedBox(
      width: 0, // No size, centers perfectly in Stack
      height: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Hardware-Accelerated Rotation
          RepaintBoundary(
            child: const SizedBox.expand()
                .animate(onPlay: (c) => c.repeat())
                .custom(
              begin: beginAngle,
              end: beginAngle + 2 * math.pi,
              duration: duration,
              curve: Curves.linear, // Keep linear for smooth orbital velocity
              builder: (context, value, child) {
                // Elliptical Math
                final xPrime = radius * math.cos(value);
                final yPrime = radius * eccentricity * math.sin(value);
                
                // Rotational Math
                final x = xPrime * math.cos(rotation) - yPrime * math.sin(rotation);
                final y = xPrime * math.sin(rotation) + yPrime * math.cos(rotation);
                
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: CometTrailPainter(
                        radius: radius,
                        currentAngle: value,
                        color: glowColor.withValues(alpha: 0.2),
                        rotation: rotation,
                        eccentricity: eccentricity,
                        isAtomic: true,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(x, y), 
                      child: Container(
                        width: bodySize,
                        height: bodySize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.9), // Near-full luminosity
                              blurRadius: 15,
                              spreadRadius: 2.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

class AtomicOrbitPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double rotation;
  final double eccentricity;

  const AtomicOrbitPainter({
    required this.color,
    required this.radius,
    required this.rotation,
    this.eccentricity = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw discrete dots instead of a continuous line
    const int dotCount = 60;
    for (int i = 0; i < dotCount; i++) {
      final double angle = (2 * math.pi / dotCount) * i;
      final xPrime = radius * math.cos(angle);
      final yPrime = radius * eccentricity * math.sin(angle);
      
      final x = center.dx + xPrime * math.cos(rotation) - yPrime * math.sin(rotation);
      final y = center.dy + xPrime * math.sin(rotation) + yPrime * math.cos(rotation);
      
      final double opacity = 0.05 + (math.Random(i).nextDouble() * 0.1);
      paint.color = color.withValues(alpha: opacity);
      
      canvas.drawCircle(Offset(x, y), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AtomicOrbitPainter oldDelegate) => false;
}

class CelestialRingPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isDotted;
  final int dotCount;

  const CelestialRingPainter({
    required this.color, 
    this.thickness = 1.0, 
    this.isDotted = false,
    this.dotCount = 180,
  });

  // Pre-cached static points for the dust effect
  static final List<double> _dustAngles = List.generate(180, (i) => i * 2 * (math.pi / 180));
  static final List<double> _dustOffsets = List.generate(180, (i) => (math.Random(i).nextDouble() - 0.5) * 6);
  static final List<double> _dustOpacities = List.generate(180, (i) => (math.Random(i + 100).nextDouble() * 0.15 + 0.05));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    if (isDotted) {
      
      for (int i = 0; i < dotCount; i++) {
        final double angle = (i * 2 * math.pi) / dotCount;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 1.0, paint..style = PaintingStyle.fill..color = color.withValues(alpha: 0.15));
      }
    } else {
      // Artistic dusty ring with static distribution
      for (int i = 0; i < 180; i++) {
        final double angle = _dustAngles[i];
        final double offset = _dustOffsets[i];
        final double opacity = _dustOpacities[i];
        
        final x = center.dx + (radius + offset) * math.cos(angle);
        final y = center.dy + (radius + offset) * math.sin(angle);
        
        canvas.drawCircle(
          Offset(x, y), 
          0.6, 
          paint..style = PaintingStyle.fill..color = color.withValues(alpha: opacity)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CelestialRingPainter oldDelegate) => false;
}

class CometTrailPainter extends CustomPainter {
  final double radius;
  final double currentAngle;
  final Color color;
  final double rotation;
  final double eccentricity;
  final bool isAtomic;

  const CometTrailPainter({
    required this.radius,
    required this.currentAngle,
    required this.color,
    this.rotation = 0.0,
    this.eccentricity = 0.35,
    this.isAtomic = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    const double tailLength = 0.35; //radians
    final double startAngle = currentAngle - tailLength;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    const int segments = 12;
    for (int i = 0; i < segments; i++) {
      final double progress = i / segments;
      final double angle = startAngle + (progress * tailLength);
      
      paint.color = color.withValues(alpha: progress * 0.6); // Increased trail opacity
      paint.strokeWidth = 0.2 + (progress * 2.5); // Thicker trail
      
      if (!isAtomic) {
        // Circular Trail
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, angle, 0.1, false, paint);
      } else {
        // Elliptical Atomic Trail (segment by segment)
        final double nextAngle = angle + (tailLength / segments) * 1.2;
        
        final x1p = radius * math.cos(angle);
        final y1p = radius * eccentricity * math.sin(angle);
        final x1 = center.dx + x1p * math.cos(rotation) - y1p * math.sin(rotation);
        final y1 = center.dy + x1p * math.sin(rotation) + y1p * math.cos(rotation);

        final x2p = radius * math.cos(nextAngle);
        final y2p = radius * eccentricity * math.sin(nextAngle);
        final x2 = center.dx + x2p * math.cos(rotation) - y2p * math.sin(rotation);
        final y2 = center.dy + x2p * math.sin(rotation) + y2p * math.cos(rotation);

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CometTrailPainter oldDelegate) => true;
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
