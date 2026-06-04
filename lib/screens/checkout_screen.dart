import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/cart_provider.dart';
import '../data/datasources/session_provider.dart';
import '../api/odoo_service.dart';
import '../api/api_constants.dart';
import '../ui/theme/app_theme.dart';
import 'thankyou_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cart    = context.read<CartProvider>();
      final session = context.read<SessionProvider>();

      // Create one Odoo sale.order per cart item
      for (final item in cart.items) {
        final productId = item.contractor.serviceType == 'Tour Guide'
          ? ApiConstants.tourGuideProductId
          : ApiConstants.sitterProductId;

        final orderId = await OdooService.instance.createBooking(
          partnerId:      session.partnerId,
          productId:      productId,
          hours:          item.hours,
          pricePerHour:   item.contractor.pricePerHour,
          contractorName: item.contractor.name,
        );
        await OdooService.instance.confirmBooking(orderId);
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => ThankYouScreen(total: cart.total, items: cart.items.length)),
        (r) => r.isFirst,
      );
      context.read<CartProvider>().clear();
    } catch (e) {
      setState(() { _error = 'Booking failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: AppTheme.primary),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Order Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...cart.items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.dark.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.contractor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${item.hours} hr × \$${item.contractor.pricePerHour.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ]),
              Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          )),
          const Divider(color: Colors.white24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(color: Colors.white70)),
            Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
          ],
        ])),
        Padding(padding: const EdgeInsets.all(20),
          child: SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: (_loading || cart.items.isEmpty) ? null : _confirm,
              child: _loading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text('Confirm & Pay via Odoo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }
}
