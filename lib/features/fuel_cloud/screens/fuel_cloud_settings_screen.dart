import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_cloud_provider.dart';

/// FuelCloud API settings screen — enter Client ID and Client Secret.
///
/// Credentials are obtained from the FuelCloud portal:
/// Settings → API → Generate API Keys
class FuelCloudSettingsScreen extends StatefulWidget {
  const FuelCloudSettingsScreen({super.key});

  @override
  State<FuelCloudSettingsScreen> createState() =>
      _FuelCloudSettingsScreenState();
}

class _FuelCloudSettingsScreenState extends State<FuelCloudSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  bool _obscureSecret = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FuelCloudProvider>();
    // We only pre-fill the client ID (non-secret). The client secret is never
    // read back from secure storage into the UI — the user must re-enter it
    // only when changing it. The validator below skips the secret field when
    // credentials are already saved (isConfigured == true).
    _clientIdController.text = provider.clientId;
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final provider = context.read<FuelCloudProvider>();
      await provider.saveCredentials(
        _clientIdController.text.trim(),
        _clientSecretController.text.trim(),
      );
      // Test the connection immediately
      await provider.refresh();
      if (!mounted) return;
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FuelCloud connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect FuelCloud?'),
        content: const Text(
            'This will remove your API credentials and clear all synced fuel data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<FuelCloudProvider>().clearCredentials();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = context.watch<FuelCloudProvider>().isConfigured;

    return Scaffold(
      appBar: AppBar(title: const Text('FuelCloud API Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('How to get API credentials',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Log in to your FuelCloud portal\n'
                      '2. Go to Settings → API\n'
                      '3. Click "Generate API Keys"\n'
                      '4. Copy your Client ID and Client Secret below',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: You must have an active FuelCloud account and API access enabled.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _clientIdController,
                    decoration: const InputDecoration(
                      labelText: 'Client ID',
                      hintText: 'Your FuelCloud Client ID',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clientSecretController,
                    decoration: InputDecoration(
                      labelText: 'Client Secret',
                      hintText: isConfigured
                          ? '••••••••••••••••'
                          : 'Your FuelCloud Client Secret',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureSecret
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureSecret = !_obscureSecret),
                      ),
                    ),
                    obscureText: _obscureSecret,
                    validator: (v) {
                      if (isConfigured) return null; // not required if already set
                      return (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                  ),
                  if (isConfigured) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Leave Client Secret blank to keep the existing value.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(isConfigured
                    ? 'Update & Reconnect'
                    : 'Connect FuelCloud'),
              ),
            ),

            if (isConfigured) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _disconnect,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect FuelCloud'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
