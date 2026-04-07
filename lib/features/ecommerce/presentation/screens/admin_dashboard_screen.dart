import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  static const _kStats = [
    ('Rs.18,430', 'Total Revenue',    Icons.payments_outlined,     AppTheme.primaryGreen),
    ('47',        'Active Listings',  Icons.inventory_2_outlined,  Color(0xFF3182CE)),
    ('12',        'Pending Orders',   Icons.pending_actions,       Color(0xFFD69E2E)),
    ('89%',       'Fulfillment Rate', Icons.verified_outlined,     Color(0xFF38A169)),
  ];

  static const _recentOrders = [
    ('ORD-1029', 'Shravanya R.',  'Arduino Uno', 449.0,  'Delivered'),
    ('ORD-1028', 'Priya K.',      'Copper Wire', 299.0,  'In Transit'),
    ('ORD-1027', 'Arjun M.',      'LED Strip',   399.0,  'Processing'),
    ('ORD-1026', 'Sneha T.',      'Flask 500ml',  89.0,  'Delivered'),
    ('ORD-1025', 'Vikram J.',     'ESP32 Board', 299.0,  'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/ecom-admin',
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w700)),
      ) : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      // Header
      Container(width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('E-Commerce Admin', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Manage listings, orders and seller activity', style: TextStyle(color: Colors.white60, fontSize: 14)),
            ])),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ])),
        ))),
      // Content
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40), child: Column(children: [
          _statsGrid(),
          const SizedBox(height: 40),
          // Tabs
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EFE8)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
            child: Column(children: [
              TabBar(
                controller: _tab,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                indicatorColor: AppTheme.primaryGreen,
                indicatorWeight: 3,
                tabs: const [Tab(text: 'Recent Orders'), Tab(text: 'Listings'), Tab(text: 'Sellers'), Tab(text: 'Analytics')],
              ),
              const Divider(height: 1, color: Color(0xFFEAF1EB)),
              SizedBox(height: 500, child: TabBarView(controller: _tab, children: [
                _ordersTable(),
                _listingsTab(),
                _sellersTab(),
                _analyticsTab(),
              ])),
            ]),
          ),
        ])),
      )),
      const WebFooter(),
    ]));
  }

  Widget _statsGrid() => Row(children: _kStats.map((s) => Expanded(child: Container(
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(color: s.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(s.$3, color: s.$4, size: 22)),
      const SizedBox(height: 14),
      Text(s.$1, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: s.$4)),
      Text(s.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]),
  ))).toList());

  Widget _ordersTable() => Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Table header
    Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFF7FAF8), borderRadius: BorderRadius.all(Radius.circular(8))),
      child: const Row(children: [
        Expanded(flex: 2, child: Text('ORDER',    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        Expanded(flex: 2, child: Text('BUYER',    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        Expanded(flex: 3, child: Text('ITEM',     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        Expanded(flex: 2, child: Text('AMOUNT',   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        Expanded(flex: 2, child: Text('STATUS',   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        SizedBox(width: 60),
      ])),
    const SizedBox(height: 8),
    ..._recentOrders.map((o) => _orderRow(o)),
  ]));

  Widget _orderRow(dynamic o) {
    final status = o.$5 as String;
    Color sc; IconData si;
    switch (status) {
      case 'Delivered':  sc = const Color(0xFF38A169); si = Icons.check_circle; break;
      case 'In Transit': sc = const Color(0xFF3182CE); si = Icons.local_shipping; break;
      case 'Processing': sc = const Color(0xFFD69E2E); si = Icons.hourglass_top; break;
      default:            sc = Colors.redAccent; si = Icons.cancel;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F5F1))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(o.$1 as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryGreen))),
        Expanded(flex: 2, child: Text(o.$2 as String, style: const TextStyle(fontSize: 13))),
        Expanded(flex: 3, child: Text(o.$3 as String, style: const TextStyle(fontSize: 13))),
        Expanded(flex: 2, child: Text('Rs.${(o.$4 as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(si, size: 12, color: sc),
            const SizedBox(width: 4),
            Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sc)),
          ]))),
        SizedBox(width: 60, child: TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(fontSize: 12)))),
      ]),
    );
  }

  Widget _listingsTab() => const Padding(padding: EdgeInsets.all(40), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primaryGreen),
    SizedBox(height: 16),
    Text('Listings management coming soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  ])));

  Widget _sellersTab() => const Padding(padding: EdgeInsets.all(40), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.people_outline, size: 48, color: AppTheme.primaryGreen),
    SizedBox(height: 16),
    Text('Seller management coming soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  ])));

  Widget _analyticsTab() => const Padding(padding: EdgeInsets.all(40), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.bar_chart, size: 48, color: AppTheme.primaryGreen),
    SizedBox(height: 16),
    Text('Analytics dashboard coming soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  ])));

  Widget _mobile(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('E-Commerce Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    const SizedBox(height: 20),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
      children: _kStats.map((s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(s.$3, color: s.$4, size: 22),
          const SizedBox(height: 8),
          Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
          Text(s.$2, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ]),
      )).toList()),
    const SizedBox(height: 24),
    const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    const SizedBox(height: 12),
    ..._recentOrders.map((o) => _mobileOrderCard(o)),
  ]);

  Widget _mobileOrderCard(dynamic o) {
    final status = o.$5 as String;
    Color sc; switch (status) {
      case 'Delivered':  sc = const Color(0xFF38A169); break;
      case 'In Transit': sc = const Color(0xFF3182CE); break;
      case 'Processing': sc = const Color(0xFFD69E2E); break;
      default:            sc = Colors.redAccent;
    }
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(o.$1 as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryGreen)),
          Text('${o.$2} · ${o.$3}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Rs.${(o.$4 as double).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sc))),
        ]),
      ]),
    );
  }
}
