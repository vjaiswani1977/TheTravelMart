import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/cart_provider.dart';
import '../data/datasources/contractor_datasource.dart';
import '../data/datasources/session_provider.dart';
import '../data/models/contractor.dart';
import '../ui/theme/app_theme.dart';
import '../ui/widgets/contractor_card.dart';
import 'cart_screen.dart';
import 'checkin_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  int _tab = 0; // 0=All, 1=Tour Guide, 2=Sitter
  int _navIdx = 0;
  List<Contractor> _all = [], _filtered = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    // TODO: swap with OdooService.instance.fetchContractors() when ready
    final data = await ContractorDataSource.instance.getAll();
    setState(() { _all = data; _filtered = data; _loading = false; });
  }

  void _filter(int tab) {
    setState(() {
      _tab = tab;
      final q = _search.text.toLowerCase();
      final base = tab == 0 ? _all : _all.where((c) => c.serviceType == ['All','Tour Guide','Sitter'][tab]).toList();
      _filtered = q.isEmpty ? base : base.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final session = context.watch<SessionProvider>();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bg,
      drawer: _drawer(context, session),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: const Text('Travel Deals'),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
            if (cart.count > 0) Positioned(right: 6, top: 6,
              child: Container(width: 16, height: 16,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('${cart.count}', style: const TextStyle(color: Colors.white, fontSize: 10))))),
          ]),
        ],
      ),
      body: Column(children: [
        // Search
        Padding(padding: const EdgeInsets.fromLTRB(16,14,16,0),
          child: Container(height: 46, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const SizedBox(width: 12),
              const Icon(Icons.tune, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _search, onChanged: (_) => _filter(_tab),
                decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
              )),
              const Icon(Icons.search, color: AppTheme.primary),
              const SizedBox(width: 8),
            ]),
          ),
        ),
        // Filter tabs
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
          child: Row(children: ['All','Tour Guide','Sitter'].asMap().entries.map((e) => Expanded(child: GestureDetector(
            onTap: () => _filter(e.key),
            child: Container(
              margin: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: _tab == e.key ? AppTheme.dark : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white54),
              ),
              child: Text(e.value, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: _tab == e.key ? FontWeight.bold : FontWeight.normal)),
            ),
          ))).toList()),
        ),
        const SizedBox(height: 10),
        // Contractor list
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => ContractorCard(
                  contractor: _filtered[i],
                  onAddToCart: () {
                    context.read<CartProvider>().add(_filtered[i]);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${_filtered[i].name} added to cart'),
                      backgroundColor: AppTheme.dark,
                      duration: const Duration(seconds: 1),
                    ));
                  },
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CheckInScreen(contractor: _filtered[i]))),
                ),
              ))),
      ]),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _drawer(BuildContext ctx, SessionProvider session) => Drawer(
    backgroundColor: AppTheme.bg,
    child: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'TRAVEL', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          TextSpan(text: 'Mart',   style: TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w300)),
        ])),
        const SizedBox(height: 20),
        Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24, border: Border.all(color: Colors.white38)),
            child: const Icon(Icons.person, color: Colors.white, size: 26)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.userName.isNotEmpty ? session.userName : 'Attendee',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const Text('Aviation Fest 2026', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ]),
        ]),
      ])),
      const Divider(color: Colors.white24),
      _item(Icons.home, 'Home', () => Navigator.pop(ctx)),
      _item(Icons.shopping_cart_outlined, 'Cart', () { Navigator.pop(ctx); Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CartScreen())); }),
      _item(Icons.notifications_outlined, 'Notifications', () { Navigator.pop(ctx); Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationsScreen())); }),
      _item(Icons.history, 'Order History', () {}),
      _item(Icons.settings_outlined, 'Settings', () {}),
      const Spacer(),
      const Divider(color: Colors.white24),
      _item(Icons.logout, 'Logout', () => _logout(ctx, session)),
      const SizedBox(height: 12),
    ])),
  );

  Widget _item(IconData icon, String label, VoidCallback onTap) =>
    ListTile(leading: Icon(icon, color: Colors.white), title: Text(label, style: const TextStyle(color: Colors.white)), onTap: onTap, dense: true);

  void _logout(BuildContext ctx, SessionProvider session) {
    Navigator.pop(ctx);
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: AppTheme.bg,
      title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
      content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: () async {
          Navigator.pop(c);
          await session.logout();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
        }, child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent))),
      ],
    ));
  }

  Widget _bottomNav(BuildContext ctx) => Container(
    decoration: const BoxDecoration(color: AppTheme.dark, border: Border(top: BorderSide(color: Colors.white24))),
    child: SafeArea(top: false, child: SizedBox(height: 56, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.shopping_cart_outlined, 'label': 'Cart'},
        {'icon': Icons.notifications_outlined, 'label': 'Alerts'},
        {'icon': Icons.person_outline, 'label': 'Profile'},
      ].asMap().entries.map((e) => GestureDetector(
        onTap: () {
          setState(() => _navIdx = e.key);
          if (e.key == 1) Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CartScreen()));
          if (e.key == 2) Navigator.push(ctx, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(e.value['icon'] as IconData, color: _navIdx == e.key ? Colors.white : Colors.white54, size: _navIdx == e.key ? 26 : 22),
          Text(e.value['label'] as String, style: TextStyle(color: _navIdx == e.key ? Colors.white : Colors.white54, fontSize: 10)),
        ]),
      )).toList(),
    ))),
  );
}
