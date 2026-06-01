import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class RealtimeService {
  static final RealtimeService instance = RealtimeService._init();
  RealtimeService._init();

  StreamSubscription? _contentSubscription;

  /// Subscribe to changes in the 'content' collection in Firestore
  void subscribeToContentChanges(Function() onUpdate) {
    if (_contentSubscription != null) return;

    _contentSubscription = FirebaseFirestore.instance
        .collection('content')
        .snapshots()
        .listen((snapshot) {
          debugPrint('Realtime Firestore Change Detected');
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
