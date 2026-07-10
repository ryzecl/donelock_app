# AGENTS.md — DoneLock

## Sebelum Memulai
Baca semua file `.md` di folder `docs/` untuk memahami requirements, arsitektur, dan konvensi aplikasi.

Daftar file yang harus dibaca:
1. `docs/PRD.md` — Product requirements & user flow
2. `docs/DESIGN_SYSTEM.md` — UI/UX guidelines (brutalist theme)
3. `docs/PATTERNS.md` — Code patterns, folder structure, naming conventions
4. `docs/ROADMAP.md` — Feature roadmap & status
5. `docs/SETUP.md` — Manual setup steps

## Tech Stack
- Flutter + Dart
- Riverpod (state management)
- Firebase Auth + Cloud Firestore
- SharedPreferences
- flutter_local_notifications

## Struktur Folder
```
lib/
  app/              # App shell, theme, AuthGate
  core/             # Utils, storage, design tokens
  features/
    auth/           # Login, Register, Google Sign-In
    splash/         # Splash screen
    onboarding/     # First-time onboarding
    home/           # Home page (dashboard + heatmap)
    journal/        # Daily journal CRUD
    calendar/       # Monthly calendar view
    statistics/     # Productivity stats
    notification/   # Daily reminder
    profile/        # User profile (update name, photo)
```

## Konvensi Kode
- State management: Riverpod (ConsumerWidget, ConsumerStatefulWidget)
- Navigation: Navigator.push / pushReplacement
- Firebase: FirebaseAuth.instance, FirebaseFirestore.instance
- Semua field database Firestore sesuai PRD: `productive` (boolean), `content` (string)

## Aturan
1. Baca semua file `.md` di folder `docs/` sebelum memulai task
2. Ikuti theme brutalist di `docs/DESIGN_SYSTEM.md` untuk semua UI work
3. Ikuti code patterns di `docs/PATTERNS.md`
4. State management pakai Riverpod (ConsumerWidget, ConsumerStatefulWidget)
5. Navigation pakai Navigator.push / pushReplacement
6. Jangan commit tanpa diminta
