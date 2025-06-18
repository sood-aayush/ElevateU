import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:college_project/Services/auth_service.dart';
import 'package:college_project/login_screen.dart';
import 'package:college_project/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = await _authService.signUp(
  context,
  _emailController.text.trim(),
  _passwordController.text.trim(),
  _nameController.text.trim(),
  _goalController.text.trim(),
);
      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Create Account", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) =>
                      value != null && value.contains('@') ? null : "Enter a valid email",
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) =>
                      value != null && value.length >= 6 ? null : "Minimum 6 characters",
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                      value != null && value.trim().length >= 3 ? null : "Enter a valid name",
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(labelText: "Your Goal"),
                  validator: (value) =>
                      value != null && value.trim().isNotEmpty ? null : "Please enter a goal",
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signup,
                        child: const Text("Sign Up"),
                      ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
