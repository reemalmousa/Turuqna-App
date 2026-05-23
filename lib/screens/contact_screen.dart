import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1D6B60);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          title: const Text("Contact Us")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Have questions? Reach out to us!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _contactTile(
              Icons.email_outlined, "Email Support", "support@turuqna.com"),
          _contactTile(Icons.phone_outlined, "Phone", "+966 500 000 000"),
          _contactTile(Icons.language, "Website", "www.turuqna.com"),
          _contactTile(Icons.location_on_outlined, "Headquarters",
              "Riyadh, Saudi Arabia"),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1D6B60)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
