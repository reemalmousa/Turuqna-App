import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyReportsScreen extends StatelessWidget {
  final String userId;
  const MyReportsScreen({super.key, required this.userId});

  Future<List> _fetch() async {
    var url = Uri.parse(
        "http://10.0.2.2:8080/turuqna_api/api_get_my_reports.php?citizen_id=$userId");
    var res = await http.get(url);
    return json.decode(res.body);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color teal = Color(0xFF1D6B60);
    return Scaffold(
      appBar: AppBar(
          title: const Text("My Reports & Feedback"),
          backgroundColor: teal,
          foregroundColor: Colors.white),
      body: FutureBuilder<List>(
        future: _fetch(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty)
            return const Center(child: Text("No reports found."));

          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (c, i) {
              var r = snap.data![i];
              final status = r['status'] ?? 'Pending';
              final statusColor = _statusColor(status);

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Report #${r['report_id']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              border: Border.all(color: statusColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(r['description'],
                          style: const TextStyle(fontSize: 16)),
                      const Divider(height: 30),
                      const Text("OFFICER NOTE:",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: teal)),
                      const SizedBox(height: 5),
                      Text(
                        r['officer_comment'] ?? "Waiting for review...",
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}