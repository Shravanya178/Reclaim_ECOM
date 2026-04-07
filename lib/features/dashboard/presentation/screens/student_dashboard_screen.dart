import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/impact/widgets/impact_dashboard.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  static const _stats = [
    ('12', 'Materials Donated',    Icons.recycling,             AppTheme.primaryGreen),
    ('8',  'Active Requests',      Icons.pending_actions,       Color(0xFF3182CE)),
    ('3',  'Orders Placed',        Icons.shopping_bag_outlined, Color(0xFFD69E2E)),
    ('24.5 kg', 'CO₂ Saved',      Icons.eco,                   Color(0xFF38A169)),
  ];

  static const _recentActivity = [
    ('Donated: Arduino Uno Rev3',      '2 min ago',  Icons.volunteer_activism, AppTheme.primaryGreen),
    ('Request approved: Copper Wire',  '1 hour ago', Icons.check_circle,       Color(0xFF38A169)),
    ('Order placed: LED Strip 5m',     '3 hours ago', Icons.shopping_bag_outlined, Color(0xFF3182CE)),
    ('Inventory updated: 5 items',     'Yesterday',  Icons.inventory_2_outlined, Color(0xFFD69E2E)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/student-dashboard',
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: () => context.go('/business-engine?role=customer'),
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 16, color: Colors.white)),
          const SizedBox(width: 12),
        ],
      ) : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  // ─── DESKTOP ─────────────────────────────────────────
  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      _heroSection(context),
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats row
            _statsRow(),
            const SizedBox(height: 40),
            // Main content
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Left (main content)
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _quickActions(context),
                const SizedBox(height: 32),
                const Text('My Recent Materials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _materialsGrid(context),
              ])),
              const SizedBox(width: 28),
              // Right sidebar
              SizedBox(width: 300, child: Column(children: [
                _activityFeed(),
                const SizedBox(height: 20),
                _ecoScore(),
                const SizedBox(height: 20),
                const ImpactDashboard(),
              ])),
            ]),
          ]),
        ),
      )),
      const WebFooter(),
    ]));
  }

  Widget _heroSection(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [AppTheme.primaryDark, AppTheme.primaryGreen, AppTheme.accent],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 50),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.white70),
                SizedBox(width: 6),
                Text('Good morning!', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            const SizedBox(height: 16),
            const Text('Welcome back,\nShravanya 👋', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 10),
            const Text('VESIT Mumbai · Environmental Eng.', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 28),
            Wrap(spacing: 14, runSpacing: 10, children: [
              _heroCta(context, 'Browse Shop', Icons.store_outlined, () => context.go('/shop')),
              _heroCta(context, 'My Inventory', Icons.inventory_2_outlined, () => context.go('/inventory'), outline: true),
              _heroCta(context, 'Business Engine', Icons.auto_graph_outlined, () => context.go('/business-engine?role=customer'), outline: true),
            ]),
          ])),
          const SizedBox(width: 48),
          // Profile card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24)),
            child: Column(children: [
              Container(width: 72, height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                child: const Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(height: 14),
              const Text('Shravanya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const Text('Student', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Eco Score: 840 pts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
            ]),
          ),
        ]),
      ),
    )),
  );

  Widget _heroCta(BuildContext context, String label, IconData ic, VoidCallback onTap, {bool outline = false}) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(ic, size: 16),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: outline ? Colors.transparent : Colors.white,
      foregroundColor: outline ? Colors.white : AppTheme.primaryGreen,
      elevation: 0,
      side: outline ? const BorderSide(color: Colors.white54) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _statsRow() {
    return Row(children: _stats.map((s) => Expanded(child: Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: s.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(s.$3, color: s.$4, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.$1, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.$4)),
          Text(s.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ]),
    ))).toList());
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      ('Donate Material', 'Upload surplus materials to the network', Icons.volunteer_activism, AppTheme.primaryGreen, '/capture', 'donation_intent'),
      ('Browse Shop', 'Find parts and materials you need', Icons.store_outlined, Color(0xFF3182CE), '/shop', 'shop_discovery'),
      ('Make Request', 'Request specific materials from labs', Icons.pending_actions, Color(0xFFD69E2E), '/requests', 'request_intent'),
      ('My Orders', 'Track and manage your purchases', Icons.receipt_long_outlined, Color(0xFF805AD5), '/orders', 'order_followup'),
    ];
    return Row(children: actions.map((a) => Expanded(child: GestureDetector(
      onTap: () {
        ErpCrmIntelligenceService.instance.recordAcquisitionChannel(a.$6);
        context.go(a.$5);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EFE8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(a.$3, color: a.$4, size: 22)),
          const SizedBox(height: 14),
          Text(a.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(a.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
        ]),
      ),
    ))).toList());
  }

  Widget _materialsGrid(BuildContext context) {
    const items = [
      ('Arduino Uno', 'Electronic', 'Available', AppTheme.primaryGreen),
      ('Copper Wire', 'Metal', 'Donated', Color(0xFF3182CE)),
      ('LED Strip', 'Electronic', 'In Cart', Color(0xFFD69E2E)),
      ('Flask 500ml', 'Chemical', 'Available', AppTheme.primaryGreen),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.8,
      children: items.map((it) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EFE8))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: it.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.inventory_2_outlined, color: it.$4, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(it.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: it.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(it.$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: it.$4))),
        ]),
      )).toList(),
    );
  }

  Widget _activityFeed() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18,18,18,12),
        child: Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      ..._recentActivity.map((a) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(a.$3, color: a.$4, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(a.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
        ]),
      )),
    ]),
  );

  Widget _ecoScore() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      const Icon(Icons.eco, color: Colors.white, size: 28),
      const SizedBox(height: 10),
      const Text('Eco Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
      const Text('840 pts', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      LinearProgressIndicator(value: 0.84, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation(Colors.white), borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 6),
      const Text('160 pts to Gold tier', style: TextStyle(color: Colors.white60, fontSize: 11)),
    ]),
  );

  // ─── MOBILE ───────────────────────────────────────────
  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Mobile hero
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('Shravanya', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const Text('VESIT Mumbai', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 32, color: Colors.white)),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stats 2x2
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
          children: _stats.map((s) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
            child: Row(children: [
              Icon(s.$3, color: s.$4, size: 22),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
                Text(s.$2, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.3)),
              ]),
            ]),
          )).toList()),
        const SizedBox(height: 24),
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        // 2x2 action grid
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _mobileAction(context, 'Shop', Icons.store_outlined, const Color(0xFF3182CE), '/shop'),
            _mobileAction(context, 'Donate', Icons.volunteer_activism, AppTheme.primaryGreen, '/capture'),
            _mobileAction(context, 'Requests', Icons.pending_actions, const Color(0xFFD69E2E), '/requests'),
            _mobileAction(context, 'Orders', Icons.receipt_long_outlined, const Color(0xFF805AD5), '/orders'),
          ]),
        const SizedBox(height: 24),
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        _activityFeed(),
      ])),
    ]));
  }

  Widget _mobileAction(BuildContext context, String label, IconData ic, Color col, String route) => GestureDetector(
    onTap: () => context.go(route),
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(ic, color: col, size: 22)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    ),
  );
}
