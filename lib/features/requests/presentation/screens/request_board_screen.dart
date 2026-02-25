import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestBoardScreen extends StatefulWidget {
  const RequestBoardScreen({super.key});

  @override
  State<RequestBoardScreen> createState() => _RequestBoardScreenState();
}

class _RequestBoardScreenState extends State<RequestBoardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;
  
  final List<MaterialRequest> _requests = [
    MaterialRequest(id: '1', title: 'Arduino Uno Boards', materialType: 'Electronic', quantity: '3 units', requester: 'Rahul Sharma', project: 'Smart Traffic System', deadline: DateTime.now().add(const Duration(days: 5)), urgency: RequestUrgency.high, status: RequestStatus.open),
    MaterialRequest(id: '2', title: 'Copper Wires (22 AWG)', materialType: 'Metal', quantity: '50m', requester: 'Priya Patel', project: 'Home Automation', deadline: DateTime.now().add(const Duration(days: 10)), urgency: RequestUrgency.medium, status: RequestStatus.open),
    MaterialRequest(id: '3', title: 'Acrylic Sheets (3mm)', materialType: 'Plastic', quantity: '5 sheets', requester: 'Amit Kumar', project: 'LED Display Case', deadline: DateTime.now().add(const Duration(days: 3)), urgency: RequestUrgency.urgent, status: RequestStatus.open),
    MaterialRequest(id: '4', title: 'Servo Motors', materialType: 'Electronic', quantity: '4 units', requester: 'Sneha Gupta', project: 'Robotic Arm', deadline: DateTime.now().add(const Duration(days: 7)), urgency: RequestUrgency.medium, status: RequestStatus.inProgress, matchedPercentage: 75),
    MaterialRequest(id: '5', title: 'PVC Pipes', materialType: 'Plastic', quantity: '10 pieces', requester: 'Vikram Singh', project: 'Hydroponics System', deadline: DateTime.now().subtract(const Duration(days: 2)), urgency: RequestUrgency.low, status: RequestStatus.fulfilled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Request Board'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Open'), Tab(text: 'In Progress'), Tab(text: 'Fulfilled')],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(_requests.where((r) => r.status == RequestStatus.open).toList()),
              _buildRequestList(_requests.where((r) => r.status == RequestStatus.inProgress).toList()),
              _buildRequestList(_requests.where((r) => r.status == RequestStatus.fulfilled).toList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRequestDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildRequestList(List<MaterialRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text('No requests found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(_isDesktop ? 24 : 16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildRequestCard(requests[index]),
    );
  }

  Widget _buildRequestCard(MaterialRequest request) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: _getTypeColor(request.materialType).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_getTypeIcon(request.materialType), color: _getTypeColor(request.materialType), size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          SizedBox(height: 2),
                          Text('${request.materialType} • ${request.quantity}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    _buildUrgencyBadge(request.urgency),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch_outlined, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Expanded(child: Text(request.project, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Text(request.requester[0], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    Text(request.requester, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(_formatDeadline(request.deadline), style: TextStyle(fontSize: 12, color: _isOverdue(request.deadline) ? Colors.red : Colors.grey.shade600)),
                  ],
                ),
                if (request.status == RequestStatus.inProgress && request.matchedPercentage != null) ...[
                  SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Match Progress', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Text('${request.matchedPercentage}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(value: request.matchedPercentage! / 100, backgroundColor: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ],
                if (request.status == RequestStatus.open) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('View Details'))),
                      SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Offer Material'))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge(RequestUrgency urgency) {
    Color color;
    String text;
    switch (urgency) {
      case RequestUrgency.urgent: color = Colors.red; text = 'Urgent'; break;
      case RequestUrgency.high: color = Colors.orange; text = 'High'; break;
      case RequestUrgency.medium: color = Colors.blue; text = 'Medium'; break;
      case RequestUrgency.low: color = Colors.green; text = 'Low'; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'electronic': return Colors.orange;
      case 'metal': return Colors.grey.shade700;
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

  String _formatDeadline(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff < 0) return '${-diff} days overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '$diff days left';
  }

  bool _isOverdue(DateTime date) => date.isBefore(DateTime.now());

  void _showCreateRequestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Request', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(decoration: InputDecoration(labelText: 'Material Name', hintText: 'e.g., Arduino Uno Board', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(decoration: InputDecoration(labelText: 'Quantity', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                  SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: ['Electronic', 'Metal', 'Plastic', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) {})),
                ],
              ),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Project Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 12),
              TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Description', hintText: 'Describe your material requirements...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(context); }, style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)), child: const Text('Post Request'))),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum RequestUrgency { urgent, high, medium, low }
enum RequestStatus { open, inProgress, fulfilled }

class MaterialRequest {
  final String id;
  final String title;
  final String materialType;
  final String quantity;
  final String requester;
  final String project;
  final DateTime deadline;
  final RequestUrgency urgency;
  final RequestStatus status;
  final int? matchedPercentage;

  MaterialRequest({required this.id, required this.title, required this.materialType, required this.quantity, required this.requester, required this.project, required this.deadline, required this.urgency, required this.status, this.matchedPercentage});
}