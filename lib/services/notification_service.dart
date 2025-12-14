import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';


  String? _getAccessToken() {
  final session = Supabase.instance.client.auth.currentSession;
  return session?.accessToken;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();


  // Supabase Edge Function URL (Legacy API - simpler!)
static const String _edgeFunctionUrl =
  'https://hwskzjaimgnrruxaeasu.supabase.co/functions/v1/send-notification';


  // Supabase Anon Key
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3c2t6amFpbWducnJ1eGFlYXN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NzY5ODgsImV4cCI6MjA4MTI1Mjk4OH0.7QrQiWJtP6kQ2WlDSBkYujH-sXpuVj35Cw99Gq1gntw';

final session = Supabase.instance.client.auth.currentSession;


final accessToken = _getAccessToken();


  /// Send notification to all admins
  /// Called when user creates a new report
  Future<bool> sendNotificationToAdmins({
    required String reportId,
    required String reportTitle,
    required String reporterName,
  }) async {
    try {
      debugPrint('📤 Sending notification to admins for report: $reportId');

      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer $_supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'to_admins',
          'title': 'Laporan Baru',
          'body': '$reporterName melaporkan: $reportTitle',
          'reportId': reportId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Notification sent to ${data['sent']} admins');
        return true;
      } else {
        debugPrint('❌ Failed to send notification: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification to admins: $e');
      return false;
    }
  }

  /// Send notification to specific user
  /// Called when admin updates report status
  Future<bool> sendNotificationToUser({
    required String userId,
    required String reportId,
    required String reportTitle,
    required String status,
  }) async {
    try {
      debugPrint('📤 Sending notification to user: $userId for report: $reportId');

      // Determine notification title and body based on status
      String title;
      String body;

      switch (status.toLowerCase()) {
        case 'approved':
          title = 'Laporan Disetujui';
          body = 'Laporanmu "$reportTitle" telah disetujui';
          break;
        case 'rejected':
          title = 'Laporan Ditolak';
          body = 'Laporanmu "$reportTitle" telah ditolak';
          break;
        case 'inprogress':
          title = 'Laporan Dalam Proses';
          body = 'Laporanmu "$reportTitle" sedang diproses';
          break;
        case 'resolved':
          title = 'Laporan Selesai';
          body = 'Laporanmu "$reportTitle" telah diselesaikan';
          break;
        default:
          title = 'Status Laporan Berubah';
          body = 'Status laporanmu "$reportTitle" telah diperbarui';
      }

      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer $_supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'to_user',
          'title': title,
          'body': body,
          'reportId': reportId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Notification sent to user (sent: ${data['sent']})');
        return true;
      } else {
        debugPrint('❌ Failed to send notification: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification to user: $e');
      return false;
    }
  }

  /// Send custom notification
  /// For future custom notification scenarios
  Future<bool> sendCustomNotification({
    required String type,
    required String title,
    required String body,
    required String reportId,
    String? userId,
  }) async {
    try {
      debugPrint('📤 Sending custom notification: $title');

      final requestBody = {
        'type': type,
        'title': title,
        'body': body,
        'reportId': reportId,
      };

      if (userId != null) {
        requestBody['userId'] = userId;
      }

      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer $_supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Custom notification sent successfully');
        return true;
      } else {
        debugPrint('❌ Failed to send custom notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending custom notification: $e');
      return false;
    }
  }
}
