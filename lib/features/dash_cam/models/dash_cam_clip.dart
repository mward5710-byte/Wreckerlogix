/// Represents a dash cam video clip and connected camera device.
enum DashCamProviderType { samsara, lytx, verizonConnect, generic }

enum ClipType { continuous, eventTriggered, manualCapture, crashRecording }

enum ClipStatus { recording, uploading, uploaded, failed }

class DashCamClip {
  final String id;
  final String vehicleId;
  final String driverName;
  final DashCamProviderType provider;
  final ClipType clipType;
  final ClipStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double? latitude;
  final double? longitude;
  final String? thumbnailUrl;
  final String? videoUrl;
  final double? fileSizeMb;
  final String? relatedEventId;

  const DashCamClip({
    required this.id,
    required this.vehicleId,
    required this.driverName,
    required this.provider,
    required this.clipType,
    this.status = ClipStatus.recording,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.latitude,
    this.longitude,
    this.thumbnailUrl,
    this.videoUrl,
    this.fileSizeMb,
    this.relatedEventId,
  });

  DashCamClip copyWith({
    ClipStatus? status,
  }) {
    return DashCamClip(
      id: id,
      vehicleId: vehicleId,
      driverName: driverName,
      provider: provider,
      clipType: clipType,
      status: status ?? this.status,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      latitude: latitude,
      longitude: longitude,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      fileSizeMb: fileSizeMb,
      relatedEventId: relatedEventId,
    );
  }

  /// Human-readable provider label.
  String get providerLabel {
    switch (provider) {
      case DashCamProviderType.samsara:
        return 'Samsara';
      case DashCamProviderType.lytx:
        return 'Lytx';
      case DashCamProviderType.verizonConnect:
        return 'Verizon Connect';
      case DashCamProviderType.generic:
        return 'Generic';
    }
  }

  /// Human-readable clip type label.
  String get clipTypeLabel {
    switch (clipType) {
      case ClipType.continuous:
        return 'Continuous';
      case ClipType.eventTriggered:
        return 'Event Triggered';
      case ClipType.manualCapture:
        return 'Manual Capture';
      case ClipType.crashRecording:
        return 'Crash Recording';
    }
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case ClipStatus.recording:
        return 'Recording';
      case ClipStatus.uploading:
        return 'Uploading';
      case ClipStatus.uploaded:
        return 'Uploaded';
      case ClipStatus.failed:
        return 'Failed';
    }
  }

  /// Duration formatted as "M:SS".
  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Represents a physical dash cam device installed in a vehicle.
class DashCamDevice {
  final String id;
  final String vehicleId;
  final DashCamProviderType provider;
  final String model;
  final bool isOnline;
  final DateTime? lastSyncTime;

  const DashCamDevice({
    required this.id,
    required this.vehicleId,
    required this.provider,
    required this.model,
    this.isOnline = false,
    this.lastSyncTime,
  });
}
