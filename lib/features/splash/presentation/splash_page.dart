import 'package:flutter/material.dart';

import '../../../core/storage/preferences_service.dart';

import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    check();
  }

  Future<void> check() async {
    await Future.delayed(const Duration(seconds: 2));

    final onboarding = await PreferencesService().isOnboardingCompleted();

    if (!mounted) return;

    if (onboarding) {
      if (context.mounted) {
        context.go('/auth/login');
      }
    } else {
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
