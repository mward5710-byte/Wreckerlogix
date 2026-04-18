import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';

/// Notifications Center — real-time dispatch alerts and activity feed.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifs, _) => notifs.unreadCount > 0
                ? TextButton.icon(
                    onPressed: () => notifs.markAllAsRead(),
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    label: const Text('Read All',
                        style: TextStyle(color: Colors.white)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifs, _) {
          if (notifs.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Dispatch alerts will appear here',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Quick filter chips
              _FilterBar(notifs: notifs),

              const Divider(height: 1),

              // Notification list
              Expanded(
                child: ListView.builder(
                  itemCount: notifs.notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifs.notifications[index];
                    return _NotificationTile(
                      item: item,
                      onTap: () {
                        notifs.markAsRead(item.id);
                        if (item.relatedJobId != null) {
                          context.push('/dispatch/${item.relatedJobId}');
                        }
                      },
                      onDismiss: () => notifs.deleteNotification(item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final NotificationProvider notifs;

  const _FilterBar({required this.notifs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              count: notifs.notifications.length,
              color: Colors.grey,
              isSelected: true,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Unread',
              count: notifs.unreadCount,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Emergency',
              count: notifs.emergencyNotifications.length,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Jobs',
              count: notifs.jobNotifications.length,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withAlpha(30) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        color: item.isRead ? null : _priorityColor.withAlpha(8),
        child: ListTile(
          leading: _buildIcon(),
          title: Text(
            item.title,
            style: TextStyle(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(item.body, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(item.timeAgo,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          trailing: !item.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _priorityColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          isThreeLine: true,
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _priorityColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_typeIcon, color: _priorityColor, size: 22),
    );
  }

  IconData get _typeIcon {
    switch (item.type) {
      case NotificationType.newJob:
        return Icons.add_circle_outline;
      case NotificationType.statusChange:
        return Icons.sync;
      case NotificationType.emergency:
        return Icons.warning_amber;
      case NotificationType.driverCheckIn:
        return Icons.person_pin;
      case NotificationType.jobCompleted:
        return Icons.check_circle_outline;
      case NotificationType.invoicePaid:
        return Icons.payment;
      case NotificationType.systemAlert:
        return Icons.info_outline;
    }
  }

  Color get _priorityColor {
    if (item.type == NotificationType.emergency) return Colors.red;
    switch (item.priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.critical:
        return Colors.red;
    }
  }
}
