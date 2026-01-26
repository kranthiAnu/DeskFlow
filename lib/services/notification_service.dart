import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int breakNotifId = 1001;

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Android 13+ runtime permission
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<void> scheduleBreakIn(Duration after) async {
    // cancel previous scheduled break reminder
    await _plugin.cancel(breakNotifId);

    final scheduledLocal = tz.TZDateTime.now(tz.local).add(after);

    const androidDetails = AndroidNotificationDetails(
      'break_reminders',
      'Break Reminders',
      channelDescription: 'Reminds you to take a micro-break while working',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      breakNotifId,
      'Time to move 💪',
      'Take a 1–3 minute break to stay fit while working.',
      scheduledLocal,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showNow() async {
    const androidDetails = AndroidNotificationDetails(
      'break_reminders',
      'Break Reminders',
      channelDescription: 'Reminds you to take a micro-break while working',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      2001,
      'Break time 💥',
      'Stand up, stretch, and do a quick workout.',
      details,
    );
  }
  
  Future<void> cancelNextBreak() async {
    await _plugin.cancel(breakNotifId);
  }
}
