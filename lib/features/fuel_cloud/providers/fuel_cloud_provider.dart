import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/fuel_transaction.dart';
import '../models/fuel_vehicle.dart';
import '../services/fuel_cloud_service.dart';

/// State management for the FuelCloud module.
///
/// Credentials are stored securely:
///   - Client ID → flutter_secure_storage (encrypted)
///   - Client Secret → flutter_secure_storage (encrypted)
///
/// Call [loadCredentials] at startup, then [refresh] to fetch live data.
class FuelCloudProvider extends ChangeNotifier {
  static const _prefClientId = 'fuelcloud_client_id';
  static const _prefClientSecret = 'fuelcloud_client_secret';

  // flutter_secure_storage encrypts values using the platform keychain/keystore.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _clientId = '';
  String _clientSecret = '';
  bool _isConfigured = false;
  bool _isLoading = false;
  String? _error;

  List<FuelTransaction> _transactions = [];
  List<FuelVehicle> _vehicles = [];
  List<FuelSite> _sites = [];
  String? _selectedVehicleId;
  DateTime? _filterStart;
  DateTime? _filterEnd;

  FuelCloudService? _service;

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isConfigured => _isConfigured;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get clientId => _clientId;

  List<FuelTransaction> get transactions {
    if (_selectedVehicleId == null) return List.unmodifiable(_transactions);
    return _transactions
        .where((t) => t.vehicleId == _selectedVehicleId)
        .toList();
  }

  List<FuelVehicle> get vehicles => List.unmodifiable(_vehicles);
  List<FuelSite> get sites => List.unmodifiable(_sites);
  String? get selectedVehicleId => _selectedVehicleId;
  DateTime? get filterStart => _filterStart;
  DateTime? get filterEnd => _filterEnd;

  double get totalVolume =>
      transactions.fold(0.0, (sum, t) => sum + t.volume);

  double get totalCost =>
      transactions.fold(0.0, (sum, t) => sum + t.totalCost);

  double get averagePPG {
    final active = transactions.where((t) => !t.isVoided).toList();
    if (active.isEmpty) return 0.0;
    return active.fold(0.0, (sum, t) => sum + t.pricePerUnit) / active.length;
  }

  // ─── Credentials ──────────────────────────────────────────────────────────

  Future<void> loadCredentials() async {
    _clientId = await _storage.read(key: _prefClientId) ?? '';
    _clientSecret = await _storage.read(key: _prefClientSecret) ?? '';
    _isConfigured = _clientId.isNotEmpty && _clientSecret.isNotEmpty;
    if (_isConfigured) {
      _service = FuelCloudService(
        clientId: _clientId,
        clientSecret: _clientSecret,
      );
    }
    notifyListeners();
  }

  /// Saves credentials to secure storage.
  ///
  /// If [clientSecret] is empty and credentials are already configured,
  /// the existing secret is preserved.
  Future<void> saveCredentials(String clientId, String clientSecret) async {
    final effectiveSecret =
        clientSecret.isEmpty ? _clientSecret : clientSecret;
    await _storage.write(key: _prefClientId, value: clientId);
    if (clientSecret.isNotEmpty) {
      await _storage.write(key: _prefClientSecret, value: clientSecret);
    }
    _clientId = clientId;
    _clientSecret = effectiveSecret;
    _isConfigured = clientId.isNotEmpty && effectiveSecret.isNotEmpty;
    _service = _isConfigured
        ? FuelCloudService(clientId: clientId, clientSecret: effectiveSecret)
        : null;
    _error = null;
    notifyListeners();
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _prefClientId);
    await _storage.delete(key: _prefClientSecret);
    _clientId = '';
    _clientSecret = '';
    _isConfigured = false;
    _service = null;
    _transactions = [];
    _vehicles = [];
    _sites = [];
    notifyListeners();
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  void setVehicleFilter(String? vehicleId) {
    _selectedVehicleId = vehicleId;
    notifyListeners();
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    _filterStart = start;
    _filterEnd = end;
    notifyListeners();
  }

  // ─── Data Fetching ────────────────────────────────────────────────────────

  /// Fetch transactions, vehicles, and sites from FuelCloud.
  Future<void> refresh() async {
    if (!_isConfigured || _service == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service!.getTransactions(
          startDate: _filterStart,
          endDate: _filterEnd,
        ),
        _service!.getVehicles(),
        _service!.getSites(),
      ]);
      _transactions = results[0] as List<FuelTransaction>;
      _vehicles = results[1] as List<FuelVehicle>;
      _sites = results[2] as List<FuelSite>;
    } on FuelCloudException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  FuelCloudProvider() {
    loadCredentials();
  }
}
