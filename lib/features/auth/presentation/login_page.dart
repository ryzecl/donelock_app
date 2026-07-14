import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import 'package:donelock/core/widgets/brutalist_loading.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    try {
      await ref.read(authRepositoryProvider).login(
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

  Future<void> forgotPassword() async {
    final resetEmailController = TextEditingController(text: emailController.text);
    final send = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 3),
        ),
        title: const Text("FORGOT PASSWORD", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a reset link.", style: TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SEND"),
          ),
        ],
      ),
    );

    if (send == true && resetEmailController.text.trim().isNotEmpty) {
      try {
        await ref.read(authRepositoryProvider).resetPassword(resetEmailController.text.trim());
        if (mounted) {
          UIUtils.showSuccess(context, "Password reset link sent!");
        }
      } catch (e) {
        if (mounted) {
          UIUtils.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "DoneLock",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: forgotPassword,
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: BrutalistLoading(size: 16, color: Colors.white),
                    )
                  : const Text("LOGIN"),
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.push('/auth/register');
              },
              child: const Text("CREATE ACCOUNT"),
            )
          ],
        ),
      ),
    );
  }
}