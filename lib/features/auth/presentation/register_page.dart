import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../app/auth_gate.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    setState(() {
      loading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,

              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : register,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
