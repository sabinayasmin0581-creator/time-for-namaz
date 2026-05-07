import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audio = AudioPlayer();
  static bool _init = false;

  static Future<void> initialize() async {
    if (_init) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (d) async {
        await playNotificationSound(d.payload ?? 'namaz');
      },
    );
    _init = true;
  }

  static Future<void> playNotificationSound(String type) async {
    try {
      await _audio.play(AssetSource(type == 'quran' ? 'audio/quran_reminder.mp3' : 'audio/namaz_reminder.mp3'));
    } catch (_) {}
  }

  static Future<void> playClickSound() async {
    try { await _audio.play(AssetSource('audio/click.mp3')); } catch (_) {}
  }

  static Future<void> playAzan() async {
    try { await _audio.play(AssetSource('audio/azan.mp3')); } catch (_) {}
  }

  static Future<void> stopAudio() async { await _audio.stop(); }

  static Future<void> scheduleNamazReminder({
    required int id, required String prayerName, required DateTime scheduledTime,
    required bool repeat, required String lang,
  }) async {
    final title = lang == 'bn' ? 'নামাজের সময়' : 'Prayer Time';
    final body = lang == 'bn' ? 'আপনার $prayerName নামাজের সময় হয়ে গেছে' : '$prayerName prayer time has arrived';
    final details = NotificationDetails(android: AndroidNotificationDetails(
      'namaz_channel', 'Namaz Reminders',
      importance: Importance.max, priority: Priority.high, playSound: false,
    ));
    if (repeat) {
      await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(scheduledTime, tz.local), details, payload: 'namaz',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
    } else {
      await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(scheduledTime, tz.local), details, payload: 'namaz',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    }
  }

  static Future<void> scheduleQuranReminder({
    required int id, required DateTime scheduledTime,
    required bool repeat, required String lang,
  }) async {
    final title = lang == 'bn' ? 'কুরআন পড়ার সময়' : 'Quran Time';
    final body = lang == 'bn' ? 'আপনার কুরআন পড়ার সময় হয়ে গেছে' : 'Time to read the Holy Quran';
    final details = NotificationDetails(android: AndroidNotificationDetails(
      'quran_channel', 'Quran Reminders',
      importance: Importance.max, priority: Priority.high, playSound: false,
    ));
    if (repeat) {
      await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(scheduledTime, tz.local), details, payload: 'quran',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
    } else {
      await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(scheduledTime, tz.local), details, payload: 'quran',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    }
  }

  static Future<void> cancelReminder(int id) async => await _notifications.cancel(id);
  static Future<void> cancelAll() async => await _notifications.cancelAll();
}
