import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatelessWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

  Future<List> _fetch() async {
    var url = Uri.parse(
        "http://10.0.2.2:8080/turuqna_api/api_get_notifications.php?user_id=$userId");
    var res = await http.get(url);
    return json.decode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Notifications"),
          backgroundColor: const Color(0xFF1D6B60),
          foregroundColor: Colors.white),
      body: FutureBuilder<List>(
        future: _fetch(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty)
            return const Center(child: Text("Your inbox is empty."));
          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (c, i) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.orange),
                title: const Text("Report Update",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(snap.data![i]['content']),
                trailing: Text(
                    snap.data![i]['created_at'].toString().substring(5, 10),
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
          );
        },
      ),
    );
  }
}
