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
| Notification | ✅ | Daily reminder at 22:00 |
| Onboarding | ✅ | 3 halaman onboarding |
| Splash Screen | ✅ | First launch detection |
| Firebase Security Rules | ✅ | User only read/write own data |

---

## Phase 2: UI Refactor & Enhancement (Planned)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Brutalist Theme Implementation | ⏳ | High | Implement DESIGN_SYSTEM.md |
| Contribution Heatmap (Homepage) | ⏳ | High | Grid 7×52 kayak GitHub |
| Homepage Dashboard Redesign | ⏳ | High | Greeting, heatmap, stat, quick actions |
| Calendar UI Customization | ⏳ | Medium | Tampilan brutalist di calendar |
| Widget Refactor | ⏳ | Medium | Semua UI pakai theme token |

---

## Phase 3: New Features (Planned)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Google Sign-In | ⏳ | High | Firebase Auth + Google |
| Profile Page | ⏳ | High | Update name & photo |
| Streak Counter | ⏳ | Medium | Hari beruntun productive |
| Photo Profile Upload | ⏳ | Medium | Firebase Storage |

---

## Phase 4: Advanced (Future)

| Feature | Status | Priority | Notes |
|---------|--------|----------|-------|
| Dark Mode | ⏳ | Low | Theme toggle |
| Bottom Navigation | ⏳ | Low | Home, Calendar, Statistics, Profile |
| Charts (Monthly Trends) | ⏳ | Low | Line chart produktivitas |
| Export Data | ⏳ | Low | CSV/PDF export journal |
| APK Release | ⏳ | Low | `flutter build apk --release` |

---

## Manual Setup Checklist

- [ ] Firebase Authentication aktifkan metode **Google Sign-In**
- [ ] Firebase Console: buka **Authentication** → **Sign-in method** → enable **Google**
- [ ] Firebase Console: buka **Storage** → setup Firebase Storage untuk foto profil
- [ ] `pubspec.yaml`: tambah dependency yang diperlukan (google_sign_in, image_picker, dll)
- [ ] Android: tambah SHA-1 fingerprint di Firebase Console untuk Google login
- [ ] iOS: tambah `GoogleService-Info.plist` di folder Xcode project

---

## Catatan
- Setiap feature baru harus mengikuti pattern di `PATTERNS.md`
- UI harus mengikuti theme di `DESIGN_SYSTEM.md`
- Update roadmap ini setelah setiap feature selesai
