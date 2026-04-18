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
import 'package:wreckerlogix/core/services/auth_service.dart';

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
    });

    test('signs in successfully', () async {
      final result = await auth.signIn('test@test.com', 'password');
      expect(result, true);
      expect(auth.isAuthenticated, true);
      expect(auth.userEmail, 'test@test.com');
    });

    test('signs out', () async {
      await auth.signIn('test@test.com', 'password');
      await auth.signOut();
      expect(auth.isAuthenticated, false);
      expect(auth.userId, isNull);
    });

    test('registers a new user', () async {
      final result = await auth.register(
          'new@test.com', 'password', 'New User', 'driver');
      expect(result, true);
      expect(auth.displayName, 'New User');
      expect(auth.role, 'driver');
    });
  });
}
