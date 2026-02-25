import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaterialInventoryScreen extends StatefulWidget {
  const MaterialInventoryScreen({super.key});

  @override
  State<MaterialInventoryScreen> createState() => _MaterialInventoryScreenState();
}

class _MaterialInventoryScreenState extends State<MaterialInventoryScreen> {
  String _selectedFilter = 'All';
  String _selectedType = 'All Types';
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;
  
  final List<MaterialLot> _materialLots = [
    MaterialLot(id: '1', name: 'Arduino Boards', type: 'Electronic', quantity: '5 units', location: 'Lab A - Chemistry', status: MaterialStatus.detected, capturedDate: DateTime.now().subtract(const Duration(hours: 2)), carbonSaved: 0.8),
    MaterialLot(id: '2', name: 'Copper Wire Spools', type: 'Metal', quantity: '3 kg', location: 'Lab B - Electronics', status: MaterialStatus.listed, capturedDate: DateTime.now().subtract(const Duration(days: 1)), carbonSaved: 1.2),
    MaterialLot(id: '3', name: 'Acrylic Sheets', type: 'Plastic', quantity: '10 sheets', location: 'Workshop', status: MaterialStatus.matched, capturedDate: DateTime.now().subtract(const Duration(days: 2)), carbonSaved: 2.5),
    MaterialLot(id: '4', name: 'Glass Beakers', type: 'Glass', quantity: '8 units', location: 'Lab A - Chemistry', status: MaterialStatus.inUse, capturedDate: DateTime.now().subtract(const Duration(days: 3)), carbonSaved: 0.5),
    MaterialLot(id: '5', name: 'Aluminum Rods', type: 'Metal', quantity: '2 kg', location: 'Workshop', status: MaterialStatus.completed, capturedDate: DateTime.now().subtract(const Duration(days: 7)), carbonSaved: 3.1),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLots = _getFilteredLots();
    
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Material Inventory'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilterSheet),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              SizedBox(height: _isDesktop ? 24 : 0),
              // Status Filters
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16, vertical: 8),
                  children: ['All', 'Detected', 'Listed', 'Matched', 'In Use', 'Completed'].map((filter) => Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) => setState(() => _selectedFilter = filter),
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: _selectedFilter == filter ? Theme.of(context).colorScheme.primary : Colors.grey.shade700),
                    ),
                  )).toList(),
                ),
              ),
              
              // Stats Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Lots', '${_materialLots.length}', Icons.inventory_2),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Carbon Saved', '${_materialLots.fold(0.0, (sum, m) => sum + m.carbonSaved).toStringAsFixed(1)} kg', Icons.eco),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Active', '${_materialLots.where((m) => m.status != MaterialStatus.completed).length}', Icons.pending_actions),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Material List
              Expanded(
                child: filteredLots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text('No materials found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                            SizedBox(height: 8),
                            Text('Capture materials to see them here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16),
                        itemCount: filteredLots.length,
                        itemBuilder: (context, index) => _buildMaterialCard(filteredLots[index]),
                      ),
              ),
              SizedBox(height: _isDesktop ? 24 : 0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lab-dashboard/capture'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture'),
      ),
    );
  }

  List<MaterialLot> _getFilteredLots() {
    var lots = _materialLots;
    if (_selectedFilter != 'All') {
      lots = lots.where((m) => m.status.name.toLowerCase() == _selectedFilter.toLowerCase().replaceAll(' ', '')).toList();
    }
    if (_selectedType != 'All Types') {
      lots = lots.where((m) => m.type == _selectedType).toList();
    }
    return lots;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMaterialCard(MaterialLot material) {
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
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: _getMaterialColor(material.type).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_getMaterialIcon(material.type), color: _getMaterialColor(material.type), size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(material.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          SizedBox(height: 2),
                          Text('${material.type} • ${material.quantity}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    _buildStatusBadge(material.status),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(material.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    const Spacer(),
                    Icon(Icons.eco_outlined, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('${material.carbonSaved} kg CO₂ saved', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MaterialStatus status) {
    Color color;
    String text;
    switch (status) {
      case MaterialStatus.detected: color = Colors.blue; text = 'Detected'; break;
      case MaterialStatus.listed: color = Colors.orange; text = 'Listed'; break;
      case MaterialStatus.matched: color = Colors.purple; text = 'Matched'; break;
      case MaterialStatus.inUse: color = Colors.teal; text = 'In Use'; break;
      case MaterialStatus.completed: color = Colors.green; text = 'Completed'; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Color _getMaterialColor(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Colors.blue;
      case 'metal': return Colors.grey.shade700;
      case 'electronic': return Colors.orange;
      case 'glass': return Colors.cyan;
      default: return Colors.green;
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Icons.local_drink;
      case 'metal': return Icons.hardware;
      case 'electronic': return Icons.memory;
      case 'glass': return Icons.science;
      default: return Icons.inventory_2;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Type', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All Types', 'Electronic', 'Metal', 'Plastic', 'Glass'].map((type) => ChoiceChip(
                label: Text(type),
                selected: _selectedType == type,
                onSelected: (selected) { setState(() => _selectedType = type); Navigator.pop(context); },
              )).toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

enum MaterialStatus { detected, listed, matched, inUse, completed }

class MaterialLot {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final String location;
  final MaterialStatus status;
  final DateTime capturedDate;
  final double carbonSaved;

  MaterialLot({required this.id, required this.name, required this.type, required this.quantity, required this.location, required this.status, required this.capturedDate, required this.carbonSaved});
}