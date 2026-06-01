import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'content_provider.dart';
import 'favorites_provider.dart';
import 'stats_provider.dart';
import 'providers.dart';

/// User affinity parameters containing category/tag weights and reading history
class UserAffinity {
  final Map<String, double> categoryWeights;
  final Map<String, double> tagWeights;
  final Set<String> readContentIds;

  UserAffinity({
    required this.categoryWeights,
    required this.tagWeights,
    required this.readContentIds,
  });
}

/// Dwell time weight calculation helper
double calculateDwellWeight(int seconds) {
  if (seconds < 3) return -0.5; // bounce penalty
  if (seconds < 10) return 0.0; // short view, neutral
  if (seconds < 30) return 1.0; // active interest
  if (seconds < 120) return 3.0; // deep engagement
  return 5.0; // immersive reflection
}

/// Dynamic similarity index using Jaccard Similarity on tags + Category/Author/Book matches
double calculateSimilarity(SacredContent a, SacredContent b) {
  if (a.id == b.id) return 1.0;
  
  // 1. Category matching (base similarity)
  final bool categoryMatch = a.category.toLowerCase() == b.category.toLowerCase();
  
  // 2. Author matching (high affinity for same author/saint)
  final bool authorMatch = a.author != null && 
      b.author != null && 
      a.author!.isNotEmpty && 
      a.author!.toLowerCase() == b.author!.toLowerCase();
      
  // 3. Book matching
  final bool bookMatch = a.book != null && 
      b.book != null && 
      a.book!.isNotEmpty && 
      a.book!.toLowerCase() == b.book!.toLowerCase();

  // 4. Combined tag union/intersection (Jaccard similarity on all tag lists)
  final tagsA = <String>{};
  tagsA.addAll(a.contentTags.map((t) => t.toLowerCase()));
  tagsA.addAll(a.audioTags.map((t) => t.toLowerCase()));
  tagsA.addAll(a.videoTags.map((t) => t.toLowerCase()));
  tagsA.addAll(a.imageTags.map((t) => t.toLowerCase()));

  final tagsB = <String>{};
  tagsB.addAll(b.contentTags.map((t) => t.toLowerCase()));
  tagsB.addAll(b.audioTags.map((t) => t.toLowerCase()));
  tagsB.addAll(b.videoTags.map((t) => t.toLowerCase()));
  tagsB.addAll(b.imageTags.map((t) => t.toLowerCase()));

  double jaccard = 0.0;
  if (tagsA.isNotEmpty || tagsB.isNotEmpty) {
    final intersection = tagsA.intersection(tagsB).length;
    final union = tagsA.union(tagsB).length;
    jaccard = intersection / union;
  }

  // Weight distribution:
  // - Category match: 0.25
  // - Author match: 0.25
  // - Book match: 0.15
  // - Tag similarity (Jaccard): 0.35
  double score = 0.0;
  if (categoryMatch) score += 0.25;
  if (authorMatch) score += 0.25;
  if (bookMatch) score += 0.15;
  score += jaccard * 0.35;
  
  return score;
}

/// Notifier to manage user's dwell time history locally
class DwellTimeNotifier extends StateNotifier<Map<String, int>> {
  final Ref ref;
  static const _key = 'user_dwell_times_map';

  DwellTimeNotifier(this.ref) : super(const {}) {
    _load();
  }

  void _load() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        state = decoded.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      debugPrint("Error loading dwell times: $e");
    }
  }

  Future<void> logDwellTime(String contentId, int seconds) async {
    if (seconds <= 0) return;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final updated = Map<String, int>.from(state);
      final current = updated[contentId] ?? 0;
      updated[contentId] = math.min(600, current + seconds); // Cap at 10 minutes max per item
      state = updated;
      await prefs.setString(_key, jsonEncode(updated));
    } catch (e) {
      debugPrint("Error logging dwell time: $e");
    }
  }
}

final dwellTimeProvider = StateNotifierProvider<DwellTimeNotifier, Map<String, int>>((ref) {
  return DwellTimeNotifier(ref);
});

