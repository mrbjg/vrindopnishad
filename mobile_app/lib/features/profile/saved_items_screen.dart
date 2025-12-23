import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../content_detail_screen.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedItems = [
      {'title': 'Bhagavad Gita - Chapter 2', 'category': 'Shloka'},
      {'title': 'Shiva Tandava Stotram', 'category': 'Strotra'},
      {'title': 'Hanuman Chalisa', 'category': 'Poem'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Items")),
      body: savedItems.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedItems.length,
              itemBuilder: (context, index) {
                final item = savedItems[index];
                return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.bookmark,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          item['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['category']!),
                        trailing: const Icon(
                          LucideIcons.chevronRight,
                          size: 18,
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
                    )
                    .animate()
                    .fadeIn(delay: (index * 100).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderOpen, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No saved items yet",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
