import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String>();

  static Future init({bool scheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    // when app is closed check whether the app is launched via the notification
    // if so add the payload to our stream so we can handle the event after launching the app
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload);
    }
    await _notifications.initialize(settings, onSelectNotification: (payload) {
      onNotifications.add(payload);
    });

    if (scheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails("id", "name", importance: Importance.max),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future showNotification({
    int id = 0,
    String title,
    String body,
    String payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );

  static Future scheduleNotification({
    int id = 0,
    String title,
    String body,
    String payload,
    @required DateTime dateTime,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

  static Future scheduleDailyNotification({
    int id = 0,
    String title,
    String body,
    String payload,
    @required tz.TZDateTime tzDateTime,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  static tz.TZDateTime tzTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate;
  }

  static tz.TZDateTime tzDateTime(Duration durationOffset) {
    final tomorrow = tz.TZDateTime.now(tz.local).add(durationOffset);
    final scheduledDate = tz.TZDateTime(
        tz.local, tomorrow.year, tomorrow.month, tomorrow.day, tomorrow.hour, tomorrow.minute, tomorrow.second);
    return scheduledDate;
  }

  static Future deleteNotificationById(int id) async => _notifications.cancel(id);
}
