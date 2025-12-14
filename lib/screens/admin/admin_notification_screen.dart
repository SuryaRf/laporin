// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:laporin/constants/colors.dart';
// import 'package:laporin/constants/text_styles.dart';
// import 'package:laporin/providers/notification_provider.dart';
// import 'package:laporin/providers/auth_provider.dart';
// import 'package:laporin/models/notification_model.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class AdminNotificationScreen extends StatefulWidget {
//   const AdminNotificationScreen({super.key});

//   @override
//   State<AdminNotificationScreen> createState() =>
//       _AdminNotificationScreenState();
// }

// class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     timeago.setLocaleMessages('id', timeago.IdMessages());

//     final auth = context.read<AuthProvider>();
//     final notif = context.read<NotificationProvider>();

//     if (auth.currentUser != null) {
//       notif.fetchAdminNotifications(); // 🔥 KHUSUS ADMIN
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<NotificationProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifikasi Admin'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         actions: [
//           if (provider.unreadCount > 0)
//             TextButton.icon(
//               onPressed: () async {
//                 await provider.markAllAdminAsRead();
//               },
//               icon: const Icon(Icons.done_all, color: Colors.white),
//               label: const Text(
//                 'Tandai Semua',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.adminNotifications.isEmpty
//               ? _empty()
//               : ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: provider.adminNotifications.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 8),
//                   itemBuilder: (_, i) =>
//                       _card(provider.adminNotifications[i], provider),
//                 ),
//     );
//   }

//   Widget _empty() => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.notifications_none,
//                 size: 96, color: AppColors.greyLight),
//             const SizedBox(height: 16),
//             Text(
//               'Belum ada laporan masuk',
//               style: AppTextStyles.h3.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget _card(NotificationModel n, NotificationProvider p) {
//     return InkWell(
//       onTap: () async {
//         if (!n.isRead) {
//           await p.markAsRead(n.id);
//         }

//         if (n.reportId != null && mounted) {
//           context.push('/admin/report/${n.reportId}');
//         }
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: n.isRead
//               ? Colors.white
//               : AppColors.primary.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: n.isRead
//                 ? AppColors.greyLight
//                 : AppColors.primary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _icon(),
//             const SizedBox(width: 12),
//             Expanded(child: _content(n)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _icon() => Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: AppColors.warning.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Icon(
//           Icons.report_outlined,
//           color: AppColors.warning,
//         ),
//       );

//   Widget _content(NotificationModel n) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   n.title,
//                   style: AppTextStyles.h4.copyWith(
//                     fontWeight:
//                         n.isRead ? FontWeight.w500 : FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (!n.isRead)
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             n.message,
//             style: AppTextStyles.body.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             timeago.format(n.createdAt, locale: 'id'),
//             style: AppTextStyles.caption,
//           ),
//         ],
//       );
// }
