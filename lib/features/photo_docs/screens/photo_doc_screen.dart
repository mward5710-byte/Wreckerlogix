import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo_doc.dart';
import '../providers/photo_doc_provider.dart';

/// Photo documentation screen — capture and manage vehicle photos.
class PhotoDocScreen extends StatelessWidget {
  const PhotoDocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Documentation')),
      body: Consumer<PhotoDocProvider>(
        builder: (context, photoProv, _) {
          if (photoProv.photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No photos yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Capture vehicle photos for documentation',
                      style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showCaptureDialog(context, photoProv),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Take First Photo'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CountBadge(
                      count: photoProv.photos.length,
                      label: 'Total Photos',
                      icon: Icons.photo_library,
                    ),
                    _CountBadge(
                      count: photoProv.photos
                          .where((p) => p.type == PhotoType.damage)
                          .length,
                      label: 'Damage',
                      icon: Icons.warning_amber,
                    ),
                    _CountBadge(
                      count: photoProv.photos
                          .where((p) => p.latitude != null)
                          .length,
                      label: 'Geotagged',
                      icon: Icons.location_on,
                    ),
                  ],
                ),
              ),

              // Photo grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: photoProv.photos.length,
                  itemBuilder: (context, index) {
                    return _PhotoCard(photo: photoProv.photos[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final photoProv = context.read<PhotoDocProvider>();
          _showCaptureDialog(context, photoProv);
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Capture'),
      ),
    );
  }

  void _showCaptureDialog(BuildContext context, PhotoDocProvider photoProv) {
    PhotoType selectedType = PhotoType.beforePickup;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Capture Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select photo type:'),
              const SizedBox(height: 12),
              DropdownButtonFormField<PhotoType>(
                value: selectedType,
                items: PhotoType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(_photoTypeLabel(t)),
                  );
                }).toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              // Camera placeholder
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Camera Preview',
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                photoProv.capturePhoto(
                  jobId: 'job-001',
                  type: selectedType,
                  caption: '${_photoTypeLabel(selectedType)} photo',
                  latitude: 39.7817,
                  longitude: -89.6501,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Capture'),
            ),
          ],
        ),
      ),
    );
  }

  String _photoTypeLabel(PhotoType type) {
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

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _CountBadge({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text('$count',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final PhotoDoc photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey[500]),
                  if (photo.caption != null)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(photo.caption!,
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                          textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(photo.typeLabel,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                if (photo.latitude != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 10, color: Colors.green),
                      const SizedBox(width: 2),
                      Text('Geotagged',
                          style: TextStyle(
                              fontSize: 10, color: Colors.green[700])),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
