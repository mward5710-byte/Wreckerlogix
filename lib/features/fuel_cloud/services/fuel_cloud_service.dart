import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel_transaction.dart';
import '../models/fuel_vehicle.dart';

/// Service for communicating with the FuelCloud REST API v2.
///
/// Authentication: OAuth2 Bearer token obtained via POST /v2/token.
/// Base URL: https://api.fuelcloud.com/v2
///
/// To obtain API credentials, log in to the FuelCloud portal and
/// navigate to Settings → API to generate a Client ID and Client Secret.
class FuelCloudService {
  static const String _baseUrl = 'https://api.fuelcloud.com/v2';

  final String clientId;
  final String clientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  FuelCloudService({
    required this.clientId,
    required this.clientSecret,
  });

  // ─── Authentication ────────────────────────────────────────────────────────

  /// Fetches a new Bearer token using client_credentials grant.
  Future<void> authenticate() async {
    final uri = Uri.parse('$_baseUrl/token');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'client_credentials',
      }),
    );

    if (response.statusCode != 200) {
      throw FuelCloudException(
        'Authentication failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    final expiresIn = data['expires_in'] as int? ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
  }

  Future<Map<String, String>> _authHeaders() async {
    if (_accessToken == null ||
        _tokenExpiry == null ||
        DateTime.now().isAfter(_tokenExpiry!)) {
      await authenticate();
    }
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  /// Fetches a list of fuel transactions.
  ///
  /// [startDate] and [endDate] filter by transaction date (ISO 8601).
  /// [vehicleId] optionally filters to a specific vehicle.
  Future<List<FuelTransaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? vehicleId,
    int page = 1,
  }) async {
    final headers = await _authHeaders();
    final queryParams = <String, String>{'page': page.toString()};
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T').first;
    }
    if (vehicleId != null) queryParams['vehicle_id'] = vehicleId;

    final uri =
        Uri.parse('$_baseUrl/transactions').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    _assertOk(response, 'fetch transactions');
    final data = jsonDecode(response.body);
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .cast<Map<String, dynamic>>()
        .map(FuelTransaction.fromJson)
        .toList();
  }

  // ─── Vehicles ──────────────────────────────────────────────────────────────

  /// Fetches the list of vehicles registered in FuelCloud.
  Future<List<FuelVehicle>> getVehicles() async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/vehicles');
    final response = await http.get(uri, headers: headers);

    _assertOk(response, 'fetch vehicles');
    final data = jsonDecode(response.body);
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .cast<Map<String, dynamic>>()
        .map(FuelVehicle.fromJson)
        .toList();
  }

  // ─── Sites ─────────────────────────────────────────────────────────────────

  /// Fetches the list of fueling sites registered in FuelCloud.
  Future<List<FuelSite>> getSites() async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/sites');
    final response = await http.get(uri, headers: headers);

    _assertOk(response, 'fetch sites');
    final data = jsonDecode(response.body);
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .cast<Map<String, dynamic>>()
        .map(FuelSite.fromJson)
        .toList();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response response, String operation) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FuelCloudException(
        'Failed to $operation (${response.statusCode}): ${response.body}',
      );
    }
  }
}

class FuelCloudException implements Exception {
  final String message;
  const FuelCloudException(this.message);

  @override
  String toString() => 'FuelCloudException: $message';
}
