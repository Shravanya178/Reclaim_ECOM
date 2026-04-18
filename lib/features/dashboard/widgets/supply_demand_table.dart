import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reclaim/core/theme/app_theme.dart';

const Color _sdSurplus = Color(0xFF2F5D3A);
const Color _sdBalanced = Color(0xFF6E4B7E);
const Color _sdDeficit = Color(0xFFB27A3B);
const Color _sdCritical = Color(0xFF8B3A2E);

class SupplyDemandTable extends StatelessWidget {
  const SupplyDemandTable({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      MaterialSupplyData('Electronic Components', 24, 38, 'Surplus'),
      MaterialSupplyData('Plastic Polymers', 18, 7, 'Deficit'),
      MaterialSupplyData('Glassware', 14, 12, 'Moderate'),
      MaterialSupplyData('Metal Alloys', 9, 3, 'Critical'),
      MaterialSupplyData('Chemical Reagents', 6, 6, 'Balanced'),
    ];

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
            'Supply vs Demand Gap Analysis',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps labs prioritize materials based on real demand',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5EFE8)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Material Type',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Requests',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Stock',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Data rows
                ...data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == data.length - 1;
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: isLast ? null : const Border(
                        bottom: BorderSide(color: Color(0xFFE5EFE8)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.material,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                item.requests.toString(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: _sdCritical,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5EFE8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (item.requests / 24).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _sdCritical,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                item.stock.toString(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: _sdSurplus,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5EFE8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (item.stock / 38).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _sdSurplus,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _buildStatusBadge(item),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EFE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Legend:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('Surplus', 'Stock > Demand', _sdSurplus),
                    _buildLegendItem('Balanced', 'Stock = Demand', _sdBalanced),
                    _buildLegendItem('Deficit', 'Stock < Demand', _sdDeficit),
                    _buildLegendItem('Critical', 'Stock < 50% Demand', _sdCritical),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MaterialSupplyData item) {
    Color color;
    String status;

    if (item.stock > item.requests) {
      color = _sdSurplus;
      status = 'Surplus';
    } else if (item.stock == item.requests) {
      color = _sdBalanced;
      status = 'Balanced';
    } else if (item.stock < item.requests * 0.5) {
      color = _sdCritical;
      status = 'Critical';
    } else {
      color = _sdDeficit;
      status = 'Deficit';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String status, String description, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class MaterialSupplyData {
  final String material;
  final int requests;
  final int stock;
  final String status;

  MaterialSupplyData(this.material, this.requests, this.stock, this.status);
}