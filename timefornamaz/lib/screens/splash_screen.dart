import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final String lang;
  const SplashScreen({super.key, required this.lang});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(lang: widget.lang),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -80, right: -80, child: Container(width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.lightBlue.withOpacity(0.1)))),
            Positioned(bottom: -60, left: -60, child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue.withOpacity(0.08)))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: const Center(child: Text('TFN', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2))),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut, begin: const Offset(0,0), end: const Offset(1,1)).fadeIn(duration: 600.ms),
                  const SizedBox(height: 28),
                  const Text('Time for Namaz', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 30, fontWeight: FontWeight.w900))
                    .animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  const Text('নামাজের সময়', style: TextStyle(color: AppTheme.lightBlue, fontSize: 22, fontWeight: FontWeight.w600))
                    .animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.offWhite, borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3))),
                    child: const Text('সময়মতো নামাজ পড়ুন • Pray on Time',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontStyle: FontStyle.italic)),
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 50),
                  SizedBox(width: 40, height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue.withOpacity(0.6))))
                    .animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),
            Positioned(bottom: 30, left: 0, right: 0,
              child: const Column(children: [
                Text('Dev By - Za v.a.u Org', textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text('v1.0.0', textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
              ]).animate().fadeIn(delay: 1000.ms)),
          ],
        ),
      ),
    );
  }
}
