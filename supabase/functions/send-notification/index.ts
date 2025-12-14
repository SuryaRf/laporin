// Supabase Edge Function to send FCM notifications
// Deploy: supabase functions deploy send-notification

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FIREBASE_PROJECT_ID = "laporin-b4a18"
const FIRESTORE_BASE_URL = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`
const FCM_URL = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`

// Interface definitions
interface NotificationRequest {
  type: 'to_admins' | 'to_user'
  title: string
  body: string
  reportId: string
  userId?: string // For 'to_user' type
}

interface FCMToken {
  userId: string
  token: string
}

// Helper: Create JWT and get OAuth2 access token
async function getAccessToken(serviceAccount: any): Promise<string> {
  const now = Math.floor(Date.now() / 1000)

  // JWT Header
  const header = {
    alg: "RS256",
    typ: "JWT"
  }

  // JWT Claim Set
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now
  }

  // Encode header and claim set
  const encodedHeader = base64UrlEncode(JSON.stringify(header))
  const encodedClaimSet = base64UrlEncode(JSON.stringify(claimSet))
  const signatureInput = `${encodedHeader}.${encodedClaimSet}`

  // Import private key
  const privateKey = serviceAccount.private_key

  // Remove PEM headers/footers and whitespace
  const pemContents = privateKey
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\\n/g, '')  // Remove literal \n characters from JSON
    .replace(/\n/g, '')   // Remove actual newlines
    .replace(/\r/g, '')   // Remove carriage returns
    .replace(/\s/g, '')   // Remove all whitespace
    .trim()

  const binaryDer = base64Decode(pemContents)

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  )

  // Sign the JWT
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signatureInput)
  )

  const encodedSignature = base64UrlEncode(signature)
  const jwt = `${signatureInput}.${encodedSignature}`

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`
  })

  if (!tokenResponse.ok) {
    const error = await tokenResponse.text()
    throw new Error(`Failed to get access token: ${error}`)
  }

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

// Helper: Base64 URL encode
function base64UrlEncode(data: string | ArrayBuffer): string {
  let base64: string

  if (typeof data === 'string') {
    base64 = btoa(data)
  } else {
    const bytes = new Uint8Array(data)
    base64 = btoa(String.fromCharCode(...bytes))
  }

  return base64
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '')
}

// Helper: Base64 decode
function base64Decode(base64: string): Uint8Array {
  const binary = atob(base64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes
}

serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('📩 Notification request received')

    // Parse request body
    const { type, title, body, reportId, userId }: NotificationRequest = await req.json()

    console.log(`Request: type=${type}, reportId=${reportId}, userId=${userId || 'N/A'}`)

    // Validate request
    if (!type || !title || !body || !reportId) {
      console.error('Missing required fields')
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get Service Account credentials from Supabase Secrets
    // Get Service Account credentials from Supabase Secrets (BASE64)
const base64Secret = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_BASE64')

if (!base64Secret) {
  throw new Error('FIREBASE_SERVICE_ACCOUNT_BASE64 not configured')
}

// Decode Base64 → JSON string
const jsonString = new TextDecoder().decode(
  Uint8Array.from(atob(base64Secret), c => c.charCodeAt(0))
)

// Parse JSON
const serviceAccount = JSON.parse(jsonString)

console.log('✅ Service account parsed successfully')
console.log('Project ID:', serviceAccount.project_id)


    console.log('✅ Service account parsed successfully')
    console.log('Project ID:', serviceAccount.project_id)

    // Get OAuth 2.0 access token
    console.log('🔐 Getting access token...')
    const accessToken = await getAccessToken(serviceAccount)
    console.log('✅ Access token obtained')

    // Get FCM tokens based on notification type
    let fcmTokens: string[] = []

    if (type === 'to_admins') {
      console.log('📋 Querying admin tokens...')
      fcmTokens = await getAdminTokens(accessToken)
      console.log(`Found ${fcmTokens.length} admin tokens`)
    } else if (type === 'to_user') {
      if (!userId) {
        console.error('userId missing for to_user type')
        return new Response(
          JSON.stringify({ error: 'userId required for to_user type' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      console.log(`📋 Querying user token for ${userId}...`)
      const userToken = await getUserToken(userId, accessToken)
      if (userToken) {
        fcmTokens = [userToken]
        console.log('✅ User token found')
      } else {
        console.log('⚠️ No FCM token found for user')
      }
    }

    console.log(`📤 Sending to ${fcmTokens.length} devices...`)

    // Send FCM notification to each token
    const results = await Promise.allSettled(
      fcmTokens.map(token => sendFCMNotification(token, title, body, reportId, accessToken))
    )

    const successCount = results.filter(r => r.status === 'fulfilled').length
    const failureCount = results.filter(r => r.status === 'rejected').length

    console.log(`✅ Sent: ${successCount} success, ${failureCount} failed`)

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        failed: failureCount,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Error:', error.message)
    console.error('Stack:', error.stack)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Get all admin FCM tokens from Firestore
async function getAdminTokens(accessToken: string): Promise<string[]> {
  try {
    // Query users collection where role == 'admin' and fcm_token exists
    const response = await fetch(
      `${FIRESTORE_BASE_URL}/users?pageSize=100`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        }
      }
    )

    if (!response.ok) {
      console.error('Firestore query failed:', await response.text())
      return []
    }

    const data = await response.json()
    const tokens: string[] = []

    if (data.documents) {
      for (const doc of data.documents) {
        const role = doc.fields?.role?.stringValue
        const fcmToken = doc.fields?.fcm_token?.stringValue

        if (role === 'admin' && fcmToken) {
          tokens.push(fcmToken)
        }
      }
    }

    return tokens
  } catch (error) {
    console.error('Error getting admin tokens:', error)
    return []
  }
}

// Get FCM token for specific user from Firestore
async function getUserToken(userId: string, accessToken: string): Promise<string | null> {
  try {
    const response = await fetch(
      `${FIRESTORE_BASE_URL}/users/${userId}`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        }
      }
    )

    if (!response.ok) {
      console.error('User not found in Firestore')
      return null
    }

    const data = await response.json()
    const fcmToken = data.fields?.fcm_token?.stringValue

    return fcmToken || null
  } catch (error) {
    console.error('Error getting user token:', error)
    return null
  }
}

// Send FCM notification using FCM v1 API
async function sendFCMNotification(
  token: string,
  title: string,
  body: string,
  reportId: string,
  accessToken: string
): Promise<void> {
  const message = {
    message: {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: {
        report_id: reportId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channel_id: 'laporin_channel',
          sound: 'default',
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          }
        }
      }
    }
  }

  const response = await fetch(FCM_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(message)
  })

  if (!response.ok) {
    const error = await response.text()
    console.error('FCM send failed:', error)
    throw new Error(`FCM send failed: ${error}`)
  }

  console.log('FCM notification sent successfully to token:', token.substring(0, 20) + '...')
}
