import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../ui/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy notifications — swap with Odoo inbox API later
  final List<AppNotification> _notifications = [
    AppNotification(id:'1', title:'Booking Confirmed', body:'Your Tour Guide James Anderson is booked for 3 hours.', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), type:'booking'),
    AppNotification(id:'2', title:'Check-In Reminder', body:'Your session with Sarah Mitchell starts in 30 minutes.', timestamp: DateTime.now().subtract(const Duration(hours: 1)), type:'checkin'),
    AppNotification(id:'3', title:'Payment Received', body:'Invoice #INV/2026/001 has been paid successfully.', timestamp: DateTime.now().subtract(const Duration(hours: 3)), type:'payment'),
    AppNotification(id:'4', title:'Booking Confirmed', body:'Your Sitter Lisa Thompson is booked for 2 hours.', timestamp: DateTime.now().subtract(const Duration(days: 1)), type:'booking'),
  ];

  IconData _icon(String type) {
    switch (type) {
      case 'booking': return Icons.bookmark_added;
      case 'checkin': return Icons.login;
      case 'payment': return Icons.payment;
      default: return Icons.notifications;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'booking': return Colors.blue;
      case 'checkin': return Colors.green;
      case 'payment': return Colors.orange;
      default: return Colors.white;
    }
  }

  String _time(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primary,
        actions: [
          TextButton(
            onPressed: () => setState(() { for (var n in _notifications) n.isRead = true; }),
            child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: _notifications.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.white38),
            SizedBox(height: 12),
            Text('No notifications', style: TextStyle(color: Colors.white54)),
          ]))
        : ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (ctx, i) {
              final n = _notifications[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.isRead ? AppTheme.dark.withOpacity(0.3) : AppTheme.dark.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: n.isRead ? Colors.white12 : Colors.white30),
                ),
                child: Row(children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: _color(n.type).withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(_icon(n.type), color: _color(n.type), size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(n.body, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_time(n.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ])),
                  if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.light, shape: BoxShape.circle)),
                ]),
              );
            },
          ),
    );
  }
}
