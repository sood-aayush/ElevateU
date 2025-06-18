import 'package:flutter/material.dart';
import 'package:college_project/Services/auth_service.dart';
import 'package:college_project/signup_screen.dart';
import 'package:college_project/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;

  void handleLogin() async {
  setState(() => isLoading = true);
  final user = await _authService.signIn(
    context,
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (!mounted) return; // 💡 prevents calling setState after disposal

  setState(() => isLoading = false);

  if (user != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text("Login", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : handleLogin,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
