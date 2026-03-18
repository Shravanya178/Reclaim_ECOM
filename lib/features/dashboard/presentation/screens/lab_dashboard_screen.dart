import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class LabDashboardScreen extends ConsumerWidget {
  const LabDashboardScreen({super.key});

  static const _stats = [
    ('34', 'Total Materials',  Icons.inventory_2_outlined, AppTheme.primaryGreen),
    ('12', 'Donated This Month', Icons.volunteer_activism, Color(0xFF38A169)),
    ('8',  'Pending Requests', Icons.pending_actions,     Color(0xFF3182CE)),
    ('6.2 kg', 'CO₂ Saved',   Icons.eco,                 Color(0xFFD69E2E)),
  ];

  static const _inventory = [
    ('Arduino Uno Rev3', 'Electronic', 5,  'Available'),
    ('Copper Wire 1kg',  'Metal',      3,  'Low Stock'),
    ('LED Strip 5m',     'Electronic', 12, 'Available'),
    ('Glass Flask 500ml','Chemical',   20, 'Available'),
    ('Steel Rod 1m',     'Metal',      2,  'Critical'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/lab-dashboard',
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Lab Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ) : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      // Hero
      Container(width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen, AppTheme.accent],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 52), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.science_outlined, size: 14, color: Colors.white70),
                  SizedBox(width: 6),
                  Text('Laboratory', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
              const SizedBox(height: 16),
              const Text('Lab A – Chemistry', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 6),
              const Text('VESIT Mumbai • Building 3, Floor 2', style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 28),
              Row(children: [
                _heroCta(context, 'AI Capture', Icons.camera_alt_outlined, () => context.go('/capture'), false),
                const SizedBox(width: 14),
                _heroCta(context, 'Inventory', Icons.inventory_2_outlined, () => context.go('/inventory'), true),
                const SizedBox(width: 14),
                _heroCta(context, 'Opportunities', Icons.explore_outlined, () => context.go('/opportunities'), true),
              ]),
            ])),
            const SizedBox(width: 48),
            // Lab badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24)),
              child: Column(children: [
                Container(width: 72, height: 72,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.science, size: 40, color: Colors.white)),
                const SizedBox(height: 14),
                const Text('Dr. Meera Patel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const Text('Lab In-charge', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Active Lab', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
              ]),
            ),
          ]))))),
      // Content
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40), child: Column(children: [
          _statsRow(),
          const SizedBox(height: 36),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 16),
              _actionsGrid(context),
              const SizedBox(height: 32),
              _sectionTitle('Inventory Overview'),
              const SizedBox(height: 16),
              _inventoryTable(),
            ])),
            const SizedBox(width: 28),
            SizedBox(width: 296, child: Column(children: [
              _requestsPanel(),
              const SizedBox(height: 20),
              _ecoPanel(),
            ])),
          ]),
        ])),
      )),
      const WebFooter(),
    ]));
  }

  Widget _heroCta(BuildContext context, String label, IconData ic, VoidCallback onTap, bool outline) =>
    ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(ic, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: outline ? Colors.transparent : Colors.white,
        foregroundColor: outline ? Colors.white : AppTheme.primaryGreen,
        elevation: 0,
        side: outline ? const BorderSide(color: Colors.white54) : null,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800));

  Widget _statsRow() => Row(children: _stats.map((s) => Expanded(child: Container(
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

  Widget _actionsGrid(BuildContext context) {
    const acts = [
      ('AI Photo Capture', 'Scan & classify surplus', Icons.camera_alt_outlined,  AppTheme.primaryGreen, '/capture'),
      ('Browse Requests',  'See what students need',  Icons.search,                Color(0xFF3182CE), '/requests'),
      ('SCM Analytics',    'Supply chain insights',    Icons.hub_outlined,          Color(0xFFD69E2E), '/scm-dashboard'),
      ('View Opportunities','Discover matches',         Icons.explore_outlined,     Color(0xFF805AD5), '/opportunities'),
    ];
    return Row(children: acts.map((a) => Expanded(child: GestureDetector(
      onTap: () => context.go(a.$5),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EFE8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(a.$3, color: a.$4, size: 22)),
          const SizedBox(height: 14),
          Text(a.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 3),
          Text(a.$2, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.4)),
        ]),
      ),
    ))).toList());
  }

  Widget _inventoryTable() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
    child: Column(children: [
      // Header
      Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(color: Color(0xFFF7FAF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
        child: const Row(children: [
          Expanded(flex: 3, child: Text('MATERIAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 1, child: Text('QTY',      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('STATUS',   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8))),
        ])),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      ..._inventory.map((item) {
        Color sc; switch (item.$4) {
          case 'Available': sc = AppTheme.primaryGreen; break;
          case 'Low Stock': sc = const Color(0xFFD69E2E); break;
          default:           sc = Colors.redAccent;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F5F1)))),
          child: Row(children: [
            Expanded(flex: 3, child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            Expanded(flex: 2, child: Text(item.$2, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
            Expanded(flex: 1, child: Text('${item.$3}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(item.$4, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sc)))),
          ]),
        );
      }),
    ]),
  );

  Widget _requestsPanel() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18,18,18,12),
        child: Text('Pending Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      for (final r in [('Copper Wire 2m', 'Shravanya R.'), ('LED Bulb x5', 'Arjun M.'), ('Glass Flask', 'Priya K.')])
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3182CE))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(r.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 28)),
            child: const Text('Review', style: TextStyle(fontSize: 12))),
        ])),
    ]),
  );

  Widget _ecoPanel() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      const Icon(Icons.eco, color: Colors.white, size: 26),
      const SizedBox(height: 10),
      const Text('Lab Eco Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
      const Text('920 pts', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      LinearProgressIndicator(value: 0.92, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation(Colors.white), borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 8),
      const Text('Top 5% of all labs!', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );

  // ─── MOBILE ───────────────────────────────────────────
  Widget _mobile(BuildContext context) => SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Lab A – Chemistry', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const Text('VESIT Mumbai', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ])),
        const Icon(Icons.science, color: Colors.white60, size: 36),
      ])),
    Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
        children: _stats.map((s) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
          child: Row(children: [
            Icon(s.$3, color: s.$4, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
              Text(s.$2, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, height: 1.3)),
            ])),
          ]),
        )).toList()),
      const SizedBox(height: 24),
      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
        children: [
          _mobileAction(context, 'AI Capture', Icons.camera_alt_outlined, AppTheme.primaryGreen, '/capture'),
          _mobileAction(context, 'Inventory', Icons.inventory_2_outlined, const Color(0xFF3182CE), '/inventory'),
          _mobileAction(context, 'SCM Analytics', Icons.hub_outlined, const Color(0xFFD69E2E), '/scm-dashboard'),
          _mobileAction(context, 'Opportunities', Icons.explore_outlined, const Color(0xFF805AD5), '/opportunities'),
        ]),
      const SizedBox(height: 24),
      _requestsPanel(),
    ])),
  ]));

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
