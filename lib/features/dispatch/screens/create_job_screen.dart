import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/dispatch_provider.dart';

/// Create a new tow/recovery job.
class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  TowType _towType = TowType.lightDuty;
  JobPriority _priority = JobPriority.normal;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _yearCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    _notesCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final job = Job(
      id: 'job-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameCtrl.text.trim(),
      customerPhone: _customerPhoneCtrl.text.trim(),
      pickupAddress: _pickupCtrl.text.trim(),
      dropoffAddress: _dropoffCtrl.text.trim(),
      vehicleYear: _yearCtrl.text.trim(),
      vehicleMake: _makeCtrl.text.trim(),
      vehicleModel: _modelCtrl.text.trim(),
      vehicleColor: _colorCtrl.text.trim(),
      licensePlate:
          _plateCtrl.text.trim().isNotEmpty ? _plateCtrl.text.trim() : null,
      towType: _towType,
      priority: _priority,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      createdAt: DateTime.now(),
      estimatedCost:
          _costCtrl.text.isNotEmpty ? double.tryParse(_costCtrl.text) : null,
    );

    context.read<DispatchProvider>().createJob(job);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Customer Information'),
              TextFormField(
                controller: _customerNameCtrl,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Locations'),
              TextFormField(
                controller: _pickupCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pickup Address *',
                  prefixIcon: Icon(Icons.my_location),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dropoffCtrl,
                decoration: const InputDecoration(
                  labelText: 'Drop-off Address *',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Vehicle Information'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _yearCtrl,
                      decoration: const InputDecoration(labelText: 'Year *'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _makeCtrl,
                      decoration: const InputDecoration(labelText: 'Make *'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _modelCtrl,
                      decoration: const InputDecoration(labelText: 'Model *'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorCtrl,
                      decoration: const InputDecoration(labelText: 'Color *'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plateCtrl,
                      decoration:
                          const InputDecoration(labelText: 'License Plate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Job Details'),
              DropdownButtonFormField<TowType>(
                value: _towType,
                decoration: const InputDecoration(labelText: 'Service Type'),
                items: TowType.values.map((t) {
                  return DropdownMenuItem(
                      value: t, child: Text(_towTypeLabel(t)));
                }).toList(),
                onChanged: (v) => setState(() => _towType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<JobPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: JobPriority.values.map((p) {
                  return DropdownMenuItem(
                      value: p, child: Text(p.name.toUpperCase()));
                }).toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                decoration: const InputDecoration(
                  labelText: 'Estimated Cost',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  String _towTypeLabel(TowType type) {
    switch (type) {
      case TowType.lightDuty:
        return 'Light Duty Tow';
      case TowType.mediumDuty:
        return 'Medium Duty Tow';
      case TowType.heavyDuty:
        return 'Heavy Duty Tow';
      case TowType.flatbed:
        return 'Flatbed';
      case TowType.motorcycle:
        return 'Motorcycle';
      case TowType.winchOut:
        return 'Winch Out';
      case TowType.lockout:
        return 'Lockout';
      case TowType.jumpStart:
        return 'Jump Start';
      case TowType.fuelDelivery:
        return 'Fuel Delivery';
      case TowType.tireChange:
        return 'Tire Change';
    }
  }
}
