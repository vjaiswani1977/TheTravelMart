// ─── Odoo API Constants ───────────────────────────────────────────────────────
// Update odooBaseUrl with your actual Odoo subscription URL
// All calls use Odoo JSON API v2: POST /json/2/{model}/{method}

class ApiConstants {
  // YOUR ODOO DETAILS — update these
  static const String odooBaseUrl  = 'https://your-company.odoo.com';
  static const String odooDatabase = 'srkj'; // your confirmed database name

  // Odoo JSON API v2 endpoints
  static const String partners     = '/json/2/res.partner/search_read';
  static const String products     = '/json/2/product.product/search_read';
  static const String saleCreate   = '/json/2/sale.order/create';
  static const String saleRead     = '/json/2/sale.order/search_read';
  static const String saleWrite    = '/json/2/sale.order/write';
  static const String saleConfirm  = '/json/2/sale.order/action_confirm';

  // Headers for every Odoo API call
  static Map<String, String> headers(String apiKey) => {
    'Content-Type':   'application/json; charset=utf-8',
    'Authorization':  'bearer $apiKey',
    'X-Odoo-Database': odooDatabase,
  };

  // Odoo product IDs — update after checking your Odoo product list
  static const int tourGuideProductId = 1; // Replace with actual Odoo product ID
  static const int sitterProductId    = 2; // Replace with actual Odoo product ID
}
