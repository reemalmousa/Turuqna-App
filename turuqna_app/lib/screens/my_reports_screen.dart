import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyReportsScreen extends StatelessWidget {
  final String userId;
  const MyReportsScreen({super.key, required this.userId});

  Future<List> _fetch() async {
    // We send your REAL userId to the server
    var url = Uri.parse(
        "http://10.0.2.2:8080/turuqna_api/api_get_my_reports.php?citizen_id=$userId");
    var res = await http.get(url);
    return json.decode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("My Reports"),
          backgroundColor: const Color(0xFF1D6B60),
          foregroundColor: Colors.white),
      body: FutureBuilder<List>(
        future: _fetch(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty)
            return const Center(
                child: Text("No reports found for your account."));

          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (c, i) {
              var r = snap.data![i];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(r['description'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Status: ${r['status']}\nOfficer Note: ${r['officer_comment'] ?? 'Pending'}"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
