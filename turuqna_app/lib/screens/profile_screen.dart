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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  final Color primaryTeal = const Color(0xFF1D6B60);

  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Load data from DB as soon as page opens
  }

  Future<void> _fetchProfile() async {
    try {
      // 10.0.2.2:8080 is for Emulator talking to XAMPP
      var url = Uri.parse(
          "http://10.0.2.2:8080/turuqna_api/api_get_profile.php?user_id=${widget.userId}");
      var res = await http.get(url);
      var data = json.decode(res.body);

      if (data['status'] == "success") {
        setState(() {
          _nameController.text = data['full_name'] ?? "";
          _phoneController.text = data['phone_number'] ?? "";
          _emailController.text = data['email'] ?? "";
          _isLoading = false;
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print("Error fetching: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load profile from DB")));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      var url =
          Uri.parse("http://10.0.2.2:8080/turuqna_api/api_update_profile.php");
      var res = await http.post(url, body: {
        "user_id": widget.userId,
        "full_name": _nameController.text,
        "phone_number": _phoneController.text,
      });

      var data = json.decode(res.body);
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile updated!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Save Error")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("My Profile"),
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(25),
              child: ListView(
                children: [
                  const CircleAvatar(
                      radius: 50, child: Icon(Icons.person, size: 50)),
                  const SizedBox(height: 30),
                  _field("Full Name", _nameController, Icons.person),
                  _field("Phone Number", _phoneController, Icons.phone),
                  _field("Email Address", _emailController, Icons.email,
                      enabled: false), // Fixed email
                  const SizedBox(height: 40),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              minimumSize: const Size(double.infinity, 55)),
                          onPressed: _saveChanges,
                          child: const Text("SAVE CHANGES",
                              style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
    );
  }

  Widget _field(String l, TextEditingController c, IconData i,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
            labelText: l,
            prefixIcon: Icon(i, color: primaryTeal),
            border: const OutlineInputBorder()),
      ),
    );
  }
}
