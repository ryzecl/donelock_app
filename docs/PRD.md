# DoneLock PRD

## Product Overview
DoneLock adalah aplikasi personal productivity journaling Android menggunakan Flutter dan Firebase.

Tujuan:
- Tracking produktivitas harian
- Journaling untuk refleksi/stress relief
- Melihat pola produktivitas bulanan
- Membangun konsistensi melalui visual progress

---

# Tech Stack

Frontend:
- Flutter
- Dart
- Riverpod

Backend:
- Firebase Authentication (Email/Password + Google)
- Cloud Firestore
- Firebase Storage (untuk foto profil)

Local:
- Shared Preferences

Notification:
- flutter_local_notifications

---

# User Flow

## First Install

Splash
↓
Onboarding
↓
Register/Login
↓
Home (Bottom Navigation)

## Returning User

Splash
↓
Auth Check
↓
Home (Bottom Navigation)

## Bottom Navigation

Setelah login, user mengakses 5 tab utama dari bottom navigation:
1. **Home** — Dashboard, heatmap, greeting
2. **Journal** — Daily journal entry
3. **Calendar** — Monthly calendar view
4. **Stats** — Productivity statistics
5. **Profile** — Update name & photo

Setiap tab mempertahankan state-nya saat berpindah (menggunakan IndexedStack).

## Deep Linking

- Notifikasi reminder jam 22:00 → tap → buka halaman **Journal**
- (Future) Share link journal → buka journal spesifik berdasarkan tanggal

---

# Features

## Authentication

- Register email/password
- Login email/password
- Login dengan Google
- Logout
- Persistent session

## Onboarding

Pertama kali aplikasi dibuka:

1. Track Your Productivity
2. Reflect Your Mind
3. Build Consistency

Status onboarding disimpan menggunakan SharedPreferences.

## Home Dashboard

Menampilkan:
- Greeting dengan nama user
- Contribution heatmap (grid 7×52, mirip GitHub)
- Statistik singkat (streak, total productive hari ini)
- Quick actions: Journal, Calendar, Statistics

## Daily Journal

Input:
- Productive / Not Productive
- Mood emoji
- Text journal
- Timestamp

Database:
users/{uid}/journals/{YYYYMMDD}

Example:
```
productive: true
mood: 😀
content: "Belajar Flutter"
```

## Calendar

Menampilkan:
- 🟢 Productive day
- 🔴 Not productive day

Klik tanggal menampilkan journal detail.
Custom tampilan dengan theme brutalist.

## Contribution Heatmap

Grid yang menampilkan produktivitas harian selama 1 tahun:
- Setiap kolom = 1 minggu (total ~52 minggu)
- Setiap baris = hari (Senin-Minggu)
- Warna hijau = productive, merah = not productive
- Klik cell → menampilkan journal hari itu

## Statistics

Menampilkan:
- Productivity percentage
- Total journal
- Productive days
- Not productive days
- Mood summary
- Streak counter

Formula:
productive days / total journal * 100

## Profile

Menampilkan & mengupdate:
- Nama
- Email (read-only)
- Foto profil (upload dari galeri/kamera)

## Notification

Reminder harian:
- Customizable time (default 22:00)
- "Bagaimana harimu hari ini? Jangan lupa reflection."

---

# Database Design

Firestore:

users
    {uid}
        profile
            name
            email
            createdAt
            photoUrl (optional)

        journals
            YYYYMMDD
                date
                productive
                mood
                content
                createdAt
