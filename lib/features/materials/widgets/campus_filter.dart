import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reclaim/core/theme/app_theme.dart';

class CampusFilter extends StatefulWidget {
  final String initialCampus;
  final Function(List<MaterialItem>, String)? onFilterChange;

  const CampusFilter({
    super.key,
    this.initialCampus = 'VESIT',
    this.onFilterChange,
  });

  @override
  State<CampusFilter> createState() => _CampusFilterState();
}

class _CampusFilterState extends State<CampusFilter> {
  late String selectedCampus;
  List<MaterialItem> filteredMaterials = [];

  final List<String> campuses = ['VESIT', 'SPIT', 'DJ Sanghvi'];

  final List<MaterialItem> allMaterials = [
    MaterialItem(1, 'Arduino Uno R3', 'VESIT', 'Electronics', '₹1,200', 15),
    MaterialItem(2, 'Breadboard Large', 'SPIT', 'Electronics', '₹150', 25),
    MaterialItem(3, 'Ultrasonic Sensor', 'VESIT', 'Sensors', '₹300', 8),
    MaterialItem(4, 'Raspberry Pi 4', 'DJ Sanghvi', 'Electronics', '₹4,500', 5),
    MaterialItem(5, 'Jumper Wires Set', 'VESIT', 'Electronics', '₹80', 30),
    MaterialItem(6, 'LCD Display 16x2', 'SPIT', 'Display', '₹250', 12),
    MaterialItem(7, 'Servo Motor SG90', 'VESIT', 'Motors', '₹200', 18),
    MaterialItem(8, 'Temperature Sensor', 'DJ Sanghvi', 'Sensors', '₹120', 20),
    MaterialItem(9, 'LED Strip 5m', 'SPIT', 'Lighting', '₹400', 7),
    MaterialItem(10, 'Resistor Kit', 'VESIT', 'Electronics', '₹180', 22),
  ];

  @override
  void initState() {
    super.initState();
    selectedCampus = widget.initialCampus;
    _filterMaterials();
  }

  void _filterMaterials() {
    filteredMaterials = allMaterials
        .where((material) => material.campus == selectedCampus)
        .toList();
    
    if (widget.onFilterChange != null) {
      widget.onFilterChange!(filteredMaterials, selectedCampus);
    }
  }

  CampusStats _getCampusStats() {
    final campusMaterials = allMaterials
        .where((m) => m.campus == selectedCampus)
        .toList();
    
    final totalStock = campusMaterials.fold<int>(
      0, 
      (sum, material) => sum + material.stock,
    );
    
    final categories = campusMaterials
        .map((m) => m.category)
        .toSet()
        .length;
    
    return CampusStats(
      count: campusMaterials.length,
      totalStock: totalStock,
      categories: categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getCampusStats();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Materials Near You',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find materials available at your campus and nearby locations',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Campus Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Campus',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5EFE8)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCampus,
                    isExpanded: true,
                    items: campuses.map((campus) {
                      return DropdownMenuItem<String>(
                        value: campus,
                        child: Text(
                          campus,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCampus = newValue;
                          _filterMaterials();
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Campus Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  stats.count.toString(),
                  'Materials',
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  stats.totalStock.toString(),
                  'Total Stock',
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  stats.categories.toString(),
                  'Categories',
                  AppTheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Materials List
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 16,
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '$selectedCampus Materials (${filteredMaterials.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (filteredMaterials.isEmpty)
            _buildEmptyState()
          else
            ...filteredMaterials.map((material) => _buildMaterialItem(material)),

          const SizedBox(height: 24),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionChip('📝 Request Material', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request material feature coming soon!'),
                        ),
                      );
                    }),
                    _buildActionChip('🎁 Donate Material', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Donate material feature coming soon!'),
                        ),
                      );
                    }),
                    _buildActionChip('🗺️ Campus Map', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Campus map feature coming soon!'),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(MaterialItem material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${material.category} • Stock: ${material.stock}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                material.price,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStockStatusColor(material.stock).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStockStatus(material.stock),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getStockStatusColor(material.stock),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5EFE8),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No materials found at $selectedCampus',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different campus',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EFE8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  String _getStockStatus(int stock) {
    if (stock > 10) return 'In Stock';
    if (stock > 5) return 'Low Stock';
    return 'Very Low';
  }

  Color _getStockStatusColor(int stock) {
    if (stock > 10) return AppTheme.success;
    if (stock > 5) return AppTheme.warning;
    return AppTheme.error;
  }
}

class MaterialItem {
  final int id;
  final String name;
  final String campus;
  final String category;
  final String price;
  final int stock;

  MaterialItem(
    this.id,
    this.name,
    this.campus,
    this.category,
    this.price,
    this.stock,
  );
}

class CampusStats {
  final int count;
  final int totalStock;
  final int categories;

  CampusStats({
    required this.count,
    required this.totalStock,
    required this.categories,
  });
}