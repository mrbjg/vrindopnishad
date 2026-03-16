import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(sacredContentProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.bokehBackground(),
          PremiumUI.mandalaOverlay(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildNowPlaying(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: content.length,
                    itemBuilder: (context, index) {
                      final item = content[index];
                      return _buildLibraryItem(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: PremiumTokens.nebulaBlue, size: 28),
          Text(
            "Sant-Vaani",
            style: PremiumTokens.displayStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.notifications_none, color: PremiumTokens.nebulaBlue, size: 24),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAkQJsMLqDCMwi1jqTeWSOOqq3Wz9ZIpqA9usLZAS95EcvHTBag2RoKJxY0vI0ignkQJ8N7UDe1CbmOARjpZ4djVMMi7DYNHPxPNoYSkcaHePL2qyHdLar7mUl0CW6gMbXv788itHF2vxM4sZWWsBBAQUG96RO8rYlrZNHgfYgQ6IfsKE6u5jOS_QRQe0dd2Fy-5dU6VL7ZLOg1jCrXoMsqJDXEiKCcCuT1CctHQ72_ivF3Rc94CqJae0t_M1fKLDyKMLPrbTHwr8I'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: PremiumTokens.surfaceCharcoal.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search sacred mantras...",
            hintStyle: PremiumTokens.sansStyle(color: Colors.white24),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: PremiumTokens.nebulaBlue),
          ),
          style: PremiumTokens.sansStyle(),
        ),
      ),
    );
  }

  Widget _buildNowPlaying() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PremiumUI.voidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCjQJTEsIPehLdGJWjz8TSfCs7o0uifTz1QfDnl0xe93A5gwv8Ccp6F6nm2FkjhjUj-lsuWJp_6-RmW3i55zjk4S3YdTRrnK9JmL9XsZSc-iTnTfSCX7_p5yEUkOkxMU3MemeaubUJtFNFJYkdACZTW5tDjmWG-00z4idxNYyHwoXDU0xQ0aLM7iRJHndrXYnv81TX6k4McMTD-djipl40MQhHU1yqz82hU_EPJxc4L3nXERe5g9bmTm34Ofr96MF0fmtSB5VA-PLg',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NOW PLAYING",
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      color: PremiumTokens.nebulaBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Gayatri Mantra (Divine Peace)",
                    style: PremiumTokens.sansStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.nebulaBlue,
              ),
              child: const Icon(Icons.pause, color: PremiumTokens.charcoal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(SacredContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumUI.voidGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PremiumTokens.surfaceCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1)),
              ),
              child: const Center(
                child: Icon(Icons.spa, color: PremiumTokens.nebulaBlue, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: PremiumTokens.sansStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PremiumTokens.nebulaBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.white24, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "10:45 • ${item.category}",
                        style: PremiumTokens.sansStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.play_arrow, color: PremiumTokens.nebulaBlue, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
