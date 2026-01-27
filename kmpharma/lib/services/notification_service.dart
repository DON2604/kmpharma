import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    await _requestPermissions();

    // Check and request exact alarm permission for Android 12+
    if (Platform.isAndroid) {
      await _checkExactAlarmPermission();
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<bool> _checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        return false;
      }
      return true;
    }
    return true;
  }

  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      return await Permission.scheduleExactAlarm.isGranted;
    }
    return true;
  }

  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();
    
    if (scheduledTime.isBefore(now)) {
      print('Scheduled time is in the past, skipping notification');
      return;
    }

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Medication reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@drawable/ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
