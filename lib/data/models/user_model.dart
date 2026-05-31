// Model representing the logged-in user
// Populated from Odoo session after login

class UserModel {
  final int id;
  final String name;
  final String email;
  final int partnerId;
  final String? imageUrl;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.partnerId,
    this.imageUrl,
    this.role = 'Attendee',
  });

  factory UserModel.fromOdooJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as int,
      name: json['name'] as String,
      email: json['username'] as String? ?? '',
      partnerId: (json['partner_id'] is List)
          ? (json['partner_id'] as List).first as int
          : json['partner_id'] as int,
      role: 'Event Attendee',
    );
  }
}
