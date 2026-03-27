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
    if (user == null) return [];
    
    final journalService = ref.read(journalServiceProvider);
    final entries = await journalService.fetchEntries(user.uid);
    
    if (entries.isEmpty) {
      return [
        JournalEntry(
          id: 'demo-1',
          firebaseUid: user.uid,
          title: 'SHRI HARIVANSH',
          content: 'radhe radhe',
          createdAt: DateTime.now(),
        ),
      ];
    }
    return entries;
  }

  Future<void> addEntry(String title, String content, {String? moonPhase}) async {
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

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final journalService = ref.read(journalServiceProvider);
      await journalService.createEntry(newEntry);
      return await journalService.fetchEntries(user.uid);
    });
  }

  Future<void> updateEntry(String id, {String? title, String? content}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final updates = <String, dynamic>{
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final journalService = ref.read(journalServiceProvider);
      await journalService.updateEntry(id, updates);
      return await journalService.fetchEntries(user.uid);
    });
  }

  Future<void> deleteEntry(String id) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final journalService = ref.read(journalServiceProvider);
      await journalService.deleteEntry(id);
      return await journalService.fetchEntries(user.uid);
    });
  }

  Future<void> refresh() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(journalServiceProvider).fetchEntries(user.uid);
    });
  }
}
