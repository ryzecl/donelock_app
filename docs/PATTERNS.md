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

```dart
// Push ke halaman baru
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SomePage()),
);

// Replace current page
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const SomePage()),
);

// Pop back
Navigator.pop(context);
```

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
