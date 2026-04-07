import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  String _selectedPeriod = 'This Month';
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;
  
  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(rank: 1, name: 'Rahul Sharma', department: 'Computer Engg', co2Saved: 24.5, materialsReused: 18, avatar: 'RS'),
    LeaderboardEntry(rank: 2, name: 'Priya Patel', department: 'Electronics', co2Saved: 21.3, materialsReused: 15, avatar: 'PP'),
    LeaderboardEntry(rank: 3, name: 'Amit Kumar', department: 'Mechanical', co2Saved: 18.7, materialsReused: 12, avatar: 'AK'),
    LeaderboardEntry(rank: 4, name: 'Sneha Gupta', department: 'IT', co2Saved: 15.2, materialsReused: 10, avatar: 'SG'),
    LeaderboardEntry(rank: 5, name: 'Vikram Singh', department: 'Civil', co2Saved: 12.8, materialsReused: 8, avatar: 'VS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Impact Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => ['This Week', 'This Month', 'This Year', 'All Time'].map((p) => PopupMenuItem(value: p, child: Text(p))).toList(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(_selectedPeriod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const Icon(Icons.arrow_drop_down, color: Colors.white)],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_isDesktop ? 24 : 0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // Hero Impact Stats
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(_isDesktop ? 0 : 16),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, color: Colors.white, size: 32),
                          SizedBox(width: 8),
                          Text('Environmental Impact', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 32,
                        runSpacing: 12,
                        children: [
                          _buildHeroStat('CO₂ Saved', '156.8 kg', Icons.cloud_outlined),
                          _buildHeroStat('Materials', '89 items', Icons.inventory_2_outlined),
                          _buildHeroStat('Projects', '34', Icons.rocket_launch_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: _isDesktop ? 24 : 16),
                
                // Stats Grid - 4 cards in a row on desktop
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16),
                  child: _isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _buildStatCard('Trees Equivalent', '7', Icons.park, Colors.green)),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Waste Diverted', '45 kg', Icons.delete_outline, Colors.orange)),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Energy Saved', '234 kWh', Icons.bolt, Colors.amber)),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard('Water Saved', '890 L', Icons.water_drop, Colors.blue)),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildStatCard('Trees Equivalent', '7', Icons.park, Colors.green)),
                                SizedBox(width: 12),
                                Expanded(child: _buildStatCard('Waste Diverted', '45 kg', Icons.delete_outline, Colors.orange)),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildStatCard('Energy Saved', '234 kWh', Icons.bolt, Colors.amber)),
                                SizedBox(width: 12),
                                Expanded(child: _buildStatCard('Water Saved', '890 L', Icons.water_drop, Colors.blue)),
                              ],
                            ),
                          ],
                        ),
                ),
                
                SizedBox(height: 24),
                
                // Chart and Leaderboard side by side on desktop
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16),
                  child: _isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildChartCard()),
                            SizedBox(width: 24),
                            Expanded(child: _buildLeaderboardCard()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildChartCard(),
                            SizedBox(height: 24),
                            _buildLeaderboardCard(),
                          ],
                        ),
                ),
                
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Impact Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Jan', 0.4, Colors.green.shade300),
                _buildChartBar('Feb', 0.6, Colors.green.shade400),
                _buildChartBar('Mar', 0.5, Colors.green.shade300),
                _buildChartBar('Apr', 0.8, Colors.green.shade500),
                _buildChartBar('May', 0.7, Colors.green.shade400),
                _buildChartBar('Jun', 1.0, Colors.green.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text('Campus Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              ],
            ),
          ),
          ..._leaderboard.map((entry) => _buildLeaderboardItem(entry)),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () {}, child: const Text('View Full Leaderboard')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        SizedBox(height: 8),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 24, height: 100 * value, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.vertical(top: Radius.circular(4)))),
        SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isTopThree = entry.rank <= 3;
    final medalColor = entry.rank == 1 ? Colors.amber : entry.rank == 2 ? Colors.grey.shade400 : entry.rank == 3 ? Colors.brown.shade300 : Colors.transparent;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTopThree ? medalColor.withOpacity(0.05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: isTopThree
                ? Icon(Icons.emoji_events, color: medalColor, size: 24)
                : Text('${entry.rank}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ),
          SizedBox(width: 12),
          CircleAvatar(radius: 18, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(entry.avatar, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(entry.department, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.co2Saved} kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              Text('${entry.materialsReused} materials', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String department;
  final double co2Saved;
  final int materialsReused;
  final String avatar;

  LeaderboardEntry({required this.rank, required this.name, required this.department, required this.co2Saved, required this.materialsReused, required this.avatar});
}