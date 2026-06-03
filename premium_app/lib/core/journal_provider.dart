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

  @override
  Future<List<JournalEntry>> build() async {
    final journalService = ref.read(journalServiceProvider);

    final entries = await journalService.fetchPublicEntries();

    // Subscribe to real-time database stream for instant updates across all users
    final subscription = journalService.getPublicEntriesStream().listen((streamEntries) {
      state = AsyncData(streamEntries);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return entries;
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

  Future<void> addLivePost(String title, String videoUrl) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final displayName = user.displayName ?? user.email?.split('@').first ?? "Divine Seeker";
    final photoUrl = user.photoURL ?? "";
    final moonPhase = "live|$videoUrl|$photoUrl|active";

    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      title: displayName,
      content: title,
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

  Future<void> endLiveStreamAndUpload(String id) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    if (!state.hasValue) return;

    final entryIndex = state.value!.indexWhere((e) => e.id == id);
    if (entryIndex == -1) return;

    final entry = state.value![entryIndex];
    final parts = entry.moonPhase?.split('|') ?? [];
    final videoUrl = parts.length > 1 ? parts[1] : '';
    final photoUrl = parts.length > 2 ? parts[2] : '';

    final updatedMoonPhase = "chat|$photoUrl|video|$videoUrl";
    final updatedContent = "Recorded Live Satsang: ${entry.content}";

    final updatedEntry = entry.copyWith(
      content: updatedContent,
      moonPhase: updatedMoonPhase,
    );

    final previousState = state;
    state = AsyncData(state.value!.map((e) => e.id == id ? updatedEntry : e).toList());

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.updateEntry(id, {
        'moon_phase': updatedMoonPhase,
        'content': updatedContent,
      });
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

  Future<void> toggleLike(String id) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    if (!state.hasValue) return;

    final currentEntries = state.value!;
    final postIndex = currentEntries.indexWhere((e) => e.id == id);
    if (postIndex == -1) return;

    final post = currentEntries[postIndex];
    final updatedLikedBy = List<String>.from(post.likedBy);
    if (updatedLikedBy.contains(user.uid)) {
      updatedLikedBy.remove(user.uid);
    } else {
      updatedLikedBy.add(user.uid);
    }

    final updatedPost = post.copyWith(likedBy: updatedLikedBy);

    // Optimistically update local state
    state = AsyncData(currentEntries.map((e) => e.id == id ? updatedPost : e).toList());

    try {
      final journalService = ref.read(journalServiceProvider);
      await journalService.updateEntry(id, {'liked_by': updatedLikedBy});
    } catch (e) {
      // Revert on error
      state = AsyncData(currentEntries);
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
