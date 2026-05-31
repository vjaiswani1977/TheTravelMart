// ─────────────────────────────────────────────────────────────────────────────
// API Constants for Odoo JSON API v2
//
// Update these values with your actual Odoo subscription details.
// IMPORTANT: Never commit your API key to Git. Use flutter_secure_storage.
// ─────────────────────────────────────────────────────────────────────────────

class ApiConstants {
  // ── YOUR ODOO SUBSCRIPTION DETAILS ─────────────────────────────────────────
  // Replace with your actual Odoo instance URL
  static const String odooBaseUrl = 'https://your-company.odoo.com';

  // Your Odoo database name (you found this: 'srkj')
  static const String odooDatabase = 'srkj';

  // ── API ENDPOINTS (Odoo JSON API v2) ───────────────────────────────────────
  static const String partnersEndpoint = '/json/2/res.partner/search_read';
  static const String productsEndpoint = '/json/2/product.product/search_read';
  static const String saleOrderEndpoint = '/json/2/sale.order/create';
  static const String saleOrderReadEndpoint = '/json/2/sale.order/search_read';
  static const String saleOrderWriteEndpoint = '/json/2/sale.order/write';

  // ── HTTP HEADERS ───────────────────────────────────────────────────────────
  // API Key is loaded from secure storage at runtime — never hardcoded here
  static Map<String, String> headers(String apiKey) {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer $apiKey',
      'X-Odoo-Database': odooDatabase,
    };
  }

  // ── ODOO PRODUCT IDs ───────────────────────────────────────────────────────
  // Replace these with the actual product IDs from your Odoo subscription
  // (Check the URL in Odoo when you click on each product to get the ID)
  static const int tourGuideProductId = 1;  // Replace with actual ID
  static const int sitterProductId = 2;      // Replace with actual ID

  // ── CONTRACTOR TAGS ────────────────────────────────────────────────────────
  // These match the tags you created in Odoo Contacts
  static const String guideTag = 'Guide';
  static const String sitterTag = 'Sitter';
}
