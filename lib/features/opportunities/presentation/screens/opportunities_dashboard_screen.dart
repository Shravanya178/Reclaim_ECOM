import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpportunitiesDashboardScreen extends StatefulWidget {
  const OpportunitiesDashboardScreen({super.key});

  @override
  State<OpportunitiesDashboardScreen> createState() => _OpportunitiesDashboardScreenState();
}

class _OpportunitiesDashboardScreenState extends State<OpportunitiesDashboardScreen> {
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;
  
  final List<OpportunityCard> _opportunities = [
    OpportunityCard(id: '1', materialName: 'Arduino Boards (5 units)', materialType: 'Electronic', suggestedProjects: ['Smart Traffic System', 'Home Automation Hub', 'IoT Weather Station'], topMatchStudent: 'Rahul Sharma', matchPercentage: 92, carbonImpact: 1.8, confidence: 0.94),
    OpportunityCard(id: '2', materialName: 'Copper Wire Spools (3kg)', materialType: 'Metal', suggestedProjects: ['PCB Prototyping', 'Motor Rewinding', 'Antenna Design'], topMatchStudent: 'Priya Patel', matchPercentage: 87, carbonImpact: 2.4, confidence: 0.89),
    OpportunityCard(id: '3', materialName: 'Acrylic Sheets (10 pcs)', materialType: 'Plastic', suggestedProjects: ['LED Display Case', 'Drone Frame', '3D Printer Enclosure'], topMatchStudent: 'Amit Kumar', matchPercentage: 78, carbonImpact: 1.5, confidence: 0.85),
    OpportunityCard(id: '4', materialName: 'Glass Beakers (8 units)', materialType: 'Glass', suggestedProjects: ['Lab Equipment Upcycling', 'Terrarium Project', 'Scientific Display'], topMatchStudent: 'Sneha Gupta', matchPercentage: 65, carbonImpact: 0.8, confidence: 0.72),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              SizedBox(height: _isDesktop ? 24 : 0),
              // Hero Stats Banner
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16, vertical: _isDesktop ? 0 : 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI-Generated Opportunities',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        _buildStatColumn('Active', '${_opportunities.length}', Colors.white),
                        _buildStatColumn('Potential CO₂', '${_opportunities.fold(0.0, (sum, o) => sum + o.carbonImpact).toStringAsFixed(1)}kg', Colors.white),
                        _buildStatColumn('Avg Match', '${(_opportunities.fold(0, (sum, o) => sum + o.matchPercentage) / _opportunities.length).round()}%', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: _isDesktop ? 24 : 0),
              
              // Opportunity Cards List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16),
                  itemCount: _opportunities.length,
                  itemBuilder: (context, index) => _buildOpportunityCard(_opportunities[index]),
                ),
              ),
              SizedBox(height: _isDesktop ? 24 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildOpportunityCard(OpportunityCard opportunity) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          // Header with Material Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getMaterialColor(opportunity.materialType).withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: _getMaterialColor(opportunity.materialType).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getMaterialIcon(opportunity.materialType), color: _getMaterialColor(opportunity.materialType), size: 26),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.materialName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text('${(opportunity.confidence * 100).toInt()}% AI Confidence', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.w600)),
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
                        children: [Icon(Icons.eco, color: Colors.green, size: 14), SizedBox(width: 2), Flexible(child: Text('${opportunity.carbonImpact} kg', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)))]),
                      Text('CO₂ savings', style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Suggested Projects
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested Projects', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.suggestedProjects.map((project) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 4),
                        Text(project, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // Top Match Student
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(opportunity.topMatchStudent[0], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Match', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(opportunity.topMatchStudent, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${opportunity.matchPercentage}% Match', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectOpportunity(opportunity),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmOpportunity(opportunity),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm & Match'),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
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