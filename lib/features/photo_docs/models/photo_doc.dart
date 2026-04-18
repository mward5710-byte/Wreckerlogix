/// Represents a geotagged photo for vehicle documentation.
enum PhotoType { beforePickup, damage, afterDropoff, scene, receipt, other }

class PhotoDoc {
  final String id;
  final String jobId;
  final String filePath;
  final PhotoType type;
  final String? caption;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String? capturedBy;

  const PhotoDoc({
    required this.id,
    required this.jobId,
    required this.filePath,
    required this.type,
    this.caption,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    this.capturedBy,
  });

  String get typeLabel {
    switch (type) {
      case PhotoType.beforePickup:
        return 'Before Pickup';
      case PhotoType.damage:
        return 'Damage';
      case PhotoType.afterDropoff:
        return 'After Drop-off';
      case PhotoType.scene:
        return 'Scene';
      case PhotoType.receipt:
        return 'Receipt';
      case PhotoType.other:
        return 'Other';
    }
  }
}
