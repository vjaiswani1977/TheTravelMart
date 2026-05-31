// Model representing a contractor (Tour Guide or Sitter)
// Later: populated from Odoo API via contractor_datasource.dart

class Contractor {
  final int id;
  final String name;
  final String serviceType; // 'Tour Guide' or 'Sitter'
  final double pricePerHour;
  final double rating;
  final String imageUrl;
  final String description;
  final bool isAvailable;

  const Contractor({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.pricePerHour,
    required this.rating,
    required this.imageUrl,
    required this.description,
    this.isAvailable = true,
  });

  // Factory constructor to create Contractor from Odoo API JSON response
  // Used later when swapping dummy data with real Odoo data
  factory Contractor.fromOdooJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'] as int,
      name: json['name'] as String,
      serviceType: _parseServiceType(json['category_id']),
      pricePerHour: (json['x_price_per_hour'] as num?)?.toDouble() ?? 0.0,
      rating: (json['x_rating'] as num?)?.toDouble() ?? 4.5,
      imageUrl: json['image_1920'] != null
          ? 'data:image/png;base64,${json['image_1920']}'
          : '',
      description: json['comment'] as String? ?? '',
      isAvailable: json['active'] as bool? ?? true,
    );
  }

  static String _parseServiceType(dynamic categoryId) {
    if (categoryId is List && categoryId.isNotEmpty) {
      final name = categoryId.last.toString().toLowerCase();
      if (name.contains('guide')) return 'Tour Guide';
      if (name.contains('sitter')) return 'Sitter';
    }
    return 'Tour Guide';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'imageUrl': imageUrl,
      'description': description,
      'isAvailable': isAvailable,
    };
  }
}
