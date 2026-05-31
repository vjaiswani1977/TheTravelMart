// Model representing a service type (Tour Guide or Sitter)
// Later: populated from Odoo product catalog via Odoo API

class ServiceModel {
  final int id;
  final String name;        // 'Tour Guide - Per Hour' or 'Sitter - Per Hour'
  final String category;    // 'Tour Guide' or 'Sitter'
  final double pricePerHour;
  final String description;
  final String iconName;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerHour,
    required this.description,
    required this.iconName,
  });

  // Factory to create from Odoo product JSON
  // Used when swapping dummy data with real Odoo API
  factory ServiceModel.fromOdooJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: _parseCategory(json['name'] as String),
      pricePerHour: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      iconName: _parseCategory(json['name'] as String) == 'Tour Guide'
          ? 'map'
          : 'child_care',
    );
  }

  static String _parseCategory(String name) {
    if (name.toLowerCase().contains('guide')) return 'Tour Guide';
    if (name.toLowerCase().contains('sitter')) return 'Sitter';
    return 'Tour Guide';
  }
}
