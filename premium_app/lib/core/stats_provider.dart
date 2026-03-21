import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';
import 'auth_provider.dart';

final statsServiceProvider = Provider<StatsService>((ref) => StatsService());

final userStatsProvider = AsyncNotifierProvider<UserStatsNotifier, UserStats?>(() {
  return UserStatsNotifier();
});

class UserStatsNotifier extends AsyncNotifier<UserStats?> {
  @override
  Future<UserStats?> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return null;
    
    final statsService = ref.read(statsServiceProvider);
    
    // Sync streak on load
    await statsService.syncStreak(user.uid);
    
    return await statsService.getOrCreateStats(user.uid);
  }

  /// Manually refresh stats
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).value;
      if (user == null) return null;
      return await ref.read(statsServiceProvider).getOrCreateStats(user.uid);
    });
  }

  /// Increment shloka read count and earn XP
  Future<void> recordReading(String contentId, {String? title, String? category}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Sync to Supabase
    await ref.read(statsServiceProvider).logReadingActivity(
      user.uid, 
      contentId: contentId,
      title: title,
      category: category,
    );
    
    // Brief delay to ensure database consistency before UI refresh
    await Future.delayed(const Duration(milliseconds: 300));
    
    await refresh();
    ref.invalidate(readingHistoryProvider);
  }
  
  /// Update total jap count silently to prevent flickering
  Future<void> syncJaps(int count) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    // Update local state immediately if available to prevent flickering
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(totalJapCount: count));
    }
    
    await ref.read(statsServiceProvider).updateStats(user.uid, {
      'total_jap_count': count,
    });
    
    // Refresh fully in background but don't show loading state
    final updatedStats = await ref.read(statsServiceProvider).getOrCreateStats(user.uid);
    state = AsyncValue.data(updatedStats);
  }
}

final readingHistoryProvider = FutureProvider<List<ReadingHistoryItem>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return await ref.read(statsServiceProvider).getReadingHistory(user.uid);
});

final japHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return await ref.read(statsServiceProvider).getJapHistory(user.uid);
});
