import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/app_data_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../dashboard/complaint_detail_screen.dart';
import 'broadcast_notification_dialog.dart';

class NotificationPanelScreen extends StatefulWidget {
  const NotificationPanelScreen({super.key});

  @override
  State<NotificationPanelScreen> createState() =>
      _NotificationPanelScreenState();
}

class _NotificationPanelScreenState extends State<NotificationPanelScreen> {
  final NotificationService _notificationService = NotificationService();

  String _formatRelativeTime(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return "Recently";
    }

    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  void initState() {
    super.initState();
    // Request browser push permission if on web
    _notificationService.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    final appData = Provider.of<AppDataProvider>(context, listen: false);
    final userRole = appData.userRole.toLowerCase().trim();
    final canBroadcast = appData.isAdmin || userRole == 'it technician';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 2.w),
              const Text("Notification Panel"),
            ],
          ),
          actions: [
            if (canBroadcast)
              IconButton(
                icon: const Icon(Icons.campaign_rounded),
                tooltip: "Send Broadcast Alert",
                onPressed: () => BroadcastNotificationDialog.show(context),
              ),
            if (userId.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: "Mark all as read",
                onPressed: () async {
                  await _notificationService.markAllAsRead(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All notifications marked as read"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: "Clear all",
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Clear Notifications"),
                      content: const Text(
                        "Are you sure you want to clear all notifications?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                          child: const Text("Clear All"),
                        ),
                      ],
                    ),
                  );
                  if (confirm ?? false) {
                    await _notificationService.clearAll(userId);
                  }
                },
              ),
            ],
          ],
        ),
        body: ResponsiveWrapper(
          child: userId.isEmpty
              ? const Center(child: Text("Please sign in to view notifications"))
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream:
                      _notificationService.getUserNotificationsStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_none,
                                  size: 48.sp,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "All caught up!",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "You will receive updates here whenever a complaint status changes or new lab tasks are assigned.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsivePadding(context),
                        vertical: 2.h,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final isRead = notif['isRead'] == true;
                        final title = notif['title'] ?? 'Notification';
                        final message = notif['message'] ?? '';
                        final lab = notif['lab'] ?? '';
                        final complaintId = notif['complaintId'] ?? '';
                        final type = notif['type'] ?? 'info';
                        final timeStr =
                            _formatRelativeTime(notif['createdAt']);

                        Color iconColor = AppTheme.accentColor;
                        IconData iconData = Icons.notifications;

                        if (type == 'complaint_created') {
                          iconColor = Colors.orange;
                          iconData = Icons.assignment_add;
                        } else if (type == 'status_changed') {
                          iconColor = AppTheme.successColor;
                          iconData = Icons.published_with_changes;
                        }

                        return Card(
                          elevation: isRead ? 1 : 3,
                          margin: EdgeInsets.only(bottom: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isRead
                                  ? AppTheme.textTertiary.withValues(alpha: 0.2)
                                  : AppTheme.accentColor.withValues(alpha: 0.5),
                              width: isRead ? 1 : 1.5,
                            ),
                          ),
                          color: isRead
                              ? AppTheme.cardColor
                              : AppTheme.cardColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (!isRead && notif['id'] != null) {
                                _notificationService.markAsRead(notif['id']);
                              }
                              if (complaintId.toString().isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ComplaintDetailScreen(
                                      complaintId: complaintId,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        iconColor.withValues(alpha: 0.15),
                                    radius: 22,
                                    child: Icon(
                                      iconData,
                                      color: iconColor,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: EdgeInsets.only(
                                                  left: 1.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppTheme.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Row(
                                          children: [
                                            if (lab.toString().isNotEmpty) ...[
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  lab,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: AppTheme.accentColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                            ],
                                            Icon(
                                              Icons.access_time,
                                              size: 13,
                                              color: AppTheme.textTertiary,
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: AppTheme.textTertiary,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (complaintId
                                                .toString()
                                                .isNotEmpty)
                                              Row(
                                                children: [
                                                  Text(
                                                    "View Ticket",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          AppTheme.accentColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.chevron_right,
                                                    size: 16,
                                                    color:
                                                        AppTheme.accentColor,
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
