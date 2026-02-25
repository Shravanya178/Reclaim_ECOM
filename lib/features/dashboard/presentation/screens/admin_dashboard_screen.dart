import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (_isDesktop) _buildSideNav(context),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        if (!_isDesktop)
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                        Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () => context.push('/settings')),
                      ],
                    ),
                  ),
                ),
                if (!_isDesktop)
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      isScrollable: true,
                      tabs: const [Tab(text: 'Overview'), Tab(text: 'Materials'), Tab(text: 'Campus Zones'), Tab(text: 'Users')],
                    ),
                  ),
                Expanded(
                  child: _isDesktop
                      ? _buildCurrentTab()
                      : TabBarView(
                          controller: _tabController,
                          children: [_buildOverviewTab(), _buildMaterialsTab(), _buildCampusZonesTab(), _buildUsersTab()],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabController.index) {
      case 0: return _buildOverviewTab();
      case 1: return _buildMaterialsTab();
      case 2: return _buildCampusZonesTab();
      case 3: return _buildUsersTab();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary, size: 28),
                SizedBox(width: 8),
                Text('Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(context, Icons.dashboard_outlined, 'Overview', _tabController.index == 0, () => setState(() => _tabController.index = 0)),
                _buildNavItem(context, Icons.inventory_2_outlined, 'Materials', _tabController.index == 1, () => setState(() => _tabController.index = 1)),
                _buildNavItem(context, Icons.location_on_outlined, 'Campus Zones', _tabController.index == 2, () => setState(() => _tabController.index = 2)),
                _buildNavItem(context, Icons.people_outlined, 'Users', _tabController.index == 3, () => setState(() => _tabController.index = 3)),
                Divider(height: 24, indent: 16, endIndent: 16),
                _buildNavItem(context, Icons.assessment_outlined, 'Impact Reports', false, () => context.push('/impact')),
                _buildNavItem(context, Icons.settings_outlined, 'Settings', false, () => context.push('/settings')),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/role-selection'),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8)),
                child: Text('Change Role', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Material(
      color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade700),
              SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 13, color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade700, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isDesktop ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Stats Cards - 2x2 on desktop row
              if (_isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Users', '234', Icons.people, Colors.blue, '+12 this week')),
                    SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Active Materials', '89', Icons.inventory_2, Colors.green, '+23 captured')),
                    SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Total CO₂ Saved', '156.8 kg', Icons.eco, Colors.teal, '+8.5kg this month')),
                    SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Active Projects', '45', Icons.rocket_launch, Colors.orange, '12 completed')),
                  ],
                )
              else ...[
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Users', '234', Icons.people, Colors.blue, '+12 this week')),
                    SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Active Materials', '89', Icons.inventory_2, Colors.green, '+23 captured')),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total CO₂ Saved', '156.8 kg', Icons.eco, Colors.teal, '+8.5kg this month')),
                    SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Active Projects', '45', Icons.rocket_launch, Colors.orange, '12 completed')),
                  ],
                ),
              ],
              SizedBox(height: 24),
              
              // Quick Actions & Recent Activity - side by side on desktop
              if (_isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildQuickActionsCard()),
                    SizedBox(width: 16),
                    Expanded(child: _buildRecentActivityCard()),
                  ],
                )
              else ...[
                _buildQuickActionsCard(),
                SizedBox(height: 16),
                _buildRecentActivityCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip('Add Material Category', Icons.add_circle_outline),
              _buildActionChip('Configure Carbon Factors', Icons.tune),
              _buildActionChip('Manage Campus Zones', Icons.location_on),
              _buildActionChip('User Reports', Icons.assessment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 12),
          _buildActivityItem('New user registered', 'Rahul Sharma - Computer Engg', '5 min ago', Icons.person_add, Colors.blue),
          _buildActivityItem('Material captured', 'Arduino boards in Lab A', '15 min ago', Icons.camera_alt, Colors.green),
          _buildActivityItem('Opportunity matched', 'Copper wires → Home Automation', '1 hour ago', Icons.handshake, Colors.purple),
          _buildActivityItem('Carbon milestone', 'Campus reached 150kg CO₂ saved', '2 hours ago', Icons.emoji_events, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    final categories = [
      {'name': 'Electronic', 'count': 34, 'factor': 2.5, 'color': Colors.orange},
      {'name': 'Metal', 'count': 23, 'factor': 1.8, 'color': Colors.grey},
      {'name': 'Plastic', 'count': 18, 'factor': 3.2, 'color': Colors.blue},
      {'name': 'Glass', 'count': 12, 'factor': 0.8, 'color': Colors.cyan},
      {'name': 'Chemical', 'count': 8, 'factor': 4.5, 'color': Colors.purple},
      {'name': 'Wood', 'count': 5, 'factor': 0.5, 'color': Colors.brown},
    ];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isDesktop ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: _isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Material Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                                IconButton(icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary), onPressed: () => _showAddCategoryDialog()),
                              ],
                            ),
                            SizedBox(height: 12),
                            ...categories.map((cat) => _buildCategoryItem(cat['name'] as String, cat['count'] as int, cat['factor'] as double, cat['color'] as Color)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Carbon Factors (kg CO₂/unit)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            SizedBox(height: 8),
                            Text('Adjust the environmental impact calculation for each material type', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            SizedBox(height: 16),
                            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune), label: const Text('Configure Carbon Factors')),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Material Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                              IconButton(icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary), onPressed: () => _showAddCategoryDialog()),
                            ],
                          ),
                          SizedBox(height: 12),
                          ...categories.map((cat) => _buildCategoryItem(cat['name'] as String, cat['count'] as int, cat['factor'] as double, cat['color'] as Color)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Carbon Factors (kg CO₂/unit)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          SizedBox(height: 8),
                          Text('Adjust the environmental impact calculation for each material type', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          SizedBox(height: 16),
                          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune), label: const Text('Configure Carbon Factors')),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCampusZonesTab() {
    final zones = [
      {'name': 'Lab A - Chemistry', 'building': 'Science Block', 'materials': 12, 'active': true},
      {'name': 'Lab B - Electronics', 'building': 'Engineering Block', 'materials': 18, 'active': true},
      {'name': 'Lab C - Mechanical', 'building': 'Engineering Block', 'materials': 8, 'active': true},
      {'name': 'Workshop', 'building': 'Main Building', 'materials': 15, 'active': true},
      {'name': 'Storage Room A', 'building': 'Admin Block', 'materials': 5, 'active': false},
    ];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isDesktop ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Campus Zones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  ElevatedButton.icon(onPressed: () => _showAddZoneDialog(), icon: const Icon(Icons.add), label: const Text('Add Zone')),
                ],
              ),
              SizedBox(height: 16),
              ...zones.map((zone) => Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: (zone['active'] as bool) ? Colors.green.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.location_on, color: (zone['active'] as bool) ? Colors.green : Colors.grey),
                  ),
                  title: Text(zone['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                  subtitle: Text('${zone['building']} • ${zone['materials']} materials'),
                  trailing: Switch.adaptive(value: zone['active'] as bool, onChanged: (v) {}),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    final users = [
      {'name': 'Rahul Sharma', 'role': 'Student', 'department': 'Computer Engg', 'status': 'Active'},
      {'name': 'Dr. Sharma', 'role': 'Lab Admin', 'department': 'Chemistry', 'status': 'Active'},
      {'name': 'Priya Patel', 'role': 'Student', 'department': 'Electronics', 'status': 'Active'},
      {'name': 'Prof. Singh', 'role': 'Lab Admin', 'department': 'Mechanical', 'status': 'Active'},
      {'name': 'Amit Kumar', 'role': 'Student', 'department': 'IT', 'status': 'Suspended'},
    ];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isDesktop ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ...users.map((user) => Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text((user['name'] as String).split(' ').map((n) => n[0]).join(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
                  title: Text(user['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                  subtitle: Text('${user['role']} • ${user['department']}'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: user['status'] == 'Active' ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(user['status'] as String, style: TextStyle(color: user['status'] == 'Active' ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  onTap: () {},
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.green.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: () {},
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, int count, double factor, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(width: 8, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)), Text('$count items • ${factor}kg CO₂/unit', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
          IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Material Category'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Carbon Factor (kg CO₂/unit)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add'))],
      ),
    );
  }

  void _showAddZoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Campus Zone'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: InputDecoration(labelText: 'Zone Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Building', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add'))],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.admin_panel_settings, color: Colors.grey.shade700, size: 28),
                ),
                SizedBox(height: 12),
                Text('Admin Panel', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('VESIT Mumbai', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: Colors.grey.shade800),
            title: Text('Overview', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 0); },
          ),
          ListTile(
            leading: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade800),
            title: Text('Materials', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 1); },
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined, color: Colors.grey.shade800),
            title: Text('Campus Zones', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 2); },
          ),
          ListTile(
            leading: Icon(Icons.people_outlined, color: Colors.grey.shade800),
            title: Text('Users', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); setState(() => _tabController.index = 3); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.assessment_outlined, color: Colors.grey.shade800),
            title: Text('Impact Reports', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/impact'); },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Colors.grey.shade800),
            title: Text('Settings', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/settings'); },
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/student-dashboard'); },
                    icon: Icon(Icons.person, size: 14),
                    label: Text('Student', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/lab-dashboard'); },
                    icon: Icon(Icons.science, size: 14),
                    label: Text('Lab', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6)),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.grey.shade800),
            title: Text('Change Role', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.go('/role-selection'); },
          ),
        ],
      ),
    );
  }
}