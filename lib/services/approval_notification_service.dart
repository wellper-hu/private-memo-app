import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';

class ApprovalNotificationService {
  static final ApprovalNotificationService _instance =
      ApprovalNotificationService._internal();
  factory ApprovalNotificationService() => _instance;
  ApprovalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;
  }

  Future<void> showPendingApprovalNotification(String title, String message) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'approval_channel',
      '审批通知',
      channelDescription: '审批相关通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> scheduleApprovalNotification({
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    tz_data.initializeTimeZones();

    final tzLocation = tz.getLocation('Asia/Shanghai');

    const androidDetails = AndroidNotificationDetails(
      'approval_channel',
      '审批通知',
      channelDescription: '审批相关通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      1,
      title,
      message,
      tz.TZDateTime.from(scheduledTime, tzLocation),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestPermission(
        sound: true,
        notification: true,
        badge: true,
      );
      return granted ?? false;
    }

    return false;
  }
}
