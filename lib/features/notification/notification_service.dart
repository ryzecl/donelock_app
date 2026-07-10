import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(settings: settings);
  }

  Future<void> scheduleDailyReminder() async {
    await notifications.zonedSchedule(
      id: 0,
      title: "DoneLock 🔒",
      body: "Bagaimana harimu hari ini? Jangan lupa reflection.",
      scheduledDate: _nextInstanceOfTwentyTwo(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Reminder untuk jurnal harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTwentyTwo() {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> showDailyReminder() async {
    await notifications.show(
      id: 0,
      title: "DoneLock 🔒",
      body: "Bagaimana harimu hari ini? Jangan lupa reflection.",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Reminder untuk jurnal harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
