import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications_example',
);

const String portName = 'notification_send_port';

String? selectedNotificationPayload;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> init() async {
    //  await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Đăng ký FCM token và topic
    if (!Platform.isLinux && !Platform.isWindows) {
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  /// Đăng ký vào 1 topic (FCM)
  Future<void> subscribeTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Huỷ đăng ký topic
  Future<void> unsubscribeTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  /// Hiển thị thông báo đơn giản
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          channelDescription: 'Default channel for notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      body: body,
      notificationDetails: notificationDetails,
      title: title,
      payload: payload,
    );
  }

  /// Lịch hẹn giờ theo TZ
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      id: id,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

/// Callback cho background notification tap
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'Tapped notification ${notificationResponse.id}, payload: ${notificationResponse.payload}',
  );
}
