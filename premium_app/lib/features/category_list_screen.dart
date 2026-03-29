import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/providers.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ref.watch(sacredCategoriesProvider);
    final filteredCategories = allCategories.where((cat) {
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: PremiumTokens.voidPure,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A1F),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 0,
                collapsedHeight: 80,
                pinned: true,
                backgroundColor: PremiumTokens.voidPure.withValues(alpha: 0.8),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left, color: PremiumTokens.celestialSilver),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Explore Categories',
                  style: PremiumTokens.sansStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PremiumTokens.celestialSilver,
                  ),
                ),
                centerTitle: true,
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: PremiumTokens.sansStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: PremiumTokens.sansStyle(color: Colors.white24),
                        prefixIcon: const Icon(Iconsax.search_normal, color: Colors.white24, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),

              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = filteredCategories[index];
                      return _buildCategoryCard(context, ref, cat);
                    },
                    childCount: filteredCategories.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, CategoryInfo cat) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Set category filter and switch to Library tab
        ref.read(libraryCategoryProvider.notifier).state = cat.name;
        ref.read(navigationIndexProvider.notifier).state = 1;
        // Pop back to main navigation (which will now show Library)
        Navigator.pop(context);
      },
      child: PremiumUI.relicStaticCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with parallax-like feel
              PremiumUI.networkImage(
                url: cat.imageUrl,
                width: 200,
                height: 250,
              ),
              
              // Gradient Overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.black26,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name.toUpperCase(),
                      style: PremiumTokens.sansStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cat.count} ITEMS',
                        style: PremiumTokens.sansStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