/// Computes category and tag weights based on favorites, reading history, and dwell time
final userAffinityProvider = Provider<UserAffinity>((ref) {
  final favorites = ref.watch(favoritesProvider);
  final historyAsync = ref.watch(readingHistoryProvider);
  final allContent = ref.watch(sacredContentProvider);
  final dwellTimes = ref.watch(dwellTimeProvider);

  final categoryWeights = <String, double>{};
  final tagWeights = <String, double>{};
  final readContentIds = <String>{};

  void addCategoryWeight(String category, double w) {
    if (category.isEmpty) return;
    categoryWeights[category] = (categoryWeights[category] ?? 0.0) + w;
  }

  void addTagWeight(String tag, double w) {
    if (tag.isEmpty) return;
    tagWeights[tag] = (tagWeights[tag] ?? 0.0) + w;
  }

  // 1. Process history (clicks = 1.0 points)
  historyAsync.whenData((history) {
    for (final item in history) {
      readContentIds.add(item.contentId);
      final category = item.category ?? '';
      addCategoryWeight(category, 1.0);
      
      final content = allContent.where((c) => c.id == item.contentId).firstOrNull;
      if (content != null) {
        for (final tag in content.contentTags) {
          addTagWeight(tag, 1.0);
        }
      }
    }
  });

  // 2. Process favorites (higher weight = 3.0 points)
  for (final favId in favorites) {
    final content = allContent.where((c) => c.id == favId).firstOrNull;
    if (content != null) {
      addCategoryWeight(content.category, 3.0);
      for (final tag in content.contentTags) {
        addTagWeight(tag, 2.0);
      }
    }
  }

  // 3. Process implicit dwell time weights
  dwellTimes.forEach((contentId, seconds) {
    final content = allContent.where((c) => c.id == contentId).firstOrNull;
    if (content != null) {
      final weight = calculateDwellWeight(seconds);
      addCategoryWeight(content.category, weight);
      for (final tag in content.contentTags) {
        addTagWeight(tag, weight * 0.8);
      }
    }
  });

  return UserAffinity(
    categoryWeights: categoryWeights,
    tagWeights: tagWeights,
    readContentIds: readContentIds,
  );
});

/// Ranks and scores all content items dynamically based on the user's affinity (Explore Mixer)
final rankedContentProvider = Provider<List<SacredContent>>((ref) {
  final allContent = ref.watch(sacredContentProvider);
  final affinity = ref.watch(userAffinityProvider);
  final historyAsync = ref.watch(readingHistoryProvider);

  if (allContent.isEmpty) return [];

  // Get the last 3 read items for recent similarity matching (Instagram/Pinterest style)
  final lastReadIds = historyAsync.maybeWhen(
    data: (history) => history.take(3).map((h) => h.contentId).toList(),
    orElse: () => <String>[],
  );
  
  final lastReadItems = lastReadIds
      .map((id) => allContent.where((c) => c.id == id).firstOrNull)
      .whereType<SacredContent>()
      .toList();

  // Hourly seed for recommendation stability with fresh exploration updates
  final hourSeed = DateTime.now().hour + DateTime.now().day * 24;
  final random = math.Random(hourSeed);

  final scoredItems = allContent.map((item) {
    double score = 100.0; // Base score

    // Category affinity matching
    final catWeight = affinity.categoryWeights[item.category] ?? 0.0;
    score += catWeight * 25.0;

    // Tag affinity matching
    double tagScore = 0.0;
    for (final tag in item.contentTags) {
      tagScore += (affinity.tagWeights[tag] ?? 0.0) * 10.0;
    }
    score += math.min(80.0, tagScore);

    // Similarity to recent reads (+20.0 max)
    if (lastReadItems.isNotEmpty) {
      double maxSim = 0.0;
      for (final lastRead in lastReadItems) {
        final sim = calculateSimilarity(lastRead, item);
        if (sim > maxSim) maxSim = sim;
      }
      score += maxSim * 20.0;
    }

    // Trending boost (+20.0 max based on simulated popularity)
    final trendingScore = (item.title.length * 7 + item.category.length * 13) % 100;
    score += (trendingScore / 100.0) * 20.0;

    // Sample/special content boost
    if (item.id.startsWith('stream-sample')) {
      score += 15.0;
    }

    // Read penalty to keep discovery fresh
    if (affinity.readContentIds.contains(item.id)) {
      score -= 35.0;
    }

    // Serendipity factor to break filter bubbles (Pinterest/Instagram style)
    score += random.nextDouble() * 30.0;

    return _ScoredContent(item, score);
  }).toList();

  scoredItems.sort((a, b) => b.score.compareTo(a.score));

  return scoredItems.map((s) => s.content).toList();
});

class _ScoredContent {
  final SacredContent content;
  final double score;
  _ScoredContent(this.content, this.score);
}

