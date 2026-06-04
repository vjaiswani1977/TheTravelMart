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
}
