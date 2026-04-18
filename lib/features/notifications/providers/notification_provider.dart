import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

/// State management for the Notifications Center — real-time dispatch alerts.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get emergencyNotifications =>
      _notifications.where((n) => n.type == NotificationType.emergency).toList();

  List<NotificationItem> get jobNotifications => _notifications
      .where((n) =>
          n.type == NotificationType.newJob ||
          n.type == NotificationType.statusChange ||
          n.type == NotificationType.jobCompleted)
      .toList();

  NotificationProvider() {
    _loadSampleNotifications();
  }

  /// Add a new notification.
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark a single notification as read.
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Delete a notification.
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications.
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Push a new-job alert (called when dispatch creates a job).
  void pushNewJobAlert({
    required String jobId,
    required String customerName,
    required String towType,
    required String pickupAddress,
    bool isEmergency = false,
  }) {
    addNotification(NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: isEmergency ? '🚨 EMERGENCY DISPATCH' : '🚛 New Job Created',
      body: '$customerName — $towType\n📍 $pickupAddress',
      type: isEmergency ? NotificationType.emergency : NotificationType.newJob,
      priority: isEmergency
          ? NotificationPriority.critical
          : NotificationPriority.normal,
      timestamp: DateTime.now(),
      relatedJobId: jobId,
    ));
  }

  /// Push a status-change alert.
  void pushStatusChangeAlert({
    required String jobId,
    required String driverName,
    required String newStatus,
  }) {
    addNotification(NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: '📋 Status Update',
      body: '$driverName → $newStatus',
      type: NotificationType.statusChange,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      relatedJobId: jobId,
      relatedDriverId: driverName,
    ));
  }

  /// Push a job-completed alert.
  void pushJobCompletedAlert({
    required String jobId,
    required String customerName,
    required String driverName,
  }) {
    addNotification(NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: '✅ Job Completed',
      body: '$driverName completed the job for $customerName',
      type: NotificationType.jobCompleted,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      relatedJobId: jobId,
    ));
  }

  /// Push an invoice-paid alert.
  void pushPaymentAlert({
    required String invoiceId,
    required String customerName,
    required double amount,
  }) {
    addNotification(NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: '💰 Payment Received',
      body: '$customerName paid \$${amount.toStringAsFixed(2)}',
      type: NotificationType.invoicePaid,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      metadata: {'invoiceId': invoiceId},
    ));
  }

  /// Push a driver check-in alert.
  void pushDriverCheckInAlert({
    required String driverName,
    required String action,
  }) {
    addNotification(NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: '👤 Driver Check-In',
      body: '$driverName $action',
      type: NotificationType.driverCheckIn,
      priority: NotificationPriority.low,
      timestamp: DateTime.now(),
    ));
  }

  void _loadSampleNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: 'notif-001',
        title: '🚨 EMERGENCY DISPATCH',
        body:
            'Tom Williams — Heavy Duty Tow\n📍 I-55 Mile Marker 42, Southbound',
        type: NotificationType.emergency,
        priority: NotificationPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        relatedJobId: 'job-002',
      ),
      NotificationItem(
        id: 'notif-002',
        title: '📋 Status Update',
        body: 'Mike Rodriguez → En Route',
        type: NotificationType.statusChange,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        relatedJobId: 'job-002',
        isRead: true,
      ),
      NotificationItem(
        id: 'notif-003',
        title: '🚛 New Job Created',
        body: 'Sarah Johnson — Flatbed\n📍 1234 Oak Street, Springfield, IL',
        type: NotificationType.newJob,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        relatedJobId: 'job-001',
      ),
      NotificationItem(
        id: 'notif-004',
        title: '✅ Job Completed',
        body: 'Jake Thompson completed the job for Lisa Chen',
        type: NotificationType.jobCompleted,
        priority: NotificationPriority.normal,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        relatedJobId: 'job-003',
        isRead: true,
      ),
      NotificationItem(
        id: 'notif-005',
        title: '💰 Payment Received',
        body: 'Lisa Chen paid \$102.60',
        type: NotificationType.invoicePaid,
        priority: NotificationPriority.normal,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
        metadata: {'invoiceId': 'inv-001'},
      ),
      NotificationItem(
        id: 'notif-006',
        title: '👤 Driver Check-In',
        body: 'Mike Rodriguez clocked in at 7:00 AM',
        type: NotificationType.driverCheckIn,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationItem(
        id: 'notif-007',
        title: '👤 Driver Check-In',
        body: 'Jake Thompson clocked in at 6:00 AM',
        type: NotificationType.driverCheckIn,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
    ]);
  }
}
