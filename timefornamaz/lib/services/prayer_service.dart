import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTime {
  final String fajr, sunrise, dhuhr, asr, maghrib, isha;
  final String date, hijriDate, location;
  PrayerTime({required this.fajr, required this.sunrise, required this.dhuhr,
    required this.asr, required this.maghrib, required this.isha,
    required this.date, required this.hijriDate, required this.location});
}

class PrayerService {
  static const String _base = 'https://api.aladhan.com/v1';

  static Future<PrayerTime?> getPrayerTimesByCity(String city) async {
    try {
      final url = Uri.parse('$_base/timingsByCity?city=$city&country=Bangladesh&method=1');
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        final t = d['data']['timings'];
        final date = d['data']['date'];
        final hijri = date['hijri'];
        return PrayerTime(
          fajr: _fmt(t['Fajr']), sunrise: _fmt(t['Sunrise']),
          dhuhr: _fmt(t['Dhuhr']), asr: _fmt(t['Asr']),
          maghrib: _fmt(t['Maghrib']), isha: _fmt(t['Isha']),
          date: date['readable'] ?? '',
          hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
          location: city,
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<PrayerTime?> getPrayerTimesByCoords(double lat, double lng) async {
    try {
      final url = Uri.parse('$_base/timings?latitude=$lat&longitude=$lng&method=1');
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        final t = d['data']['timings'];
        final date = d['data']['date'];
        final hijri = date['hijri'];
        return PrayerTime(
          fajr: _fmt(t['Fajr']), sunrise: _fmt(t['Sunrise']),
          dhuhr: _fmt(t['Dhuhr']), asr: _fmt(t['Asr']),
          maghrib: _fmt(t['Maghrib']), isha: _fmt(t['Isha']),
          date: date['readable'] ?? '',
          hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
          location: 'Your Location',
        );
      }
    } catch (_) {}
    return null;
  }

  static String _fmt(String time) {
    if (time.contains(' ')) time = time.split(' ')[0];
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int h = int.parse(parts[0]);
    final m = parts[1];
    final p = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '$h:$m $p';
  }

  static String getNextPrayer(PrayerTime pt) {
    final now = DateTime.now();
    final prayers = {'Fajr': pt.fajr, 'Dhuhr': pt.dhuhr, 'Asr': pt.asr, 'Maghrib': pt.maghrib, 'Isha': pt.isha};
    for (var e in prayers.entries) {
      final t = _parseTime(e.value);
      if (t != null && now.isBefore(t)) return e.key;
    }
    return 'Fajr';
  }

  static DateTime? _parseTime(String s) {
    try {
      final parts = s.split(' ');
      final tp = parts[0].split(':');
      int h = int.parse(tp[0]);
      final m = int.parse(tp[1]);
      if (parts[1] == 'PM' && h != 12) h += 12;
      if (parts[1] == 'AM' && h == 12) h = 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, h, m);
    } catch (_) { return null; }
  }
}
