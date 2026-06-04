import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../data/models/contractor.dart';
import 'api_constants.dart';

// ─── OdooService ─────────────────────────────────────────────────────────────
// All Odoo API calls live here. Screens never call the API directly.
// Uses Odoo JSON API v2 with bearer token authentication.
// ─────────────────────────────────────────────────────────────────────────────

class OdooService {
  static final OdooService instance = OdooService._();
  OdooService._();

  final _storage = const FlutterSecureStorage();

  // ── Keychain helpers ────────────────────────────────────────────────────────
  Future<String?> getApiKey()     async => await _storage.read(key: 'odoo_api_key');
  Future<String?> getEmail()      async => await _storage.read(key: 'odoo_email');
  Future<int?>    getPartnerId()  async {
    final v = await _storage.read(key: 'odoo_partner_id');
    return v != null ? int.tryParse(v) : null;
  }

  Future<void> saveSession({required String email, required String apiKey, required int partnerId}) async {
    await _storage.write(key: 'odoo_email',      value: email);
    await _storage.write(key: 'odoo_api_key',    value: apiKey);
    await _storage.write(key: 'odoo_partner_id', value: partnerId.toString());
  }

  Future<void> clearSession() async => await _storage.deleteAll();
  Future<bool> isLoggedIn()   async {
    final k = await getApiKey();
    return k != null && k.isNotEmpty;
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  // Verifies email + API key against Odoo and saves session locally.
  Future<Map<String, dynamic>> login({required String email, required String apiKey}) async {
    final url = Uri.parse('${ApiConstants.odooBaseUrl}/json/2/res.users/search_read');
    final res = await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'domain': [['login', '=', email]],
        'fields': ['id', 'name', 'login', 'partner_id'],
        'limit': 1,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty) {
        final user = data[0] as Map<String, dynamic>;
        final partnerId = (user['partner_id'] as List).first as int;
        await saveSession(email: email, apiKey: apiKey, partnerId: partnerId);
        return {'name': user['name'], 'partnerId': partnerId};
      }
    }
    throw Exception('Login failed — check your email and API key');
  }

  // ── Fetch contractors ───────────────────────────────────────────────────────
  // Returns all contacts tagged as Guide or Sitter from Odoo
  Future<List<Contractor>> fetchContractors() async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('Not logged in');
    final url = Uri.parse('${ApiConstants.odooBaseUrl}${ApiConstants.partners}');
    final res = await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'domain': [
          ['category_id.name', 'in', ['Guide', 'Sitter']],
          ['active', '=', true],
        ],
        'fields': ['id', 'name', 'image_1920', 'phone', 'email', 'comment', 'category_id'],
        'order': 'name asc',
        'limit': 100,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((j) {
        final cat = (j['category_id'] as List?)?.lastOrNull?.toString() ?? '';
        final type = cat.toLowerCase().contains('sitter') ? 'Sitter' : 'Tour Guide';
        final price = type == 'Tour Guide' ? 35.0 : 30.0;
        return Contractor(
          id: j['id'] as int,
          name: j['name'] as String,
          serviceType: type,
          pricePerHour: price,
          rating: 4.7,
          imageUrl: '',
          description: j['comment'] as String? ?? '',
        );
      }).toList();
    }
    throw Exception('Failed to fetch contractors');
  }

  // ── Create booking (sale.order) ─────────────────────────────────────────────
  Future<int> createBooking({
    required int partnerId,
    required int productId,
    required int hours,
    required double pricePerHour,
    required String contractorName,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('Not logged in');
    final url = Uri.parse('${ApiConstants.odooBaseUrl}${ApiConstants.saleCreate}');
    final res = await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'partner_id': partnerId,
        'order_line': [[0, 0, {
          'product_id': productId,
          'product_uom_qty': hours,
          'price_unit': pricePerHour,
          'name': '$contractorName — $hours hr(s)',
        }]],
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as int;
    throw Exception('Failed to create booking');
  }

  // ── Confirm booking ─────────────────────────────────────────────────────────
  Future<void> confirmBooking(int orderId) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('Not logged in');
    final url = Uri.parse('${ApiConstants.odooBaseUrl}${ApiConstants.saleConfirm}');
    await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({'args': [[orderId]]}),
    );
  }

  // ── Check in ────────────────────────────────────────────────────────────────
  Future<void> checkIn(int orderId) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('Not logged in');
    final url = Uri.parse('${ApiConstants.odooBaseUrl}${ApiConstants.saleWrite}');
    final now = DateTime.now().toUtc().toIso8601String();
    await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'args': [[orderId], {'x_checkin_time': now, 'x_checkin_status': 'checked_in'}],
      }),
    );
  }

  // ── Check out ───────────────────────────────────────────────────────────────
  Future<void> checkOut(int orderId) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception('Not logged in');
    final url = Uri.parse('${ApiConstants.odooBaseUrl}${ApiConstants.saleWrite}');
    final now = DateTime.now().toUtc().toIso8601String();
    await http.post(url,
      headers: ApiConstants.headers(apiKey),
      body: jsonEncode({
        'args': [[orderId], {'x_checkout_time': now, 'x_checkin_status': 'completed'}],
      }),
    );
  }
}
