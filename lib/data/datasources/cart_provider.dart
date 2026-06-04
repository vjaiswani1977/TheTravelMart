import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/contractor.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items  => List.unmodifiable(_items);
  int  get count            => _items.length;
  double get total          => _items.fold(0, (s, i) => s + i.subtotal);

  void add(Contractor c, {int hours = 1}) {
    _items.add(CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contractor: c,
      hours: hours,
    ));
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void updateHours(String id, int hours) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) { _items[idx].hours = hours; notifyListeners(); }
  }

  void clear() { _items.clear(); notifyListeners(); }
}
