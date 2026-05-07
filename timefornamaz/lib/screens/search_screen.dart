import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class SearchScreen extends StatefulWidget {
  final String lang;
  const SearchScreen({super.key, required this.lang});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final List<String> _all = ['Dhaka','Chittagong','Sylhet','Rajshahi','Khulna','Barisal',
    'Rangpur','Mymensingh','Comilla','Jessore','Narayanganj','Gazipur','Tangail','Bogra',
    'Dinajpur','Faridpur','Pabna','Sirajganj','Brahmanbaria','Noakhali'];
  List<String> _filtered = [];

  @override
  void initState() { super.initState(); _filtered = _all; }

  void _search(String q) => setState(() =>
    _filtered = _all.where((c) => c.toLowerCase().contains(q.toLowerCase())).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () async { await NotificationService.playClickSound(); if (mounted) Navigator.pop(context); }),
        title: Text(widget.lang == 'bn' ? 'এলাকা খুঁজুন' : 'Search Location',
          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        Container(color: AppTheme.white, padding: const EdgeInsets.fromLTRB(16,0,16,16),
          child: TextField(controller: _ctrl, autofocus: true, onChanged: _search,
            decoration: InputDecoration(
              hintText: widget.lang == 'bn' ? 'শহর বা এলাকার নাম লিখুন...' : 'Type city or area name...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
              filled: true, fillColor: AppTheme.offWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            ))),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () async { await NotificationService.playClickSound(); if (mounted) Navigator.pop(context, _filtered[i]); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 6, offset: const Offset(0,2))]),
              child: Row(children: [
                const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(_filtered[i], style: const TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 14),
              ]),
            ).animate().fadeIn(delay: Duration(milliseconds: 30*i)),
          ),
        )),
      ]),
    );
  }
}
