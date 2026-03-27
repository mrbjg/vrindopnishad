import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(initSettings);

    // Initialize FCM
    await _initFCM();
  }

  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create Custom Sound Channels for Android
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          'divine_flute',
          'Divine Flute',
          description: 'Notifications with flute sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('flute'),
        ));
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          'temple_bell',
          'Temple Bell',
          description: 'Notifications with temple bell sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('temple_bell'),
        ));
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          'sacred_shankh',
          'Sacred Shankh',
          description: 'Notifications with shankh sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('shankh'),
        ));
      }
    }

    // Handle incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showRemoteNotification(message);
      }
    });
  }

  Future<void> _showRemoteNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    
    String channelId = 'default_channel';
    String sound = data['sound'] ?? 'default';
    
    if (sound == 'flute') channelId = 'divine_flute';
    else if (sound == 'temple_bell') channelId = 'temple_bell';
    else if (sound == 'shankh') channelId = 'sacred_shankh';

    await _notifications.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          importance: Importance.max,
          priority: Priority.high,
          sound: sound != 'default' ? RawResourceAndroidNotificationSound(sound) : null,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          sound: sound != 'default' ? '$sound.mp3' : null,
        ),
      ),
    );
  }
}
