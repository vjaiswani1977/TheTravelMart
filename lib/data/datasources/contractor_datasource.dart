import '../models/contractor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContractorDataSource
//
// PURPOSE: Single source of truth for contractor data in the app.
// CURRENT STATE: Returns dummy/hardcoded data for development and testing.
// NEXT STEP: Swap the dummy data below with real Odoo API calls using OdooService.
//
// HOW TO SWAP LATER:
//   1. Import OdooService from ../../api/odoo_service.dart
//   2. Call OdooService.instance.fetchContractors()
//   3. Return the result instead of _dummyContractors
// ─────────────────────────────────────────────────────────────────────────────

class ContractorDataSource {
  static final ContractorDataSource instance = ContractorDataSource._internal();
  ContractorDataSource._internal();

  // ── DUMMY DATA ──────────────────────────────────────────────────────────────
  // Replace this list with Odoo API data when ready
  static const List<Contractor> _dummyContractors = [
    // Tour Guides
    Contractor(
      id: 1,
      name: 'James Anderson',
      serviceType: 'Tour Guide',
      pricePerHour: 35.0,
      rating: 4.8,
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      description: 'Experienced aviation tour guide with 10+ years at airshows.',
      isAvailable: true,
    ),
    Contractor(
      id: 2,
      name: 'Sarah Mitchell',
      serviceType: 'Tour Guide',
      pricePerHour: 35.0,
      rating: 4.9,
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      description: 'Certified aviation enthusiast and professional event guide.',
      isAvailable: true,
    ),
    Contractor(
      id: 3,
      name: 'Robert Chen',
      serviceType: 'Tour Guide',
      pricePerHour: 35.0,
      rating: 4.7,
      imageUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
      description: 'Former air traffic controller turned aviation tour expert.',
      isAvailable: true,
    ),
    Contractor(
      id: 4,
      name: 'Emily Rodriguez',
      serviceType: 'Tour Guide',
      pricePerHour: 35.0,
      rating: 4.6,
      imageUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
      description: 'Multilingual guide specializing in aircraft history.',
      isAvailable: false,
    ),

    // Sitters
    Contractor(
      id: 5,
      name: 'Lisa Thompson',
      serviceType: 'Sitter',
      pricePerHour: 30.0,
      rating: 4.9,
      imageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      description: 'Certified childcare professional with 8 years of experience.',
      isAvailable: true,
    ),
    Contractor(
      id: 6,
      name: 'Michael Brown',
      serviceType: 'Sitter',
      pricePerHour: 30.0,
      rating: 4.7,
      imageUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
      description: 'Event sitter specializing in family-friendly activities.',
      isAvailable: true,
    ),
    Contractor(
      id: 7,
      name: 'Jessica Park',
      serviceType: 'Sitter',
      pricePerHour: 30.0,
      rating: 4.8,
      imageUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
      description: 'CPR-certified sitter with aviation event experience.',
      isAvailable: true,
    ),
    Contractor(
      id: 8,
      name: 'David Wilson',
      serviceType: 'Sitter',
      pricePerHour: 30.0,
      rating: 4.5,
      imageUrl: 'https://randomuser.me/api/portraits/men/28.jpg',
      description: 'Professional event sitter, great with all age groups.',
      isAvailable: true,
    ),
  ];

  // ── PUBLIC METHODS ──────────────────────────────────────────────────────────

  /// Get all contractors
  /// TODO: Replace with OdooService.instance.fetchContractors()
  Future<List<Contractor>> getAllContractors() async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    return _dummyContractors;
  }

  /// Get contractors filtered by service type
  /// TODO: Replace with OdooService.instance.fetchContractorsByType(type)
  Future<List<Contractor>> getContractorsByType(String serviceType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyContractors
        .where((c) => c.serviceType == serviceType)
        .toList();
  }

  /// Get only available contractors
  Future<List<Contractor>> getAvailableContractors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyContractors.where((c) => c.isAvailable).toList();
  }
}
