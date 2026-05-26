import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

final journalServiceProvider = Provider<JournalService>((ref) => JournalService());

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(() {
  return JournalNotifier();
});

final journalSearchProvider = StateProvider<String>((ref) => "");

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final user = ref.watch(authStateProvider).value;
    final journalService = ref.read(journalServiceProvider);
    final entries = await journalService.fetchPublicEntries();
    
    if (entries.isEmpty && user != null) {
      // Mock data to ensure a gorgeous layout immediately if backend is empty
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
      ];
    }
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(journalServiceProvider).fetchPublicEntries();
    });
  }
}
