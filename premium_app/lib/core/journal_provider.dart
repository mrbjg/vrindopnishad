import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import 'package:uuid/uuid.dart';

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(() {
  return JournalNotifier();
});

final journalSearchProvider = StateProvider<String>((ref) => "");

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  static const _storageKey = 'divine_journal_entries';

  @override
  Future<List<JournalEntry>> build() async {
    final entries = await _loadEntries();
    if (entries.isEmpty) {
      return _seedDemoData();
    }
    return entries;
  }

  Future<List<JournalEntry>> _seedDemoData() async {
    final now = DateTime.now();
    final demoEntries = [
      JournalEntry(
        id: 'demo-reflection-1',
        title: 'Morning Reflection: The Path of Devotion',
        content: 'I began my morning by reflecting on the sacred chants. The realization that every moment is a precious gift from the Divine feels more real than ever. How can I carry this stillness throughout the day?',
        createdAt: now.subtract(const Duration(hours: 4)),
        moonPhase: 'WANING CRESCENT',
      ),
      JournalEntry(
        id: 'demo-reflection-2',
        title: 'Soul Insight: Stillness in Chaos',
        content: 'Sri Krishna says the mind can be subdued by practice and detachment. I noticed today that even five minutes of deep Naam Jap brought a profound shift in my energy. I must commit to this consistency.',
        createdAt: now.subtract(const Duration(days: 1)),
        moonPhase: 'NEW MOON',
      ),
    ];

    // Mark as data to avoid infinite loop or flickering
    state = AsyncValue.data(demoEntries);
    await _saveEntries(demoEntries);
    return demoEntries;
  }

  Future<List<JournalEntry>> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => JournalEntry.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> addEntry(String title, String content, {String? moonPhase}) async {
    final entries = state.value ?? [];
    final newEntry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      moonPhase: moonPhase,
    );

    final updated = [newEntry, ...entries];
    state = AsyncValue.data(updated);
    await _saveEntries(updated);
  }

  Future<void> updateEntry(String id, {String? title, String? content}) async {
    final entries = state.value ?? [];
    final updated = entries.map((e) {
      if (e.id == id) {
        return e.copyWith(
          title: title ?? e.title,
          content: content ?? e.content,
        );
      }
      return e;
    }).toList();

    state = AsyncValue.data(updated);
    await _saveEntries(updated);
  }

  Future<void> deleteEntry(String id) async {
    final entries = state.value ?? [];
    final updated = entries.where((e) => e.id != id).toList();
    
    state = AsyncValue.data(updated);
    await _saveEntries(updated);
  }
}
