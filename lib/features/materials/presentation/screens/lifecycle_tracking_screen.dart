import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LifecycleTrackingScreen extends StatefulWidget {
  const LifecycleTrackingScreen({super.key});

  @override
  State<LifecycleTrackingScreen> createState() => _LifecycleTrackingScreenState();
}

class _LifecycleTrackingScreenState extends State<LifecycleTrackingScreen> {
  String _selectedMaterial = 'Arduino Boards (5 units)';
  
  final Map<String, List<LifecycleEvent>> _materialLifecycles = {
    'Arduino Boards (5 units)': [
      LifecycleEvent(status: 'Captured', description: 'AI detected in Lab A - Chemistry', timestamp: DateTime.now().subtract(const Duration(days: 5)), icon: Icons.camera_alt, color: Colors.blue),
      LifecycleEvent(status: 'Listed', description: 'Added to material inventory', timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 2)), icon: Icons.inventory_2, color: Colors.orange),
      LifecycleEvent(status: 'Opportunity Generated', description: 'Matched with 3 potential projects', timestamp: DateTime.now().subtract(const Duration(days: 4)), icon: Icons.auto_awesome, color: Colors.purple),
      LifecycleEvent(status: 'Requested', description: 'Rahul Sharma requested for Smart Traffic System', timestamp: DateTime.now().subtract(const Duration(days: 3)), icon: Icons.person, color: Colors.teal),
      LifecycleEvent(status: 'Approved', description: 'Lab admin approved the transfer', timestamp: DateTime.now().subtract(const Duration(days: 2)), icon: Icons.check_circle, color: Colors.green),
      LifecycleEvent(status: 'In Use', description: 'Currently being used in project', timestamp: DateTime.now().subtract(const Duration(days: 1)), icon: Icons.build, color: Colors.amber),
    ],
    'Copper Wire Spools (3kg)': [
      LifecycleEvent(status: 'Captured', description: 'AI detected in Lab B - Electronics', timestamp: DateTime.now().subtract(const Duration(days: 7)), icon: Icons.camera_alt, color: Colors.blue),
      LifecycleEvent(status: 'Listed', description: 'Added to material inventory', timestamp: DateTime.now().subtract(const Duration(days: 7, hours: 1)), icon: Icons.inventory_2, color: Colors.orange),
      LifecycleEvent(status: 'Opportunity Generated', description: 'Matched with 2 potential projects', timestamp: DateTime.now().subtract(const Duration(days: 6)), icon: Icons.auto_awesome, color: Colors.purple),
    ],
    'Acrylic Sheets (10 pcs)': [
      LifecycleEvent(status: 'Captured', description: 'AI detected in Workshop', timestamp: DateTime.now().subtract(const Duration(days: 10)), icon: Icons.camera_alt, color: Colors.blue),
      LifecycleEvent(status: 'Listed', description: 'Added to material inventory', timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 1)), icon: Icons.inventory_2, color: Colors.orange),
      LifecycleEvent(status: 'Opportunity Generated', description: 'Matched with 4 potential projects', timestamp: DateTime.now().subtract(const Duration(days: 9)), icon: Icons.auto_awesome, color: Colors.purple),
      LifecycleEvent(status: 'Requested', description: 'Amit Kumar requested for LED Display Case', timestamp: DateTime.now().subtract(const Duration(days: 8)), icon: Icons.person, color: Colors.teal),
      LifecycleEvent(status: 'Approved', description: 'Lab admin approved the transfer', timestamp: DateTime.now().subtract(const Duration(days: 7)), icon: Icons.check_circle, color: Colors.green),
      LifecycleEvent(status: 'In Use', description: 'Currently being used in project', timestamp: DateTime.now().subtract(const Duration(days: 5)), icon: Icons.build, color: Colors.amber),
      LifecycleEvent(status: 'Completed', description: 'Project completed successfully', timestamp: DateTime.now().subtract(const Duration(days: 1)), icon: Icons.done_all, color: Colors.green),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final lifecycle = _materialLifecycles[_selectedMaterial] ?? [];
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Lifecycle Tracking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Material Selector
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)]),
            child: DropdownButton<String>(
              value: _selectedMaterial,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _materialLifecycles.keys.map((material) => DropdownMenuItem(value: material, child: Text(material, style: TextStyle(color: Colors.grey.shade800)))).toList(),
              onChanged: (value) => setState(() => _selectedMaterial = value!),
            ),
          ),
          
          // Progress Overview
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(28)),
                  child: Center(child: Text('${lifecycle.length}', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lifecycle Events', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Current status: ${lifecycle.isNotEmpty ? lifecycle.last.status : "N/A"}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(_calculateProgress(lifecycle), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Timeline
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: lifecycle.length,
              itemBuilder: (context, index) {
                final event = lifecycle[index];
                final isLast = index == lifecycle.length - 1;
                final isFirst = index == 0;
                return _buildTimelineItem(event, isFirst, isLast, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(LifecycleEvent event, bool isFirst, bool isLast, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Dot
          SizedBox(
            width: 60,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 20, color: Colors.grey.shade300),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: event.color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: event.color, width: 2)),
                  child: Icon(event.icon, color: event.color, size: 20),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)],
                border: isLast ? Border.all(color: event.color, width: 2) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: event.color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(event.status, style: TextStyle(color: event.color, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      if (isLast) Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                        child: Text('Current', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(event.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      SizedBox(width: 4),
                      Text(_formatTimestamp(event.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  String _calculateProgress(List<LifecycleEvent> lifecycle) {
    if (lifecycle.isEmpty) return '0%';
    final hasCompleted = lifecycle.any((e) => e.status == 'Completed');
    if (hasCompleted) return '100%';
    return '${((lifecycle.length / 7) * 100).clamp(0, 100).toInt()}%';
  }
}

class LifecycleEvent {
  final String status;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  LifecycleEvent({required this.status, required this.description, required this.timestamp, required this.icon, required this.color});
}
