import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import 'auth_provider.dart';
import 'providers.dart';
import 'package:uuid/uuid.dart';

final journalServiceProvider = Provider<JournalService>((ref) => JournalService());

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(() {
  return JournalNotifier();
});

final journalSearchProvider = StateProvider<String>((ref) => "");

final readStoriesProvider = StateNotifierProvider<ReadStoriesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReadStoriesNotifier(prefs);
});

class ReadStoriesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences prefs;
  static const _key = 'read_stories_ids';

  ReadStoriesNotifier(this.prefs) : super({}) {
    _load();
  }

  void _load() {
    try {
      final list = prefs.getStringList(_key);
      if (list != null) {
        state = list.toSet();
      }
    } catch (_) {}
  }

  void markAsRead(String id) {
    if (!state.contains(id)) {
      final newState = {...state, id};
      state = newState;
      try {
        prefs.setStringList(_key, newState.toList());
      } catch (_) {}
    }
  }
}

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  List<JournalEntry> _getMockEntries() {
    return [
      JournalEntry(
        id: 'mock-katha-1',
        firebaseUid: 'system',
        title: 'SHRI HARIVANSH',
        content: 'Watch today\'s divine katha on the eternal pastimes of Shri Radha Krishna. Nectar of Vrindavan!\nhttps://www.youtube.com/watch?v=dQw4w9WgXcQ',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        moonPhase: 'post|https://www.youtube.com/watch?v=dQw4w9WgXcQ|https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      ),
      JournalEntry(
        id: 'mock-post-2',
        firebaseUid: 'system',
        title: 'Ananda Das',
        content: 'The essence of Bhakti is continuous remembrance of the divine name. Keep chanting Radhe Radhe!',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        moonPhase: 'post||https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      ),
      JournalEntry(
        id: 'mock-chat-1',
        firebaseUid: 'system',
        title: 'Radha Seeker',
        content: 'Radhe Radhe everyone! 🙏 Let us join in the evening kirtan.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        moonPhase: 'chat|https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      ),
      JournalEntry(
        id: 'mock-comment-1',
        firebaseUid: 'mock-user-1',
        title: 'gopal_das',
        content: 'Radhe Radhe! Chanting Harinam brings absolute bliss.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        moonPhase: 'comment|mock-katha-1|https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      ),
      JournalEntry(
        id: 'mock-comment-2',
        firebaseUid: 'mock-user-2',
        title: 'sita_ram',
        content: 'Thank you for posting this nectar katha 🙏',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        moonPhase: 'comment|mock-katha-1|https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      ),
      JournalEntry(
        id: 'mock-comment-3',
        firebaseUid: 'mock-user-3',
        title: 'braj_seeker',
        content: 'Beautifully said! Continuous chanting is the key.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        moonPhase: 'comment|mock-post-2|https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      ),
    ];
  }

  @override
  Future<List<JournalEntry>> build() async {
    final user = ref.watch(authStateProvider).value;
    final journalService = ref.read(journalServiceProvider);

    // Helper to merge database entries with mock entries to keep the Katha room and posts accessible
    List<JournalEntry> mergeWithMocks(List<JournalEntry> dbEntries) {
      if (user == null) return dbEntries;
      final mockList = _getMockEntries();
      final existingIds = dbEntries.map((e) => e.id).toSet();
      final combined = [
        ...dbEntries,
        ...mockList.where((m) => !existingIds.contains(m.id)),
      ];
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }

    final entries = await journalService.fetchPublicEntries();
    
    // Subscribe to real-time database stream for instant updates across all users
    final subscription = journalService.getPublicEntriesStream().listen((streamEntries) {
      final combined = mergeWithMocks(streamEntries);
      state = AsyncData(combined);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return mergeWithMocks(entries);
  }

  Future<void> addPost(String content, String? videoUrl) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final displayName = user.displayName ?? user.email?.split('@').first ?? "Divine Seeker";
    final photoUrl = user.photoURL ?? "";
    final moonPhase = "post|${videoUrl ?? ''}|$photoUrl";

    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      title: displayName,
      content: content,
      createdAt: DateTime.now(),
      moonPhase: moonPhase,
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData([newEntry, ...state.value!]);
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.createEntry(newEntry);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> addStory(String content, String? videoUrl) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final displayName = user.displayName ?? user.email?.split('@').first ?? "Divine Seeker";
    final photoUrl = user.photoURL ?? "";
    final moonPhase = "story|${videoUrl ?? ''}|$photoUrl";

    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      title: displayName,
      content: content,
      createdAt: DateTime.now(),
      moonPhase: moonPhase,
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData([newEntry, ...state.value!]);
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.createEntry(newEntry);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> addChatMessage(String content) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final displayName = user.displayName ?? user.email?.split('@').first ?? "Divine Seeker";
    final photoUrl = user.photoURL ?? "";
    final moonPhase = "chat|$photoUrl";

    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      title: displayName,
      content: content,
      createdAt: DateTime.now(),
      moonPhase: moonPhase,
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData([newEntry, ...state.value!]);
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.createEntry(newEntry);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> addEntry(String title, String content, {String? moonPhase}) async {
    // Kept for backward compatibility
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      moonPhase: moonPhase,
    );

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData([newEntry, ...state.value!]);
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.createEntry(newEntry);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateEntry(String id, {String? title, String? content}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final updates = <String, dynamic>{
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData(state.value!.map((e) {
        if (e.id == id) {
          return e.copyWith(
            title: title ?? e.title,
            content: content ?? e.content,
          );
        }
        return e;
      }).toList());
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.updateEntry(id, updates);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteEntry(String id) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final previousState = state;
    if (state.hasValue) {
      state = AsyncData(state.value!.where((e) => e.id != id).toList());
    }

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.deleteEntry(id);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> refresh() async {
    final previousState = state;
    state = const AsyncLoading<List<JournalEntry>>().copyWithPrevious(previousState);
    state = await AsyncValue.guard(() async {
      return await ref.read(journalServiceProvider).fetchPublicEntries();
    });
  }
}
