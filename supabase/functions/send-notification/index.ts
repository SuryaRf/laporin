// Supabase Edge Function to send FCM notifications
// Deploy: supabase functions deploy send-notification

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { GoogleAuth } from "https://esm.sh/google-auth-library@9.0.0"

const FIRESTORE_BASE_URL = "https://firestore.googleapis.com/v1/projects/laporin-b4a18/databases/(default)/documents"
const FCM_URL = "https://fcm.googleapis.com/v1/projects/laporin-b4a18/messages:send"

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
    // Parse request body
    const { type, title, body, reportId, userId }: NotificationRequest = await req.json()

    // Validate request
    if (!type || !title || !body || !reportId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get Service Account credentials from Supabase Secrets
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountJson) {
      throw new Error('Firebase Service Account not configured in Supabase Secrets')
    }

    const serviceAccount = JSON.parse(serviceAccountJson)

    // Get OAuth 2.0 access token
    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging']
    })
    const client = await auth.getClient()
    const accessToken = await client.getAccessToken()

    if (!accessToken.token) {
      throw new Error('Failed to get access token')
    }

    // Get FCM tokens based on notification type
    let fcmTokens: string[] = []

    if (type === 'to_admins') {
      // Query Firestore for all admin users
      fcmTokens = await getAdminTokens(accessToken.token)
    } else if (type === 'to_user') {
      // Query Firestore for specific user
      if (!userId) {
        return new Response(
          JSON.stringify({ error: 'userId required for to_user type' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      const userToken = await getUserToken(userId, accessToken.token)
      if (userToken) {
        fcmTokens = [userToken]
      }
    }

    console.log(`Found ${fcmTokens.length} FCM tokens to send to`)

    // Send FCM notification to each token
    const results = await Promise.allSettled(
      fcmTokens.map(token => sendFCMNotification(token, title, body, reportId, accessToken.token!))
    )

    const successCount = results.filter(r => r.status === 'fulfilled').length
    const failureCount = results.filter(r => r.status === 'rejected').length

    console.log(`Notifications sent: ${successCount} success, ${failureCount} failed`)

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        failed: failureCount,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error sending notification:', error)
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
