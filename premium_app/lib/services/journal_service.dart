import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/journal_entry.dart';

class JournalService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  /// Fetch all journal entries for a user
  Future<List<JournalEntry>> fetchEntries(String uid) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('firebase_uid', uid)
          .order('created_at', ascending: false);
          
      return (response as List).map((e) => JournalEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching journal entries: $e');
      return [];
    }
  }

  /// Fetch all public entries (feed & chat)
  Future<List<JournalEntry>> fetchPublicEntries() async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
          
      return (response as List).map((e) => JournalEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching public entries: $e');
      return [];
    }
  }

  /// Create a new journal entry
  Future<JournalEntry?> createEntry(JournalEntry entry) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .insert(entry.toJson())
          .select()
          .single();
          
      return JournalEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      return null;
    }
  }

  /// Update an existing journal entry
  Future<void> updateEntry(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('journal_entries')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
    }
  }

  /// Delete a journal entry
  Future<void> deleteEntry(String id) async {
    try {
      await _supabase
          .from('journal_entries')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
    }
  }
}
