import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'content_provider.dart';

/// Repository to handle data fetching and caching for Sacred Content.
/// This acts as a bridge between the frontend and various data sources (Firebase, Local DB).
class SacredDataRepository {
  final Ref _ref;

  SacredDataRepository(this._ref);

  /// Fetches content with optional category filtering.
  /// Currently pulls from content_provider, but ready for Firebase integration.
  Future<List<SacredContent>> getSacredContent({String? category}) async {
    // Artificial delay to simulate network/cache lookup
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allContent = _ref.read(sacredContentProvider);
    if (category == null) return allContent;
    
    return allContent.where((item) => item.category == category).toList();
  }
}

final sacredRepositoryProvider = Provider((ref) => SacredDataRepository(ref));

/// Async provider for specialized content fetching
final asyncSacredContentProvider = FutureProvider.family<List<SacredContent>, String?>((ref, category) {
  return ref.watch(sacredRepositoryProvider).getSacredContent(category: category);
});
