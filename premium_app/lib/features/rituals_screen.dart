import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/rituals_provider.dart';
import '../models/ritual.dart';
import 'package:flutter/services.dart';

class RitualsScreen extends ConsumerWidget {
  const RitualsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ritualsAsync = ref.watch(ritualsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background handled by MainNavigationScreen to prevent overdraw
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ritualsAsync.when(
                    data: (rituals) => _buildRitualsList(context, ref, rituals),
                    loading: () => const Center(child: CircularProgressIndicator(color: PremiumTokens.nebulaBlue)),
                    error: (e, _) => Center(child: Text("Error loading rituals: $e", style: const TextStyle(color: Colors.redAccent))),
                  ),
                ),
              ],
            ),
          ),

          // Floating Add Button
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              onPressed: () => _showAddRitualDialog(context, ref),
              backgroundColor: PremiumTokens.nebulaBlue,
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.elasticOut),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Iconsax.sun_1, color: PremiumTokens.celestialGlow, size: 40),
          const SizedBox(height: 16),
          Text(
            "MY SACRED RITUALS",
            style: GoogleFonts.spectral(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, PremiumTokens.celestialGlow.withValues(alpha: 0.5), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRitualsList(BuildContext context, WidgetRef ref, List<Ritual> rituals) {
    final categories = ['Morning', 'Afternoon', 'Evening'];
    
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: categories.map((category) {
        final categoryRituals = rituals.where((r) => r.category == category).toList();
        if (categoryRituals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Row(
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.nebulaBlue.withValues(alpha: 0.6),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            ...categoryRituals.map((ritual) => _buildRitualCard(context, ref, ritual)).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRitualCard(BuildContext context, WidgetRef ref, Ritual ritual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(ritual.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          ref.read(ritualsProvider.notifier).removeRitual(ritual.id);
          PremiumUI.showNotification(
            context, 
            "Ritual removed",
            icon: Iconsax.trash,
            color: Colors.redAccent,
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Iconsax.trash, color: Colors.redAccent),
        ),
        child: GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showAddRitualDialog(context, ref, ritual: ritual);
          },
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ritual.title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ritual.isCompleted ? Colors.white38 : Colors.white,
                          decoration: ritual.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${ritual.time} ${ritual.subtitle != null ? '• ${ritual.subtitle}' : ''}",
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(ritualsProvider.notifier).toggleRitual(ritual.id),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ritual.isCompleted 
                          ? PremiumTokens.nebulaBlue.withValues(alpha: 0.2) 
                          : Colors.transparent,
                      border: Border.all(
                        color: ritual.isCompleted 
                            ? PremiumTokens.nebulaBlue 
                            : Colors.white.withValues(alpha: 0.1),
                        width: 2,
                      ),
                      boxShadow: ritual.isCompleted ? [
                        BoxShadow(
                          color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                    child: ritual.isCompleted 
                        ? const Icon(Icons.check, color: PremiumTokens.nebulaBlue, size: 20) 
                        : null,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
        ),
      ),
    );
  }

  void _showAddRitualDialog(BuildContext context, WidgetRef ref, {Ritual? ritual}) {
    final titleController = TextEditingController(text: ritual?.title);
    final timeController = TextEditingController(text: ritual?.time);
    final subtitleController = TextEditingController(text: ritual?.subtitle);
    String category = ritual?.category ?? 'Morning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => PremiumUI.glassCard(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          borderRadius: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ritual == null ? "Add New Ritual" : "Edit Ritual",
                style: GoogleFonts.spectral(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              _buildInputLabel("TITLE"),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("e.g., Morning Meditation"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("TIME"),
                        TextField(
                          controller: timeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("06:00 AM"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("SUBTITLE"),
                        TextField(
                          controller: subtitleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("15 Mins"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInputLabel("CATEGORY"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Morning', 'Afternoon', 'Evening'].map((cat) {
                  final isSelected = category == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? PremiumTokens.nebulaBlue : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isSelected ? PremiumTokens.nebulaBlue : Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: PremiumUI.primaryButton(
                  text: ritual == null ? "ESTABLISH RITUAL" : "UPDATE RITUAL",
                  onTap: () {
                    if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                      if (ritual == null) {
                        ref.read(ritualsProvider.notifier).addRitual(Ritual(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          time: timeController.text,
                          subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                          category: category,
                          updatedAt: DateTime.now(),
                        ));
                      } else {
                        ref.read(ritualsProvider.notifier).updateRitual(ritual.copyWith(
                          title: titleController.text,
                          time: timeController.text,
                          subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                          category: category,
                          updatedAt: DateTime.now(),
                        ));
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white24,
          letterSpacing: 2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white10),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: PremiumTokens.nebulaBlue, width: 1),
      ),
    );
  }
}
