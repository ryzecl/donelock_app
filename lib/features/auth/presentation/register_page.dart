import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import 'package:donelock/core/widgets/brutalist_loading.dart';

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
      await ref.read(authRepositoryProvider).register(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
          );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showError(context, e);
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() => loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showError(context, e);
      }
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CREATE ACCOUNT")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: BrutalistLoading(size: 16, color: Colors.white),
                    )
                  : const Text("REGISTER"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: loading ? null : loginWithGoogle,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 2),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("CONTINUE WITH GOOGLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
}
