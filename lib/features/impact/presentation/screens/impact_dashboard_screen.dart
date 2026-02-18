import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  String _selectedPeriod = 'This Month';
  
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
      backgroundColor: Colors.grey.shade50,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(_selectedPeriod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const Icon(Icons.arrow_drop_down, color: Colors.white)],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Impact Stats
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: Colors.white, size: 32.sp),
                      SizedBox(width: 8.w),
                      Text('Environmental Impact', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 16.w,
                    runSpacing: 12.h,
                    children: [
                      _buildHeroStat('CO₂ Saved', '156.8 kg', Icons.cloud_outlined),
                      _buildHeroStat('Materials', '89 items', Icons.inventory_2_outlined),
                      _buildHeroStat('Projects', '34', Icons.rocket_launch_outlined),
                    ],
                  ),
                ],
              ),
            ),
            
            // Stats Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Trees Equivalent', '7', Icons.park, Colors.green)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildStatCard('Waste Diverted', '45 kg', Icons.delete_outline, Colors.orange)),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Energy Saved', '234 kWh', Icons.bolt, Colors.amber)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildStatCard('Water Saved', '890 L', Icons.water_drop, Colors.blue)),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Monthly Trend Chart Placeholder
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Impact Trend', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 150.h,
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
            ),
            
            SizedBox(height: 24.h),
            
            // Leaderboard Section
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(Icons.leaderboard, color: Colors.amber, size: 24.sp),
                        SizedBox(width: 8.w),
                        Text('Campus Leaderboard', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                  ..._leaderboard.map((entry) => _buildLeaderboardItem(entry)),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(onPressed: () {}, child: const Text('View Full Leaderboard')),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24.sp),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 44.w, height: 44.h,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
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
        Container(width: 24.w, height: 100.h * value, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)))),
        SizedBox(height: 6.h),
        Text(label, style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isTopThree = entry.rank <= 3;
    final medalColor = entry.rank == 1 ? Colors.amber : entry.rank == 2 ? Colors.grey.shade400 : entry.rank == 3 ? Colors.brown.shade300 : Colors.transparent;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isTopThree ? medalColor.withOpacity(0.05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: isTopThree
                ? Icon(Icons.emoji_events, color: medalColor, size: 24.sp)
                : Text('${entry.rank}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(radius: 18.r, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(entry.avatar, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(entry.department, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.co2Saved} kg', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              Text('${entry.materialsReused} materials', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
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