import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../content_detail_screen.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final historyItems = [
      {'title': 'Ashtavakra Gita', 'category': 'Shloka', 'time': '2 hours ago'},
      {'title': 'Gayatri Mantra', 'category': 'Strotra', 'time': 'Yesterday'},
      {
        'title': 'Introduction to Vedas',
        'category': 'Article',
        'time': '3 days ago',
      },
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text("Reading History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: historyItems.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.clock,
                        color: isDark ? Colors.white60 : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "${item['category']} • ${item['time']}",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentDetailScreen(
                            title: item['title']!,
                            category: item['category']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.history,
              size: 48,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No reading history",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start exploring sacred content",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
