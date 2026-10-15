import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationType { success, info, warning }

class AppNotification {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isUnread;

  const AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = true,
  });
}

class NotificationsSheet extends StatefulWidget {
  final String role; // 'donor', 'ngo', 'rider'

  const NotificationsSheet({super.key, required this.role});

  static void show(BuildContext context, {required String role}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationsSheet(role: role),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _getMockNotifications(widget.role);
  }

  List<AppNotification> _getMockNotifications(String role) {
    return const <AppNotification>[];
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => AppNotification(
                title: n.title,
                message: n.message,
                time: n.time,
                type: n.type,
                isUnread: false,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text('Mark all read', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bellOff, size: 48, color: AppColors.textDisabled.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('No new notifications', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _notifications.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 64, color: AppColors.border),
                      itemBuilder: (ctx, i) {
                        final notif = _notifications[i];
                        Color iconBg;
                        Color iconColor;
                        IconData iconData;

                        switch (notif.type) {
                          case NotificationType.success:
                            iconBg = AppColors.accent.withOpacity(0.12);
                            iconColor = AppColors.accent;
                            iconData = LucideIcons.checkCircle2;
                            break;
                          case NotificationType.warning:
                            iconBg = AppColors.urgent.withOpacity(0.12);
                            iconColor = AppColors.urgent;
                            iconData = LucideIcons.alertCircle;
                            break;
                          case NotificationType.info:
                            iconBg = AppColors.primary.withOpacity(0.12);
                            iconColor = AppColors.primary;
                            iconData = LucideIcons.info;
                            break;
                        }

                        return Container(
                          color: notif.isUnread ? AppColors.primary.withOpacity(0.04) : Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, color: iconColor, size: 22),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: TextStyle(
                                      fontWeight: notif.isUnread ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  notif.time,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                notif.message,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
