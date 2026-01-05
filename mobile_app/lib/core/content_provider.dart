import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import '../services/api_service.dart';

class SacredContent {
  final String id;
  final String title;
  final String category;
  final String sanskritText;
  final String translation;
  final String hindiMeaning;
  final String commentary;
  final String? imageUrl;

  SacredContent({
    required this.id,
    required this.title,
    required this.category,
    required this.sanskritText,
    required this.translation,
    required this.hindiMeaning,
    required this.commentary,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'sanskritText': sanskritText,
      'translation': translation,
      'hindiMeaning': hindiMeaning,
      'commentary': commentary,
      'imageUrl': imageUrl,
    };
  }

  factory SacredContent.fromMap(Map<String, dynamic> map) {
    return SacredContent(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      sanskritText: map['sanskritText'],
      translation: map['translation'],
      hindiMeaning: map['hindiMeaning'],
      commentary: map['commentary'],
      imageUrl: map['imageUrl'],
    );
  }
}

class ContentNotifier extends StateNotifier<List<SacredContent>> {
  ContentNotifier() : super([]) {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    try {
      // 1. Try to fetch from API
      final apiContent = await ApiService.fetchAllContent();

      if (apiContent.isNotEmpty) {
        // 2. If successful, update local DB
        await DatabaseHelper.instance.deleteAllContent();
        for (var item in apiContent) {
          await DatabaseHelper.instance.insertContent(item);
        }
        state = apiContent;
        return;
      }
    } catch (e) {
      // Ignore API errors, fallback to local DB
      print("Sync failed: $e");
    }

    // 3. Fallback to local DB (offline mode)
    final dbContent = await DatabaseHelper.instance.fetchAllContent();
    if (dbContent.isEmpty) {
      state = _initialContent;
      // Seed initial data to database
      for (var item in _initialContent) {
        await DatabaseHelper.instance.insertContent(item);
      }
    } else {
      state = dbContent;
    }
  }

  static final List<SacredContent> _initialContent = [
    SacredContent(
      id: '1',
      title: 'Bhagavad Gita - Chapter 2',
      category: 'Shloka',
      sanskritText:
          'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
      translation:
          'You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.',
      hindiMeaning: 'तेरा कर्म करने में ही अधिकार है, उसके फलों में कभी नहीं।',
      commentary: 'This shloka is the cornerstone of Karma Yoga...',
    ),
    SacredContent(
      id: '2',
      title: 'Shiva Tandava Stotram',
      category: 'Strotra',
      sanskritText: 'जटाटवीगलज्जलप्रवाहपावितस्थले...',
      translation:
          'With his neck, consecrated by the flow of water that flows from his hair...',
      hindiMeaning:
          'उनकी गर्दन से गिरते हुए जल के प्रवाह से पवित्र स्थान पर...',
      commentary: 'A powerful hymn dedicated to Lord Shiva...',
    ),
  ];

  Future<void> addContent(SacredContent content) async {
    await DatabaseHelper.instance.insertContent(content);
    state = [...state, content];
  }

  Future<void> removeContent(String id) async {
    await DatabaseHelper.instance.deleteContent(id);
    state = state.where((item) => item.id != id).toList();
  }
}

final sacredContentProvider =
    StateNotifierProvider<ContentNotifier, List<SacredContent>>((ref) {
      return ContentNotifier();
    });
