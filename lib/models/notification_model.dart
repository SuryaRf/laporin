import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function to parse DateTime from Firestore Timestamp or String
DateTime _parseDateTime(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}

enum NotificationType {
  reportApproved,
  reportRejected,
  reportStatusChanged,
  newReport,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.reportApproved:
        return 'Laporan Disetujui';
      case NotificationType.reportRejected:
        return 'Laporan Ditolak';
      case NotificationType.reportStatusChanged:
        return 'Status Laporan Berubah';
      case NotificationType.newReport:
        return 'Laporan Baru';
      case NotificationType.general:
        return 'Notifikasi';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.reportApproved:
        return '✅';
      case NotificationType.reportRejected:
        return '❌';
      case NotificationType.reportStatusChanged:
        return '🔄';
      case NotificationType.newReport:
        return '📝';
      case NotificationType.general:
        return '📢';
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? reportId;
  final String? reportTitle;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.reportId,
    this.reportTitle,
    this.isRead = false,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      reportId: json['report_id'] as String?,
      reportTitle: json['report_title'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'report_id': reportId,
      'report_title': reportTitle,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? reportId,
    String? reportTitle,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      reportId: reportId ?? this.reportId,
      reportTitle: reportTitle ?? this.reportTitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
