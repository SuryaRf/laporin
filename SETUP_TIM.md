# 🚀 Panduan Setup untuk Tim LaporJTI

Panduan lengkap untuk setup project LaporJTI di komputer Anda.

## 📋 Checklist Persiapan

- [ ] Install Flutter SDK (versi 3.9.0+)
- [ ] Install Git
- [ ] Install Android Studio / VS Code
- [ ] Punya akses ke GitHub repository
- [ ] Punya akses ke Firebase Console (opsional)
- [ ] Punya akses ke Supabase (opsional)

## 🔧 Langkah Setup Detail

### 1. Install Flutter

**Windows:**
1. Download Flutter SDK dari https://flutter.dev/docs/get-started/install/windows
2. Extract ke folder (contoh: `C:\src\flutter`)
3. Tambahkan Flutter ke PATH:
   - Buka "Environment Variables"
   - Edit "Path" di System Variables
   - Tambahkan `C:\src\flutter\bin`
4. Buka Command Prompt/Terminal baru dan jalankan:
   ```bash
   flutter doctor
   ```

**macOS/Linux:**
```bash
# Download dan extract Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Tambahkan ke PATH (~/.bashrc atau ~/.zshrc)
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell
source ~/.bashrc  # atau source ~/.zshrc

# Verify
flutter doctor
```

### 2. Resolve Flutter Doctor Issues

Jalankan `flutter doctor` dan resolve semua issue:

```bash
flutter doctor
```

**Common fixes:**
- **Android toolchain**: Install Android Studio, accept Android licenses
  ```bash
  flutter doctor --android-licenses
  ```
- **VS Code**: Install Flutter & Dart extensions
- **Android Studio**: Install Flutter plugin dari Preferences > Plugins

### 3. Clone Repository

```bash
# Clone dari GitHub
git clone https://github.com/SuryaRf/laporin.git

# Masuk ke folder project
cd laporin

# Check branch yang tersedia
git branch -a
```

### 4. Install Dependencies

```bash
# Install semua package yang diperlukan
flutter pub get
```

Jika ada error, coba:
```bash
flutter clean
flutter pub get
```

### 5. Setup Firebase (Android)

File `google-services.json` sudah termasuk di project (`android/app/google-services.json`).

**Jika perlu update:**
1. Login ke [Firebase Console](https://console.firebase.google.com/)
2. Pilih project LaporJTI
3. Go to Project Settings > Your apps > Android app
4. Download `google-services.json`
5. Replace file di `android/app/google-services.json`

### 6. Setup Firebase (iOS) - Opsional

Jika develop untuk iOS:
1. Download `GoogleService-Info.plist` dari Firebase Console
2. Letakkan di `ios/Runner/GoogleService-Info.plist`

### 7. Setup Emulator/Device

**Android Emulator:**
1. Buka Android Studio
2. Tools > Device Manager
3. Create Virtual Device
4. Pilih device (contoh: Pixel 5)
5. Download system image (API 33 recommended)
6. Finish dan start emulator

**Physical Device:**
1. Enable Developer Options di HP
2. Enable USB Debugging
3. Connect ke komputer
4. Allow USB debugging di HP

**Check devices:**
```bash
flutter devices
```

### 8. Run Aplikasi

```bash
# Run aplikasi
flutter run

# Atau pilih device spesifik
flutter run -d chrome        # Web
flutter run -d emulator-5554 # Android emulator
```

## 🔄 Workflow Sehari-hari

### Mulai Development

```bash
# 1. Pull perubahan terbaru dari GitHub
git pull origin main-features

# 2. Install dependencies jika ada yang baru
flutter pub get

# 3. Run aplikasi
flutter run
```

### Selesai Development

```bash
# 1. Check perubahan yang dibuat
git status

# 2. Add files
git add .

# 3. Commit dengan pesan yang jelas
git commit -m "feat: tambah fitur notifikasi"

# 4. Push ke GitHub
git push origin main-features
```

### Format Commit Message

Gunakan format berikut:
- `feat: ...` - Fitur baru
- `fix: ...` - Bug fix
- `refactor: ...` - Refactor code
- `docs: ...` - Update dokumentasi
- `style: ...` - Format code (tidak mengubah logic)
- `test: ...` - Tambah/update tests

**Contoh:**
```bash
git commit -m "feat: tambah halaman detail laporan"
git commit -m "fix: perbaiki error saat upload gambar"
git commit -m "refactor: improve authentication flow"
```

## 🌿 Branching Strategy

### Buat Branch Baru untuk Fitur

```bash
# Buat dan switch ke branch baru
git checkout -b feature/nama-fitur-anda

# Contoh:
git checkout -b feature/tambah-filter-laporan
git checkout -b fix/bug-upload-foto
```

### Merge ke Main Branch

Gunakan **Pull Request** di GitHub:
1. Push branch ke GitHub: `git push origin feature/nama-fitur`
2. Buka GitHub repository
3. Klik "Pull requests" > "New pull request"
4. Select your branch
5. Add description dan klik "Create pull request"
6. Tunggu review dari team lead
7. Setelah approved, merge ke main

## 🐛 Troubleshooting Common Issues

### Error: "Unable to locate Android SDK"

```bash
# Set ANDROID_HOME environment variable
# Windows: C:\Users\YourName\AppData\Local\Android\Sdk
# macOS: ~/Library/Android/sdk
# Linux: ~/Android/Sdk
```

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Error: "Version conflict"

```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Error: "No devices found"

```bash
# Check devices
flutter devices

# Restart adb (Android)
adb kill-server
adb start-server

# Untuk iOS
killall -9 com.apple.CoreSimulator.CoreSimulatorService
```

### Build Error setelah Pull

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## 📱 Platform-Specific Setup

### Android Minimum Requirements

- Android Studio Arctic Fox atau lebih baru
- Android SDK 21+ (Lollipop)
- Java JDK 11+

### iOS Minimum Requirements (macOS only)

- macOS 10.14+
- Xcode 12+
- CocoaPods
- iOS 11+

## 🔐 Credentials & Secrets

### Firebase

Credentials Firebase sudah disetup di project. File yang **JANGAN** di-commit ke GitHub:
- `google-services.json` (sudah ada di `.gitignore`)
- `GoogleService-Info.plist`
- Service account JSON files

### Supabase

Supabase URL dan anon key sudah dikonfigurasi di `lib/main.dart`.

Jika perlu update, hubungi team lead untuk credentials terbaru.

## 📞 Bantuan

Jika mengalami kesulitan:
1. Check error message di terminal
2. Google error message
3. Check Flutter documentation: https://flutter.dev/docs
4. Tanya di group chat tim
5. Contact team lead

## 🎯 Next Steps

Setelah setup selesai:
1. Familiarize dengan struktur project (lihat README.md)
2. Baca dokumentasi provider pattern yang digunakan
3. Check TODO list di README untuk fitur yang perlu dikerjakan
4. Pick task dan mulai coding!

---

**Happy Coding!** 🚀
