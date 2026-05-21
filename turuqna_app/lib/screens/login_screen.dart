import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// IMPORTANT: Imports to allow navigation
import 'map_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  final Color primaryTeal = const Color(0xFF1D6B60);

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ensure the Port 8080 matches your XAMPP Apache
      var url = Uri.parse("http://10.0.2.2:8080/turuqna_api/api_login.php");
      var res = await http.post(url, body: {
        "email": _emailController.text,
        "password": _passController.text,
      });

      var data = json.decode(res.body);

      if (data['status'] == "success") {
        // SUCCESS: Send real User ID and Name to the Map
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (c) => MapScreen(
              userId: data['user_id'].toString(),
              userName: data['name'] ?? "Citizen",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Invalid Credentials")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Error. Is XAMPP running?")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- RESTORED BACK BUTTON ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal),
          onPressed: () =>
              Navigator.pop(context), // Goes back to Welcome Screen
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Logo
            Image.asset('assets/about_logo.png', height: 120),
            const SizedBox(height: 30),
            Text("Secure Login",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal)),
            const Text("Login to your Turuqna account",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 50),

            // Email Input
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 40),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryTeal))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _login,
                      child: const Text("LOGIN",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
            ),

            const SizedBox(height: 30),

            // --- RESTORED SIGN UP LINK ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SignupScreen()));
                  },
                  child: Text("Sign Up",
                      style: TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
