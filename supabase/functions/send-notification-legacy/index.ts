// Supabase Edge Function - FCM Notifications using Legacy API (SIMPLE!)
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FIREBASE_PROJECT_ID = "laporin-b4a18"
const FIRESTORE_BASE_URL = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`
const FCM_LEGACY_URL = "https://fcm.googleapis.com/fcm/send"

interface NotificationRequest {
  type: 'to_admins' | 'to_user'
  title: string
  body: string
  reportId: string
  userId?: string
}

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('📩 Notification request received')

    const { type, title, body, reportId, userId }: NotificationRequest = await req.json()

    // Get FCM Server Key from env
    const serverKey = Deno.env.get('FCM_SERVER_KEY')
    if (!serverKey) {
      throw new Error('FCM_SERVER_KEY not configured')
    }

    console.log('✅ FCM Server Key loaded')

    // Get FCM tokens
    let fcmTokens: string[] = []

    if (type === 'to_admins') {
      fcmTokens = await getAdminTokens()
      console.log(`Found ${fcmTokens.length} admin tokens`)
    } else if (type === 'to_user') {
      if (!userId) {
        return new Response(
          JSON.stringify({ error: 'userId required for to_user type' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      const userToken = await getUserToken(userId)
      if (userToken) {
        fcmTokens = [userToken]
      }
    }

    console.log(`📤 Sending to ${fcmTokens.length} devices...`)

    // Send notifications
    const results = await Promise.allSettled(
      fcmTokens.map(token => sendFCMLegacy(token, title, body, reportId, serverKey))
    )

    const successCount = results.filter(r => r.status === 'fulfilled').length

    console.log(`✅ Sent: ${successCount} success`)

    return new Response(
      JSON.stringify({ success: true, sent: successCount }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Error:', error.message)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Get admin tokens from Firestore (public API - no auth needed for read)
async function getAdminTokens(): Promise<string[]> {
  try {
    // Use Firestore REST API with API Key (simpler than Service Account)
    const apiKey = "AIzaSyDsSID1TnbC5Djrna__6g8zVQalZDsgpzE" // Your Firebase API Key

    const response = await fetch(
      `${FIRESTORE_BASE_URL}/users?key=${apiKey}`,
      { headers: { 'Content-Type': 'application/json' } }
    )

    if (!response.ok) {
      console.error('Firestore query failed')
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

// Get user token from Firestore
async function getUserToken(userId: string): Promise<string | null> {
  try {
    const apiKey = "AIzaSyDsSID1TnbC5Djrna__6g8zVQalZDsgpzE"

    const response = await fetch(
      `${FIRESTORE_BASE_URL}/users/${userId}?key=${apiKey}`,
      { headers: { 'Content-Type': 'application/json' } }
    )

    if (!response.ok) {
      return null
    }

    const data = await response.json()
    return data.fields?.fcm_token?.stringValue || null
  } catch (error) {
    console.error('Error getting user token:', error)
    return null
  }
}

// Send FCM notification using Legacy API (SIMPLE!)
async function sendFCMLegacy(
  token: string,
  title: string,
  body: string,
  reportId: string,
  serverKey: string
): Promise<void> {
  const message = {
    to: token,
    notification: {
      title: title,
      body: body,
      sound: 'default',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    data: {
      report_id: reportId,
    },
    priority: 'high',
  }

  const response = await fetch(FCM_LEGACY_URL, {
    method: 'POST',
    headers: {
      'Authorization': `key=${serverKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(message),
  })

  if (!response.ok) {
    const error = await response.text()
    console.error('FCM send failed:', error)
    throw new Error(`FCM failed: ${error}`)
  }

  console.log('✅ FCM sent to:', token.substring(0, 20) + '...')
}
