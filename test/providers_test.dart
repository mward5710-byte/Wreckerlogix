import 'package:flutter_test/flutter_test.dart';
import 'package:wreckerlogix/features/dispatch/models/job.dart';
import 'package:wreckerlogix/features/dispatch/providers/dispatch_provider.dart';
import 'package:wreckerlogix/features/accounting/models/invoice.dart';
import 'package:wreckerlogix/features/accounting/providers/accounting_provider.dart';
import 'package:wreckerlogix/features/time_tracking/providers/time_tracking_provider.dart';
import 'package:wreckerlogix/features/gps/providers/gps_provider.dart';
import 'package:wreckerlogix/features/voice_commands/providers/voice_command_provider.dart';
import 'package:wreckerlogix/features/photo_docs/providers/photo_doc_provider.dart';
import 'package:wreckerlogix/features/photo_docs/models/photo_doc.dart';
import 'package:wreckerlogix/features/notifications/models/notification_item.dart';
import 'package:wreckerlogix/features/notifications/providers/notification_provider.dart';
import 'package:wreckerlogix/core/services/auth_service.dart';
import 'package:wreckerlogix/core/services/firebase_options.dart';
import 'package:wreckerlogix/features/driver_panel/providers/driver_panel_provider.dart';

void main() {
  group('DispatchProvider', () {
    late DispatchProvider provider;

    setUp(() {
      provider = DispatchProvider();
    });

    test('initializes with sample jobs', () {
      expect(provider.jobs, isNotEmpty);
    });

    test('creates a new job', () {
      final initialCount = provider.jobs.length;
      provider.createJob(Job(
        id: 'test-job',
        customerName: 'Test Customer',
        customerPhone: '555-0000',
        pickupAddress: '123 Test St',
        dropoffAddress: '456 Test Ave',
        vehicleYear: '2020',
        vehicleMake: 'Test',
        vehicleModel: 'Car',
        vehicleColor: 'Red',
        towType: TowType.lightDuty,
        createdAt: DateTime.now(),
      ));
      expect(provider.jobs.length, initialCount + 1);
      expect(provider.jobs.first.customerName, 'Test Customer');
    });

    test('updates job status', () {
      final jobId = provider.jobs.first.id;
      provider.updateJobStatus(jobId, JobStatus.enRoute);
      expect(provider.getJobById(jobId)?.status, JobStatus.enRoute);
    });

    test('assigns a driver', () {
      final jobId = provider.pendingJobs.first.id;
      provider.assignDriver(jobId, 'driver-99', 'Test Driver');
      final job = provider.getJobById(jobId);
      expect(job?.assignedDriverName, 'Test Driver');
      expect(job?.status, JobStatus.assigned);
    });

    test('deletes a job', () {
      final initialCount = provider.jobs.length;
      final jobId = provider.jobs.first.id;
      provider.deleteJob(jobId);
      expect(provider.jobs.length, initialCount - 1);
    });
  });

  group('AccountingProvider', () {
    late AccountingProvider provider;

    setUp(() {
      provider = AccountingProvider();
    });

    test('initializes with sample invoices', () {
      expect(provider.invoices, isNotEmpty);
    });

    test('creates a new invoice', () {
      final initialCount = provider.invoices.length;
      provider.createInvoice(Invoice(
        id: 'test-inv',
        jobId: 'test-job',
        customerName: 'Test',
        customerEmail: 'test@test.com',
        lineItems: const [LineItem(description: 'Tow', unitPrice: 100.0)],
        createdAt: DateTime.now(),
      ));
      expect(provider.invoices.length, initialCount + 1);
    });

    test('marks invoice as paid', () {
      final inv = provider.sentInvoices.first;
      provider.markAsPaid(inv.id, PaymentMethod.cash);
      final updated = provider.invoices.firstWhere((i) => i.id == inv.id);
      expect(updated.status, InvoiceStatus.paid);
      expect(updated.paymentMethod, PaymentMethod.cash);
    });

    test('calculates revenue totals', () {
      expect(provider.totalRevenue, greaterThan(0));
    });
  });

  group('TimeTrackingProvider', () {
    late TimeTrackingProvider provider;

    setUp(() {
      provider = TimeTrackingProvider();
    });

    test('initializes with sample shifts', () {
      expect(provider.entries, isNotEmpty);
    });

    test('clocks in and out', () {
      expect(provider.isClockedIn, false);
      provider.clockIn('driver-test', 'Test Driver');
      expect(provider.isClockedIn, true);
      expect(provider.activeShift, isNotNull);

      provider.clockOut();
      expect(provider.isClockedIn, false);
      expect(provider.activeShift, isNull);
    });

    test('handles breaks', () {
      provider.clockIn('driver-test', 'Test Driver');
      provider.startBreak();
      expect(provider.activeShift?.breaks, isNotEmpty);

      provider.endBreak();
      expect(provider.activeShift?.breaks.last.end, isNotNull);
      provider.clockOut();
    });
  });

  group('GpsProvider', () {
    late GpsProvider provider;

    setUp(() {
      provider = GpsProvider();
    });

    test('initializes with fleet vehicles', () {
      expect(provider.vehicles, isNotEmpty);
    });

    test('selects a vehicle', () {
      provider.selectVehicle(provider.vehicles.first);
      expect(provider.selectedVehicle, isNotNull);
    });

    test('toggles tracking', () {
      expect(provider.isTracking, false);
      provider.startTracking();
      expect(provider.isTracking, true);
      provider.stopTracking();
      expect(provider.isTracking, false);
    });
  });

  group('VoiceCommandProvider', () {
    late VoiceCommandProvider provider;

    setUp(() {
      provider = VoiceCommandProvider();
    });

    test('processes known commands', () {
      provider.processCommand('en route');
      expect(provider.commandHistory, isNotEmpty);
      expect(provider.commandHistory.first.executed, true);
      expect(provider.commandHistory.first.interpretedAction,
          'update_status_en_route');
    });

    test('handles unknown commands', () {
      provider.processCommand('gibberish unknown text');
      expect(provider.commandHistory.first.executed, false);
      expect(provider.commandHistory.first.interpretedAction, isNull);
    });

    test('toggles listening', () {
      expect(provider.isListening, false);
      provider.startListening();
      expect(provider.isListening, true);
      provider.stopListening();
      expect(provider.isListening, false);
    });
  });

  group('PhotoDocProvider', () {
    late PhotoDocProvider provider;

    setUp(() {
      provider = PhotoDocProvider();
    });

    test('captures a photo', () {
      provider.capturePhoto(
        jobId: 'job-001',
        type: PhotoType.beforePickup,
        caption: 'Test',
        latitude: 39.78,
        longitude: -89.65,
      );
      expect(provider.photos, isNotEmpty);
      expect(provider.photos.first.jobId, 'job-001');
    });

    test('filters photos by job', () {
      provider.capturePhoto(jobId: 'job-001', type: PhotoType.damage);
      provider.capturePhoto(jobId: 'job-002', type: PhotoType.scene);
      expect(provider.getPhotosForJob('job-001').length, 1);
      expect(provider.getPhotosForJob('job-002').length, 1);
    });

    test('deletes a photo', () {
      provider.capturePhoto(jobId: 'job-001', type: PhotoType.damage);
      final photoId = provider.photos.first.id;
      provider.deletePhoto(photoId);
      expect(provider.photos, isEmpty);
    });
  });

  group('AuthService', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
    });

    test('starts unauthenticated', () {
      expect(auth.isAuthenticated, false);
      expect(auth.lastAuthMethod, isNull);
    });

    test('signs in successfully', () async {
      final result = await auth.signIn('test@test.com', 'password');
      expect(result, true);
      expect(auth.isAuthenticated, true);
      expect(auth.userEmail, 'test@test.com');
      expect(auth.lastAuthMethod, AuthMethod.emailPassword);
    });

    test('signs out', () async {
      await auth.signIn('test@test.com', 'password');
      await auth.signOut();
      expect(auth.isAuthenticated, false);
      expect(auth.userId, isNull);
      expect(auth.lastAuthMethod, isNull);
    });

    test('registers a new user', () async {
      final result = await auth.register(
          'new@test.com', 'password', 'New User', 'driver');
      expect(result, true);
      expect(auth.displayName, 'New User');
      expect(auth.role, 'driver');
      expect(auth.lastAuthMethod, AuthMethod.emailPassword);
    });
  });

  group('AuthService Apple Sign-In', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
    });

    test('signs in with Apple successfully', () async {
      final result = await auth.signInWithApple();
      expect(result, true);
      expect(auth.isAuthenticated, true);
      expect(auth.userId, 'apple-user-001');
      expect(auth.displayName, 'Apple User');
      expect(auth.lastAuthMethod, AuthMethod.apple);
    });

    test('Apple sign-in sets email to private relay', () async {
      await auth.signInWithApple();
      expect(auth.userEmail, contains('appleid.com'));
    });

    test('sign out clears Apple auth state', () async {
      await auth.signInWithApple();
      expect(auth.isAuthenticated, true);
      await auth.signOut();
      expect(auth.isAuthenticated, false);
      expect(auth.lastAuthMethod, isNull);
    });
  });

  group('AuthService Passkey', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
    });

    test('signs in with Passkey successfully', () async {
      final result = await auth.signInWithPasskey();
      expect(result, true);
      expect(auth.isAuthenticated, true);
      expect(auth.userId, 'passkey-user-001');
      expect(auth.displayName, 'Passkey User');
      expect(auth.lastAuthMethod, AuthMethod.passkey);
      expect(auth.passkeyRegistered, true);
    });

    test('registers a passkey for authenticated user', () async {
      await auth.signIn('test@test.com', 'password');
      final result = await auth.registerPasskey();
      expect(result, true);
      expect(auth.passkeyRegistered, true);
    });

    test('cannot register passkey without signing in', () async {
      final result = await auth.registerPasskey();
      expect(result, false);
      expect(auth.passkeyRegistered, false);
    });

    test('sign out clears Passkey auth state', () async {
      await auth.signInWithPasskey();
      await auth.signOut();
      expect(auth.isAuthenticated, false);
      expect(auth.lastAuthMethod, isNull);
    });
  });

  group('NotificationProvider', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider();
    });

    test('initializes with sample notifications', () {
      expect(provider.notifications, isNotEmpty);
    });

    test('has unread notifications', () {
      expect(provider.unreadCount, greaterThan(0));
    });

    test('marks a notification as read', () {
      final unread =
          provider.notifications.firstWhere((n) => !n.isRead);
      provider.markAsRead(unread.id);
      final updated =
          provider.notifications.firstWhere((n) => n.id == unread.id);
      expect(updated.isRead, true);
    });

    test('marks all as read', () {
      provider.markAllAsRead();
      expect(provider.unreadCount, 0);
    });

    test('pushes a new job alert', () {
      final initialCount = provider.notifications.length;
      provider.pushNewJobAlert(
        jobId: 'job-test',
        customerName: 'Test Customer',
        towType: 'Flatbed',
        pickupAddress: '123 Test St',
      );
      expect(provider.notifications.length, initialCount + 1);
      expect(provider.notifications.first.type, NotificationType.newJob);
    });

    test('pushes an emergency alert', () {
      provider.pushNewJobAlert(
        jobId: 'job-emerg',
        customerName: 'Emergency Customer',
        towType: 'Heavy Duty',
        pickupAddress: 'I-55 Crash',
        isEmergency: true,
      );
      expect(
          provider.notifications.first.type, NotificationType.emergency);
      expect(provider.notifications.first.priority,
          NotificationPriority.critical);
    });

    test('pushes status change alert', () {
      provider.pushStatusChangeAlert(
        jobId: 'job-001',
        driverName: 'Mike',
        newStatus: 'En Route',
      );
      expect(provider.notifications.first.type,
          NotificationType.statusChange);
    });

    test('pushes job completed alert', () {
      provider.pushJobCompletedAlert(
        jobId: 'job-001',
        customerName: 'Test',
        driverName: 'Mike',
      );
      expect(provider.notifications.first.type,
          NotificationType.jobCompleted);
    });

    test('pushes payment alert', () {
      provider.pushPaymentAlert(
        invoiceId: 'inv-001',
        customerName: 'Lisa',
        amount: 102.60,
      );
      expect(provider.notifications.first.type,
          NotificationType.invoicePaid);
    });

    test('pushes driver check-in alert', () {
      provider.pushDriverCheckInAlert(
        driverName: 'Jake',
        action: 'clocked in',
      );
      expect(provider.notifications.first.type,
          NotificationType.driverCheckIn);
    });

    test('deletes a notification', () {
      final initialCount = provider.notifications.length;
      final id = provider.notifications.first.id;
      provider.deleteNotification(id);
      expect(provider.notifications.length, initialCount - 1);
    });

    test('clears all notifications', () {
      provider.clearAll();
      expect(provider.notifications, isEmpty);
    });
  });

  group('FirebaseConfig', () {
    test('is not configured by default', () {
      expect(FirebaseConfig.isConfigured, false);
    });
  });

  group('AuthService Firebase mode', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
    });

    test('reports firebase not active when unconfigured', () {
      expect(auth.isFirebaseActive, false);
    });

    test('sign in works in dev mode', () async {
      final result = await auth.signIn('test@test.com', 'password');
      expect(result, true);
      expect(auth.isAuthenticated, true);
    });
  });

  group('DriverPanelProvider', () {
    late DriverPanelProvider panel;

    setUp(() {
      panel = DriverPanelProvider();
    });

    test('starts off duty', () {
      expect(panel.mode, DriverMode.offDuty);
      expect(panel.isClockedIn, false);
      expect(panel.hasActiveJob, false);
    });

    test('clocks in', () {
      panel.clockIn();
      expect(panel.isClockedIn, true);
      expect(panel.mode, DriverMode.available);
      expect(panel.clockInTime, isNotNull);
    });

    test('clocks out', () {
      panel.clockIn();
      panel.clockOut();
      expect(panel.isClockedIn, false);
      expect(panel.mode, DriverMode.offDuty);
    });

    test('loads a job', () {
      panel.clockIn();
      panel.loadJob(
        jobId: 'test-job',
        customer: 'Test Customer',
        pickup: '123 Test St',
        dropoff: '456 Drop Ave',
        vehicle: '2020 Honda Civic',
      );
      expect(panel.hasActiveJob, true);
      expect(panel.mode, DriverMode.onJob);
      expect(panel.currentJobCustomer, 'Test Customer');
      expect(panel.currentJobStatus, 'Assigned');
    });

    test('progresses through job statuses', () {
      panel.clockIn();
      panel.loadJob(
        jobId: 'test-job',
        customer: 'Test',
        pickup: '123 St',
        dropoff: '456 Ave',
        vehicle: '2020 Car',
      );

      panel.goEnRoute();
      expect(panel.currentJobStatus, 'En Route');

      panel.arriveOnScene();
      expect(panel.currentJobStatus, 'On Scene');

      panel.startTow();
      expect(panel.currentJobStatus, 'In Progress');

      final jobsBefore = panel.todayJobsCompleted;
      panel.completeJob();
      expect(panel.currentJobStatus, 'Completed');
      expect(panel.todayJobsCompleted, jobsBefore + 1);
      expect(panel.mode, DriverMode.available);
    });

    test('clears completed job', () {
      panel.clockIn();
      panel.acceptDemoJob();
      panel.completeJob();
      panel.clearCompletedJob();
      expect(panel.hasActiveJob, false);
      expect(panel.currentJobId, isNull);
    });

    test('accepts demo job', () {
      panel.clockIn();
      panel.acceptDemoJob();
      expect(panel.hasActiveJob, true);
      expect(panel.currentJobCustomer, 'Sarah Johnson');
    });

    test('tracks today stats', () {
      expect(panel.todayJobsCompleted, greaterThanOrEqualTo(0));
      expect(panel.todayEarnings, greaterThanOrEqualTo(0));
      expect(panel.todayMiles, greaterThanOrEqualTo(0));
    });

    test('formats hours worked', () {
      expect(panel.hoursWorkedToday, '0:00');
      panel.clockIn();
      expect(panel.hoursWorkedToday, isNotEmpty);
    });
  });
}
