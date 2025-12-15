import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/notification_provider.dart';
import 'package:laporin/models/notification_model.dart';
import 'package:laporin/screens/report_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());

    // Fetch admin notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notif = context.read<NotificationProvider>();
      notif.fetchAdminNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await provider.markAllAdminAsRead();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi ditandai sudah dibaca'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const Text(
                'Tandai Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.adminNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchAdminNotifications();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.adminNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _buildNotificationCard(
                          provider.adminNotifications[i],
                          provider,
                        ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 100,
              color: AppColors.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada laporan masuk',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );

  Widget _buildNotificationCard(NotificationModel n, NotificationProvider p) {
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        p.deleteNotification(n.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: InkWell(
        onTap: () async {
          if (!n.isRead) {
            await p.markAsRead(n.id);
          }

          if (n.reportId != null && mounted) {
            // Navigate to report detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(
                  reportId: n.reportId!,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: n.isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: n.isRead
                  ? AppColors.greyLight
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(n.type),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(NotificationType type) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getNotificationColor(type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            _getNotificationIcon(type),
            color: _getNotificationColor(type),
            size: 24,
          ),
        ),
      );

  Widget _buildContent(NotificationModel n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  n.title,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight:
                        n.isRead ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            n.message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                timeago.format(n.createdAt, locale: 'id'),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (n.reportTitle != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '• ${n.reportTitle}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      );

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newReport:
        return Icons.report_outlined;
      case NotificationType.reportApproved:
        return Icons.check_circle_outline;
      case NotificationType.reportRejected:
        return Icons.cancel_outlined;
      case NotificationType.reportStatusChanged:
        return Icons.update_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newReport:
        return AppColors.warning;
      case NotificationType.reportApproved:
        return AppColors.success;
      case NotificationType.reportRejected:
        return AppColors.error;
      case NotificationType.reportStatusChanged:
        return AppColors.info;
      case NotificationType.general:
        return AppColors.primary;
    }
  }
}
