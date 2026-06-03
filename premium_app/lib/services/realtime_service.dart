import 'package:flutter/foundation.dart';
import 'dart:async';
import '../core/firestore_service.dart';

class RealtimeService {
  static final RealtimeService instance = RealtimeService._init();
  RealtimeService._init();

  StreamSubscription? _contentSubscription;

  /// Subscribe to changes in the 'content' collection in Firestore.
  /// Only triggers update on genuine server-side changes to reduce data transfer.
  void subscribeToContentChanges(Function() onUpdate) {
    if (_contentSubscription != null) return;

    _contentSubscription = firestore
        .collection('content')
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          // Only react to genuine server-side changes (not local cache events)
          if (snapshot.metadata.isFromCache) return;
          // Only trigger if documents actually changed
          if (snapshot.docChanges.isEmpty) return;
          
          debugPrint('Realtime Firestore Change Detected (${snapshot.docChanges.length} docs changed)');
          onUpdate();
        }, onError: (error) {
          debugPrint('Realtime Subscription Error: $error');
        });
  }

  /// Unsubscribe from changes
  void unsubscribe() {
    if (_contentSubscription != null) {
      _contentSubscription!.cancel();
      _contentSubscription = null;
    }
  }
}
