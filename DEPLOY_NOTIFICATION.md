# 🚀 Deploy FCM Notification - Langkah Sederhana

## ⚡ Quick Fix untuk Error 500

Edge Function sudah diperbaiki! Sekarang menggunakan Web Crypto API yang kompatibel dengan Deno.

---

## 📋 Yang Anda Butuhkan

1. ✅ Firebase Service Account JSON file
2. ✅ Supabase CLI installed
3. ✅ 5-10 menit waktu

---

## 🔥 Step 1: Download Firebase Service Account

1. Buka: https://console.firebase.google.com/
2. Pilih project: **laporin-b4a18**
3. Klik ⚙️ **Settings** → **Project settings**
4. Tab **Service accounts**
5. Klik **Generate new private key**
6. Download file JSON

**File akan bernama seperti:**
```
laporin-b4a18-firebase-adminsdk-xxxxx.json
```

**Simpan di folder Downloads Anda.**

---

## 🛠️ Step 2: Install Supabase CLI

### Pilih salah satu:

**A. Menggunakan NPM (Recommended):**
```bash
npm install -g supabase
```

**B. Menggunakan Scoop (Windows):**
```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**Verify:**
```bash
supabase --version
```

---

## 🔐 Step 3: Login & Setup

### 3.1 Login ke Supabase
```bash
supabase login
```
Browser akan terbuka → Login dengan akun Supabase Anda

### 3.2 Link Project
```bash
cd "D:\COOLYEAH\PEM MOBILE\PBL\laporin"
supabase link --project-ref hwskzjaimgnrruxaeasu
```

**Password:** Masukkan password database Supabase Anda

---

## 🔑 Step 4: Set Firebase Service Account

**IMPORTANT:** Ganti path dengan lokasi file yang Anda download!

### Windows PowerShell:
```powershell
# Ganti path ini!
$json = Get-Content "D:\Downloads\laporin-b4a18-firebase-adminsdk-xxxxx.json" -Raw
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$json"
```

### Windows CMD:
```cmd
supabase secrets set FIREBASE_SERVICE_ACCOUNT="{paste entire JSON content here}"
```

### Git Bash / Linux / macOS:
```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat /path/to/laporin-b4a18-firebase-adminsdk-xxxxx.json)"
```

**Verify:**
```bash
supabase secrets list
```

Output:
```
NAME                           VALUE (PREVIEW)
FIREBASE_SERVICE_ACCOUNT       {"type":"service_account",...
```

---

## 🚀 Step 5: Deploy Edge Function

```bash
supabase functions deploy send-notification
```

**Output yang diharapkan:**
```
Deploying send-notification (project ref: hwskzjaimgnrruxaeasu)
Bundling send-notification
Deploying send-notification (1/1)
Deployed send-notification (1/1)

Send-notification URL:
  https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification
```

---

## ✅ Step 6: Test Notifikasi

### Test 1: Create Report (User → Admin notification)
1. **Device User**: Login sebagai User
2. **Device User**: Buat laporan baru
3. **Check logs** di Android Studio Logcat:
   ```
   ✅ Notification sent to 2 admins  ← Ini yang harus muncul!
   ```
4. **Device Admin**: Check notifikasi masuk

### Test 2: Approve/Reject (Admin → User notification)
1. **Device Admin**: Login sebagai Admin
2. **Device Admin**: Approve atau Reject laporan
3. **Check logs**:
   ```
   ✅ Notification sent to user (sent: 1)  ← Ini yang harus muncul!
   ```
4. **Device User**: Check notifikasi masuk

---

## 🐛 Troubleshooting

### Error: "command not found: supabase"

**Solusi:**
- Restart terminal setelah install
- Atau install via npm: `npm install -g supabase`

### Error: "Failed to link project"

**Solusi:**
```bash
# Pastikan sudah login
supabase login

# Link dengan password database
supabase link --project-ref hwskzjaimgnrruxaeasu
```

### Error: "FIREBASE_SERVICE_ACCOUNT not configured"

**Solusi:**
```bash
# Check apakah secret sudah di-set
supabase secrets list

# Jika belum ada, set ulang (Step 4)
```

### Masih Error 500?

**Check Logs:**
```bash
supabase functions logs send-notification
```

Atau buka:
https://supabase.com/dashboard/project/hwskzjaimgnrruxaeasu/functions/send-notification/logs

---

## 📊 Monitoring

### View Logs Real-time:
```bash
supabase functions logs send-notification --tail
```

### View Logs di Dashboard:
1. Buka: https://supabase.com/dashboard/
2. Project → Edge Functions → send-notification → Logs

---

## ✅ Success Indicators

Setelah deployment berhasil, Anda akan lihat:

**Flutter Logs:**
```
I/flutter: 📤 Sending notification to admins for report: xxxxx
I/flutter: ✅ Notification sent to 2 admins  ✅
```

**Supabase Logs:**
```
📩 Notification request received
✅ Service account loaded
🔐 Getting access token...
✅ Access token obtained
📋 Querying admin tokens...
Found 2 admin tokens
📤 Sending to 2 devices...
✅ Sent: 2 success, 0 failed
```

**FCM Console:**
https://console.firebase.google.com/project/laporin-b4a18/notification

---

## 🎯 Next Steps

Setelah notifikasi berfungsi:
- [ ] Test semua flow: Create → Approve → Reject
- [ ] Test dengan multiple admins
- [ ] Test notifikasi tap → navigation
- [ ] Add notification settings di app

