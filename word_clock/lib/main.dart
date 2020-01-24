import 'package:flutter/material.dart';
import 'dart:async';

import './screens/splash_screen.dart';
import './screens/main_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  bool _isPastSplashScreen = false;

  static const int splashScreenTimeout = 6;

  @override
  void initState() {
    super.initState();
    _startSplashScreenTimer();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 94, 80, 63),
        accentColor: Color.fromARGB(255, 94, 80, 63),
      ),
      home: Scaffold(
        body: !_isPastSplashScreen ? SplashScreen() : MainScreen(),
      ),
    );
  }

  _startSplashScreenTimer() {
    Timer(Duration(seconds: splashScreenTimeout), () {
      setState(() {
        _isPastSplashScreen = true;
      });
    });
  }
}
