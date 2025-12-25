import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../content_detail_screen.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final savedItems = [
      {'title': 'Bhagavad Gita - Chapter 2', 'category': 'Shloka'},
      {'title': 'Shiva Tandava Stotram', 'category': 'Strotra'},
      {'title': 'Hanuman Chalisa', 'category': 'Poem'},
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text("Saved Items"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: savedItems.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedItems.length,
              itemBuilder: (context, index) {
                final item = savedItems[index];
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
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.bookmark,
                        color: Colors.white,
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
                      item['category']!,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
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
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.folderOpen,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No saved items yet",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bookmark your favorite content",
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
