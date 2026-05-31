import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/contractor.dart';
import '../data/models/service_model.dart';
import '../data/models/user_model.dart';
import 'api_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OdooService
//
// PURPOSE: All Odoo API calls live here. No screen touches the API directly.
// USAGE: OdooService.instance.methodName()
//
// AUTHENTICATION: Uses Odoo JSON API v2 with Bearer token (API Key)
// Endpoint pattern: POST /json/2/{model}/{method}
// Headers: Content-Type, Authorization: bearer {apiKey}, X-Odoo-Database
// ─────────────────────────────────────────────────────────────────────────────

class OdooService {
  static final OdooService instance = OdooService._internal();
  OdooService._internal();

  final _storage = const FlutterSecureStorage();
  static const _apiKeyStorageKey = 'odoo_api_key';
  static const _userIdStorageKey = 'odoo_user_id';
  static const _partnerIdStorageKey = 'odoo_partner_id';

  // ── AUTH HELPERS ────────────────────────────────────────────────────────────

  Future<String?> getStoredApiKey() async {
    return await _storage.read(key: _apiKeyStorageKey);
  }

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyStorageKey, value: apiKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdStorageKey, value: userId);
  }

  Future<void> savePartnerId(String partnerId) async {
    await _storage.write(key: _partnerIdStorageKey, value: partnerId);
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final key = await getStoredApiKey();
    return key != null && key.isNotEmpty;
  }

  // ── LOGIN ───────────────────────────────────────────────────────────────────

  /// Authenticate with Odoo using email and API key
  /// Returns UserModel on success, throws on failure
  Future<UserModel> login({
    required String email,
    required String apiKey,
  }) async {
    final url = Uri.parse(
        '${ApiConstants.odooBaseUrl}/json/2/res.users/search_read');

    final response = await http.post(
      url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'domain': [['login', '=', email]],
        'fields': ['id', 'name', 'login', 'partner_id'],
        'limit': 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final userJson = data[0] as Map<String, dynamic>;
        userJson['uid'] = userJson['id'];
        userJson['username'] = userJson['login'];
        final user = UserModel.fromOdooJson(userJson);
        await saveApiKey(apiKey);
        await saveUserId(user.id.toString());
        await savePartnerId(user.partnerId.toString());
        return user;
      }
      throw Exception('User not found');
    }
    throw Exception('Login failed: ${response.statusCode}');
  }

  // ── CONTRACTORS ─────────────────────────────────────────────────────────────

  /// Fetch all contractors (guides and sitters) from Odoo
  Future<List<Contractor>> fetchContractors() async {
    final apiKey = await getStoredApiKey();
    if (apiKey == null) throw Exception('Not authenticated');

    final url = Uri.parse(
        '${ApiConstants.odooBaseUrl}${ApiConstants.partnersEndpoint}');

    final response = await http.post(
      url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'domain': [
          ['category_id.name', 'in', ['Guide', 'Sitter']],
          ['active', '=', true],
        ],
        'fields': ['id', 'name', 'image_1920', 'phone', 'email',
                   'comment', 'category_id', 'x_price_per_hour', 'x_rating'],
        'order': 'name asc',
        'limit': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) =>
          Contractor.fromOdooJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch contractors');
  }

  // ── PRODUCTS ────────────────────────────────────────────────────────────────

  /// Fetch service products from Odoo (Tour Guide, Sitter)
  Future<List<ServiceModel>> fetchProducts() async {
    final apiKey = await getStoredApiKey();
    if (apiKey == null) throw Exception('Not authenticated');

    final url = Uri.parse(
        '${ApiConstants.odooBaseUrl}${ApiConstants.productsEndpoint}');

    final response = await http.post(
      url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'domain': [
          ['name', 'in', ['Tour Guide - Per Hour', 'Sitter - Per Hour']],
        ],
        'fields': ['id', 'name', 'list_price', 'description'],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) =>
          ServiceModel.fromOdooJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch products');
  }

  // ── BOOKINGS ────────────────────────────────────────────────────────────────

  /// Create a booking (sale.order) in Odoo
  Future<int> createBooking({
    required int partnerId,
    required int contractorPartnerId,
    required int productId,
    required int hours,
    required double pricePerHour,
    required String contractorName,
  }) async {
    final apiKey = await getStoredApiKey();
    if (apiKey == null) throw Exception('Not authenticated');

    final url = Uri.parse(
        '${ApiConstants.odooBaseUrl}${ApiConstants.saleOrderEndpoint}');

    final response = await http.post(
      url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'partner_id': partnerId,
        'order_line': [
          [0, 0, {
            'product_id': productId,
            'product_uom_qty': hours,
            'price_unit': pricePerHour,
            'name': '$contractorName - $hours hour(s)',
          }]
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as int;
    }
    throw Exception('Failed to create booking');
  }
}
