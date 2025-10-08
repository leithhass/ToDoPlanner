
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/todos/domain/todo.dart';

final notificationServiceProvider = Provider<NotificationService>((_) => NotificationService.instance);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  int _idForTodo(Todo t) => t.id.hashCode;

  Future<void> scheduleFor(Todo t) async {
    if (!_initialized || t.dueDate == null || t.deletedAt != null || t.done) return;
    final when = tz.TZDateTime.from(t.dueDate!, tz.local);
    final androidDetails = const AndroidNotificationDetails(
      'todo_channel', 'Rappels',
      channelDescription: 'Rappels de tâches à échéance',
      importance: Importance.defaultImportance, priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.zonedSchedule(
      _idForTodo(t),
      'Rappel',
      t.title,
      when,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelFor(Todo t) async {
    if (!_initialized) return;
    await _plugin.cancel(_idForTodo(t));
  }
}
