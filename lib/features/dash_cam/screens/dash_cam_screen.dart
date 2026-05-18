import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dash_cam_clip.dart';
import '../providers/dash_cam_provider.dart';

/// Dash cam integration screen — view devices and video clips.
class DashCamScreen extends StatelessWidget {
  const DashCamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Cam'),
        actions: [
          Consumer<DashCamProvider>(
            builder: (context, camProv, _) => IconButton(
              onPressed: camProv.isSyncing ? null : () => camProv.syncDevices(),
              icon: camProv.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Sync Devices',
            ),
          ),
        ],
      ),
      body: Consumer<DashCamProvider>(
        builder: (context, camProv, _) {
          if (camProv.devices.isEmpty && camProv.clips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No dash cams connected',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Sync to discover connected devices',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => camProv.syncDevices(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // --- Devices section ---
              _SectionHeader(
                title: 'Connected Cameras',
                trailing:
                    '${camProv.devices.where((d) => d.isOnline).length}/${camProv.devices.length} online',
              ),
              ...camProv.devices.map((device) => _DeviceTile(device: device)),

              const Divider(height: 32),

              // --- Recent clips section ---
              _SectionHeader(
                title: 'Recent Clips',
                trailing: '${camProv.clips.length} clips',
              ),
              ...camProv.clips.map(
                (clip) => _ClipCard(
                  clip: clip,
                  onTap: () => _showClipDetails(context, clip),
                  onDelete: () => camProv.deleteClip(clip.id),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final camProv = context.read<DashCamProvider>();
          _showRequestClipDialog(context, camProv);
        },
        icon: const Icon(Icons.videocam),
        label: const Text('Request Clip'),
      ),
    );
  }

  void _showRequestClipDialog(BuildContext context, DashCamProvider camProv) {
    String? selectedVehicle;
    final vehicleIds =
        camProv.devices.map((d) => d.vehicleId).toSet().toList();

    if (vehicleIds.isEmpty) return;
    selectedVehicle = vehicleIds.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Request New Clip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedVehicle,
                decoration: const InputDecoration(labelText: 'Vehicle'),
                items: vehicleIds
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedVehicle = v),
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
                if (selectedVehicle != null) {
                  camProv.requestClip(selectedVehicle!);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClipDetails(BuildContext context, DashCamClip clip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(_clipTypeIcon(clip.clipType), size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(clip.clipTypeLabel)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 48, color: Colors.grey[500]),
                  const SizedBox(height: 4),
                  Text(clip.durationFormatted,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Driver', value: clip.driverName),
            _DetailRow(label: 'Vehicle', value: clip.vehicleId),
            _DetailRow(label: 'Provider', value: clip.providerLabel),
            _DetailRow(label: 'Status', value: clip.statusLabel),
            _DetailRow(label: 'Duration', value: clip.durationFormatted),
            if (clip.fileSizeMb != null)
              _DetailRow(
                  label: 'File Size',
                  value: '${clip.fileSizeMb!.toStringAsFixed(1)} MB'),
            if (clip.latitude != null)
              _DetailRow(
                  label: 'Location',
                  value:
                      '${clip.latitude!.toStringAsFixed(4)}, ${clip.longitude!.toStringAsFixed(4)}'),
            if (clip.relatedEventId != null)
              _DetailRow(label: 'Event ID', value: clip.relatedEventId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _clipTypeIcon(ClipType type) {
    switch (type) {
      case ClipType.continuous:
        return Icons.fiber_manual_record;
      case ClipType.eventTriggered:
        return Icons.warning_amber;
      case ClipType.manualCapture:
        return Icons.touch_app;
      case ClipType.crashRecording:
        return Icons.car_crash;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (trailing != null)
            Text(trailing!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DashCamDevice device;

  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (device.isOnline ? Colors.green : Colors.grey).withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.videocam,
          color: device.isOnline ? Colors.green : Colors.grey,
          size: 22,
        ),
      ),
      title: Text(device.model,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text('${device.vehicleId} · ${_providerLabel(device.provider)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (device.isOnline ? Colors.green : Colors.grey).withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          device.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: device.isOnline ? Colors.green[700] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _providerLabel(DashCamProviderType provider) {
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
}

class _ClipCard extends StatelessWidget {
  final DashCamClip clip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ClipCard({
    required this.clip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 72,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.videocam, size: 28, color: Colors.grey[500]),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          clip.durationFormatted,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(clip.driverName,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        _StatusBadge(status: clip.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TypeBadge(clipType: clip.clipType),
                        const SizedBox(width: 6),
                        _ProviderTag(provider: clip.provider),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clip.vehicleId} · ${_timeAgo(clip.startTime)}',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Delete
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.grey[400]),
                onPressed: onDelete,
                tooltip: 'Delete clip',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusBadge extends StatelessWidget {
  final ClipStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case ClipStatus.recording:
        return Colors.red;
      case ClipStatus.uploading:
        return Colors.orange;
      case ClipStatus.uploaded:
        return Colors.green;
      case ClipStatus.failed:
        return Colors.grey;
    }
  }

  String get _label {
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
}

class _TypeBadge extends StatelessWidget {
  final ClipType clipType;

  const _TypeBadge({required this.clipType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey[700]),
      ),
    );
  }

  String get _label {
    switch (clipType) {
      case ClipType.continuous:
        return 'Continuous';
      case ClipType.eventTriggered:
        return 'Event';
      case ClipType.manualCapture:
        return 'Manual';
      case ClipType.crashRecording:
        return 'Crash';
    }
  }
}

class _ProviderTag extends StatelessWidget {
  final DashCamProviderType provider;

  const _ProviderTag({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.indigo[600]),
      ),
    );
  }

  String get _label {
    switch (provider) {
      case DashCamProviderType.samsara:
        return 'Samsara';
      case DashCamProviderType.lytx:
        return 'Lytx';
      case DashCamProviderType.verizonConnect:
        return 'Verizon';
      case DashCamProviderType.generic:
        return 'Generic';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
