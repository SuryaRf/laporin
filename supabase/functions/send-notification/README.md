# Send Notification Edge Function

Supabase Edge Function untuk mengirim Firebase Cloud Messaging (FCM) notifications.

## Setup & Deployment

### 1. Install Supabase CLI

```bash
# Install via npm
npm install -g supabase

# Atau via Homebrew (Mac)
brew install supabase/tap/supabase
```

### 2. Login ke Supabase

```bash
supabase login
```

### 3. Link Project

```bash
# Di root folder project (D:\COOLYEAH\PEM MOBILE\PBL\laporin)
supabase link --project-ref hwskzjaimgnrruxaeasu
```

### 4. Set Firebase Service Account Secret

Buka file Service Account JSON yang sudah kamu download:
`laporin-b4a18-firebase-adminsdk-fbsvc-5bcb65367d.json`

Copy seluruh isi file JSON tersebut, lalu simpan sebagai Supabase Secret:

```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT='paste-entire-json-here'
```

**PENTING:** Paste seluruh isi JSON dalam single quotes, contoh:

```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"laporin-b4a18","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...","client_email":"...","client_id":"...","auth_uri":"...","token_uri":"...","auth_provider_x509_cert_url":"...","client_x509_cert_url":"..."}'
```

### 5. Deploy Function

```bash
# Deploy function
supabase functions deploy send-notification

# Function akan tersedia di:
# https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification
```

### 6. Test Function (Optional)

```bash
curl -X POST \
  'https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "type": "to_admins",
    "title": "Laporan Baru",
    "body": "Ada laporan baru dari user",
    "reportId": "test123"
  }'
```

## API Documentation

### Endpoint

```
POST https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification
```

### Headers

```
Authorization: Bearer YOUR_SUPABASE_ANON_KEY
Content-Type: application/json
```

### Request Body

#### Kirim ke Admin (saat user buat laporan)

```json
{
  "type": "to_admins",
  "title": "Laporan Baru",
  "body": "User John Doe melaporkan kerusakan",
  "reportId": "report_abc123"
}
```

#### Kirim ke User (saat admin update status)

```json
{
  "type": "to_user",
  "title": "Status Laporan Berubah",
  "body": "Laporanmu telah disetujui",
  "reportId": "report_abc123",
  "userId": "user_xyz789"
}
```

### Response

```json
{
  "success": true,
  "sent": 3,
  "failed": 0
}
```

## Troubleshooting

### Error: Firebase Service Account not configured

- Pastikan sudah set secret `FIREBASE_SERVICE_ACCOUNT`
- Cek dengan: `supabase secrets list`

### Error: Failed to get access token

- Pastikan JSON Service Account valid
- Pastikan project ID di index.ts sesuai: `laporin-b4a18`

### Error: FCM send failed

- Cek FCM token masih valid
- Pastikan user sudah login dan fcm_token tersimpan di Firestore

## Local Development

Untuk test Edge Function secara lokal:

```bash
# Start Supabase local
supabase start

# Serve function locally
supabase functions serve send-notification --env-file .env.local

# Test locally
curl -X POST 'http://localhost:54321/functions/v1/send-notification' \
  -H 'Content-Type: application/json' \
  -d '{"type":"to_admins","title":"Test","body":"Test notification","reportId":"test123"}'
```

Buat file `.env.local`:

```
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
```
