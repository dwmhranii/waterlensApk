// screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waterlens/main.dart';
// import 'home_screen.dart';
// import 'analyze_screen.dart';
// import 'history_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationController()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFECF8FD),
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          width: 180,
        ),
      ),
    );
  }
}
