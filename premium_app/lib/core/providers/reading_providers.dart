import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReadingTheme {
  divineFlow,
  sacredParchment,
  voidFocus,
}

final readerThemeProvider = StateProvider<ReadingTheme>((ref) => ReadingTheme.divineFlow);
