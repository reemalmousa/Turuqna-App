import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          title: const Text("About Turuqna")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/about_logo.png', height: 120),
            const SizedBox(height: 30),
            const Text(
              "Turuqna is a smart traffic management system designed to help citizens report and avoid road congestion in real-time. Our mission is to reduce travel time and improve road safety through community-driven data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
