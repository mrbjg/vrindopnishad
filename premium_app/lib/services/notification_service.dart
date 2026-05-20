import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Request exact alarms permission if on Android
      if (!kIsWeb && Platform.isAndroid) {
        final allowed = await androidPlugin.requestExactAlarmsPermission();
        if (allowed == false) {
          debugPrint('Exact alarms not permitted.');
          return false;
        }
      }
    }
    // For iOS, permissions are requested during initialization, but we can add a check here if needed.
    // For now, assume true if not Android or if Android permission was granted.
    return true;
  }

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
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

    // Request permissions (especially for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // Get the token for this device
      String? token = await messaging.getToken();
      debugPrint("FCM Token: $token");
      // TODO: Save this token to Supabase for targeted notifications
    }

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
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          'naam_jap_reminders',
          'Naam Jap Reminders',
          description: 'Daily morning and evening reminders to complete your Naam Jap',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));
      }
    }

    // Handle incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showRemoteNotification(message);
      }
    });
  }

  Future<void> _showRemoteNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    
    String channelId = 'sacred_reminders';
    String sound = data['sound'] ?? 'default';
    
    if (sound == 'flute') {
      channelId = 'divine_flute';
    } else if (sound == 'temple_bell') {
      channelId = 'temple_bell';
    } else if (sound == 'shankh') {
      channelId = 'sacred_shankh';
    }

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

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // Cancel existing reminders
    await _notifications.cancel(1001);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      if (!kIsWeb && Platform.isAndroid) {
         final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
         if (androidPlugin != null) {
           final allowed = await androidPlugin.requestExactAlarmsPermission();
           if (allowed == false) {
             // Fallback to inexact if needed, or just handle
             debugPrint('Exact alarms not permitted. Falling back.');
           }
         }
      }

      await _notifications.zonedSchedule(
        1001,
        'Sacred Reminder',
        'It is time for your daily Mala. Return to stillness.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sacred_reminders',
            'Sacred Reminders',
            channelDescription: 'Daily spiritual practice reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // If exact fails, try inexact as fallback
      try {
        await _notifications.zonedSchedule(
          1001,
          'Sacred Reminder',
          'It is time for your daily Mala. Return to stillness.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sacred_reminders',
              'Sacred Reminders',
              channelDescription: 'Daily spiritual practice reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e2) {
        debugPrint('Fallback failed: $e2');
      }
    }
  }

  /// Schedule a reminder for a Vrat or Utsav the day before
  Future<void> scheduleSacredEventReminder(String id, String title, DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local).subtract(const Duration(days: 1));
    // Set to 8:00 PM the night before
    final finalDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month, scheduledDate.day, 20, 0);

    if (finalDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id.hashCode,
      'Sacred Preparation',
      'Tomorrow is $title. Prepare your heart for the divine tithi.',
      finalDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sacred_calendar',
          'Sacred Calendar',
          channelDescription: 'Vrat and Utsav reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule a warning when a streak is at risk of being lost
  Future<void> scheduleStreakWarning(int currentStreak) async {
    await _notifications.cancel(2001); // 2001 is for streak warnings

    final now = tz.TZDateTime.now(tz.local);
    // Schedule for 8 PM tonight if they haven't checked in
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);

    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      2001,
      '🔥 Streak at Risk!',
      'Your $currentStreak-day streak is ending soon. Complete your Sadhana now!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_warnings',
          'Streak Warnings',
          channelDescription: 'Alerts when your streak is about to be lost',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule daily wisdom (Daily Gyaan)
  Future<void> scheduleDailyGyaanNotification(String title) async {
    await _notifications.cancel(3001);

    final now = tz.TZDateTime.now(tz.local);
    // 9:00 AM every morning
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3001,
      'Daily Gyaan',
      'Today\'s Wisdom: $title',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_gyaan',
          'Daily Gyaan',
          channelDescription: 'Daily spiritual wisdom notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ── Naam Jap Smart Reminders ──────────────────────────────────────────────
  // ID range 4001-4002 reserved for jap reminders (morning + evening).

  static const _japMorningMessages = [
    ("ॐ उठो, जपो।", "सूर्योदय आपका जप बुला रहा है। आज की माला पूरी करें।"),
    ("🙏 भोर में जप।", "सुबह का समय प्रभु के चिंतन के लिए सर्वोत्तम है।"),
    ("✨ नाम जप करें।", "हर श्वास में राम, हर पल में शांति।"),
    ("🪷 जागो, जपो।", "माला के 108 मनकों में आज की शुरुआत करें।"),
  ];

  static const _japEveningMessages = [
    ("🌙 संध्या जप।", "दिन ढलने से पहले अपनी माला पूरी करें।"),
    ("🪔 दीप जलाओ।", "रात की शांति में प्रभु-नाम का स्मरण करें।"),
    ("✨ अभी जपो।", "कल का भरोसा नहीं — आज की माला आज ही पूरी करें।"),
    ("🙏 माला शेष है।", "एक पल रुकें, राम का नाम लें।"),
  ];

  /// Schedule two daily Naam Jap reminders — morning at [morningHour]:00
  /// and evening at [eveningHour]:00. Rotates through spiritual messages.
  Future<void> scheduleJapReminders({
    int morningHour = 7,
    int eveningHour = 20,
  }) async {
    await cancelJapReminders();

    final now = tz.TZDateTime.now(tz.local);
    final dayOfYear = now.difference(DateTime(now.year)).inDays;

    // Pick message variant based on day of year (rotates every 4 days)
    final morningMsg = _japMorningMessages[dayOfYear % _japMorningMessages.length];
    final eveningMsg = _japEveningMessages[dayOfYear % _japEveningMessages.length];

    await _scheduleJapAt(
      id: 4001,
      hour: morningHour,
      minute: 0,
      title: morningMsg.$1,
      body: morningMsg.$2,
    );

    await _scheduleJapAt(
      id: 4002,
      hour: eveningHour,
      minute: 0,
      title: eveningMsg.$1,
      body: eveningMsg.$2,
    );

    debugPrint('Naam Jap reminders scheduled: ${morningHour}:00 & ${eveningHour}:00');
  }

  Future<void> _scheduleJapAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'naam_jap_reminders',
        'Naam Jap Reminders',
        channelDescription: 'Daily reminders to complete your Naam Jap practice',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Fall back to inexact on restricted devices
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelJapReminders() async {
    await _notifications.cancel(4001);
    await _notifications.cancel(4002);
  }
}

