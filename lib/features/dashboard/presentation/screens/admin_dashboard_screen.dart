import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/dashboard/widgets/most_requested_materials_chart.dart';
import 'package:reclaim/features/dashboard/widgets/supply_demand_table.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────
class _Stat {
  final String label, value, change;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.change, this.icon, this.color);
}

class _Material {
  final String id, name, category, lab, status;
  final double qty;
  const _Material(this.id, this.name, this.category, this.lab, this.qty, this.status);
}

class _User {
  final String name, email, role, joined;
  final bool active;
  const _User(this.name, this.email, this.role, this.joined, this.active);
}

class _Zone {
  final String name, building, contact;
  final int items;
  final String status;
  const _Zone(this.name, this.building, this.contact, this.items, this.status);
}

// ─── Main Screen ─────────────────────────────────────────────────────────────
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  String _materialSearch = '';
  String _userSearch = '';

  static const _stats = [
    _Stat('Total Materials', '3,420', '+12%', Icons.inventory_2_outlined, Color(0xFF2D6A4F)),
    _Stat('Active Users', '284', '+8%', Icons.people_outline, Color(0xFF1565C0)),
    _Stat('CO₂ Saved (kg)', '18,750', '+22%', Icons.eco_outlined, Color(0xFF2E7D32)),
    _Stat('Pending Requests', '47', '-5%', Icons.assignment_outlined, Color(0xFFE65100)),
  ];

  static final _materials = [
    const _Material('MAT-001', 'Borosilicate Glassware', 'Lab Glass', 'Chemistry A', 120, 'Available'),
    const _Material('MAT-002', 'Analytical Balance', 'Equipment', 'Physics B', 3, 'In Use'),
    const _Material('MAT-003', 'Ethanol 99.9%', 'Chemicals', 'Bio Lab', 50, 'Low Stock'),
    const _Material('MAT-004', 'Micropipette Set', 'Equipment', 'Biology A', 8, 'Available'),
    const _Material('MAT-005', 'Magnetic Stirrer', 'Equipment', 'Chemistry B', 5, 'Available'),
    const _Material('MAT-006', 'Distilled Water', 'Chemicals', 'Central Store', 200, 'Available'),
    const _Material('MAT-007', 'Arduino Mega', 'Electronics', 'ECE Lab', 15, 'In Use'),
    const _Material('MAT-008', 'Centrifuge Tubes', 'Lab Glass', 'Biology B', 400, 'Available'),
  ];

  static final _users = [
    const _User('Dr. Meera Patel', 'meera@vesit.edu', 'Lab Admin', 'Jan 2024', true),
    const _User('Shravanya R.', 'shravanya@student.vesit.edu', 'Student', 'Aug 2023', true),
    const _User('Prof. Arvind Nair', 'arvind@vesit.edu', 'Lab Admin', 'Mar 2022', true),
    const _User('Rohan Sharma', 'rohan@student.vesit.edu', 'Student', 'Aug 2024', true),
    const _User('Dr. Priya Singh', 'priya@vesit.edu', 'Lab Admin', 'Nov 2021', false),
    const _User('Ananya Desai', 'ananya@student.vesit.edu', 'Student', 'Aug 2024', true),
  ];

  static final _zones = [
    const _Zone('Lab A – Chemistry', 'Science Block', 'Dr. Meera Patel', 320, 'Active'),
    const _Zone('Lab B – Physics', 'Tech Block', 'Prof. Arvind Nair', 180, 'Active'),
    const _Zone('Lab C – Biology', 'Science Block', 'Dr. Priya Singh', 210, 'Maintenance'),
    const _Zone('ECE Lab', 'Engineering Block', 'Prof. Ramesh Kumar', 145, 'Active'),
    const _Zone('Central Store', 'Admin Block', 'Mr. Suresh', 865, 'Active'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/admin-dashboard',
      cartItemCount: 0,
      mobileAppBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(isMobile),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              _OverviewTab(stats: _stats, materials: _materials, zones: _zones, isMobile: isMobile),
              _MaterialsTab(materials: _materials, search: _materialSearch,
                onSearch: (v) => setState(() => _materialSearch = v)),
              _ZonesTab(zones: _zones, isMobile: isMobile),
              _UsersTab(users: _users, search: _userSearch,
                onSearch: (v) => setState(() => _userSearch = v)),
              const _AnalyticsTab(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isMobile) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: TabBar(
      controller: _tab,
      labelColor: AppTheme.primaryGreen,
      unselectedLabelColor: AppTheme.textSecondary,
      indicatorColor: AppTheme.primaryGreen,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      isScrollable: isMobile,
      tabs: const [
        Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Overview'),
        Tab(icon: Icon(Icons.inventory_outlined, size: 18), text: 'Materials'),
        Tab(icon: Icon(Icons.location_city_outlined, size: 18), text: 'Zones'),
        Tab(icon: Icon(Icons.people_outlined, size: 18), text: 'Users'),
        Tab(icon: Icon(Icons.bar_chart_outlined, size: 18), text: 'Analytics'),
      ],
    ),
  );
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final List<_Stat> stats;
  final List<_Material> materials;
  final List<_Zone> zones;
  final bool isMobile;
  const _OverviewTab({required this.stats, required this.materials, required this.zones, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = AppTheme.pagePadding(w);
    return SingleChildScrollView(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Platform Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('VESIT Mumbai – Circular Economy Platform', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(10)),
                child: const Row(children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Add Material', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
            ]),
            const SizedBox(height: 24),
            // Stats Grid
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.4 : 1.6,
              children: stats.map((s) => _StatCard(s)).toList(),
            ),
            const SizedBox(height: 28),
            // Two-col content
            if (isMobile) ...[
              _recentMaterials(context),
              const SizedBox(height: 20),
              _zonesPanel(context),
              const SizedBox(height: 20),
              _activityFeed(context),
            ] else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: Column(children: [
                _recentMaterials(context),
                const SizedBox(height: 20),
                _zonesPanel(context),
              ])),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _activityFeed(context)),
            ]),
            const SizedBox(height: 32),
            WebFooter(),
          ]),
        ),
      ),
    );
  }

  Widget _recentMaterials(BuildContext context) => _SectionCard(
    title: 'Recent Material Activity',
    icon: Icons.inventory_2_outlined,
    child: Column(
      children: materials.take(5).map((m) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(
            color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.science_outlined, color: AppTheme.primaryGreen, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
            Text('${m.category} · ${m.lab}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${m.qty} units', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
            _StatusBadge(m.status),
          ]),
        ]),
      )).toList(),
    ),
  );

  Widget _zonesPanel(BuildContext context) => _SectionCard(
    title: 'Campus Zones',
    icon: Icons.location_city_outlined,
    child: Column(
      children: zones.map((z) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(
            gradient: LinearGradient(colors: z.status == 'Active'
              ? [AppTheme.primaryGreen, AppTheme.primaryLight]
              : [Colors.orange.shade300, Colors.orange.shade500]),
            borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(z.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
            Text(z.building, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${z.items} items', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
            _StatusBadge(z.status),
          ]),
        ]),
      )).toList(),
    ),
  );

  Widget _activityFeed(BuildContext context) => _SectionCard(
    title: 'Recent Activity',
    icon: Icons.timeline_outlined,
    child: Column(children: [
      _activityItem(Icons.add_circle_outline, AppTheme.primaryGreen, 'New material listed', 'Lab A – x40 beakers', '5 min ago'),
      _activityItem(Icons.swap_horiz, Colors.blue, 'Transfer completed', 'ECE Lab → Bio Lab', '32 min ago'),
      _activityItem(Icons.warning_amber_outlined, Colors.orange, 'Low stock alert', 'Ethanol 99.9% – 50L left', '1 hr ago'),
      _activityItem(Icons.person_add_outlined, AppTheme.primaryGreen, 'New user joined', 'Ananya Desai – Student', '3 hr ago'),
      _activityItem(Icons.inventory_outlined, Colors.purple, 'Audit completed', 'Central Store verified', '5 hr ago'),
      _activityItem(Icons.eco, AppTheme.primaryGreen, 'Impact milestone', '18,750 kg CO₂ saved!', '1 day ago'),
    ]),
  );

  Widget _activityItem(IconData icon, Color color, String title, String sub, String time) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimary)),
        Text(sub, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ])),
      Text(time, style: TextStyle(fontSize: 10, color: AppTheme.textHint)),
    ]));
}

