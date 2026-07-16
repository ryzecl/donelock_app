# Roadmap — DoneLock

## Status Legend
- ✅ Done
- 🔧 In Progress
- ⏳ Planned

---

## Phase 1: Core Features (Done)

| Feature | Status | Notes |
|---------|--------|-------|
| Authentication (Email/Password) | ✅ | Register, Login, Logout |
| Firebase Firestore | ✅ | Database terhubung |
| Daily Journal | ✅ | CRUD dengan mood & productivity |
| Calendar | ✅ | Monthly view dengan green/red indicator |
| Statistics | ✅ | Productivity percentage, mood summary |
| Notification | ✅ | Customizable daily reminder (default 22:00) |
| Onboarding | ✅ | 3 halaman onboarding |
| Splash Screen | ✅ | First launch detection |
| Firebase Security Rules | ✅ | User only read/write own data |

---

## Phase 2: UI Refactor & Navigation (Planned)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Brutalist Theme Implementation | ✅ | High | Implement DESIGN_SYSTEM.md |
| Contribution Heatmap (Homepage) | ✅ | High | Grid 7×52 kayak GitHub |
| Homepage Dashboard Redesign | ✅ | High | Greeting, heatmap, stat, quick actions |
| go_router Implementation | ✅ | High | Ganti semua Navigator.push dengan GoRouter |
| Bottom Navigation Bar | ✅ | High | 5 tabs: Home, Journal, Calendar, Stats, Profile |
| Route Guards (Auth + Onboarding) | ✅ | High | Centralized redirect logic |
| Logout Stack Clearing | ✅ | High | `context.go('/auth/login')` setelah signOut |
| Calendar UI Customization | ✅ | Medium | Heatmap view per week/month/year (Unified + Modal) |
| Notification Tap Deep Link | ⏳ | Medium | Tap notifikasi → buka halaman journal |
| Widget Refactor | ✅ | Medium | Semua UI pakai theme token |
| PopScope Back Button Guards | ⏳ | Medium | Blokir back ke splash/onboarding |
| App Branding | ✅ | High | Custom Icon & Native Splash Screen |

---

## Phase 3: New Features (Planned)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Google Sign-In | ✅ | High | Firebase Auth + Google |
| Profile Page | ✅ | High | Update name, password, logout |
| Forgot Password | ✅ | High | Send reset link via Firebase |
| Delete Account | ✅ | High | Delete from Firestore & Auth |
| Streak Counter | ✅ | Medium | Hari beruntun productive di Home & Stats |
| Photo Profile Upload | ✅ | Medium | ImgBB API (with auto compression) |
| AI Brainstorming | ✅ | High | Chatbot pakai Groq API dengan konteks jurnal |
| Lock-in Pomodoro | ✅ | High | Timer kerja dengan state Work & Rest |
| Colorful Neo-Brutalism Redesign | ✅ | High | Update UI agar lebih colorful & rounded corners |
| Daily Journal UI Redesign | ✅ | High | Neo-brutalism mood toolbar, productive toggle, save button |

---

## Phase 4: Advanced (Future)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Dark Mode | ⏳ | Low | Theme toggle |
| Charts (Monthly Trends) | ⏳ | Low | Line chart produktivitas |
| Export Data | ⏳ | Low | CSV/PDF export journal |
| APK Release | ⏳ | Low | `flutter build apk --release` |

---

## Manual Setup Checklist

- [ ] Firebase Authentication aktifkan metode **Google Sign-In**
- [ ] Firebase Console: buka **Authentication** → **Sign-in method** → enable **Google**
- [ ] ImgBB API: Taruh API Key di `lib/core/utils/constants.dart`
- [ ] `pubspec.yaml`: tambah dependency yang diperlukan (google_sign_in, image_picker, dll)
- [ ] Android: tambah SHA-1 fingerprint di Firebase Console untuk Google login
- [ ] iOS: tambah `GoogleService-Info.plist` di folder Xcode project

---

## Catatan
- Setiap feature baru harus mengikuti pattern di `PATTERNS.md`
- UI harus mengikuti theme di `DESIGN_SYSTEM.md`
- Update roadmap ini setelah setiap feature selesai
