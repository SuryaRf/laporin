import 'package:flutter/material.dart';
import 'package:laporin/main.dart';
import 'package:laporin/screens/report_detail_screen.dart';

class NotificationNavigation {
  /// Navigate to report detail screen
  static void navigateToReportDetail(String reportId) {
    final context = navigatorKey.currentContext;

    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportDetailScreen(reportId: reportId),
        ),
      );
    }
  }

  /// Handle notification data and navigate accordingly
  static void handleNotificationTap(Map<String, dynamic> data) {
    final reportId = data['report_id'];

    if (reportId != null && reportId is String) {
      navigateToReportDetail(reportId);
    }
  }
}
