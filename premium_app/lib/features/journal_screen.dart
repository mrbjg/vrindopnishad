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
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: StardustPainter(),
                ),
              ),
            ),
            
            // Deep Background Nebula
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1E3A8A).withValues(alpha: 0.15),
                      const Color(0xFF0F172A).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.4, 1.4),
                duration: 6.seconds,
                curve: Curves.easeInOut,
              ),
            ),
            
            // Teal Resonance Nebula
            Positioned(
              top: 100,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF134E4A).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 8.seconds,
                curve: Curves.easeInOut,
              ),
            ),
            
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, ref)),
                  SliverToBoxAdapter(child: _buildSoulOrb()),
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
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.search_normal, color: Colors.white38, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: (val) => ref.read(journalSearchProvider.notifier).state = val,
                        style: PremiumTokens.sansStyle(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Filter reflections...",
                          hintStyle: PremiumTokens.sansStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle, color: Colors.white24, size: 18),
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
                      ref.read(journalSearchVisibleProvider.notifier).state = true;
                    },
                  ),
                ],
              ),
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
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
                          blurRadius: 100,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 10.seconds),
    
                  // 2. The Textured Saturn Ring (Dusty Debris)
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: const CelestialRingPainter(
                      color: Color(0x26E5E2E1), // PremiumTokens.silver with alpha 0.15
                      thickness: 1.5,
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                   .rotate(duration: 40.seconds),
    
                  // 3. Inner Cosmic Ring (Faint)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                  ),
    
                  // 4. Orbiting Bodies (Planetary Resonances)
                  
                  // Planet Indigo (Outer, Slow)
                  _buildOrbitalBody(
                    radius: 125,
                    bodySize: 8,
                    color: const Color(0xFF312E81),
                    glowColor: Colors.blueAccent,
                    duration: 25.seconds,
                    glowIntensity: 0.6,
                  ),
    
                  // Planet Teal (Middle, Fluid)
                  _buildOrbitalBody(
                    radius: 100,
                    bodySize: 6,
                    color: const Color(0xFF0F766E),
                    glowColor: Colors.tealAccent,
                    duration: 15.seconds,
                    beginAngle: 2.0, // Start elsewhere
                    glowIntensity: 0.4,
                  ),
    
                  // Starlight Spark (Inner, Fast)
                  _buildOrbitalBody(
                    radius: 75,
                    bodySize: 3,
                    color: Colors.white,
                    glowColor: Colors.white,
                    duration: 8.seconds,
                    beginAngle: 4.5,
                    glowIntensity: 1.0,
                  ),
    
                  // 5. The Sacred Singularity (Core)
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          PremiumTokens.silver.withValues(alpha: 0.2),
                          const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                          gradient: const RadialGradient(
                            colors: [Colors.white, Colors.transparent],
                            stops: [0.1, 1.0],
                          ),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds)
                       .blur(begin: const Offset(5, 5), end: const Offset(15, 15)),
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


  Widget _buildOrbitalBody({
    required double radius,
    required double bodySize,
    required Color color,
    required Color glowColor,
    required Duration duration,
    double beginAngle = 0.0,
    double glowIntensity = 0.5,
  }) {
    return SizedBox(
      width: radius * 2 + 20,
      height: radius * 2 + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbital Path (Faint) - Const-like
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.015),
                width: 0.5,
              ),
            ),
            child: SizedBox(width: radius * 2, height: radius * 2),
          ),
          // Hardware-Accelerated Rotation
          RepaintBoundary(
            child: const SizedBox.expand()
                .animate(onPlay: (c) => c.repeat())
                .custom(
              begin: beginAngle,
              end: beginAngle + 2 * math.pi,
              duration: duration,
              builder: (context, value, child) {
                // Using transform.translate directly
                final x = radius * math.cos(value);
                final y = radius * math.sin(value);
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Center(
                    child: Container(
                      width: bodySize,
                      height: bodySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.4 * glowIntensity),
                            blurRadius: 8 * glowIntensity,
                            spreadRadius: 1 * glowIntensity,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CelestialRingPainter extends CustomPainter {
  final Color color;
  final double thickness;

  const CelestialRingPainter({required this.color, this.thickness = 1.0});

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

    // Faster drawing using pre-calculated lists
    for (int i = 0; i < _dustAngles.length; i++) {
      final angle = _dustAngles[i];
      final rOffset = _dustOffsets[i];
      final alpha = _dustOpacities[i];
      
      paint.color = color.withValues(alpha: alpha);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + rOffset), 
        angle, 
        0.04, 
        false, 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CelestialRingPainter oldDelegate) => false;
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