/// Netflix-style Percent Match calculation (stable version of scoring formula)
final matchPercentageProvider = Provider.family<int, SacredContent>((ref, item) {
  final affinity = ref.watch(userAffinityProvider);
  final historyAsync = ref.watch(readingHistoryProvider);
  final allContent = ref.watch(sacredContentProvider);

  if (allContent.isEmpty) return 75; // Default match

  double score = 100.0; // Base score
  
  final catWeight = affinity.categoryWeights[item.category] ?? 0.0;
  score += catWeight * 25.0;

  double tagScore = 0.0;
  for (final tag in item.contentTags) {
    tagScore += (affinity.tagWeights[tag] ?? 0.0) * 10.0;
  }
  score += math.min(80.0, tagScore);

  final lastReadIds = historyAsync.maybeWhen(
    data: (history) => history.take(3).map((h) => h.contentId).toList(),
    orElse: () => <String>[],
  );
  
  final lastReadItems = lastReadIds
      .map((id) => allContent.where((c) => c.id == id).firstOrNull)
      .whereType<SacredContent>()
      .toList();
      
  if (lastReadItems.isNotEmpty) {
    double maxSim = 0.0;
    for (final lastRead in lastReadItems) {
      final sim = calculateSimilarity(lastRead, item);
      if (sim > maxSim) maxSim = sim;
    }
    score += maxSim * 20.0;
  }

  // Normalize between 60% and 99% match
  // 100 -> 60%, 250+ -> 99%
  final percent = (60 + ((score - 100.0) / 150.0 * 39.0)).clamp(60, 99).toInt();
  return percent;
});

/// Netflix/Amazon style "More Like This" similar content provider with robust fallback mechanisms
final similarContentProvider = Provider.family<List<SacredContent>, SacredContent>((ref, currentItem) {
  final allContent = ref.watch(sacredContentProvider);
  if (allContent.isEmpty) return [];

  final scored = allContent
      .where((item) => item.id != currentItem.id)
      .map((item) {
        final similarity = calculateSimilarity(currentItem, item);
        return _ScoredContent(item, similarity);
      })
      .toList();
      
  scored.sort((a, b) => b.score.compareTo(a.score));
  
  // Filter for items that have some similarity boost
  final matches = scored.where((s) => s.score > 0.05).map((s) => s.content).toList();
  
  if (matches.isNotEmpty) {
    return matches.take(8).toList();
  }
  
  // Fallback 1: Recommend items from the same category
  final categoryFallback = allContent
      .where((item) => item.id != currentItem.id && item.category.toLowerCase() == currentItem.category.toLowerCase())
      .take(8)
      .toList();
      
  if (categoryFallback.isNotEmpty) {
    return categoryFallback;
  }
  
  // Fallback 2: General fallback to other items
  return allContent.where((item) => item.id != currentItem.id).take(8).toList();
});

/// State for personalized discovery feed with loading status
class PersonalizedFeedState {
  final List<SacredContent> items;
  final bool hasMore;
  final bool isLoading;

  const PersonalizedFeedState({
    required this.items,
    required this.hasMore,
    required this.isLoading,
  });

