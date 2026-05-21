import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          title: const Text("Help & FAQ")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Frequently Asked Questions",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal)),
          const SizedBox(height: 15),
          _faqItem("How do I report traffic?",
              "Log in, go to the Map, and click the 'Report Traffic' button at the bottom."),
          _faqItem("Can I add photos to my report?",
              "Yes! You can use your camera or gallery in the Report screen."),
          _faqItem("Is my data private?",
              "Your personal information is encrypted and only used for report verification."),
          _faqItem("How accurate is the map?",
              "The map updates every 60 seconds based on user submissions."),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(answer, style: const TextStyle(color: Colors.black87)),
        )
      ],
    );
  }
}
