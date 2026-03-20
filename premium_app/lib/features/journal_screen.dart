import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/journal_provider.dart';
import '../models/journal_entry.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Iconsax.sort, color: PremiumTokens.nebulaBlue, size: 24),
          Column(
            children: [
              Text(
                "SANT-VAANI",
                style: PremiumTokens.sansStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),
              Text(
                "SOUL REFLECTIONS",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.nebulaBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showSearchDialog(context, ref),
            child: const Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 24),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PremiumTokens.nebulaBlue.withValues(alpha: 0.2),
                  PremiumTokens.nebulaBlue.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: PremiumTokens.nebulaBlue.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTokens.voidBlack,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "WANING CRESCENT",
            style: PremiumTokens.sansStyle(
              fontSize: 12,
              color: Colors.white60,
              letterSpacing: 2,
            ),
          ),
          Text(
            "Oct 25, 2026 • The Void Calls",
            style: PremiumTokens.sansStyle(
              fontSize: 10,
              color: Colors.white38,
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
        title: Text(
          entry == null ? "NEW REFLECTION" : "EDIT REFLECTION",
          style: GoogleFonts.spectral(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Title of Enlightenment",
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.nebulaBlue)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                hintText: "Descend into your thoughts...",
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PremiumTokens.nebulaBlue)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CLOSE"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumTokens.nebulaBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
            child: Text(entry == null ? "ASCEND" : "SAVE", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.read(journalSearchProvider));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
        content: TextField(
          controller: searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search reflections...",
            hintStyle: TextStyle(color: Colors.white24),
            border: InputBorder.none,
            prefixIcon: Icon(Iconsax.search_normal, color: Colors.white24),
          ),
          onChanged: (val) {
            ref.read(journalSearchProvider.notifier).state = val;
          },
        ),
      ),
    );
  }
}
