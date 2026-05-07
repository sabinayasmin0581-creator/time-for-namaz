import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final String lang;
  const SettingsScreen({super.key, required this.lang});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _lang;
  bool _sound = true;

  @override
  void initState() { super.initState(); _lang = widget.lang; _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _sound = p.getBool('sound_enabled') ?? true; });
  }

  Future<void> _save(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is String) await p.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () async { await NotificationService.playClickSound(); if (mounted) Navigator.pop(context); }),
        title: Text(_lang == 'bn' ? 'সেটিং' : 'Settings',
          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title(_lang == 'bn' ? 'ভাষা' : 'Language'),
        _card([
          _langTile('বাংলা', 'bn'),
          const Divider(height: 1),
          _langTile('English', 'en'),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),
        _title(_lang == 'bn' ? 'শব্দ' : 'Sound'),
        _card([
          SwitchListTile(
            activeColor: AppTheme.primaryBlue,
            secondary: const Icon(Icons.volume_up, color: AppTheme.primaryBlue),
            title: Text(_lang == 'bn' ? 'ক্লিক শব্দ' : 'Click Sound',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            value: _sound,
            onChanged: (v) async { setState(() => _sound = v); await _save('sound_enabled', v); }),
        ]).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 20),
        _title(_lang == 'bn' ? 'অ্যাপ সম্পর্কে' : 'About'),
        _card([
          Container(width: double.infinity, padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(width: 70, height: 70,
                decoration: const BoxDecoration(shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.lightBlue])),
                child: const Center(child: Text('TFN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)))),
              const SizedBox(height: 12),
              const Text('Time for Namaz', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.w900)),
              const Text('নামাজের সময়', style: TextStyle(color: AppTheme.lightBlue, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Version 1.0.0', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              const Text('Dev By - Za v.a.u Org', style: TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
            ])),
        ]).animate().fadeIn(delay: 200.ms),
      ])),
    );
  }

  Widget _title(String t) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(t, style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 14, fontWeight: FontWeight.w700)));

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 8, offset: const Offset(0,3))]),
    child: Column(children: children));

  Widget _langTile(String label, String value) {
    final sel = _lang == value;
    return ListTile(
      leading: Container(width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? AppTheme.primaryBlue : AppTheme.offWhite),
        child: Center(child: Text(value == 'bn' ? 'ব' : 'A',
          style: TextStyle(color: sel ? Colors.white : AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 16)))),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      trailing: sel ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue) : const Icon(Icons.circle_outlined, color: AppTheme.textGrey),
      onTap: () async {
        await NotificationService.playClickSound();
        setState(() => _lang = value);
        await _save('language', value);
        if (mounted) MyApp.setLocale(context, value);
      },
    );
  }
}
