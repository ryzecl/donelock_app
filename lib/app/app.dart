import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class DoneLockApp extends ConsumerWidget {
  const DoneLockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DoneLock',
      debugShowCheckedModeBanner: false,
      theme: BrutalistTheme.light,
      routerConfig: router,
    );
  }
}
