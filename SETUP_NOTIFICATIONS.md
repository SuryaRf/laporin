# Setup Firebase Cloud Messaging (FCM) Notifications

## 📋 Ringkasan Masalah

Error yang muncul:
```
❌ Failed to send notification: 500
Response: {"code":"WORKER_ERROR","message":"Function exited due to an error (please check logs)"}
```

Penyebab: Edge Function belum di-deploy dan Firebase Service Account belum di-setup di Supabase Secrets.

---

## 🔧 Langkah-Langkah Perbaikan

### Step 1: Download Firebase Service Account JSON

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **laporin-b4a18**
3. Klik ikon **⚙️ Settings** (kiri atas) → **Project settings**
4. Pilih tab **Service accounts**
5. Klik tombol **Generate new private key**
6. Download file JSON yang dihasilkan (akan bernama seperti `laporin-b4a18-firebase-adminsdk-xxxxx.json`)
7. ⚠️ **PENTING**: Jangan commit file ini ke Git! Simpan di tempat aman.

### Step 2: Install Supabase CLI (jika belum)

#### Windows:
```bash
# Menggunakan Scoop
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# ATAU menggunakan npm
npm install -g supabase
```

#### Verify Installation:
```bash
supabase --version
```

### Step 3: Login ke Supabase

```bash
supabase login
```

Browser akan terbuka, login dengan akun Supabase Anda.

### Step 4: Link Project ke Supabase

```bash
# Di root folder project laporin
supabase link --project-ref hwskzjaimgnrruxaeasu
```

Project ref ID Anda: `hwskzjaimgnrruxaeasu` (dari URL Supabase)

### Step 5: Set Firebase Service Account sebagai Secret

```bash
# Ganti path/to/service-account.json dengan path file yang Anda download di Step 1
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat path/to/laporin-b4a18-firebase-adminsdk-xxxxx.json)"
```

**Contoh:**
```bash
# Jika file ada di D:\Downloads\laporin-b4a18-firebase-adminsdk-abc123.json
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat D:\Downloads\laporin-b4a18-firebase-adminsdk-abc123.json)"
```

Verify secret sudah ter-set:
```bash
supabase secrets list
```

### Step 6: Deploy Edge Function

```bash
# Deploy send-notification function
supabase functions deploy send-notification
```

Output yang diharapkan:
```
Deploying function send-notification...
Function deployed successfully!
URL: https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification
```

---

## 🧪 Testing Notifikasi

Setelah deployment selesai, test dengan membuat laporan baru:

1. **Login sebagai User** di aplikasi
2. **Buat laporan baru** dengan foto/video
3. **Check logs** di aplikasi:
   ```
   I/flutter: 📤 Sending notification to admins for report: xxxxx
   I/flutter: ✅ Notification sent to X admins
   ```

4. **Check notifikasi** di device admin

5. **Login sebagai Admin**, approve/reject laporan

6. **Check notifikasi** di device user yang membuat laporan

---

## 🐛 Troubleshooting

### Error: "Missing Firebase credentials"

**Solusi:** Pastikan secret `FIREBASE_SERVICE_ACCOUNT` sudah di-set dengan benar:
```bash
supabase secrets list
```

Jika tidak ada, ulangi Step 5.

### Error: "Failed to get access token"

**Penyebab:** Format Service Account JSON tidak valid atau permissions kurang.

**Solusi:**
1. Download ulang Service Account JSON dari Firebase Console
2. Pastikan Service Account memiliki role **Firebase Admin**
3. Set ulang secret:
   ```bash
   supabase secrets unset FIREBASE_SERVICE_ACCOUNT
   supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat path/to/service-account.json)"
   ```

### Error: "Firestore query failed"

**Penyebab:** Service Account tidak memiliki akses ke Firestore.

**Solusi:**
1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Pilih project **laporin-b4a18**
3. Pergi ke **IAM & Admin** → **Service Accounts**
4. Cari service account yang Anda gunakan
5. Klik **Edit** (icon pensil)
6. Tambahkan role:
   - **Cloud Datastore User**
   - **Firebase Admin SDK Administrator Service Agent**

### Check Logs di Supabase Dashboard

1. Buka [Supabase Dashboard](https://supabase.com/dashboard/)
2. Pilih project Anda
3. Pergi ke **Edge Functions** → **send-notification** → **Logs**
4. Lihat error detail untuk debugging

---

## 📊 Monitoring

Setelah setup selesai, Anda bisa monitoring notifikasi di:

1. **Flutter App Logs** (via `flutter logs` atau Android Studio Logcat)
2. **Supabase Edge Function Logs** (Dashboard)
3. **Firebase Console** → **Cloud Messaging** → **Reports**

---

## ✅ Checklist

- [ ] Download Firebase Service Account JSON
- [ ] Install Supabase CLI
- [ ] Login ke Supabase (`supabase login`)
- [ ] Link project (`supabase link`)
- [ ] Set secret (`supabase secrets set FIREBASE_SERVICE_ACCOUNT`)
- [ ] Deploy Edge Function (`supabase functions deploy send-notification`)
- [ ] Test: User create report → Admin dapat notifikasi
- [ ] Test: Admin approve/reject → User dapat notifikasi
- [ ] Video player bottom overflow sudah fixed ✅

---

## 🔐 Security Note

**JANGAN PERNAH:**
- Commit Service Account JSON ke Git
- Share Service Account JSON di public
- Hardcode credentials di source code

**SELALU:**
- Simpan credentials di environment variables atau secrets
- Gunakan `.gitignore` untuk exclude sensitive files
- Rotate credentials secara berkala

