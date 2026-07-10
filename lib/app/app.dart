import 'package:flutter/material.dart';
import 'auth_gate.dart';
import '../features/splash/presentation/splash_page.dart';

class DoneLockApp extends StatelessWidget {
  const DoneLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoneLock',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      home: const SplashPage(),
    );
  }
}
