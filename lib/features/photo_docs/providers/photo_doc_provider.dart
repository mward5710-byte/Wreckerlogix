import 'package:flutter/foundation.dart';
import '../models/photo_doc.dart';

/// State management for photo documentation.
class PhotoDocProvider extends ChangeNotifier {
  final List<PhotoDoc> _photos = [];
  bool _isCapturing = false;

  List<PhotoDoc> get photos => List.unmodifiable(_photos);
  bool get isCapturing => _isCapturing;

  /// Get all photos for a specific job.
  List<PhotoDoc> getPhotosForJob(String jobId) =>
      _photos.where((p) => p.jobId == jobId).toList();

  /// Add a captured photo.
  void addPhoto(PhotoDoc photo) {
    _photos.insert(0, photo);
    notifyListeners();
  }

  /// Delete a photo.
  void deletePhoto(String photoId) {
    _photos.removeWhere((p) => p.id == photoId);
    notifyListeners();
  }

  /// Start camera capture.
  void startCapture() {
    _isCapturing = true;
    notifyListeners();
  }

  /// End camera capture.
  void endCapture() {
    _isCapturing = false;
    notifyListeners();
  }

  /// Simulate capturing a photo (dev mode).
  void capturePhoto({
    required String jobId,
    required PhotoType type,
    String? caption,
    double? latitude,
    double? longitude,
  }) {
    final photo = PhotoDoc(
      id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      filePath: '/mock/path/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      type: type,
      caption: caption,
      latitude: latitude,
      longitude: longitude,
      capturedAt: DateTime.now(),
      capturedBy: 'current-user',
    );
    addPhoto(photo);
  }
}
