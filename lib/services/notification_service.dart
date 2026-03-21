import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Note: timezone handling is required in a real app using timezone package.
    // For this boilerplate, we use a delayed Future if it's within runtime,
    // otherwise the proper timezone-based scheduling would be used.
    
    // In production, we would use:
    // _flutterLocalNotificationsPlugin.zonedSchedule(...)
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'diary_reminders',
      'Diary Reminders',
      channelDescription: 'Reminders for Diary Sync tasks',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    // Fallback simple schedule for this codebase context
    // It assumes app is running or backgrounded. Proper persistent scheduling needs flutter_timezone.
    final duration = scheduledDate.difference(DateTime.now());
    if (duration.isNegative) return;

    Future.delayed(duration, () {
      _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
    });
  }
}
