import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen for success or error
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      next.maybeWhen(
        data: (user) {
          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration Successful! Please Login.")),
            );
            Navigator.pop(context); // Go back to Login page
          }
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        ),
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthField(hintText: 'Full Name', controller: nameController),
            const SizedBox(height: 15),
            AuthField(hintText: 'Email', controller: emailController),
            const SizedBox(height: 15),
            AuthField(hintText: 'Password', controller: passwordController, isPassword: true),
            const SizedBox(height: 25),
            authState.maybeWhen(
              loading: () => const CircularProgressIndicator(),
              orElse: () => ElevatedButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).register(
                    emailController.text,
                    passwordController.text,
                    nameController.text,
                  );
                },
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}