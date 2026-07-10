import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_provider.dart';

import '../features/auth/presentation/login_page.dart';

import '../features/home/presentation/home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (error, stack) {
        return Scaffold(body: Center(child: Text(error.toString())));
      },

      data: (user) {
        if (user != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
