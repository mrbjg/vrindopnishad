import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ritual.dart';
import 'cache_service.dart';

final ritualsProvider = AsyncNotifierProvider<RitualsNotifier, List<Ritual>>(() {
  return RitualsNotifier();
});

class RitualsNotifier extends AsyncNotifier<List<Ritual>> {
  static const String _storageKey = 'spiritual_rituals';

  @override
  Future<List<Ritual>> build() async {
    final cache = CacheService.instance;
    final data = await cache.get(_storageKey);
    
    if (data == null) {
      // Default rituals if none exist
      return [
        Ritual(
          id: '1',
          title: 'Surya Namaskar',
          time: '06:30 AM',
          subtitle: '12 Rounds',
          category: 'Morning',
          updatedAt: DateTime.now(),
        ),
        Ritual(
          id: '2',
          title: 'Pranayama',
          time: '07:00 AM',
          subtitle: '15 Mins',
          category: 'Morning',
          updatedAt: DateTime.now(),
        ),
        Ritual(
          id: '3',
          title: 'Afternoon Stillness',
          time: '01:30 PM',
          subtitle: '10 Mins',
          category: 'Afternoon',
          updatedAt: DateTime.now(),
        ),
        Ritual(
          id: '4',
          title: 'Bedtime Mantra',
          time: '09:45 PM',
          subtitle: 'Om Shanti',
          category: 'Evening',
          updatedAt: DateTime.now(),
        ),
      ];
    }

    final List<dynamic> list = jsonDecode(data);
    final rituals = list.map((e) => Ritual.fromJson(e)).toList();
    
    // Daily Reset Logic
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    
    bool needsUpdate = false;
    final updated = rituals.map((r) {
      final updatedStr = "${r.updatedAt.year}-${r.updatedAt.month}-${r.updatedAt.day}";
      if (updatedStr != todayStr && r.isCompleted) {
        needsUpdate = true;
        return r.copyWith(isCompleted: false, updatedAt: now);
      }
      return r;
    }).toList();

    if (needsUpdate) {
      await _persist(updated);
    }
    
    return updated;
  }

  Future<void> toggleRitual(String id) async {
    final rituals = state.value ?? [];
    final now = DateTime.now();
    final updated = rituals.map((r) {
      if (r.id == id) {
        return r.copyWith(isCompleted: !r.isCompleted, updatedAt: now);
      }
      return r;
    }).toList();

    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> addRitual(Ritual ritual) async {
    final rituals = state.value ?? [];
    final updated = [...rituals, ritual];
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> updateRitual(Ritual ritual) async {
    final rituals = state.value ?? [];
    final updated = rituals.map((r) => r.id == ritual.id ? ritual : r).toList();
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> removeRitual(String id) async {
    final rituals = state.value ?? [];
    final updated = rituals.where((r) => r.id != id).toList();
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> _persist(List<Ritual> rituals) async {
    final cache = CacheService.instance;
    final data = jsonEncode(rituals.map((r) => r.toJson()).toList());
    await cache.set(_storageKey, data);
  }
}
