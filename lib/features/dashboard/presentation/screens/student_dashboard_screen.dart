import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          // Desktop side navigation
          if (_isDesktop) _buildSideNav(context),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
                        Text('ReClaim', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: Badge(smallSize: 8, child: const Icon(Icons.notifications_outlined, color: Colors.white)),
                          onPressed: () => context.push('/notifications'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(_isDesktop ? 24 : 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(_isDesktop ? 24 : 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: _isDesktop ? 28 : 24,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Welcome back, Shravanya!', style: TextStyle(color: Colors.white, fontSize: _isDesktop ? 20 : 18, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text('VESIT Mumbai • Information Technology', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                                        SizedBox(height: 8),
                                        Text('Discover materials and build sustainably', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Stats & Actions - side by side on desktop
                            if (_isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildStatsSection(context)),
                                  SizedBox(width: 24),
                                  Expanded(child: _buildActionsSection(context)),
                                ],
                              )
                            else ...[
                              _buildStatsSection(context),
                              SizedBox(height: 24),
                              _buildActionsSection(context),
                            ],
                            
                            SizedBox(height: 24),
                            
                            // Materials & Activity - side by side on desktop
                            if (_isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _buildMaterialsSection(context)),
                                  SizedBox(width: 24),
                                  Expanded(flex: 2, child: _buildActivitySection(context)),
                                ],
                              )
                            else ...[
                              _buildMaterialsSection(context),
                              SizedBox(height: 24),
                              _buildActivitySection(context),
                            ],
                            
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Materials', '12', Icons.inventory_2_outlined, Colors.blue)),
            SizedBox(width: 10),
            Expanded(child: _buildStatCard(context, 'CO₂ Saved', '4.2kg', Icons.eco_outlined, Colors.green)),
            SizedBox(width: 10),
            Expanded(child: _buildStatCard(context, 'Projects', '3', Icons.rocket_launch_outlined, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Discover', 'Find materials', Icons.map_outlined, Colors.blue, () => context.push('/student-dashboard/discovery'))),
            SizedBox(width: 10),
            Expanded(child: _buildActionCard(context, 'Request', 'Post needs', Icons.add_circle_outline, Colors.green, () => context.push('/requests'))),
            SizedBox(width: 10),
            Expanded(child: _buildActionCard(context, 'Barter', 'Skill exchange', Icons.swap_horiz, Colors.purple, () => context.push('/barter'))),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Materials Near You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            TextButton(onPressed: () => context.push('/student-dashboard/discovery'), child: const Text('See All')),
          ],
        ),
        SizedBox(height: 8),
        _buildMaterialCard(context, 'Arduino Boards', 'Lab A - Chemistry', '5 units', '0.2 km', 'Electronic'),
        SizedBox(height: 8),
        _buildMaterialCard(context, 'Copper Wire Spools', 'Lab B - Electronics', '3 kg', '0.4 km', 'Metal'),
        SizedBox(height: 8),
        _buildMaterialCard(context, 'Acrylic Sheets', 'Workshop', '10 sheets', '0.6 km', 'Plastic'),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            TextButton(onPressed: () => context.push('/notifications'), child: const Text('View All')),
          ],
        ),
        SizedBox(height: 8),
        _buildActivityItem('Material request matched', 'Arduino boards for Smart Traffic System', '2 hours ago', Icons.check_circle, Colors.green),
        _buildActivityItem('New opportunity', 'Copper wires available near you', '5 hours ago', Icons.notifications, Colors.blue),
        _buildActivityItem('Impact milestone', 'You\'ve saved 4kg of CO₂!', '1 day ago', Icons.emoji_events, Colors.amber),
      ],
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.recycling, color: Theme.of(context).colorScheme.primary, size: 28),
                SizedBox(width: 8),
                Text('ReClaim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', true, () {}),
                _buildNavItem(context, Icons.map_outlined, 'Discover', false, () => context.push('/student-dashboard/discovery')),
                _buildNavItem(context, Icons.swap_horiz, 'Skill Barter', false, () => context.push('/barter')),
                _buildNavItem(context, Icons.add_circle_outline, 'My Requests', false, () => context.push('/requests')),
                Divider(height: 24, indent: 16, endIndent: 16),
                _buildNavItem(context, Icons.assessment_outlined, 'Impact', false, () => context.push('/impact')),
                _buildNavItem(context, Icons.timeline_outlined, 'Lifecycle', false, () => context.push('/lifecycle')),
                _buildNavItem(context, Icons.settings_outlined, 'Settings', false, () => context.push('/settings')),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade200, child: Icon(Icons.person, size: 18, color: Colors.grey.shade600)),
                    SizedBox(width: 8),
                    Expanded(child: Text('Shravanya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/role-selection'),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8)),
                    child: Text('Change Role', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, String name, String location, String quantity, String distance, String type) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _getTypeColor(type).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(quantity, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
              Text(distance, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Colors.orange;
      case 'metal': return Colors.blueGrey;
      case 'plastic': return Colors.blue;
      default: return Colors.green;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Icons.memory;
      case 'metal': return Icons.hardware;
      case 'plastic': return Icons.local_drink;
      default: return Icons.inventory_2;
    }
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
                  child: Icon(Icons.person, color: Colors.grey.shade700, size: 28),
                ),
                SizedBox(height: 12),
                Text('Shravanya', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('VESIT • IT Dept', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: Colors.grey.shade800),
            title: Text('Dashboard', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.map_outlined, color: Colors.grey.shade800),
            title: Text('Discover Materials', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/student-dashboard/discovery'); },
          ),
          ListTile(
            leading: Icon(Icons.swap_horiz, color: Colors.grey.shade800),
            title: Text('Skill Barter', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/barter'); },
          ),
          ListTile(
            leading: Icon(Icons.add_circle_outline, color: Colors.grey.shade800),
            title: Text('My Requests', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/requests'); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.assessment_outlined, color: Colors.grey.shade800),
            title: Text('Impact Dashboard', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/impact'); },
          ),
          ListTile(
            leading: Icon(Icons.timeline_outlined, color: Colors.grey.shade800),
            title: Text('Material Lifecycle', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/lifecycle'); },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Colors.grey.shade800),
            title: Text('Settings', style: TextStyle(color: Colors.grey.shade800)),
            onTap: () { Navigator.pop(context); context.push('/settings'); },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/lab-dashboard'); },
                    icon: Icon(Icons.science, size: 14),
                    label: Text('Lab', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); context.go('/admin-dashboard'); },
                    icon: Icon(Icons.admin_panel_settings, size: 14),
                    label: Text('Admin', style: TextStyle(fontSize: 11)),
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