// ─── Materials Tab ─────────────────────────────────────────────────────────────
class _MaterialsTab extends StatelessWidget {
  final List<_Material> materials;
  final String search;
  final ValueChanged<String> onSearch;
  const _MaterialsTab({required this.materials, required this.search, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = AppTheme.pagePadding(w);
    final filtered = search.isEmpty ? materials
      : materials.where((m) => m.name.toLowerCase().contains(search.toLowerCase()) ||
          m.category.toLowerCase().contains(search.toLowerCase())).toList();
    return SingleChildScrollView(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
          child: _SectionCard(
            title: 'Materials Inventory',
            icon: Icons.inventory_outlined,
            headerTrailing: SizedBox(width: 280, height: 40,
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search materials…',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true, fillColor: const Color(0xFFF5F9F6),
                  isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              )),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.primarySurface),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary),
                dataRowColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppTheme.primarySurface : Colors.white),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Lab / Zone')),
                  DataColumn(label: Text('Qty'), numeric: true),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((m) => DataRow(cells: [
                  DataCell(Text(m.id, style: TextStyle(color: AppTheme.textHint, fontSize: 12))),
                  DataCell(Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  DataCell(Text(m.category, style: const TextStyle(fontSize: 13))),
                  DataCell(Text(m.lab, style: const TextStyle(fontSize: 13))),
                  DataCell(Text('${m.qty}', style: const TextStyle(fontSize: 13))),
                  DataCell(_StatusBadge(m.status)),
                  DataCell(Row(children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppTheme.primaryGreen),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () {}, color: Colors.red.shade400),
                  ])),
                ])).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Zones Tab ─────────────────────────────────────────────────────────────────
