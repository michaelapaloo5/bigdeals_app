import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() { _loading = true; });
    final res = await ApiService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = (res['notifications'] as List? ?? []).map((n) => NotificationItem.fromJson(n)).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiService.markNotificationRead();
              _loadNotifications();
            },
            child: const Text('Mark all read', style: TextStyle(color: AppTheme.gold, fontSize: 12)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('No notifications', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: AppTheme.gold,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (ctx, i) => _notifCard(_notifications[i]),
                  ),
                ),
    );
  }

  Widget _notifCard(NotificationItem notif) {
    final icon = notif.type == 'success'
        ? Icons.check_circle
        : notif.type == 'warning'
            ? Icons.warning
            : notif.type == 'error'
                ? Icons.error
                : Icons.info;
    final color = notif.type == 'success'
        ? AppTheme.success
        : notif.type == 'warning'
            ? AppTheme.goldLight
            : notif.type == 'error'
                ? AppTheme.danger
                : AppTheme.accent;

    return GestureDetector(
      onTap: () async {
        if (!notif.isRead) {
          await ApiService.markNotificationRead(id: notif.id);
          setState(() => notif.isRead = true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppTheme.cardBg : AppTheme.cardBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notif.isRead ? AppTheme.border : color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title, style: TextStyle(
                    fontSize: 14,
                    fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                  )),
                  const SizedBox(height: 4),
                  Text(notif.message, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                  if (notif.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(notif.createdAt!, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
