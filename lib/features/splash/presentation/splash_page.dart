import 'package:flutter/material.dart';

import '../../../core/storage/preferences_service.dart';

import '../../onboarding/presentation/onboarding_page.dart';
import '../../../app/auth_gate.dart';

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
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } else {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "DoneLock 🔒",

              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
