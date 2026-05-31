import '../models/service_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ServiceDataSource
//
// PURPOSE: Provides the two service types available in TravelMart.
// CURRENT STATE: Returns dummy/hardcoded data matching your two Odoo products.
// NEXT STEP: Swap with real Odoo product catalog API call.
//
// HOW TO SWAP LATER:
//   1. Call OdooService.instance.fetchProducts()
//   2. Map the result to ServiceModel.fromOdooJson()
// ─────────────────────────────────────────────────────────────────────────────

class ServiceDataSource {
  static final ServiceDataSource instance = ServiceDataSource._internal();
  ServiceDataSource._internal();

  // ── DUMMY DATA ──────────────────────────────────────────────────────────────
  // These match the two products you created in your Odoo subscription:
  // Product 1: Tour Guide - Per Hour ($35)
  // Product 2: Sitter - Per Hour ($30)
  static const List<ServiceModel> _dummyServices = [
    ServiceModel(
      id: 1,                         // Replace with actual Odoo product ID later
      name: 'Tour Guide - Per Hour',
      category: 'Tour Guide',
      pricePerHour: 35.0,
      description: 'Professional aviation event guide who will walk you through'
          ' the exhibits, explain aircraft history, and make your experience unforgettable.',
      iconName: 'map',
    ),
    ServiceModel(
      id: 2,                         // Replace with actual Odoo product ID later
      name: 'Sitter - Per Hour',
      category: 'Sitter',
      pricePerHour: 30.0,
      description: 'Certified event sitter to look after your children while you'
          ' enjoy the Aviation Fest 2026 freely and safely.',
      iconName: 'child_care',
    ),
  ];

  // ── PUBLIC METHODS ──────────────────────────────────────────────────────────

  /// Get all services
  /// TODO: Replace with OdooService.instance.fetchProducts()
  Future<List<ServiceModel>> getAllServices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _dummyServices;
  }

  /// Get a service by category name
  Future<ServiceModel?> getServiceByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _dummyServices.firstWhere((s) => s.category == category);
    } catch (_) {
      return null;
    }
  }
}