class _ZonesTab extends StatelessWidget {
  final List<_Zone> zones;
  final bool isMobile;
  const _ZonesTab({required this.zones, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = AppTheme.pagePadding(w);
    return SingleChildScrollView(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Campus Zones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(10)),
                child: const Row(children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Add Zone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.2 : 2.8,
              ),
              itemCount: zones.length,
              itemBuilder: (_, i) => _ZoneCard(zones[i]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final _Zone zone;
  const _ZoneCard(this.zone);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(width: 52, height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: zone.status == 'Active'
              ? [AppTheme.primaryGreen, AppTheme.primaryLight]
              : [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.location_city, color: Colors.white, size: 26)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
        const SizedBox(height: 3),
        Text(zone.building, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 3),
        Text('Contact: ${zone.contact}', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${zone.items}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
        Text('items', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        _StatusBadge(zone.status),
      ]),
    ]),
  );
}

// ─── Users Tab ─────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final List<_User> users;
  final String search;
  final ValueChanged<String> onSearch;
  const _UsersTab({required this.users, required this.search, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = AppTheme.pagePadding(w);
    final filtered = search.isEmpty ? users
      : users.where((u) => u.name.toLowerCase().contains(search.toLowerCase()) ||
          u.email.toLowerCase().contains(search.toLowerCase())).toList();
    return SingleChildScrollView(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
          child: _SectionCard(
            title: 'User Management',
            icon: Icons.people_outlined,
            headerTrailing: SizedBox(width: 280, height: 40,
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search users…',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true, fillColor: const Color(0xFFF5F9F6),
                  isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              )),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.primarySurface),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary),
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Joined')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((u) => DataRow(cells: [
                  DataCell(Row(children: [
                    CircleAvatar(radius: 16,
                      backgroundColor: AppTheme.primarySurface,
                      child: Text(u.name[0], style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13))),
                    const SizedBox(width: 10),
                    Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ])),
                  DataCell(Text(u.email, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: u.role == 'Lab Admin' ? const Color(0xFFE8F4FD) : AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(u.role, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: u.role == 'Lab Admin' ? const Color(0xFF1565C0) : AppTheme.primaryGreen)))),
                  DataCell(Text(u.joined, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: u.active ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(u.active ? 'Active' : 'Inactive', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: u.active ? const Color(0xFF2E7D32) : Colors.orange.shade700)))),
                  DataCell(Row(children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppTheme.primaryGreen),
                    IconButton(icon: Icon(u.active ? Icons.block : Icons.check_circle_outline, size: 16),
                      onPressed: () {}, color: u.active ? Colors.orange : AppTheme.primaryGreen),
                  ])),
                ])).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard(this.stat);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(
          color: stat.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(stat.icon, color: stat.color, size: 20)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: stat.change.startsWith('+') ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20)),
          child: Text(stat.change, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: stat.change.startsWith('+') ? const Color(0xFF2E7D32) : Colors.orange.shade700))),
      ]),
      const SizedBox(height: 8),
      Text(stat.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: stat.color)),
      Text(stat.label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? headerTrailing;
  const _SectionCard({required this.title, required this.icon, required this.child, this.headerTrailing});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
        child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(
            color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          if (headerTrailing != null) headerTrailing!,
        ]),
      ),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), child: child),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  Color get _bg => switch (status) {
    'Available' || 'Active' => const Color(0xFFE8F5E9),
    'In Use' => const Color(0xFFE8F4FD),
    'Low Stock' || 'Maintenance' => const Color(0xFFFFF3E0),
    _ => const Color(0xFFF5F5F5),
  };
  Color get _fg => switch (status) {
    'Available' || 'Active' => const Color(0xFF2E7D32),
    'In Use' => const Color(0xFF1565C0),
    'Low Stock' || 'Maintenance' => Colors.orange,
    _ => Colors.grey,
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _fg)),
  );
}


