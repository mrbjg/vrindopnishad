import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../core/stats_provider.dart';
import '../../models/user_stats.dart';
import '../content_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth_provider.dart';

class ReadingHistoryScreen extends ConsumerWidget {
  const ReadingHistoryScreen({super.key});

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text(
                  "JOURNEY HISTORY",
                  style: GoogleFonts.spectral(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16,
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
                    color: PremiumTokens.nebulaBlue,
                    onTap: () => Navigator.pop(context),
                  ),
                  onPressed: () {}, // Handled by animatedIcon onTap
                ),
                actions: [
                  historyAsync.when(
                    data: (items) => items.isNotEmpty 
                      ? TextButton(
                          onPressed: () => _showClearConfirmation(context, ref),
                          child: Text(
                            "Clear", 
                            style: GoogleFonts.manrope(
                              color: Colors.redAccent, 
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              historyAsync.when(
                data: (historyItems) {
                  if (historyItems.isEmpty) return SliverFillRemaining(child: _buildEmptyState(context));
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = historyItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PremiumUI.voidGlassCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Iconsax.clock, color: PremiumTokens.nebulaBlue, size: 20),
                                ),
                                title: Text(
                                  item.title ?? "Unknown Sacred Text",
                                  style: PremiumTokens.displayStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${item.category ?? 'Divine'} • ${_formatTime(item.readAt)}",
                                  style: PremiumTokens.sansStyle(color: Colors.white38, fontSize: 12),
                                ),
                                trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.white24),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContentDetailScreen(
                                        title: item.title ?? "",
                                        category: item.category ?? "",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        childCount: historyItems.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, __) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
        title: Text(
          "Clear History?",
          style: GoogleFonts.spectral(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "This will remove all your recorded reading sessions. This action cannot be undone.",
          style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Keep History"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(authServiceProvider).currentUser;
              if (user != null) {
                await ref.read(statsServiceProvider).clearReadingHistory(user.uid);
                ref.invalidate(readingHistoryProvider);
              }
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Iconsax.clock,
              size: 48,
              color: PremiumTokens.nebulaBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No reading history",
            style: PremiumTokens.displayStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start exploring sacred content",
            style: PremiumTokens.sansStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
