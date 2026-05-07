import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class ReminderModel {
  final int id;
  final String title, type;
  final TimeOfDay time;
  final bool repeat;
  final List<int> days;
  bool isActive;
  ReminderModel({required this.id, required this.title, required this.type,
    required this.time, required this.repeat, required this.days, this.isActive = true});
  Map<String, dynamic> toJson() => {'id':id,'title':title,'type':type,'hour':time.hour,'minute':time.minute,'repeat':repeat,'days':days,'isActive':isActive};
  factory ReminderModel.fromJson(Map<String, dynamic> j) => ReminderModel(
    id:j['id'],title:j['title'],type:j['type'],
    time:TimeOfDay(hour:j['hour'],minute:j['minute']),
    repeat:j['repeat'],days:List<int>.from(j['days']),isActive:j['isActive']);
}

class ReminderScreen extends StatefulWidget {
  final String lang;
  const ReminderScreen({super.key, required this.lang});
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<ReminderModel> _reminders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final data = p.getStringList('reminders') ?? [];
    setState(() => _reminders = data.map((e) => ReminderModel.fromJson(json.decode(e))).toList());
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('reminders', _reminders.map((e) => json.encode(e.toJson())).toList());
  }

  Future<void> _add() async {
    await NotificationService.playClickSound();
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue)), child: child!));
    if (picked == null || !mounted) return;
    String type = 'namaz';
    bool repeat = true;
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.lang == 'bn' ? 'রিমাইন্ডার সেটিং' : 'Reminder Settings',
          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.lang == 'bn' ? 'ধরন:' : 'Type:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            _chip('namaz', widget.lang == 'bn' ? 'নামাজ' : 'Namaz', type, (v) => setS(() => type = v)),
            const SizedBox(width: 8),
            _chip('quran', widget.lang == 'bn' ? 'কুরআন' : 'Quran', type, (v) => setS(() => type = v)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Text(widget.lang == 'bn' ? 'পুনরাবৃত্তি:' : 'Repeat:', style: const TextStyle(fontWeight: FontWeight.w600)),
            Switch(value: repeat, activeColor: AppTheme.primaryBlue, onChanged: (v) => setS(() => repeat = v)),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(widget.lang == 'bn' ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final id = DateTime.now().millisecondsSinceEpoch % 100000;
              final title = type == 'quran' ? (widget.lang == 'bn' ? 'কুরআন রিমাইন্ডার' : 'Quran Reminder') : (widget.lang == 'bn' ? 'নামাজ রিমাইন্ডার' : 'Namaz Reminder');
              final now = DateTime.now();
              final scheduled = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
              if (type == 'quran') {
                await NotificationService.scheduleQuranReminder(id: id, scheduledTime: scheduled, repeat: repeat, lang: widget.lang);
              } else {
                await NotificationService.scheduleNamazReminder(id: id, prayerName: title, scheduledTime: scheduled, repeat: repeat, lang: widget.lang);
              }
              setState(() => _reminders.add(ReminderModel(id: id, title: title, type: type, time: picked, repeat: repeat, days: [])));
              await _save();
            },
            child: Text(widget.lang == 'bn' ? 'সংরক্ষণ' : 'Save'),
          ),
        ],
      ),
    ));
  }

  Widget _chip(String value, String label, String current, Function(String) onTap) {
    final sel = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primaryBlue : AppTheme.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4))),
        child: Text(label, style: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () async { await NotificationService.playClickSound(); if (mounted) Navigator.pop(context); }),
        title: Text(widget.lang == 'bn' ? 'রিমাইন্ডার' : 'Reminders',
          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add, backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(widget.lang == 'bn' ? 'নতুন' : 'New', style: const TextStyle(color: Colors.white)),
      ),
      body: _reminders.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.alarm_off, color: AppTheme.textGrey, size: 70),
            const SizedBox(height: 16),
            Text(widget.lang == 'bn' ? 'কোনো রিমাইন্ডার নেই' : 'No reminders yet',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 16)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16,16,16,100),
            itemCount: _reminders.length,
            itemBuilder: (_, i) {
              final r = _reminders[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 8, offset: const Offset(0,3))]),
                child: Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: r.type == 'quran' ? Colors.green.withOpacity(0.1) : AppTheme.primaryBlue.withOpacity(0.1)),
                    child: Icon(r.type == 'quran' ? Icons.menu_book : Icons.access_time,
                      color: r.type == 'quran' ? Colors.green : AppTheme.primaryBlue)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    Text(r.time.format(context), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.w900)),
                  ])),
                  Column(children: [
                    Switch(value: r.isActive, activeColor: AppTheme.primaryBlue, onChanged: (v) async {
                      await NotificationService.playClickSound();
                      setState(() => r.isActive = v);
                      if (!v) await NotificationService.cancelReminder(r.id);
                      await _save();
                    }),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () async {
                        await NotificationService.cancelReminder(r.id);
                        setState(() => _reminders.removeAt(i));
                        await _save();
                      }),
                  ]),
                ]),
              ).animate().fadeIn(delay: Duration(milliseconds: 80*i));
            }),
    );
  }
}
