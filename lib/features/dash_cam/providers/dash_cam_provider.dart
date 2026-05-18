import 'package:flutter/foundation.dart';
import '../models/dash_cam_clip.dart';

/// State management for dash cam integration.
class DashCamProvider extends ChangeNotifier {
  final List<DashCamClip> _clips = [];
  final List<DashCamDevice> _devices = [];
  bool _isSyncing = false;

  List<DashCamClip> get clips => List.unmodifiable(_clips);
  List<DashCamDevice> get devices => List.unmodifiable(_devices);
  bool get isSyncing => _isSyncing;

  DashCamProvider() {
    _loadSampleData();
  }

  /// Get all clips for a specific vehicle.
  List<DashCamClip> getClipsForVehicle(String vehicleId) =>
      _clips.where((c) => c.vehicleId == vehicleId).toList();

  /// Get all clips related to a specific event (e.g., crash event).
  List<DashCamClip> getClipsForEvent(String eventId) =>
      _clips.where((c) => c.relatedEventId == eventId).toList();

  /// Request a new clip from a vehicle's dash cam.
  void requestClip(
    String vehicleId, {
    ClipType type = ClipType.manualCapture,
  }) {
    final device = _devices.where((d) => d.vehicleId == vehicleId).firstOrNull;
    final clip = DashCamClip(
      id: 'clip-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicleId,
      driverName: device != null ? 'Driver — $vehicleId' : 'Unknown',
      provider: device?.provider ?? DashCamProviderType.generic,
      clipType: type,
      status: ClipStatus.recording,
      startTime: DateTime.now(),
      durationSeconds: 0,
      latitude: 39.7817,
      longitude: -89.6501,
    );
    _clips.insert(0, clip);
    notifyListeners();
  }

  /// Simulate syncing devices with dash cam APIs.
  void syncDevices() {
    _isSyncing = true;
    notifyListeners();

    // Simulate async sync completing after a short delay.
    Future.delayed(const Duration(seconds: 2), () {
      _isSyncing = false;
      notifyListeners();
    });
  }

  /// Delete a clip by ID.
  void deleteClip(String clipId) {
    _clips.removeWhere((c) => c.id == clipId);
    notifyListeners();
  }

  void _loadSampleData() {
    // Sample devices
    _devices.addAll([
      DashCamDevice(
        id: 'cam-001',
        vehicleId: 'VH-001',
        provider: DashCamProviderType.samsara,
        model: 'Samsara CM32',
        isOnline: true,
        lastSyncTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      DashCamDevice(
        id: 'cam-002',
        vehicleId: 'VH-002',
        provider: DashCamProviderType.lytx,
        model: 'Lytx SF300',
        isOnline: true,
        lastSyncTime: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      DashCamDevice(
        id: 'cam-003',
        vehicleId: 'VH-003',
        provider: DashCamProviderType.verizonConnect,
        model: 'VC Integrated Cam',
        isOnline: false,
        lastSyncTime: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    // Sample clips
    _clips.addAll([
      DashCamClip(
        id: 'clip-001',
        vehicleId: 'VH-001',
        driverName: 'Mike Rodriguez',
        provider: DashCamProviderType.samsara,
        clipType: ClipType.eventTriggered,
        status: ClipStatus.uploaded,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        endTime: DateTime.now().subtract(const Duration(minutes: 28)),
        durationSeconds: 150,
        latitude: 39.7817,
        longitude: -89.6501,
        fileSizeMb: 45.2,
        relatedEventId: 'crash-001',
      ),
      DashCamClip(
        id: 'clip-002',
        vehicleId: 'VH-002',
        driverName: 'Jake Thompson',
        provider: DashCamProviderType.lytx,
        clipType: ClipType.manualCapture,
        status: ClipStatus.uploaded,
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().subtract(const Duration(minutes: 58)),
        durationSeconds: 120,
        latitude: 39.7600,
        longitude: -89.6700,
        fileSizeMb: 38.0,
      ),
      DashCamClip(
        id: 'clip-003',
        vehicleId: 'VH-001',
        driverName: 'Mike Rodriguez',
        provider: DashCamProviderType.samsara,
        clipType: ClipType.continuous,
        status: ClipStatus.uploading,
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        durationSeconds: 600,
        latitude: 39.7900,
        longitude: -89.6400,
        fileSizeMb: 180.5,
      ),
      DashCamClip(
        id: 'clip-004',
        vehicleId: 'VH-003',
        driverName: 'Carlos Mendez',
        provider: DashCamProviderType.verizonConnect,
        clipType: ClipType.crashRecording,
        status: ClipStatus.uploaded,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 59)),
        durationSeconds: 60,
        latitude: 39.8000,
        longitude: -89.6400,
        fileSizeMb: 22.1,
        relatedEventId: 'crash-002',
      ),
      DashCamClip(
        id: 'clip-005',
        vehicleId: 'VH-002',
        driverName: 'Jake Thompson',
        provider: DashCamProviderType.lytx,
        clipType: ClipType.eventTriggered,
        status: ClipStatus.failed,
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        durationSeconds: 90,
        latitude: 39.7550,
        longitude: -89.6750,
      ),
      DashCamClip(
        id: 'clip-006',
        vehicleId: 'VH-001',
        driverName: 'Mike Rodriguez',
        provider: DashCamProviderType.samsara,
        clipType: ClipType.manualCapture,
        status: ClipStatus.recording,
        startTime: DateTime.now().subtract(const Duration(minutes: 2)),
        durationSeconds: 0,
        latitude: 39.7820,
        longitude: -89.6510,
      ),
    ]);
  }
}
