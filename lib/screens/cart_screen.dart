import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/cart_provider.dart';
import '../data/datasources/session_provider.dart';
import '../ui/theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('My Cart'), backgroundColor: AppTheme.primary),
      body: cart.items.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.white38),
            SizedBox(height: 16),
            Text('Your cart is empty', style: TextStyle(color: Colors.white54, fontSize: 16)),
          ]))
        : Column(children: [
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.dark.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.contractor.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(item.contractor.serviceType, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('Hours:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 8),
                        IconButton(onPressed: () { if (item.hours > 1) context.read<CartProvider>().updateHours(item.id, item.hours - 1); },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        const SizedBox(width: 6),
                        Text('${item.hours}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        IconButton(onPressed: () { if (item.hours < 8) context.read<CartProvider>().updateHours(item.id, item.hours + 1); },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ]),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GestureDetector(onTap: () => context.read<CartProvider>().remove(item.id),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22)),
                    ]),
                  ]),
                );
              },
            )),
            // Total + Checkout
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppTheme.dark, border: Border(top: BorderSide(color: Colors.white24))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(color: Colors.white70, fontSize: 15)),
                  Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                    child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ]),
    );
  }
}
