import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

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
                        Text('ReClaim Lab', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => context.push('/notifications')),
                        IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () => context.push('/settings')),
                      ],
                    ),
                  ),
                ),
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
                                gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(Icons.science, color: Colors.white, size: 28),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Lab A - Chemistry', style: TextStyle(color: Colors.white, fontSize: _isDesktop ? 22 : 20, fontWeight: FontWeight.bold)),
                                            Text('VESIT Mumbai', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildQuickStat('Materials', '23', Icons.inventory_2_outlined),
                                      _buildQuickStat('Matches', '8', Icons.handshake_outlined),
                                      _buildQuickStat('CO₂ Saved', '12.5kg', Icons.eco_outlined),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Desktop: Side by side; Mobile: Stacked
                            if (_isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildActionsSection(context)),
                                  SizedBox(width: 24),
                                  Expanded(child: _buildOpportunitiesSection(context)),
                                ],
                              )
                            else ...[
                              _buildActionsSection(context),
                              SizedBox(height: 24),
                              _buildOpportunitiesSection(context),
                            ],
                            
                            SizedBox(height: 24),
                            
                            // Lab Management
                            Text('Lab Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildFeatureCard(context, 'Lifecycle', 'Track usage', Icons.timeline, () => context.push('/lifecycle'))),
                                SizedBox(width: 8),
                                Expanded(child: _buildFeatureCard(context, 'Reports', 'Lab analytics', Icons.assessment, () => context.push('/impact'))),
                                SizedBox(width: 8),
                                Expanded(child: _buildFeatureCard(context, 'Approve', 'Pending', Icons.check_circle_outline, () => context.push('/requests'))),
                              ],
                            ),
                            
                            SizedBox(height: 32),
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

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Capture', 'AI detection', Icons.camera_alt, Colors.blue, () => context.push('/lab-dashboard/capture'))),
            SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'Inventory', 'Materials', Icons.inventory_2, Colors.green, () => context.push('/lab-dashboard/inventory'))),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Opportunities', 'AI matches', Icons.auto_awesome, Colors.purple, () => context.push('/lab-dashboard/opportunities'))),
            SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, 'Requests', 'Students', Icons.inbox, Colors.orange, () => context.push('/requests'))),
          ],
        ),
      ],
    );
  }

  Widget _buildOpportunitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Opportunities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            TextButton(onPressed: () => context.push('/lab-dashboard/opportunities'), child: Text('View All', style: TextStyle(fontSize: 12))),
          ],
        ),
        SizedBox(height: 8),
        _buildOpportunityCard(context, 'Arduino Boards', 'Smart Traffic System', 'Rahul Sharma', 92, 1.8),
        SizedBox(height: 8),
        _buildOpportunityCard(context, 'Copper Wires', 'Home Automation Hub', 'Priya Patel', 87, 2.4),
      ],
    );
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
                Icon(Icons.science, color: Theme.of(context).colorScheme.primary, size: 28),
                SizedBox(width: 8),
                Text('Lab Portal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', true, () {}),
                _buildNavItem(context, Icons.camera_alt_outlined, 'Capture', false, () => context.push('/lab-dashboard/capture')),
                _buildNavItem(context, Icons.inventory_2_outlined, 'Inventory', false, () => context.push('/lab-dashboard/inventory')),
                _buildNavItem(context, Icons.auto_awesome_outlined, 'Opportunities', false, () => context.push('/lab-dashboard/opportunities')),
                _buildNavItem(context, Icons.inbox_outlined, 'Requests', false, () => context.push('/requests')),
                Divider(height: 24, indent: 16, endIndent: 16),
                _buildNavItem(context, Icons.timeline_outlined, 'Lifecycle', false, () => context.push('/lifecycle')),
                _buildNavItem(context, Icons.assessment_outlined, 'Reports', false, () => context.push('/impact')),
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
                CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade300, child: Icon(Icons.science, color: Colors.grey.shade700, size: 28)),
                SizedBox(height: 12),
                Text('Lab A - Chemistry', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('VESIT Mumbai', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
          ListTile(leading: Icon(Icons.dashboard_outlined), title: Text('Dashboard'), onTap: () => Navigator.pop(context)),
          ListTile(leading: Icon(Icons.camera_alt_outlined), title: Text('Capture Materials'), onTap: () { Navigator.pop(context); context.push('/lab-dashboard/capture'); }),
          ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('Inventory'), onTap: () { Navigator.pop(context); context.push('/lab-dashboard/inventory'); }),
          ListTile(leading: Icon(Icons.auto_awesome_outlined), title: Text('Opportunities'), onTap: () { Navigator.pop(context); context.push('/lab-dashboard/opportunities'); }),
          const Divider(),
          ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings'), onTap: () { Navigator.pop(context); context.push('/settings'); }),
          ListTile(leading: Icon(Icons.logout_outlined), title: Text('Change Role'), onTap: () { Navigator.pop(context); context.go('/role-selection'); }),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        SizedBox(height: 6),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, String material, String project, String student, int matchPercent, double carbonSaved) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis),
                Text('$project', style: TextStyle(fontSize: 10, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Text('$matchPercent%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 2),
              Text('$carbonSaved kg', style: TextStyle(fontSize: 9, color: Colors.green.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
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
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(height: 6),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}