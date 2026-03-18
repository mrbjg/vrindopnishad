import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RealtimeService {
  static final RealtimeService instance = RealtimeService._init();
  RealtimeService._init();

  RealtimeChannel? _contentChannel;

  /// Subscribe to changes in the 'content' table
  void subscribeToContentChanges(Function() onUpdate) {
    if (_contentChannel != null) return;

    _contentChannel = Supabase.instance.client
        .channel('public:content')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'content',
          callback: (payload) {
            debugPrint('Realtime Change Detected: ${payload.toString()}');
            onUpdate();
          },
        )
        .subscribe((status, [error]) {
          if (error != null) {
            debugPrint('Realtime Subscription Error: $error');
          } else {
            debugPrint('Realtime Subscription Status: $status');
          }
        });
  }

  /// Unsubscribe from changes
  void unsubscribe() {
    if (_contentChannel != null) {
      Supabase.instance.client.removeChannel(_contentChannel!);
      _contentChannel = null;
    }
  }
}
