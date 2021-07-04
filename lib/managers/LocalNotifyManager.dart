import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class LocalNotifyManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String appNotificationIcon = 'app_notification_icon';
  var initSettings;
  // BehaviorSubject<ReceivedNotification> get didReceiveLocalNotificationSubject => BehaviorSubject<ReceivedNotification>();

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function
  final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

  String? selectedNotificationPayload;

  LocalNotifyManager.init() {
    if (Platform.isIOS) {
      requestIOSPermissions();
    }

    initializePlatform();
  }

  requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
      alert: true,
      badge: true,
      sound: true
    );
  }

  initializePlatform() {
    var initSettingsAndroid = AndroidInitializationSettings(appNotificationIcon);
    var initSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification notification = ReceivedNotification(id: id, title: title, body: body, payload: payload);
        didReceiveLocalNotificationSubject.add(notification);
      }
    );

    initSettings = InitializationSettings(android: initSettingsAndroid, iOS: initSettingsIOS);
  }

  setOnNotificationReceived(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClicked(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSettings,
      onSelectNotification: (String? payload) async {
        onNotificationClick(payload);
      }
    );
  }

  Future<void> showNotification() async {
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESC',
      importance: Importance.max,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      ledColor: Colors.green,
      priority: Priority.high
    );

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(
      android: androidChannel,
      iOS: iosChannel
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'Hi im just testing this plugin for notification',
      platformChannel,
      payload: 'New Payload'
    );
  }
}

LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload
  });
}
