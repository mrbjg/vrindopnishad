import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class JournalService {
  /// Fetch all journal entries for a user
  Future<List<JournalEntry>> fetchEntries(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .where('firebase_uid', isEqualTo: uid)
          .get();
          
      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JournalEntry.fromJson(data);
      }).toList();

      // Sort in-memory to avoid needing index
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      debugPrint('Error fetching journal entries: $e');
      return [];
    }
  }

  /// Fetch all public entries (feed & chat)
  Future<List<JournalEntry>> fetchPublicEntries() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .limit(100)
          .get();
          
      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JournalEntry.fromJson(data);
      }).toList();

      // Sort in-memory
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      debugPrint('Error fetching public entries: $e');
      return [];
    }
  }

  /// Stream all public entries in real-time
  Stream<List<JournalEntry>> getPublicEntriesStream() {
    return FirebaseFirestore.instance
        .collection('journal_entries')
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return JournalEntry.fromJson(data);
          }).toList();

          // Sort in-memory
          entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return entries.take(100).toList();
        });
  }

  /// Create a new journal entry
  Future<JournalEntry?> createEntry(JournalEntry entry) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('journal_entries')
          .add(entry.toJson());
          
      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;
      
      return JournalEntry.fromJson(data);
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      return null;
    }
  }

  /// Update an existing journal entry
  Future<void> updateEntry(String id, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection('journal_entries')
          .doc(id)
          .update(updates);
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
    }
  }

  /// Delete a journal entry
  Future<void> deleteEntry(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('journal_entries')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
    }
  }
}
