import 'dart:async';
import 'package:flutter/material.dart';
import '../api/odoo_service.dart';
import '../data/models/contractor.dart';
import '../ui/theme/app_theme.dart';
import 'thankyou_screen.dart';

class CheckInScreen extends StatefulWidget {
  final Contractor contractor;
  final int orderId;

  const CheckInScreen({super.key, required this.contractor, this.orderId = 0});
  @override State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  enum Status { pending, checkedIn, completed }
  Status _status = Status.pending;
  bool _loading = false;
  DateTime? _checkInTime;
  Timer? _timer;
  String _elapsed = '00:00:00';
  double _cost = 0;

  @override void dispose() { _timer?.cancel(); super.dispose(); }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_checkInTime == null) return;
      final diff = DateTime.now().difference(_checkInTime!);
      final h = diff.inHours.toString().padLeft(2,'0');
      final m = (diff.inMinutes % 60).toString().padLeft(2,'0');
      final s = (diff.inSeconds % 60).toString().padLeft(2,'0');
      setState(() {
        _elapsed = '$h:$m:$s';
        _cost = diff.inSeconds / 3600 * widget.contractor.pricePerHour;
      });
    });
  }

  Future<void> _checkIn() async {
    setState(() => _loading = true);
    try {
      if (widget.orderId > 0) await OdooService.instance.checkIn(widget.orderId);
      setState(() { _status = Status.checkedIn; _checkInTime = DateTime.now(); _loading = false; });
      _startTimer();
    } catch (_) {
      // Still allow check-in UI even if API fails (offline mode)
      setState(() { _status = Status.checkedIn; _checkInTime = DateTime.now(); _loading = false; });
      _startTimer();
    }
  }

  Future<void> _checkOut() async {
    setState(() => _loading = true);
    _timer?.cancel();
    try {
      if (widget.orderId > 0) await OdooService.instance.checkOut(widget.orderId);
    } catch (_) {}
    if (!mounted) return;
    setState(() { _status = Status.completed; _loading = false; });
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ThankYouScreen(total: _cost, items: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Session'), backgroundColor: AppTheme.primary),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        // Contractor info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.dark.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
          child: Row(children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.light, border: Border.all(color: Colors.white38)),
              child: Center(child: Text(widget.contractor.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.contractor.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              Text(widget.contractor.serviceType, style: const TextStyle(color: Colors.white60, fontSize: 13)),
              Text('\$${widget.contractor.pricePerHour.toStringAsFixed(0)}/hr', style: const TextStyle(color: AppTheme.light, fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
        const SizedBox(height: 32),

        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(_status == Status.checkedIn ? 'Elapsed Time' : 'Session',
              style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 8),
            Text(_elapsed, style: TextStyle(
              color: _status == Status.checkedIn ? AppTheme.light : Colors.white,
              fontSize: 52, fontWeight: FontWeight.w200, fontFamily: 'monospace')),
          ]),
        ),
        const SizedBox(height: 24),

        // Cost
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.dark.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Estimated Cost', style: TextStyle(color: Colors.white70)),
            Text('\$${_cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        const Spacer(),

        // Action button
        SizedBox(width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : (_status == Status.pending ? _checkIn : _checkOut),
            icon: Icon(_status == Status.pending ? Icons.login : Icons.logout),
            label: Text(_status == Status.pending ? 'Check In' : 'Check Out',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _status == Status.pending ? AppTheme.primary : Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(color: AppTheme.light),
      ])),
    );
  }
}
