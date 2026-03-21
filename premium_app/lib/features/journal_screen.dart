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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, ref)),
                SliverToBoxAdapter(child: _buildMoonPhase()),
                journalAsync.when(
                  data: (entries) {
                    final filteredEntries = entries.where((e) => 
                      e.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                      e.content.toLowerCase().contains(searchQuery.toLowerCase())
                    ).toList();

                    if (filteredEntries.isEmpty) {
                      return SliverFillRemaining(child: _buildEmptyState());
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
                            );
                          },
                          childCount: filteredEntries.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                  error: (e, __) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: GestureDetector(
          onTap: () => _showEntryDialog(context, ref),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: PremiumTokens.nebulaGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.nebulaBlue.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.note_21, color: Colors.white10, size: 80),
          const SizedBox(height: 24),
          Text(
            "NO REFLECTIONS YET",
            style: PremiumTokens.sansStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start your journey of self-discovery",
            style: PremiumTokens.sansStyle(fontSize: 12, color: Colors.white10),
          ),
        ],
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
                color: PremiumTokens.nebulaBlue,
                onTap: () => Navigator.pop(context),
              ),
              onPressed: () {},
            )
          else
            const Icon(Iconsax.sort, color: PremiumTokens.nebulaBlue, size: 24),
          Column(
            children: [
              Text(
                "SANT-VAANI",
                style: GoogleFonts.spectral(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              Text(
                "SOUL REFLECTIONS",
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: PremiumTokens.nebulaBlue,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 20),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonPhase() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTokens.nebulaBlue.withOpacity(0.3 * value),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PremiumTokens.nebulaBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    // Moon shape
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            PremiumTokens.silver,
                            PremiumTokens.silver.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Shadow for crescent effect
                    Positioned(
                      left: 15,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF02020B), // Match background
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            "WANING CRESCENT",
            style: GoogleFonts.spectral(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Phase of Release & Reflection",
            style: PremiumTokens.sansStyle(
              fontSize: 10,
              color: PremiumTokens.nebulaBlue.withOpacity(0.6),
              letterSpacing: 1,
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
        padding: const EdgeInsets.only(right: 24),
        color: Colors.transparent,
        child: const Icon(Iconsax.trash, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        ref.read(journalProvider.notifier).deleteEntry(entry.id);
        PremiumUI.showNotification(context, "Reflection released to the void");
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white12,
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? PremiumTokens.nebulaBlue : Colors.white24,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.white12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onLongPress: () => _showEntryDialog(context, ref, entry: entry),
                  child: PremiumUI.voidCard(
                    accentColor: isActive ? PremiumTokens.nebulaBlue : Colors.white10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                style: PremiumTokens.displayStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              timeStr,
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.content,
                          style: PremiumTokens.sansStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                color: isActive ? PremiumTokens.nebulaBlue : Colors.white38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white10,
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
          ],
        ),
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
      barrierColor: Colors.black.withOpacity(0.85),
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
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.nebulaBlue)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: contentController,
                        maxLines: 8,
                        style: GoogleFonts.manrope(color: Colors.white70, fontSize: 15, height: 1.6),
                        decoration: InputDecoration(
                          hintText: "Descend into your thoughts...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
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
                                backgroundColor: PremiumTokens.nebulaBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(entry == null ? "ASCEND" : "SAVE", style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold)),
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
