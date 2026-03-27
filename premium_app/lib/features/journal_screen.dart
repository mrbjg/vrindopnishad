import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/journal_provider.dart';
import '../models/journal_entry.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

final journalSearchVisibleProvider = StateProvider<bool>((ref) => false);

class EternalReflectionScreen extends ConsumerWidget {
  final bool showBackButton;
  const EternalReflectionScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider);
    final searchQuery = ref.watch(journalSearchProvider);

    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTokens.spaceVoidGradient,
        ),
        child: Stack(
          children: [
            // Twinkling Stardust Background
            Positioned.fill(
              child: CustomPaint(
                painter: StardustPainter(),
              ),
            ),
            
            // Ambient Nebula Glows
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.15),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.3, 1.3),
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),
            ),
            
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, ref)),
                  SliverToBoxAdapter(child: _buildSoulOrb()),
                  if (ref.watch(journalSearchVisibleProvider))
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: _buildInlineSearch(context, ref),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                    ),
                  journalAsync.when(
                    data: (entries) {
                      final filteredEntries = entries.where((e) => 
                        e.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                        e.content.toLowerCase().contains(searchQuery.toLowerCase())
                      ).toList();

                      if (filteredEntries.isEmpty) {
                        return SliverFillRemaining(child: _buildEmptyState(context, ref));
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = filteredEntries[index];
                              return _buildTimelineItem(
                                context: context,
                                ref: ref,
                                entry: entry,
                                isActive: index == 0,
                              ).animate().fadeIn(delay: (index * 100).ms).moveX(begin: 10, end: 0);
                            },
                            childCount: filteredEntries.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue))),
                    error: (e, __) => SliverFillRemaining(child: Center(child: Text("Error syncing reflections: $e", style: const TextStyle(color: Colors.white38)))),
                  ),
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
              color: PremiumTokens.voidPure,
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.etherealBlue.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Iconsax.add, color: PremiumTokens.celestialSilver, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Iconsax.arrow_left, color: PremiumTokens.celestialSilver, size: 24),
              onPressed: () => Navigator.pop(context),
            )
          else
            const Icon(Iconsax.menu, color: PremiumTokens.celestialSilver, size: 24),
          Column(
            children: [
              Text(
                "SANT-VAANI",
                style: GoogleFonts.spectral(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: PremiumTokens.celestialSilver,
                ),
              ),
              Text(
                "SOUL RESONANCE",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: PremiumTokens.celestialSilver, size: 20),
            onPressed: () {
              ref.read(journalSearchVisibleProvider.notifier).state = !ref.read(journalSearchVisibleProvider);
            },
          ),
        ],
      ),
    );
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
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Icon(Iconsax.note_21, color: PremiumTokens.nebulaBlue, size: 64),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds),
          const SizedBox(height: 32),
          Text(
            "THE VOID IS SILENT",
            style: PremiumTokens.sansStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Capture your echoes of spiritual wisdom",
            style: PremiumTokens.sansStyle(
              fontSize: 12, 
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _showEntryDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              "BEGIN REFLECTION",
              style: PremiumTokens.sansStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoulOrb() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Deep Void Atmosphere (Base Glow)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTokens.silver.withValues(alpha: 0.05),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 8.seconds),

              // Evolving Aura (Sacred Pulse)
              Container(
                width: 200,
                height: 200,
                decoration: PremiumTokens.evolvingAura(
                  color: PremiumTokens.silver,
                  intensity: 0.3,
                ),
              ),

              // Outer Ring (Slow)
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumTokens.silver.withValues(alpha: 0.05),
                    width: 0.5,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .rotate(duration: 30.seconds),

              // Inner Ring (Counter-Rotate)
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PremiumTokens.silver.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .rotate(begin: 1, end: 0, duration: 20.seconds),

              // The Sacred Core
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumTokens.silver.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(1, 1), end: const Offset(2.5, 2.5), duration: 2.seconds)
                       .blur(begin: const Offset(0, 0), end: const Offset(10, 10)),
                    ),
                  ),
                ),
              ),
            ],
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
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, right: 8),
                child: Transform.rotate(
                  angle: ((entry.id.hashCode % 3) - 1) * 0.02, // Subtle -1.1 to 1.1 degree rotation
                  child: GestureDetector(
                    onTap: () => _showEntryDialog(context, ref, entry: entry),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: _getNoteGradient(entry.id.hashCode),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
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
                                  color: Colors.white24,
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
                              color: Colors.white.withValues(alpha: 0.7),
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
                                  color: Colors.white.withValues(alpha: 0.05),
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
                                color: Colors.white.withValues(alpha: 0.1),
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
    final gradients = [
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
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
                  decoration: PremiumTokens.indigoGlass(),
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
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: "Title of Enlightenment",
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.celestialSilver)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: contentController,
                        maxLines: 8,
                        style: GoogleFonts.manrope(color: Colors.white70, fontSize: 15, height: 1.6),
                        decoration: InputDecoration(
                          hintText: "Descend into your thoughts...",
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
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
                                side: const BorderSide(color: Colors.white10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text("CLOSE", style: TextStyle(color: Colors.white38, letterSpacing: 2)),
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
                                backgroundColor: PremiumTokens.voidIndigo,
                                side: BorderSide(color: PremiumTokens.celestialSilver.withValues(alpha: 0.2)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(entry == null ? "ASCEND" : "SAVE", style: const TextStyle(color: PremiumTokens.celestialSilver, letterSpacing: 2, fontWeight: FontWeight.bold)),
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
        ).animate().fadeIn().moveY(begin: 20, end: 0);
      },
    );
  }

  Widget _buildInlineSearch(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.watch(journalSearchProvider));
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Timeline line for search bar
            SizedBox(
              width: 12,
              child: Column(
                children: [
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4), // Subtle dot for search
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: PremiumUI.voidGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Icon(Iconsax.search_normal, color: Colors.white.withValues(alpha: 0.4), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => ref.read(journalSearchProvider.notifier).state = val,
                          style: PremiumTokens.sansStyle(fontSize: 14, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search reflections...",
                            hintStyle: PremiumTokens.sansStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Iconsax.close_circle, color: Colors.white24, size: 16),
                          onPressed: () {
                            searchController.clear();
                            ref.read(journalSearchProvider.notifier).state = "";
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StardustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42); // Fixed seed for stars
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
