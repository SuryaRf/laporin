# LaporJTI - Aplikasi Pelaporan Fasilitas Kampus

Aplikasi mobile untuk melaporkan kerusakan fasilitas di kampus JTI.

## 🚀 Fitur yang Telah Dibuat

### ✅ Fase 1 (Selesai)
- **Splash Screen**: Animasi splash screen dengan logo LaporJTI
- **Onboarding Screen**: 3 halaman onboarding dengan smooth page indicator
- **Login Screen**: Form login dengan validasi email dan password
- **Register Screen**: Form registrasi dengan validasi lengkap
- **Home Screen**: Halaman utama dengan menu grid (placeholder)
- **State Management**: Menggunakan Provider untuk mengelola state
- **Routing**: Navigasi menggunakan go_router dengan redirect logic

## 📁 Struktur Project

```
lib/
├── constants/
│   ├── colors.dart           # Definisi warna aplikasi
│   └── text_styles.dart      # Definisi text styles dengan Google Fonts
├── models/
│   └── onboarding_model.dart # Model untuk data onboarding
├── providers/
│   ├── auth_provider.dart    # Provider untuk authentication
│   └── onboarding_provider.dart # Provider untuk onboarding
├── routes/
│   └── app_router.dart       # Konfigurasi routing dengan go_router
├── screens/
│   ├── splash_screen.dart    # Splash screen dengan animasi
│   ├── onboarding_screen.dart # Onboarding screen
│   ├── login_screen.dart     # Login screen
│   ├── register_screen.dart  # Register screen
│   └── home_screen.dart      # Home screen
└── main.dart                 # Entry point aplikasi
```

## 🎨 Design System

### Warna
- **Primary**: #2196F3 (Blue)
- **Secondary**: #FF9800 (Orange)
- **Success**: #4CAF50
- **Error**: #F44336
- **Background**: #F5F5F5

### Typography
Menggunakan Google Fonts Poppins untuk konsistensi typography.

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2              # State management
  go_router: ^14.6.2            # Routing
  shared_preferences: ^2.3.3    # Local storage
  smooth_page_indicator: ^1.2.0 # Onboarding indicators
  google_fonts: ^6.2.1          # Typography
```

## 🔐 Authentication Flow

1. **Splash Screen** → Ditampilkan selama 3 detik
2. **Onboarding Screen** → Hanya muncul sekali (first time user)
3. **Login Screen** → Default entry point setelah onboarding
4. **Register Screen** → Accessible dari login screen
5. **Home Screen** → Accessible setelah login/register berhasil

### State Management dengan Provider

- **AuthProvider**: Mengelola authentication state (login, register, logout)
- **OnboardingProvider**: Mengelola onboarding state dan progress

## 🚦 Routing

Aplikasi menggunakan **go_router** dengan fitur:
- Declarative routing
- Deep linking support
- Redirect logic untuk authentication
- Error handling

### Routes:
- `/` - Splash Screen
- `/onboarding` - Onboarding Screen
- `/login` - Login Screen
- `/register` - Register Screen
- `/home` - Home Screen (Protected)

## 💾 Local Storage

Menggunakan **SharedPreferences** untuk:
- Menyimpan status onboarding
- Menyimpan data user (email, name)
- Menyimpan status authentication

## 🔧 Setup dan Instalasi untuk Tim

### Prasyarat
Pastikan sudah terinstall:
- **Flutter SDK** versi 3.9.0 atau lebih baru ([Download](https://flutter.dev/docs/get-started/install))
- **Git** ([Download](https://git-scm.com/downloads))
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Java JDK** 11 atau lebih baru (untuk Android development)
- **Xcode** (untuk iOS development - hanya Mac)

### Langkah 1: Clone Repository

```bash
# Clone repository dari GitHub
git clone https://github.com/SuryaRf/laporin.git

# Masuk ke folder project
cd laporin
```

### Langkah 2: Install Dependencies

```bash
# Install semua package dependencies
flutter pub get
```

### Langkah 3: Konfigurasi Firebase

#### Android:
1. File `google-services.json` sudah ada di `android/app/`
2. Jika perlu update, download dari [Firebase Console](https://console.firebase.google.com/)
3. Letakkan di `android/app/google-services.json`

#### iOS (jika develop untuk iOS):
1. Download `GoogleService-Info.plist` dari Firebase Console
2. Letakkan di `ios/Runner/GoogleService-Info.plist`

### Langkah 4: Konfigurasi Supabase

1. Buat file `.env` di root project (jika diperlukan)
2. Tambahkan Supabase credentials (minta ke team lead):
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

### Langkah 5: Verifikasi Setup

```bash
# Check Flutter installation
flutter doctor

# Pastikan semua checklist hijau atau resolve issue yang muncul
```

### Langkah 6: Run Aplikasi

```bash
# Run di emulator/device yang sudah connect
flutter run

# Atau pilih device spesifik
flutter devices           # List available devices
flutter run -d <device-id>
```

## 🔄 Workflow Git untuk Tim

### Push Changes ke GitHub

```bash
# 1. Check status perubahan
git status

# 2. Add files yang ingin di-commit
git add .

# 3. Commit dengan pesan yang jelas
git commit -m "feat: deskripsi fitur yang dibuat"

# 4. Push ke branch saat ini
git push origin main-features

# Atau push ke branch lain
git push origin nama-branch-anda
```

### Pull Changes dari GitHub

```bash
# Pull perubahan terbaru dari remote
git pull origin main-features

# Setelah pull, install dependencies yang mungkin baru
flutter pub get
```

### Branching Strategy

```bash
# Buat branch baru untuk fitur baru
git checkout -b feature/nama-fitur

# Pindah ke branch lain
git checkout nama-branch

# List semua branch
git branch -a

# Merge branch (biasanya lewat Pull Request di GitHub)
git checkout main
git merge feature/nama-fitur
```

## 🚨 Troubleshooting

### Error: "Pod install failed"
```bash
cd ios
pod install
cd ..
flutter run
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

### Error: "No devices found"
- Pastikan emulator sudah running atau device sudah connect
- Check dengan: `flutter devices`
- Restart adb: `adb kill-server && adb start-server`

### Firebase/Supabase Connection Error
- Pastikan `google-services.json` ada di `android/app/`
- Pastikan internet connection aktif
- Check Firebase/Supabase credentials

## 📝 Catatan untuk Development

### Login Credentials (Development)
Saat ini menggunakan validasi mock:
- Email: Format email yang valid
- Password: Minimal 6 karakter

### TODO: Fitur Selanjutnya
- [ ] Integrasi dengan Backend API
- [ ] Implementasi form laporan fasilitas
- [ ] Upload gambar untuk laporan
- [ ] List dan detail laporan
- [ ] Notifikasi real-time
- [ ] Profile management
- [ ] History laporan
- [ ] Admin dashboard

## 🎯 Best Practices yang Diterapkan

1. **Clean Architecture**: Pemisahan concerns (UI, Business Logic, Data)
2. **State Management**: Menggunakan Provider pattern
3. **Reusable Components**: Constants untuk colors dan text styles
4. **Form Validation**: Input validation untuk semua forms
5. **Error Handling**: Proper error messages dan user feedback
6. **Navigation**: Proper routing dengan authentication guards
7. **UI/UX**: Smooth animations dan transitions

## 👨‍💻 Developer

Developed with ❤️ for JTI Campus

---

**Version**: 1.0.0
**Last Updated**: November 12, 2025
