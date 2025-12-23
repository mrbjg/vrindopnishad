import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../content_detail_screen.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text("Reading History"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.clock, color: Colors.grey),
                  ),
                  title: Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${item['category']} • ${item['time']}"),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
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
}
