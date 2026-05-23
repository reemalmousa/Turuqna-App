import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _loading = true;
  final Color teal = const Color(0xFF1D6B60);

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    var res = await http.get(Uri.parse(
        "http://10.0.2.2:8080/turuqna_api/api_get_profile.php?user_id=${widget.userId}"));
    var data = json.decode(res.body);
    setState(() {
      _name.text = data['full_name'];
      _phone.text = data['phone_number'];
      _email.text = data['email'];
      _loading = false;
    });
  }

  Future<void> _update() async {
    await http.post(
        Uri.parse("http://10.0.2.2:8080/turuqna_api/api_update_profile.php"),
        body: {
          "user_id": widget.userId,
          "full_name": _name.text,
          "phone_number": _phone.text
        });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("My Profile"),
          backgroundColor: teal,
          foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(25),
              children: [
                const CircleAvatar(
                    radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 30),
                TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                        labelText: "Full Name", border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(
                    controller: _phone,
                    decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(
                    controller: _email,
                    enabled: false,
                    decoration: const InputDecoration(
                        labelText: "Email (Fixed)",
                        border: OutlineInputBorder(),
                        filled: true)),
                const SizedBox(height: 40),
                ElevatedButton(
                    onPressed: _update,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        minimumSize: const Size(double.infinity, 55)),
                    child: const Text("SAVE CHANGES",
                        style: TextStyle(color: Colors.white))),
              ],
            ),
    );
  }
}
