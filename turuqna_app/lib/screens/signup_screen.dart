import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isLoading = false;
  final Color primaryTeal = const Color(0xFF1D6B60);

  // --- THE REGISTRATION LOGIC ---
  Future<void> _register() async {
    // 1. Check all conditions (Email, Phone, Password)
    if (!_formKey.currentState!.validate()) {

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Form"),
          content: const Text(
              "Please complete all required fields correctly."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      // API URL (Ensure Port 8080 is correct in your XAMPP)
      var url = Uri.parse("http://10.0.2.2:8080/turuqna_api/api_signup.php");

      var res = await http.post(url, body: {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "password": _passController.text,
      });

      var data = json.decode(res.body);

      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account Created! You can now log in."),
              backgroundColor: Colors.green),
        );
        // Go to Login Page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Connection Error. Check XAMPP and Firewall.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode:
            AutovalidateMode.onUserInteraction, // Shows red errors while typing
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Text("Join Turuqna",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 1. Full Name
              _field(_nameController, "Full Name", Icons.person,
                      (v) => v == null || v.isEmpty ? "Full Name is required" : null),

// 2. Email
              _field(_emailController, "Email Address", Icons.email, (v) {
                if (v == null || v.isEmpty) {
                  return "Email is required";
                }

                final emailRegex =
                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                if (!emailRegex.hasMatch(v)) {
                  return "Enter a valid email";
                }

                return null;
              }, type: TextInputType.emailAddress),

// 3. Phone
              _field(_phoneController, "Phone (05xxxxxxxx)", Icons.phone, (v) {
                if (v == null || v.isEmpty) {
                  return "Phone number is required";
                }

                if (v.length != 10 || !v.startsWith("05")) {
                  return "Must be 10 digits starting with 05";
                }

                return null;
              }, type: TextInputType.phone),

// 4. Password
              _field(_passController, "Password", Icons.lock, (v) {
                if (v == null || v.isEmpty) {
                  return "Password is required";
                }

                final passRegex = RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');

                if (!passRegex.hasMatch(v)) {
                  return "8+ chars: Upper, Lower, Number & Symbol";
                }

                return null;
              }, hide: true),

// 5. Confirm Password
              _field(_confirmPassController, "Confirm Password",
                  Icons.lock_outline, (v) {

                    if (v == null || v.isEmpty) {
                      return "Please confirm password";
                    }

                    if (v != _passController.text) {
                      return "Passwords do not match";
                    }

                    return null;
                  }, hide: true),

              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text("REGISTER",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold))),

              const SizedBox(height: 20),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Already have an account? Login",
                      style: TextStyle(color: primaryTeal)))
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Field Helper
  Widget _field(TextEditingController c, String l, IconData i,
      String? Function(String?)? v,
      {bool hide = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c,
        validator: v,
        obscureText: hide,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i, color: primaryTeal),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
