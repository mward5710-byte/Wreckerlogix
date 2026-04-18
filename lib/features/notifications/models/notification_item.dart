/// Represents an in-app notification/alert for dispatch operations.
enum NotificationType {
  newJob,
  statusChange,
  emergency,
  driverCheckIn,
  jobCompleted,
  invoicePaid,
  systemAlert,
}

enum NotificationPriority { low, normal, high, critical }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedJobId;
  final String? relatedDriverId;
  final Map<String, String> metadata;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.isRead = false,
    this.relatedJobId,
    this.relatedDriverId,
    this.metadata = const {},
  });

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      relatedJobId: relatedJobId,
      relatedDriverId: relatedDriverId,
      metadata: metadata,
    );
  }

  /// Human-readable type label.
  String get typeLabel {
    switch (type) {
      case NotificationType.newJob:
        return 'New Job';
      case NotificationType.statusChange:
        return 'Status Update';
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.driverCheckIn:
        return 'Driver Check-In';
      case NotificationType.jobCompleted:
        return 'Job Completed';
      case NotificationType.invoicePaid:
        return 'Payment Received';
      case NotificationType.systemAlert:
        return 'System Alert';
    }
  }

  /// Icon-friendly type identifier.
  bool get isCritical => priority == NotificationPriority.critical;
  bool get isHighPriority =>
      priority == NotificationPriority.high ||
      priority == NotificationPriority.critical;

  /// Time ago label for display.
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year % 100}';
  }
}
