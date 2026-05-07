import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final prefs = await SharedPreferences.getInstance();
  final String lang = prefs.getString('language') ?? 'bn';
  runApp(MyApp(initialLang: lang));
}

class MyApp extends StatefulWidget {
  final String initialLang;
  const MyApp({super.key, required this.initialLang});

  static void setLocale(BuildContext context, String lang) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLang(lang);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLang;
  }

  void setLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _lang == 'bn' ? 'নামাজের সময়' : 'Time for Namaz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(lang: _lang),
    );
  }
}
