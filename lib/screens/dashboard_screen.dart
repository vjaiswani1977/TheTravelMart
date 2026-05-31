import 'package:flutter/material.dart';
import '../data/datasources/contractor_datasource.dart';
import '../data/models/contractor.dart';
import '../ui/theme/app_theme.dart';
import '../ui/widgets/contractor_card.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen
//
// Main screen after login. Based on your IMG_6902 design (Travel Deals screen).
// Shows:
//   - Green AppBar with hamburger menu and "Travel Deals" title
//   - Search bar
//   - Filter tabs: All / Tour Guide / Sitter
//   - List of contractors (from ContractorDataSource — dummy data for now)
//   - Side drawer (from IMG_6900 design)
//   - Bottom nav bar: Home, Explore, Saved, Notification, Profile
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  int _selectedTab = 0;        // 0=All, 1=Tour Guide, 2=Sitter
  int _selectedNavIndex = 0;
  List<Contractor> _allContractors = [];
  List<Contractor> _filteredContractors = [];
  bool _loading = true;

  final List<String> _tabs = ['All', 'Tour Guide', 'Sitter'];

  @override
  void initState() {
    super.initState();
    _loadContractors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContractors() async {
    setState(() { _loading = true; });

    // TODO: Swap ContractorDataSource with OdooService.instance.fetchContractors()
    final contractors = await ContractorDataSource.instance.getAllContractors();
    setState(() {
      _allContractors = contractors;
      _filteredContractors = contractors;
      _loading = false;
    });
  }

  void _applyFilter(int tabIndex) {
    setState(() {
      _selectedTab = tabIndex;
      final query = _searchController.text.toLowerCase();
      List<Contractor> base = tabIndex == 0
          ? _allContractors
          : _allContractors
              .where((c) => c.serviceType == _tabs[tabIndex])
              .toList();
      _filteredContractors = query.isEmpty
          ? base
          : base
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
    });
  }

  void _onSearch(String query) {
    _applyFilter(_selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundGreen,

      // ── Side Drawer (IMG_6900 design) ──────────────────────────────────────
      drawer: _buildDrawer(context),

      // ── App Bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Travel Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.tune, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: AppTheme.textGrey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    onPressed: () => _onSearch(_searchController.text),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Tabs: All / Tour Guide / Sitter ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _applyFilter(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.darkGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                      child: Text(
                        _tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // ── Contractor List ──────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _filteredContractors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                color: Colors.white54, size: 50),
                            const SizedBox(height: 12),
                            const Text(
                              'No contractors found',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadContractors,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _filteredContractors.length,
                          itemBuilder: (context, index) {
                            final contractor = _filteredContractors[index];
                            return ContractorCard(
                              contractor: contractor,
                              onTap: () {
                                // TODO: Navigate to contractor detail screen (V2)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Selected: ${contractor.name}'),
                                    backgroundColor: AppTheme.darkGreen,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── DRAWER (from IMG_6900) ─────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundGreen,
      child: SafeArea(
        child: Column(
          children: [
            // Header: Logo + user profile
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'TRAVEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: 'Mart',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User info row
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 2),
                          color: Colors.white24,
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Attendee',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Aviation Fest 2026',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),

            // Menu items
            _drawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
            _drawerItem(Icons.explore, 'Explore', () {}),
            _drawerItem(Icons.notifications_outlined, 'Notification', () {}),
            _drawerItem(Icons.shopping_cart_outlined, 'Cart', () {}),
            _drawerItem(Icons.bookmark_border, 'Booking', () {}),
            _drawerItem(Icons.favorite_border, 'Saved', () {}),
            _drawerItem(Icons.history, 'Order history', () {}),
            _drawerItem(Icons.subscriptions_outlined, 'Subscription Plan', () {}),

            const Spacer(),
            const Divider(color: Colors.white24),

            // Settings & Logout
            _drawerItem(Icons.settings_outlined, 'Setting', () {}),
            _drawerItem(Icons.logout, 'Logout', () => _logout(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  // ── BOTTOM NAV BAR ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.explore, 'label': 'Explore'},
      {'icon': Icons.favorite_border, 'label': 'Saved'},
      {'icon': Icons.notifications_outlined, 'label': 'Notification'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkGreen,
        border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() { _selectedNavIndex = i; }),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: selected
                          ? Colors.white
                          : Colors.white54,
                      size: selected ? 26 : 22,
                    ),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white54,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundGreen,
        title: const Text('Sign Out',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
