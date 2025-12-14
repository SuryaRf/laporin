import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:laporin/services/firestore_service.dart';
import 'package:laporin/utils/notification_navigation.dart';

/// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('📱 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        await _getToken();

        // Set up message handlers
        _setupMessageHandlers();

        // Listen to token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          debugPrint('🔄 FCM Token refreshed: $newToken');
          _fcmToken = newToken;
          _saveTokenToFirestore(newToken);
        });

        debugPrint('✅ FCM initialized successfully');
      } else {
        debugPrint('⚠️ FCM permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Initialize local notifications (for Android foreground)
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'laporin_channel', // id
      'LaporJTI Notifications', // name
      description: 'Notifikasi untuk laporan dan perubahan status',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      _fcmToken = await _fcm.getToken();
      debugPrint('📲 FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      // Get current user ID from FirebaseAuth
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await _firestoreService.updateUser(userId, {'fcm_token': token});
        debugPrint('✅ FCM token saved to Firestore for user: $userId');
      } else {
        debugPrint('⚠️ No user logged in, FCM token not saved');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Background message handler (must be top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message received: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });

    // When user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped (background): ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from notification (terminated state)
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🔔 App opened from notification (terminated): ${message.messageId}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Show local notification (for foreground messages)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'laporin_channel',
            'LaporJTI Notifications',
            channelDescription: 'Notifikasi untuk laporan dan perubahan status',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['report_id'],
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 Handling notification tap with data: $data');

    // Use NotificationNavigation to handle navigation
    NotificationNavigation.handleNotificationTap(data);
  }

  /// Callback when notification is tapped (local notification)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      _handleNotificationTap({'report_id': response.payload});
    }
  }

  /// Subscribe to FCM token and save to Firestore
  Future<void> subscribeToNotifications(String userId) async {
    try {
      final token = await _getToken();
      if (token != null) {
        await _firestoreService.updateUser(userId, {'fcm_token': token});
        debugPrint('✅ User subscribed to notifications');
      }
    } catch (e) {
      debugPrint('❌ Error subscribing to notifications: $e');
    }
  }

  /// Unsubscribe from FCM (delete token from Firestore)
  Future<void> unsubscribeFromNotifications(String userId) async {
    try {
      await _firestoreService.updateUser(userId, {'fcm_token': null});
      await _fcm.deleteToken();
      _fcmToken = null;
      debugPrint('✅ User unsubscribed from notifications');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from notifications: $e');
    }
  }

  /// Request permission (for iOS or re-request)
  Future<bool> requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
      return false;
    }
  }
}
