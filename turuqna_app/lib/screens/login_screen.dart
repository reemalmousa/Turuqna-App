import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    try {

      var url = Uri.parse("http://10.0.2.2:8080/turuqna_api/api_login.php");
      var res = await http
          .post(url, body: {"email": _email.text, "password": _pass.text});
      var data = json.decode(res.body);

      if (data['status'] == "success") {
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Connection error")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1D6B60)),
              onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 30),
            TextField(
                controller: _email,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder())),
            const SizedBox(height: 15),

            TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder())),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 15),
            _loading

                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D6B60),
                        minimumSize: const Size(double.infinity, 55)),
                    child: const Text("LOGIN",
                        style: TextStyle(color: Colors.white))),
            TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const SignupScreen())),
                child: const Text("Sign Up"))
          ],
        ),
      ),
    );
  }
}
