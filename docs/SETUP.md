# Setup — DoneLock

## Prasyarat

- Flutter SDK (^3.11.5)
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Git

---

## 1. Clone & Install Dependencies

```bash
git clone <repo-url>
cd donelock
flutter pub get
```

---

## 2. Firebase Console Setup

### 2.1 Firebase Authentication

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project: **donelock-8d9af**
3. Kiri sidebar → **Authentication** → **Sign-in method**
4. Enable **Email/Password** ✅
5. Enable **Google** ✅

### 2.2 Google Sign-In — Android

1. Firebase Console → **Project Settings** → **General**
2. Di bagian **Your apps** → Android
3. Tambah **SHA-1 certificate fingerprint**:
   ```bash
   # Windows
   cd android && gradlew signingReport

   # macOS/Linux
   cd android && ./gradlew signingReport
   ```
4. Copy SHA-1 dari output `debug.keystore`
5. Paste di Firebase Console → Save

### 2.3 Google Sign-In — iOS (Jika target iOS)

1. Firebase Console → **Project Settings** → **General**
2. **Your apps** → iOS → tambah `GoogleService-Info.plist`
3. Download dan taruh di folder Xcode project

### 2.4 Setup ImgBB (Foto Profil)

1. Daftar ke [ImgBB API](https://api.imgbb.com/)
2. Buat API Key
3. Taruh API Key di file `lib/core/utils/constants.dart` pada `AppConstants.imgbbApiKey`.

### 2.5 Firebase Security Rules (Sudah)

File `firestore.rules` sudah ada di root project. Deploy:
```bash
firebase deploy --only firestore:rules
```

---

## 3. FlutterFire Configuration

```bash
# Jika perlu regenerate firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure --project=donelock-8d9af
```

---

## 4. Run Aplikasi

```bash
# Run di emulator / device
flutter run

# Run spesifik platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run                    # Android default device
```

---

## 5. Build APK Release

```bash
flutter build apk --release
```

Hasil build di: `build/app/outputs/flutter-apk/app-release.apk`

---

## Troubleshooting

### Google Sign-In error "12500"
- SHA-1 fingerprint belum terdaftar di Firebase Console
- Jalankan `signingReport` dan cek SHA-1

### Firestore permission denied
- Deploy `firestore.rules` dengan `firebase deploy --only firestore:rules`
- Pastikan user sudah login

### Notification tidak muncul
- Android 13+ perlu permission `POST_NOTIFICATIONS` manual via settings
- Pastikan zona waktu sudah diinisialisasi menggunakan `flutter_timezone`
- Cek `AndroidManifest.xml` sudah ada permission-nya

### Build error setelah add dependency
```bash
flutter clean
flutter pub get
flutter run
```
