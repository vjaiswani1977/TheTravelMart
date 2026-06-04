import 'contractor.dart';

class CartItem {
  final String id;
  final Contractor contractor;
  int hours;

  CartItem({
    required this.id,
    required this.contractor,
    required this.hours,
  });

  double get subtotal => contractor.pricePerHour * hours;
}