// ─── Analytics Tab ────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = Breakpoints.isMobile(context);

    return SingleChildScrollView(
      padding: AppTheme.pagePadding(w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section header
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart, color: AppTheme.primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Analytics & Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text('Material demand trends and supply gap analysis',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ]),
          const Spacer(),
          // Export button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Export Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        const SizedBox(height: 28),

        // Quick stats row
        isMobile
            ? Column(children: _analyticsStats().map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12), child: w)).toList())
            : Row(children: _analyticsStats()
                .asMap().entries.map((e) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: e.key < 3 ? 16 : 0),
                    child: e.value,
                  ),
                )).toList()),
        const SizedBox(height: 28),

        // Chart + Table
        isMobile
            ? const Column(children: [
                MostRequestedMaterialsChart(),
                SizedBox(height: 20),
                SupplyDemandTable(),
              ])
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: MostRequestedMaterialsChart()),
                  SizedBox(width: 24),
                  Expanded(child: SupplyDemandTable()),
                ],
              ),
        const SizedBox(height: 28),

        // Trend summary
        _trendSummary(),
        const SizedBox(height: 20),
      ]),
    );
  }

  List<Widget> _analyticsStats() {
    final items = [
      ('Total Requests', '156', '+18%', Icons.trending_up, AppTheme.primaryGreen),
      ('Avg Supply Ratio', '74%', '-3%', Icons.inventory_2_outlined, AppTheme.info),
      ('Critical Items', '2', '+1', Icons.warning_amber_outlined, AppTheme.error),
      ('Surplus Items', '3', '+2', Icons.check_circle_outline, AppTheme.success),
    ];
    return items.map((s) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: s.$5.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(s.$4, color: s.$5, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.$1, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Row(children: [
            Text(s.$2, style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: s.$5)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: s.$3.startsWith('+') && !s.$3.contains('-')
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(s.$3, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: s.$3.startsWith('+') && !s.$3.contains('-')
                      ? AppTheme.success : AppTheme.error)),
            ),
          ]),
        ])),
      ]),
    )).toList();
  }

  Widget _trendSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.insights, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text('Key Insights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _insightChip('⚠️ Metal Alloys critically low — restock needed', AppTheme.error),
          _insightChip('✅ Electronic Components well stocked (surplus)', AppTheme.success),
          _insightChip('📈 Plastic demand up 20% this month', AppTheme.warning),
          _insightChip('🔄 Chemical Reagents perfectly balanced', AppTheme.info),
        ]),
      ]),
    );
  }

  Widget _insightChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
    );
  }
}
