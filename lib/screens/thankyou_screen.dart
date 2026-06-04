import 'dart:math';
import 'package:flutter/material.dart';
import '../ui/theme/app_theme.dart';
import 'dashboard_screen.dart';

class ThankYouScreen extends StatefulWidget {
  final double total;
  final int items;
  const ThankYouScreen({super.key, required this.total, required this.items});
  @override State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _Particle {
  double x, y, vx, vy, size, rotation, rotSpeed, opacity;
  Color color;
  _Particle({required this.x, required this.y, required this.vx, required this.vy,
    required this.size, required this.rotation, required this.rotSpeed,
    required this.opacity, required this.color});
}

class _ThankYouScreenState extends State<ThankYouScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final List<_Particle> _particles = [];
  final _colors = [Colors.yellow, Colors.orange, Colors.blue, Colors.green, Colors.pink, Colors.purple, Colors.red, Colors.cyan];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _spawnParticles();
    _animate();
  }

  void _spawnParticles() {
    for (int i = 0; i < 100; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble() * 400,
        y: _rng.nextDouble() * -300,
        vx: (_rng.nextDouble() - 0.5) * 120,
        vy: _rng.nextDouble() * 400 + 150,
        size: _rng.nextDouble() * 12 + 6,
        rotation: _rng.nextDouble() * 360,
        rotSpeed: (_rng.nextDouble() - 0.5) * 400,
        opacity: 1.0,
        color: _colors[_rng.nextInt(_colors.length)],
      ));
    }
  }

  void _animate() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (!mounted) return;
      setState(() {
        const dt = 0.016;
        final h = MediaQuery.of(context).size.height;
        for (final p in _particles) {
          p.x += p.vx * dt;
          p.y += p.vy * dt;
          p.vy += 300 * dt;
          p.rotation += p.rotSpeed * dt;
          if (p.y > h + 20) {
            p.y = _rng.nextDouble() * -200;
            p.x = _rng.nextDouble() * MediaQuery.of(context).size.width;
            p.vy = _rng.nextDouble() * 400 + 150;
          }
        }
      });
      _animate();
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // Glitter
        CustomPaint(size: Size.infinite, painter: _GlitterPainter(_particles)),
        // Content
        SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(scale: _scale, child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 3)),
            child: const Icon(Icons.check_rounded, color: Colors.green, size: 60),
          )),
          const SizedBox(height: 28),
          const Text('Thank You!', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('for using TravelMart\nAviation Fest 2026', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.dark.withOpacity(0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Services booked', style: TextStyle(color: Colors.white70)),
                Text('${widget.items}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total amount', style: TextStyle(color: Colors.white70)),
                Text('\$${widget.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false),
              child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ])))),
      ]),
    );
  }
}

class _GlitterPainter extends CustomPainter {
  final List<_Particle> particles;
  _GlitterPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withOpacity(p.opacity.clamp(0,1));
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation * 3.14159 / 180);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.4), paint);
      canvas.restore();
    }
  }

  @override bool shouldRepaint(_) => true;
}
