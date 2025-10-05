import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Tinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LandingScreen(),
    );
  }
}