  PersonalizedFeedState copyWith({
    List<SacredContent>? items,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PersonalizedFeedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Lazy-loaded StateNotifier for paginated infinite scroll
class PersonalizedDiscoveryNotifier extends StateNotifier<PersonalizedFeedState> {
  final Ref ref;
  static const int _pageSize = 10;

  PersonalizedDiscoveryNotifier(this.ref)
      : super(const PersonalizedFeedState(items: [], hasMore: true, isLoading: false)) {
    loadMore();
  }

  void loadMore() {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final ranked = ref.read(rankedContentProvider);
    final currentCount = state.items.length;

    if (currentCount >= ranked.length) {
      state = state.copyWith(hasMore: false, isLoading: false);
      return;
    }

    final nextPageItems = ranked.skip(currentCount).take(_pageSize).toList();
    final newItems = [...state.items, ...nextPageItems];
    final hasMore = newItems.length < ranked.length;

    state = state.copyWith(
      items: newItems,
      hasMore: hasMore,
      isLoading: false,
    );
  }

  void refresh() {
    state = const PersonalizedFeedState(items: [], hasMore: true, isLoading: false);
    loadMore();
  }
}

final personalizedDiscoveryProvider =
    StateNotifierProvider<PersonalizedDiscoveryNotifier, PersonalizedFeedState>((ref) {
  return PersonalizedDiscoveryNotifier(ref);
});

/// Trending content provider scored by local popularity
final trendingContentProvider = Provider<List<SacredContent>>((ref) {
  final allContent = ref.watch(sacredContentProvider);
  if (allContent.isEmpty) return [];

  final trendingItems = List<SacredContent>.from(allContent);
  trendingItems.sort((a, b) {
    final aPop = (a.title.length * 7 + a.category.length * 13) % 100;
    final bPop = (b.title.length * 7 + b.category.length * 13) % 100;
    return bPop.compareTo(aPop);
  });

  return trendingItems.take(8).toList();
});

/// Dynamically sorted categories based on user affinity (highest preference first)
final personalizedCategoriesProvider = Provider<List<CategoryInfo>>((ref) {
  final categories = ref.watch(sacredCategoriesProvider);
  final affinity = ref.watch(userAffinityProvider);
  if (categories.isEmpty) return [];

  final sorted = List<CategoryInfo>.from(categories);
  sorted.sort((a, b) {
    final aWeight = affinity.categoryWeights[a.name] ?? 0.0;
    final bWeight = affinity.categoryWeights[b.name] ?? 0.0;
    if (aWeight != bWeight) {
      return bWeight.compareTo(aWeight); // Highest weight first
    }
    // Fallback to item count
    return b.count.compareTo(a.count);
  });
  return sorted;
});

/// Recommended items across the user's top categories, weighted by affinity
final categoryRecommendationsProvider = Provider<List<SacredContent>>((ref) {
  final affinity = ref.watch(userAffinityProvider);
  final allContent = ref.watch(sacredContentProvider);

  if (allContent.isEmpty) return [];

  // Sort categories by user affinity
  final sortedCategories = affinity.categoryWeights.entries
      .where((e) => e.value > 0)
      .toList();
  sortedCategories.sort((a, b) => b.value.compareTo(a.value));

  // If user has no affinity, fallback to general categories
  if (sortedCategories.isEmpty) {
    // Default to the first category available in content
    final defaultCat = allContent.firstOrNull?.category ?? 'Bhajans';
    final list = allContent.where((item) => item.category.toLowerCase() == defaultCat.toLowerCase()).toList();
    return list.take(8).toList();
  }

  // Get content grouped by category
  final result = <SacredContent>[];
  final categoriesToPull = sortedCategories.take(3).toList(); // Look at top 3 categories

  // Pull items from each category, prioritizing unread items
  for (final entry in categoriesToPull) {
    final categoryName = entry.key;
    final catItems = allContent.where((item) => item.category.toLowerCase() == categoryName.toLowerCase()).toList();
    
    // Sort so unread is first
    catItems.sort((a, b) {
      final aRead = affinity.readContentIds.contains(a.id) ? 1 : 0;
      final bRead = affinity.readContentIds.contains(b.id) ? 1 : 0;
      return aRead.compareTo(bRead);
    });

    // Add up to 4 items from this top category
    result.addAll(catItems.take(4));
  }

  // Deduplicate and return up to 8 recommendations
  final uniqueItems = <String, SacredContent>{};
  for (final item in result) {
    uniqueItems[item.id] = item;
  }
  
  // Sort the final selection based on the overall ranked score for consistency
  final ranked = ref.read(rankedContentProvider);
  final finalItems = uniqueItems.values.toList();
  finalItems.sort((a, b) {
    final aIdx = ranked.indexWhere((item) => item.id == a.id);
    final bIdx = ranked.indexWhere((item) => item.id == b.id);
    // If not found in ranked list, put at the end
    final aVal = aIdx == -1 ? 9999 : aIdx;
    final bVal = bIdx == -1 ? 9999 : bIdx;
    return aVal.compareTo(bVal);
  });

  return finalItems.take(8).toList();
});

/// "Continue Reading" recently accessed content items
final continueReadingProvider = Provider<List<SacredContent>>((ref) {
  final historyAsync = ref.watch(readingHistoryProvider);
  final allContent = ref.watch(sacredContentProvider);

  return historyAsync.maybeWhen(
    data: (history) {
      final recentIds = history.map((h) => h.contentId).toList();
      final result = <SacredContent>[];
      
      for (final id in recentIds) {
        final content = allContent.where((c) => c.id == id).firstOrNull;
        if (content != null && !result.contains(content)) {
          result.add(content);
        }
      }
      return result.take(5).toList();
    },
    orElse: () => <SacredContent>[],
  );
});
