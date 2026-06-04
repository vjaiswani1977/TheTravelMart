import 'package:flutter/material.dart';
import '../../data/models/contractor.dart';
import '../../ui/theme/app_theme.dart';

class ContractorCard extends StatelessWidget {
  final Contractor contractor;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const ContractorCard({super.key, required this.contractor, this.onAddToCart, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.dark.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 2), color: AppTheme.light),
            child: ClipOval(child: contractor.imageUrl.startsWith('http')
              ? Image.network(contractor.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => _initials())
              : _initials()),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(contractor.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text(contractor.serviceType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 4),
            Row(children: List.generate(5, (i) => Icon(
              i < contractor.rating.floor() ? Icons.star : Icons.star_border,
              size: 13, color: Colors.amber,
            ))),
          ])),
          // Price + Cart
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${contractor.pricePerHour.toStringAsFixed(0)}/hr',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: contractor.isAvailable ? onAddToCart : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: contractor.isAvailable ? AppTheme.primary : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(contractor.isAvailable ? 'Add' : 'Busy',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _initials() => Center(child: Text(
    contractor.name.isNotEmpty ? contractor.name[0] : '?',
    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
  ));
}
