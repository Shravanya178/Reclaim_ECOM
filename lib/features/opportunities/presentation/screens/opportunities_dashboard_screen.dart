import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OpportunitiesDashboardScreen extends StatefulWidget {
  const OpportunitiesDashboardScreen({super.key});

  @override
  State<OpportunitiesDashboardScreen> createState() => _OpportunitiesDashboardScreenState();
}

class _OpportunitiesDashboardScreenState extends State<OpportunitiesDashboardScreen> {
  final List<OpportunityCard> _opportunities = [
    OpportunityCard(id: '1', materialName: 'Arduino Boards (5 units)', materialType: 'Electronic', suggestedProjects: ['Smart Traffic System', 'Home Automation Hub', 'IoT Weather Station'], topMatchStudent: 'Rahul Sharma', matchPercentage: 92, carbonImpact: 1.8, confidence: 0.94),
    OpportunityCard(id: '2', materialName: 'Copper Wire Spools (3kg)', materialType: 'Metal', suggestedProjects: ['PCB Prototyping', 'Motor Rewinding', 'Antenna Design'], topMatchStudent: 'Priya Patel', matchPercentage: 87, carbonImpact: 2.4, confidence: 0.89),
    OpportunityCard(id: '3', materialName: 'Acrylic Sheets (10 pcs)', materialType: 'Plastic', suggestedProjects: ['LED Display Case', 'Drone Frame', '3D Printer Enclosure'], topMatchStudent: 'Amit Kumar', matchPercentage: 78, carbonImpact: 1.5, confidence: 0.85),
    OpportunityCard(id: '4', materialName: 'Glass Beakers (8 units)', materialType: 'Glass', suggestedProjects: ['Lab Equipment Upcycling', 'Terrarium Project', 'Scientific Display'], topMatchStudent: 'Sneha Gupta', matchPercentage: 65, carbonImpact: 0.8, confidence: 0.72),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Opportunity Cards'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Hero Stats Banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 28.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'AI-Generated Opportunities',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 12.w,
                  runSpacing: 8.h,
                  children: [
                    _buildStatColumn('Active', '${_opportunities.length}', Colors.white),
                    _buildStatColumn('Potential CO₂', '${_opportunities.fold(0.0, (sum, o) => sum + o.carbonImpact).toStringAsFixed(1)}kg', Colors.white),
                    _buildStatColumn('Avg Match', '${(_opportunities.fold(0, (sum, o) => sum + o.matchPercentage) / _opportunities.length).round()}%', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          
          // Opportunity Cards List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _opportunities.length,
              itemBuilder: (context, index) => _buildOpportunityCard(_opportunities[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildOpportunityCard(OpportunityCard opportunity) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          // Header with Material Info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getMaterialColor(opportunity.materialType).withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w, height: 50.h,
                  decoration: BoxDecoration(color: _getMaterialColor(opportunity.materialType).withOpacity(0.15), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(_getMaterialIcon(opportunity.materialType), color: _getMaterialColor(opportunity.materialType), size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.materialName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4.r)),
                            child: Text('${(opportunity.confidence * 100).toInt()}% AI Confidence', style: TextStyle(color: Colors.green.shade700, fontSize: 10.sp, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.eco, color: Colors.green, size: 14.sp), SizedBox(width: 2.w), Flexible(child: Text('${opportunity.carbonImpact} kg', style: TextStyle(color: Colors.green.shade700, fontSize: 11.sp, fontWeight: FontWeight.bold)))]),
                      Text('CO₂ savings', style: TextStyle(color: Colors.grey.shade500, fontSize: 9.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Suggested Projects
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested Projects', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: opportunity.suggestedProjects.map((project) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(20.r)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14.sp, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 4.w),
                        Text(project, style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // Top Match Student
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              children: [
                CircleAvatar(radius: 18.r, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(opportunity.topMatchStudent[0], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Match', style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
                      Text(opportunity.topMatchStudent, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('${opportunity.matchPercentage}% Match', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectOpportunity(opportunity),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 12.h)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmOpportunity(opportunity),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm & Match'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Colors.orange;
      case 'metal': return Colors.blueGrey;
      case 'plastic': return Colors.blue;
      case 'glass': return Colors.cyan;
      default: return Colors.green;
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Icons.memory;
      case 'metal': return Icons.hardware;
      case 'plastic': return Icons.local_drink;
      case 'glass': return Icons.science;
      default: return Icons.inventory_2;
    }
  }

  void _confirmOpportunity(OpportunityCard opportunity) {
    setState(() => _opportunities.remove(opportunity));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Matched ${opportunity.materialName} with ${opportunity.topMatchStudent}!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: 'View', textColor: Colors.white, onPressed: () {}),
    ));
  }

  void _rejectOpportunity(OpportunityCard opportunity) {
    setState(() => _opportunities.remove(opportunity));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Opportunity dismissed'),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: 'Undo', onPressed: () => setState(() => _opportunities.add(opportunity))),
    ));
  }
}

class OpportunityCard {
  final String id;
  final String materialName;
  final String materialType;
  final List<String> suggestedProjects;
  final String topMatchStudent;
  final int matchPercentage;
  final double carbonImpact;
  final double confidence;

  OpportunityCard({required this.id, required this.materialName, required this.materialType, required this.suggestedProjects, required this.topMatchStudent, required this.matchPercentage, required this.carbonImpact, required this.confidence});
}