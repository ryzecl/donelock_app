
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/preferences_service.dart';
import '../features/auth/providers/auth_provider.dart';

import '../features/splash/presentation/splash_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';

import 'presentation/main_shell.dart';
import '../features/home/presentation/home_page.dart';
import '../features/journal/presentation/daily_journal_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import '../features/profile/presentation/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isOnSplash = state.matchedLocation == '/';
      final isOnOnboarding = state.matchedLocation == '/onboarding';
      final isOnAuth = state.matchedLocation.startsWith('/auth');
      
      final isLoggedIn = authState.value != null;
      
      if (isOnSplash) return null; // Splash handles its own delay and redirect
      
      final isOnboardingCompleted = await PreferencesService().isOnboardingCompleted();
      
      if (!isOnboardingCompleted && !isOnSplash && !isOnOnboarding) {
        return '/onboarding';
      }

      if (!isLoggedIn && !isOnAuth && !isOnSplash && !isOnOnboarding) {
        return '/auth/login';
      }
      
      if (isLoggedIn && isOnAuth) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) => const DailyJournalPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
