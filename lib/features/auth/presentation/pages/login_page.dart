import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';
import 'register_page.dart'; // <--- MUST HAVE THIS

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GymBuddy AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            AuthField(hintText: 'Email', controller: emailController),
            const SizedBox(height: 15),
            AuthField(hintText: 'Password', controller: passwordController, isPassword: true),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).login(
                  emailController.text,
                  passwordController.text,
                );
              },
              child: const Text("Login"),
            ),
            
            // CHECK THIS PART CAREFULLY
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("Don't have an account? Register"),
            )
          ],
        ),
      ),
    );
  }
}