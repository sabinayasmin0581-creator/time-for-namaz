import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';
import 'reminder_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String lang;
  const HomeScreen({super.key, required this.lang});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTime? _pt;
  bool _loading = true;
  String _error = '';
  late String _lang;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _prayers = [
    {'key': 'fajr', 'bn': 'ফজর', 'en': 'Fajr', 'icon': Icons.wb_twilight},
    {'key': 'sunrise', 'bn': 'সূর্যোদয়', 'en': 'Sunrise', 'icon': Icons.wb_sunny_outlined},
    {'key': 'dhuhr', 'bn': 'যোহর', 'en': 'Dhuhr', 'icon': Icons.light_mode},
    {'key': 'asr', 'bn': 'আসর', 'en': 'Asr', 'icon': Icons.wb_cloudy_outlined},
    {'key': 'maghrib', 'bn': 'মাগরিব', 'en': 'Maghrib', 'icon': Icons.wb_twilight_outlined},
    {'key': 'isha', 'bn': 'এশা', 'en': 'Isha', 'icon': Icons.nightlight_round},
  ];

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    NotificationService.initialize();
    _requestAndLoad();
  }

  Future<void> _requestAndLoad() async {
    await Permission.notification.request();
    await Permission.location.request();
    await _loadByLocation();
  }

  Future<void> _loadByLocation() async {
    setState(() { _loading = true; _error = ''; });
    try {
      bool ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) { await _loadByCity('Dhaka'); return; }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.deniedForever) { await _loadByCity('Dhaka'); return; }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final pt = await PrayerService.getPrayerTimesByCoords(pos.latitude, pos.longitude);
      if (pt != null) { setState(() { _pt = pt; _loading = false; }); }
      else { await _loadByCity('Dhaka'); }
    } catch (_) { await _loadByCity('Dhaka'); }
  }

  Future<void> _loadByCity(String city) async {
    setState(() { _loading = true; _error = ''; });
    final pt = await PrayerService.getPrayerTimesByCity(city);
    setState(() {
      _pt = pt; _loading = false;
      if (pt == null) _error = _lang == 'bn' ? 'ডেটা লোড হয়নি' : 'Failed to load';
    });
  }

  String _getTime(String key) {
    if (_pt == null) return '--:--';
    switch (key) {
      case 'fajr': return _pt!.fajr;
      case 'sunrise': return _pt!.sunrise;
      case 'dhuhr': return _pt!.dhuhr;
      case 'asr': return _pt!.asr;
      case 'maghrib': return _pt!.maghrib;
      case 'isha': return _pt!.isha;
      default: return '--:--';
    }
  }

  String get _next => _pt != null ? PrayerService.getNextPrayer(_pt!) : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _error.isNotEmpty ? _buildError() : _buildContent()),
      ])),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    decoration: const BoxDecoration(color: AppTheme.white,
      boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 8, offset: Offset(0, 2))]),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_lang == 'bn' ? 'নামাজের সময়' : 'Time for Namaz',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
        if (_pt != null) Text(_pt!.date, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
      ]),
      Row(children: [
        IconButton(icon: const Icon(Icons.search, color: AppTheme.primaryBlue), onPressed: () async {
          await NotificationService.playClickSound();
          if (!mounted) return;
          final city = await Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(lang: _lang)));
          if (city != null) _loadByCity(city);
        }),
        IconButton(icon: const Icon(Icons.refresh, color: AppTheme.primaryBlue), onPressed: () async {
          await NotificationService.playClickSound();
          _loadByLocation();
        }),
      ]),
    ]),
  );

  Widget _buildContent() => RefreshIndicator(
    onRefresh: _loadByLocation, color: AppTheme.primaryBlue,
    child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildNextCard(), const SizedBox(height: 16),
        _buildHijriCard(), const SizedBox(height: 16),
        _buildGrid(), const SizedBox(height: 16),
        _buildAzanBtn(), const SizedBox(height: 80),
      ])),
  );

  Widget _buildNextCard() => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Column(children: [
      Text(_lang == 'bn' ? 'পরবর্তী নামাজ' : 'Next Prayer',
        style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 8),
      Text(_next, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(_pt?.location ?? '', style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);

  Widget _buildHijriCard() => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.calendar_month, color: AppTheme.primaryBlue, size: 18),
      const SizedBox(width: 8),
      Text(_pt?.hijriDate ?? '', style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  ).animate().fadeIn(delay: 200.ms);

  Widget _buildGrid() => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemCount: _prayers.length,
    itemBuilder: (_, i) {
      final p = _prayers[i];
      final isNext = _next.toLowerCase() == (p['en'] as String).toLowerCase();
      return GestureDetector(
        onTap: () => NotificationService.playClickSound(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isNext ? AppTheme.primaryBlue : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
            border: isNext ? null : Border.all(color: AppTheme.lightBlue.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(p['icon'] as IconData, color: isNext ? Colors.white70 : AppTheme.lightBlue, size: 18),
                const SizedBox(width: 6),
                Text(_lang == 'bn' ? p['bn'] as String : p['en'] as String,
                  style: TextStyle(color: isNext ? Colors.white : AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              Text(_getTime(p['key'] as String),
                style: TextStyle(color: isNext ? Colors.white : AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.w900)),
            ]),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideY(begin: 0.3, end: 0),
      );
    },
  );

  Widget _buildAzanBtn() => ElevatedButton.icon(
    icon: const Icon(Icons.volume_up),
    label: Text(_lang == 'bn' ? 'আজান শুনুন' : 'Play Azan'),
    onPressed: () async { await NotificationService.playClickSound(); await NotificationService.playAzan(); },
    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  ).animate().fadeIn(delay: 600.ms);

  Widget _buildError() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.wifi_off, color: AppTheme.textGrey, size: 60),
    const SizedBox(height: 16),
    Text(_error, style: const TextStyle(color: AppTheme.textGrey)),
    const SizedBox(height: 16),
    ElevatedButton(onPressed: _loadByLocation,
      child: Text(_lang == 'bn' ? 'আবার চেষ্টা করুন' : 'Try Again')),
  ]));

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'bn': 'হোম', 'en': 'Home'},
      {'icon': Icons.alarm, 'bn': 'রিমাইন্ডার', 'en': 'Reminder'},
      {'icon': Icons.settings, 'bn': 'সেটিং', 'en': 'Settings'},
    ];
    return Container(
      decoration: const BoxDecoration(color: AppTheme.white,
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 12, offset: Offset(0, -3))]),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryBlue, unselectedItemColor: AppTheme.textGrey,
        backgroundColor: AppTheme.white, elevation: 0,
        onTap: (i) async {
          await NotificationService.playClickSound();
          setState(() => _selectedIndex = i);
          if (i == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderScreen(lang: _lang)));
          else if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(lang: _lang)));
        },
        items: items.map((item) => BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          label: _lang == 'bn' ? item['bn'] as String : item['en'] as String,
        )).toList(),
      ),
    );
  }
}
