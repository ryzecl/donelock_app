# DoneLock 🔒

> **Lock in your productivity. One day at a time.**

DoneLock adalah aplikasi **personal productivity journaling** yang membantu kamu melacak, merefleksikan, dan membangun konsistensi produktivitas harian. Bukan sekadar to-do list — DoneLock adalah tempat aman untuk mencatat bagaimana harimu berjalan, apakah produktif atau tidak, dan melihat pola produktivitasmu dari waktu ke waktu.

---

## 🧠 Storytelling — Kenapa DoneLock?

Pernah merasa hari-hari berlalu begitu saja tanpa jelas apakah kamu produktif atau hanya sibuk?

Kamu kerja keras, tapi di akhir minggu rasanya tidak ada kemajuan. Kamu coba berbagai aplikasi produktivitas — Trello, Notion, Todoist — tapi semuanya terlalu kompleks, terlalu bising, atau malah membuatmu makin stres.

**Kamu tidak butuh aplikasi yang mengatur tugasmu. Kamu butuh aplikasi yang membantumu merefleksikan dirimu sendiri.**

Saya membangun DoneLock karena saya sendiri butuh jawaban atas satu pertanyaan sederhana setiap malam:

> _"Apa hari ini produktif?"_

Bukan untuk menghakimi. Bukan untuk membandingkan dengan orang lain. Tapi untuk **melihat pola**, memahami apa yang bekerja dan apa yang tidak, serta membangun kebiasaan yang lebih baik — satu hari dalam satu waktu.

DoneLock adalah jurnal produktivitas pribadimu. Brutalist, minimal, dan fokus pada satu hal: **kamu dan harimu.**

---

## ✨ Fitur Utama

### 📖 Daily Journal
Catat apakah harimu produktif atau tidak, pilih mood-mu, dan tulis refleksi singkat.

- ✅ / ❌ Toggle Productive / Not Productive
- 😀 Mood emoji (5 pilihan)
- ✍️ Text journal untuk menuangkan pikiran

### 📊 Contribution Heatmap
Grid 7×52 ala GitHub yang menunjukkan produktivitasmu sepanjang tahun.

- 🟢 Hijau = hari produktif
- 🔴 Merah = hari tidak produktif
- ⬜ Abu-abu = belum ada catatan
- Klik cell → lihat journal hari itu

### 📅 Calendar View
Monthly calendar dengan warna hijau/merah di setiap tanggal.

- Geser antar bulan
- Klik tanggal → lihat detail journal
- Lihat pola produktivitas bulanan

### 📈 Statistics
Statistik lengkap produktivitasmu.

- 🎯 Productivity score (persentase)
- 📊 Total journal entries
- 🟢 / 🔴 Productive vs Not Productive days
- 😊 Mood summary
- 🔥 Streak counter

### 🔔 Daily Reminder
Notifikasi otomatis setiap jam 22:00.

> *"Bagaimana harimu hari ini? Jangan lupa reflection."*

### 👤 Profile
Kelola profil pribadimu.

- Ubah nama tampilan
- Foto profil (upload dari galeri)
- Email (read-only)

---

## 🎨 Desain: Brutalist

DoneLock menggunakan **brutalist design** — bold, raw, dan fungsional.

- **Monospace typography** — bersih, fokus, tanpa distraksi
- **Border tebal 2-3px** — tegas dan berani
- **Sudut siku-siku** — brutal, tidak ada yang dilembutkan
- **Hitam & putih** — tidak perlu warna yang berteriak

Setiap elemen punya tujuan. Tidak ada dekorasi yang tidak perlu. Brutalist bukan hanya soal estetika — ini filosofi: **jujur, fungsional, dan apa adanya.**

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Frontend** | Flutter + Dart |
| **State Management** | Riverpod |
| **Backend** | Firebase Auth + Cloud Firestore |
| **Auth** | Email/Password + Google Sign-In |
| **Storage** | Firebase Storage (foto profil) |
| **Local** | SharedPreferences |
| **Notification** | flutter_local_notifications |
| **Navigation** | go_router |
| **Calendar** | table_calendar |

