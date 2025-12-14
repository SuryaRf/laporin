import 'package:flutter/foundation.dart';
import 'package:laporin/models/notification_model.dart';
import 'package:laporin/services/firestore_service.dart';
import 'dart:async';

class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _adminNotifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _adminNotificationsSubscription;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get adminNotifications => _adminNotifications;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;


  

  // Fetch notifications for a user
  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _notificationsSubscription?.cancel();

      // Listen to notifications stream
      _notificationsSubscription = _firestoreService
          .getNotificationsByUserId(userId)
          .listen(
        (notifications) {
          _notifications = notifications;
          _unreadCount = notifications.where((n) => !n.isRead).length;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = 'Gagal memuat notifikasi: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a notification
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? reportId,
    String? reportTitle,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        reportId: reportId,
        reportTitle: reportTitle,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _firestoreService.createNotification(notification);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat notifikasi: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menandai notifikasi: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _firestoreService.markAllNotificationsAsRead(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menandai semua notifikasi: $e';
      notifyListeners();
      return false;
    }
  }

  

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestoreService.deleteNotification(notificationId);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus notifikasi: $e';
      notifyListeners();
      return false;
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount(String userId) async {
    try {
      _unreadCount = await _firestoreService.getUnreadNotificationCount(userId);
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  // Fetch admin notifications
  Future<void> fetchAdminNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _adminNotificationsSubscription?.cancel();

      // Listen to admin notifications stream
      _adminNotificationsSubscription = _firestoreService
          .getAdminNotifications()
          .listen(
        (notifications) {
          _adminNotifications = notifications;
          _unreadCount = notifications.where((n) => !n.isRead).length;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = 'Gagal memuat notifikasi: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark all admin notifications as read
  Future<bool> markAllAdminAsRead() async {
    try {
      // Mark all unread admin notifications as read
      for (final notification in _adminNotifications.where((n) => !n.isRead)) {
        await _firestoreService.markNotificationAsRead(notification.id);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menandai semua notifikasi: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _adminNotificationsSubscription?.cancel();
    super.dispose();
  }
}
