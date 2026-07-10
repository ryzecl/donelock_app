# Patterns — DoneLock Code Conventions

## Folder Structure

Setiap feature mengikuti pola:
```
lib/features/{feature}/
  data/       # Repository, data source
  models/     # Data class
  providers/  # Riverpod providers
  presentation/  # UI widgets (pages, components)
```

### Contoh: Auth feature
```
lib/features/auth/
  data/
    auth_repository.dart
  models/
    user_model.dart
  providers/
    auth_provider.dart
  presentation/
    login_page.dart
    register_page.dart
```

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| File | `snake_case.dart` | `auth_repository.dart` |
| Class | `PascalCase` | `AuthRepository` |
| Provider | `camelCase` | `authStateProvider` |
| Variable | `camelCase` | `emailController` |
| Private | `_camelCase` | `_loading`, `_login()` |
| Constant | `camelCase` | `const emailKey = "email"` |
| Folder | `snake_case` | `lib/features/auth/presentation/` |

---

## Riverpod Patterns

### Provider dasar
```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

### StreamProvider (untuk Firebase stream)
```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
```

### FutureProvider.family (untuk fetch data dengan parameter)
```dart
final monthlyJournalProvider = FutureProvider.family((ref, String month) async {
  final repository = ref.read(journalRepositoryProvider);
  return await repository.getMonthlyJournals(month);
});
```

### Provider untuk repository
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});
```

### Widget pattern
```dart
// Stateless dengan Riverpod
class MyPage extends ConsumerWidget { ... }

// Stateful dengan Riverpod
class MyPage extends ConsumerStatefulWidget { ... }
class _MyPageState extends ConsumerState<MyPage> { ... }
```

---

## Firestore Field Names

Semua field harus sesuai PRD:

| Koleksi | Document | Field | Tipe |
|---------|----------|-------|------|
| `users` | `{uid}` | `name` | string |
| | | `email` | string |
| | | `createdAt` | Timestamp |
| | | `photoUrl` | string? |
| `users/{uid}/journals` | `{YYYYMMDD}` | `date` | string |
| | | `productive` | boolean |
| | | `mood` | string |
| | | `content` | string |
| | | `createdAt` | Timestamp |

---

## Navigation Patterns

### Arsitektur Navigasi

Gunakan **go_router** sebagai router utama (sudah di `pubspec.yaml`).

### Router Structure (`lib/app/router.dart`)

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation.startsWith('/auth');
      final isOnSplash = state.matchedLocation == '/';

      if (isOnSplash) return null;
      if (!isLoggedIn && !isOnAuth) return '/auth/login';
      if (isLoggedIn && isOnAuth) return '/home';
      return null;
    },

    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),

      GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),

      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/journal', builder: (_, __) => const DailyJournalPage()),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarPage()),
          GoRoute(path: '/statistics', builder: (_, __) => const StatisticsPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
    ],
  );
});
```

### Route Guards

- **Auth guard**: `redirect` di `GoRouter` otomatis arahkan ke `/auth/login` jika belum login
- **Onboarding guard**: Jika `onboarding_completed` false, redirect ke `/onboarding`
- **Logout**: Panggil `context.go('/auth/login')` setelah signOut untuk clear stack

### Bottom Navigation (ShellRoute)

`ShellRoute` membungkus halaman-halaman utama dengan `MainShell` yang berisi `BottomNavigationBar` + `IndexedStack`. Ini mempertahankan state tiap tab saat berpindah.

```dart
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateIndex(context),
        onTap: (index) => _onTabTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
```

### Deep Linking (Notification Tap)

Saat notifikasi di-tap, navigasi ke halaman journal:

```dart
// Di NotificationService
onDidReceiveNotificationResponse: (details) {
  ref.read(routerProvider).go('/journal');
}
```

### Navigasi Imperatif (Push / Pop)

Meskipun pakai go_router, `Navigator.push` masih bisa digunakan untuk halaman-halaman sederhana yang tidak perlu route:
- Push: `Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailPage()))`
- Pop: `Navigator.pop(context)`

Tapi preferensi utama tetap `context.go()` atau `context.push()` dari go_router.

### Aturan Navigasi

1. Semua halaman utama (Home, Journal, Calendar, Statistics, Profile) harus melalui `ShellRoute` + bottom nav
2. Halaman sementara (Splash, Onboarding, Login, Register) pakai route penuh tanpa shell
3. Logout harus clear seluruh stack → `context.go('/auth/login')`
4. Tidak boleh ada `Navigator.pop` yang mengarah ke SplashPage atau OnboardingPage (gunakan `PopScope` untuk blok)
5. Setiap route baru harus ditambahkan ke router dan di-test semua state (logged in/out, onboarding done/not)


---

## Theme Pattern

Gunakan ThemeData dengan custom theme extension untuk brutalist tokens:

```dart
// Di lib/app/theme.dart
class BrutalistTheme {
  static ThemeData get light => ThemeData(
    fontFamily: 'monospace',
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
    scaffoldBackgroundColor: const Color(0xFFF5F5F0),
    // ... lainnya
  );
}
```

---

## Error Handling Pattern

```dart
try {
  await someOperation();
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
```

---

## File Organization per Page

1. imports
2. widget class (ConsumerWidget / ConsumerStatefulWidget)
3. state class (jika ConsumerStatefulWidget)
4. private helper widgets (prefixed with `_`)
5. private methods