---

## 📱 User Flow

### First Install
```
Splash → Onboarding → Register → Home
```
### Returning User
```
Splash → Auth Check → Home (Bottom Navigation)
```

### Bottom Navigation (5 Tabs)
| Tab | Tujuan |
|-----|--------|
| 🏠 **Home** | Dashboard, heatmap, quick stats |
| ✏️ **Journal** | Daily journal entry |
| 📅 **Calendar** | Monthly calendar view |
| 📊 **Stats** | Productivity statistics |
| 👤 **Profile** | Edit profile & photo |

---

## 🚀 Cara Mulai

### Prasyarat
- Flutter SDK ^3.11.5
- Firebase account
- Android Studio / VS Code

### Instalasi

```bash
# Clone repository
git clone https://github.com/yourusername/donelock.git
cd donelock

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### Firebase Setup
Karena alasan keamanan, file konfigurasi Firebase tidak disertakan di repository ini. Kamu harus membuat project Firebase-mu sendiri:

1. Buka [Firebase Console](https://console.firebase.google.com) dan buat project baru.
2. Aktifkan layanan berikut:
   - **Authentication**: Aktifkan **Email/Password** dan **Google Sign-In**.
   - **Firestore Database**: Buat database.
   - **Firebase Storage**: Aktifkan storage untuk foto profil.
3. Daftarkan aplikasi Android/iOS milikmu di setelan project Firebase.
4. Download konfigurasi Firebase:
   - **Android**: Download `google-services.json` dan letakkan di `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` dan letakkan di `ios/Runner/`
5. Generate file opsi Firebase Flutter dengan menjalankan perintah:
   ```bash
   flutterfire configure
   ```
   Atau buat file `lib/firebase_options.dart` secara manual sesuai project-mu.
6. Deploy Firestore Security Rules (opsional tapi disarankan):
   ```bash
   firebase deploy --only firestore:rules
   ```

### Build APK
```bash
flutter build apk --release
```
Hasil: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 Struktur Proyek

```
lib/
  app/              # App shell, theme, AuthGate, router
  core/             # Utils, storage, design tokens
  features/
    auth/           # Login, Register, Google Sign-In
    splash/         # Splash screen
    onboarding/     # First-time onboarding (3 pages)
    home/           # Dashboard + contribution heatmap
    journal/        # Daily journal CRUD
    calendar/       # Monthly calendar view
    statistics/     # Productivity stats
    notification/   # Daily reminder service
    profile/        # User profile management
```

---

## 🗺️ Roadmap

### Phase 1 ✅ — Core Features (Done)
- Authentication (Email/Password)
- Daily Journal
- Calendar
- Statistics
- Onboarding
- Notification
- Firestore Security Rules

### Phase 2 🔧 — UI Refactor & Navigation
- Brutalist theme implementation
- go_router navigation
- Bottom Navigation Bar (5 tabs)
- Contribution heatmap
- Route guards & deep linking

### Phase 3 ⏳ — New Features
- Google Sign-In
- Profile page (update name & photo)
- Streak counter

### Phase 4 ⏳ — Advanced
- Dark mode
- Monthly trend charts
- Data export
- APK release

---

## 🤝 Kontribusi

DoneLock adalah proyek open-source. Kontribusi sangat diterima!

1. Fork repository
2. Buat branch feature (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

---

## 📄 Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙏 Catatan Penutup

DoneLock bukan aplikasi yang akan membuatmu lebih produktif dalam semalam. Tapi dengan mencatat satu hari dalam satu waktu, kamu akan mulai melihat pola — apa yang membuatmu produktif, apa yang menguras energimu, dan bagaimana kamu bisa menjadi versi terbaik dari dirimu sendiri.

**Lock in your productivity. One day at a time.** 🔒
