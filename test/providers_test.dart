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
import 'package:wreckerlogix/features/eld/models/eld_log.dart';
import 'package:wreckerlogix/features/eld/providers/eld_provider.dart';
import 'package:wreckerlogix/features/crash_detection/models/crash_event.dart';
import 'package:wreckerlogix/features/crash_detection/providers/crash_detection_provider.dart';
import 'package:wreckerlogix/features/dash_cam/models/dash_cam_clip.dart';
import 'package:wreckerlogix/features/dash_cam/providers/dash_cam_provider.dart';
import 'package:wreckerlogix/features/roadside_assistance/models/assistance_request.dart';
import 'package:wreckerlogix/features/roadside_assistance/providers/roadside_assistance_provider.dart';
import 'package:wreckerlogix/features/maintenance/models/maintenance_record.dart';
import 'package:wreckerlogix/features/maintenance/providers/maintenance_provider.dart';
import 'package:wreckerlogix/features/ai_assistant/models/ai_message.dart';
import 'package:wreckerlogix/features/ai_assistant/providers/ai_assistant_provider.dart';

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

  group('EldProvider', () {
    late EldProvider provider;

    setUp(() {
      provider = EldProvider();
    });

    test('initializes with sample logs', () {
      expect(provider.logs, isNotEmpty);
    });

    test('starts with ELD connected', () {
      expect(provider.eldConnected, true);
      expect(provider.eldDeviceId, isNotNull);
    });

    test('connects and disconnects device', () {
      provider.disconnectDevice();
      expect(provider.eldConnected, false);
      expect(provider.eldDeviceId, isNull);

      provider.connectDevice('ELD-TEST-001');
      expect(provider.eldConnected, true);
      expect(provider.eldDeviceId, 'ELD-TEST-001');
    });

    test('changes duty status', () {
      final initialCount = provider.logs.length;
      provider.changeDutyStatus(DutyStatus.driving, annotation: 'Test drive');
      expect(provider.currentStatus, DutyStatus.driving);
      expect(provider.logs.length, initialCount + 1);
      expect(provider.logs.last.annotation, 'Test drive');
    });

    test('adds intermediate log', () {
      final initialCount = provider.logs.length;
      provider.addIntermediateLog(lat: 40.0, lng: -89.0, odometer: 105000.0);
      expect(provider.logs.length, initialCount + 1);
      expect(provider.logs.last.eventType, EldEventType.intermediateLog);
    });

    test('certifies a log', () {
      final uncertified = provider.logs.where((l) => !l.certified).toList();
      if (uncertified.isNotEmpty) {
        provider.certifyLog(uncertified.first.id);
        final updated = provider.logs.firstWhere(
            (l) => l.id == uncertified.first.id);
        expect(updated.certified, true);
      }
    });

    test('filters logs by driver', () {
      final driverLogs = provider.getLogsForDriver('drv-001');
      expect(driverLogs, isNotEmpty);
      expect(driverLogs.every((l) => l.driverId == 'drv-001'), true);
    });

    test('HOS summary has valid values', () {
      expect(provider.hosSummary.drivingHoursToday, greaterThanOrEqualTo(0));
      expect(provider.hosSummary.remainingDrivingToday, lessThanOrEqualTo(11));
      expect(provider.hosSummary.complianceStatus, isNotEmpty);
    });
  });

  group('CrashDetectionProvider', () {
    late CrashDetectionProvider provider;

    setUp(() {
      provider = CrashDetectionProvider();
    });

    test('initializes with sample events', () {
      expect(provider.events, isNotEmpty);
    });

    test('starts not monitoring', () {
      expect(provider.isMonitoring, false);
    });

    test('toggles monitoring', () {
      provider.startMonitoring();
      expect(provider.isMonitoring, true);
      provider.stopMonitoring();
      expect(provider.isMonitoring, false);
    });

    test('reports a crash', () {
      final initialCount = provider.events.length;
      provider.reportCrash(
        vehicleId: 'VH-001',
        driverName: 'Test Driver',
        latitude: 39.78,
        longitude: -89.65,
        impactForceG: 4.5,
        speedAtImpact: 45.0,
        severity: CrashSeverity.moderate,
      );
      expect(provider.events.length, initialCount + 1);
      expect(provider.activeCrash, isNotNull);
      expect(provider.countdownRemaining, isNotNull);
    });

    test('cancels alert (false alarm)', () {
      provider.reportCrash(
        vehicleId: 'VH-001',
        driverName: 'Test',
        latitude: 39.78,
        longitude: -89.65,
        impactForceG: 3.5,
        speedAtImpact: 30.0,
        severity: CrashSeverity.minor,
      );
      provider.cancelAlert();
      expect(provider.activeCrash, isNull);
      expect(provider.countdownRemaining, isNull);
      expect(provider.events.first.status, CrashAlertStatus.falseAlarm);
    });

    test('acknowledges crash event', () {
      provider.reportCrash(
        vehicleId: 'VH-002',
        driverName: 'Test',
        latitude: 39.78,
        longitude: -89.65,
        impactForceG: 5.0,
        speedAtImpact: 55.0,
        severity: CrashSeverity.severe,
      );
      final crashId = provider.activeCrash!.id;
      provider.acknowledgeAlert(crashId);
      final event = provider.events.firstWhere((e) => e.id == crashId);
      expect(event.status, CrashAlertStatus.acknowledged);
      expect(event.respondedAt, isNotNull);
    });

    test('updates settings', () {
      provider.updateSettings(const CrashDetectionSettings(
        isEnabled: false,
        sensitivityThreshold: 5.0,
        autoAlert911: false,
        autoAlertDispatch: true,
        countdownSeconds: 60,
        emergencyContacts: ['555-0000'],
      ));
      expect(provider.settings.isEnabled, false);
      expect(provider.settings.sensitivityThreshold, 5.0);
      expect(provider.settings.countdownSeconds, 60);
    });
  });

  group('DashCamProvider', () {
    late DashCamProvider provider;

    setUp(() {
      provider = DashCamProvider();
    });

    test('initializes with sample devices and clips', () {
      expect(provider.devices, isNotEmpty);
      expect(provider.clips, isNotEmpty);
    });

    test('gets clips for vehicle', () {
      final clips = provider.getClipsForVehicle('VH-001');
      expect(clips, isNotEmpty);
      expect(clips.every((c) => c.vehicleId == 'VH-001'), true);
    });

    test('requests a new clip', () {
      final initialCount = provider.clips.length;
      provider.requestClip('VH-001', type: ClipType.manualCapture);
      expect(provider.clips.length, initialCount + 1);
      expect(provider.clips.first.clipType, ClipType.manualCapture);
      expect(provider.clips.first.status, ClipStatus.recording);
    });

    test('deletes a clip', () {
      final initialCount = provider.clips.length;
      final clipId = provider.clips.first.id;
      provider.deleteClip(clipId);
      expect(provider.clips.length, initialCount - 1);
    });

    test('syncs devices', () {
      provider.syncDevices();
      expect(provider.isSyncing, true);
    });
  });

  group('RoadsideAssistanceProvider', () {
    late RoadsideAssistanceProvider provider;

    setUp(() {
      provider = RoadsideAssistanceProvider();
    });

    test('initializes with sample requests', () {
      expect(provider.requests, isNotEmpty);
    });

    test('has active and completed requests', () {
      expect(provider.activeRequests, isNotEmpty);
    });

    test('creates a new request', () {
      final initialCount = provider.requests.length;
      provider.createRequest(
        customerName: 'Test Customer',
        customerPhone: '555-1234',
        assistanceType: AssistanceType.jumpStart,
        latitude: 39.78,
        longitude: -89.65,
        address: '123 Test St',
        vehicleDescription: '2020 Honda Civic',
      );
      expect(provider.requests.length, initialCount + 1);
      expect(provider.requests.first.customerName, 'Test Customer');
      expect(provider.requests.first.status, RequestStatus.requested);
    });

    test('assigns a driver', () {
      final reqId = provider.activeRequests.first.id;
      provider.assignDriver(reqId, 'driver-99', 'Test Driver');
      final updated = provider.getRequestById(reqId);
      expect(updated?.assignedDriverName, 'Test Driver');
      expect(updated?.status, RequestStatus.dispatched);
    });

    test('updates status', () {
      final reqId = provider.activeRequests.first.id;
      provider.updateStatus(reqId, RequestStatus.enRoute);
      expect(provider.getRequestById(reqId)?.status, RequestStatus.enRoute);
    });

    test('completes a request', () {
      final reqId = provider.activeRequests.first.id;
      provider.completeRequest(reqId, finalCost: 150.0);
      final updated = provider.getRequestById(reqId);
      expect(updated?.status, RequestStatus.completed);
      expect(updated?.completedAt, isNotNull);
    });

    test('cancels a request', () {
      final reqId = provider.activeRequests.first.id;
      provider.cancelRequest(reqId);
      expect(provider.getRequestById(reqId)?.status, RequestStatus.cancelled);
    });
  });

  group('MaintenanceProvider', () {
    late MaintenanceProvider provider;

    setUp(() {
      provider = MaintenanceProvider();
    });

    test('initializes with sample records', () {
      expect(provider.records, isNotEmpty);
    });

    test('adds a new record', () {
      final initialCount = provider.records.length;
      provider.addRecord(MaintenanceRecord(
        id: 'maint-test',
        vehicleId: 'VH-001',
        vehicleLabel: 'Test Truck',
        type: MaintenanceType.oilChange,
        description: 'Test oil change',
        scheduledDate: DateTime.now().add(const Duration(days: 7)),
      ));
      expect(provider.records.length, initialCount + 1);
      expect(provider.records.first.id, 'maint-test');
    });

    test('completes a record', () {
      final scheduled = provider.scheduledRecords;
      if (scheduled.isNotEmpty) {
        final id = scheduled.first.id;
        provider.completeRecord(id, cost: 75.0, notes: 'Done');
        final updated = provider.records.firstWhere((r) => r.id == id);
        expect(updated.status, MaintenanceStatus.completed);
        expect(updated.cost, 75.0);
        expect(updated.completedDate, isNotNull);
      }
    });

    test('cancels a record', () {
      final scheduled = provider.scheduledRecords;
      if (scheduled.isNotEmpty) {
        final id = scheduled.first.id;
        provider.cancelRecord(id);
        final updated = provider.records.firstWhere((r) => r.id == id);
        expect(updated.status, MaintenanceStatus.cancelled);
      }
    });

    test('deletes a record', () {
      final initialCount = provider.records.length;
      final id = provider.records.first.id;
      provider.deleteRecord(id);
      expect(provider.records.length, initialCount - 1);
    });

    test('filters records by vehicle', () {
      final vehicleRecords = provider.getRecordsForVehicle('VH-001');
      expect(vehicleRecords.every((r) => r.vehicleId == 'VH-001'), true);
    });

    test('gets upcoming maintenance', () {
      final upcoming = provider.getUpcomingMaintenance();
      final now = DateTime.now();
      final cutoff = now.add(const Duration(days: 30));
      for (final r in upcoming) {
        expect(r.scheduledDate.isAfter(now), true);
        expect(r.scheduledDate.isBefore(cutoff), true);
      }
    });
  });

  group('AiAssistantProvider', () {
    late AiAssistantProvider provider;

    setUp(() {
      provider = AiAssistantProvider();
    });

    test('initializes with welcome messages', () {
      expect(provider.messages, isNotEmpty);
      expect(
          provider.messages.any((m) => m.role == MessageRole.assistant), true);
    });

    test('all capabilities are active by default', () {
      expect(provider.activeCapabilities.length,
          AssistantCapability.values.length);
    });

    test('sends a message', () {
      final initialCount = provider.messages.length;
      provider.sendMessage('Check my hours');
      // User message should be added immediately
      expect(provider.messages.length, initialCount + 1);
      expect(provider.messages.last.role, MessageRole.user);
      expect(provider.isProcessing, true);
    });

    test('clears chat and reloads welcome messages', () {
      provider.sendMessage('test');
      provider.clearChat();
      // Should have welcome messages only
      expect(provider.messages.any((m) => m.role == MessageRole.user), false);
    });

    test('toggles capabilities', () {
      final initialCount = provider.activeCapabilities.length;
      provider.toggleCapability(AssistantCapability.weatherAlert);
      expect(provider.activeCapabilities.length, initialCount - 1);
      provider.toggleCapability(AssistantCapability.weatherAlert);
      expect(provider.activeCapabilities.length, initialCount);
    });
  });
}
