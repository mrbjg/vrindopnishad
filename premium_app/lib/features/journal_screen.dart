import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background managed at navigation level
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildMoonPhase()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTimelineItem(
                        title: "Eternal Stillness",
                        time: "11:44 PM",
                        content: "In the silence of the void, I found the echo of my own soul. It doesn't scream, it whispers truths that the light was too loud to hear...",
                        date: "Oct 24",
                        isActive: true,
                      ),
                      _buildTimelineItem(
                        title: "Whispers of the Void",
                        time: "02:15 AM",
                        content: "The darkness is not empty, it is full of potential. Today I realized that letting go is not losing; it is simply making space for the infinite...",
                        date: "Oct 22",
                      ),
                      const SizedBox(height: 120), // Padding for FAB
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PremiumUI.animatedIcon(
            folder: 'Filter',
            fileName: 'filter.json',
            size: 28,
            color: PremiumTokens.nebulaBlue,
          ),
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
          Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 28),
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
    required String title,
    required String time,
    required String content,
    required String date,
    bool isActive = false,
  }) {
    return IntrinsicHeight(
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
              child: PremiumUI.voidCard(
                accentColor: isActive ? PremiumTokens.nebulaBlue : Colors.white10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: PremiumTokens.displayStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          time,
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
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
                          date,
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
        ],
      ),
    );
  }
}
