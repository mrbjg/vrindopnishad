import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/journal_provider.dart';
import '../models/journal_entry.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EternalReflectionScreen extends ConsumerWidget {
  const EternalReflectionScreen({super.key});

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
          if (Navigator.canPop(context))
            IconButton(
              icon: PremiumUI.animatedIcon(
                folder: 'Chevron-left',
                fileName: 'chevron-left.json',
                size: 20,
                color: PremiumTokens.celestialSilver,
                onTap: () => Navigator.pop(context),
              ),
              onPressed: () {},
            )
          else
            const Icon(Iconsax.sort, color: PremiumTokens.celestialSilver, size: 24),
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
            onPressed: () => _showSearchDialog(context, ref),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.etherealBlue.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Rotating Celestial Ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
                  
                  // The Core Orb
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.voidPure,
                      border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.2), width: 0.5),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 3.seconds,
                    curve: Curves.easeInOutSine,
                  ),

                  // Interior Pulsing Glow
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTokens.celestialSilver.withValues(alpha: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.celestialSilver.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 2.seconds),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => PremiumTokens.silverGradient.createShader(bounds),
            child: Text(
              "SOUL RESONANCE",
              style: GoogleFonts.spectral(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Phase of Release & Clarity",
            style: PremiumTokens.sansStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 2,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      isActive ? PremiumTokens.celestialSilver : Colors.white10,
                    ],
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? PremiumTokens.celestialSilver : Colors.transparent,
                  border: Border.all(
                    color: isActive ? Colors.white : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: PremiumTokens.celestialSilver.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 120, // Tall enough for typical card contents
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isActive ? PremiumTokens.celestialSilver : Colors.white10,
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: () => _showEntryDialog(context, ref, entry: entry),
                child: PremiumUI.voidGlassCard(
                  optimized: false, // Use backdrop filters for absolute premium feel
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.title.toUpperCase(),
                              style: PremiumTokens.sansStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: isActive ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                          Text(
                            timeStr,
                            style: PremiumTokens.sansStyle(
                              fontSize: 10,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.content,
                        style: PremiumTokens.sansStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 4,
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
                                fontWeight: FontWeight.bold,
                                color: isActive ? PremiumTokens.celestialSilver : Colors.white38,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
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
        ],
      ),
    );
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

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.read(journalSearchProvider));
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PremiumUI.sacredSearchBar(
              controller: searchController,
              hintText: "Search reflections...",
              onChanged: (val) {
                ref.read(journalSearchProvider.notifier).state = val;
                setState(() {}); // Rebuild for suffix icon
              },
              onClear: () {
                searchController.clear();
                ref.read(journalSearchProvider.notifier).state = "";
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }
}
