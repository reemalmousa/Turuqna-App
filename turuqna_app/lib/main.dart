import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const TuruqnaApp());
}

class TuruqnaApp extends StatelessWidget {
  const TuruqnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Turuqna',
      theme: ThemeData(
        primaryColor: const Color(0xFF1D6B60),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
