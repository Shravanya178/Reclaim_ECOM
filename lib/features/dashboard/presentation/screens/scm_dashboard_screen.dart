import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCM Dashboard — Supply Chain Management Analytics
// 1. Inventory Health Report Card
// 2. Most-Requested Materials Bar Chart
// 3. Supply vs Demand Gap Table
// ─────────────────────────────────────────────────────────────────────────────

class ScmDashboardScreen extends ConsumerWidget {
  const ScmDashboardScreen({super.key});

  // ── DEMO DATA ──────────────────────────────────────────────────────────────

  static const _healthStats = [
    ('147',       'Total Products Listed',   Icons.inventory_2_outlined, AppTheme.primaryGreen),
    ('₹2,34,800', 'Estimated Inventory Value', Icons.currency_rupee,    Color(0xFF3182CE)),
    ('18',        'Low Stock Items',          Icons.warning_amber_rounded, Color(0xFFD69E2E)),
    ('7',         'Out of Stock',             Icons.error_outline,        Color(0xFFE53E3E)),
  ];

  static const _lowStockItems = [
    ('Copper Wire 1kg',    'Metal',      3, Color(0xFFD69E2E)),
    ('Steel Rod 1m',       'Metal',      2, Color(0xFFE53E3E)),
    ('Arduino Uno Rev3',   'Electronic', 4, Color(0xFFD69E2E)),
    ('Glass Beaker 250ml', 'Glassware',  1, Color(0xFFE53E3E)),
    ('Resistor Pack 100x', 'Electronic', 5, Color(0xFFD69E2E)),
    ('NaOH 500g',          'Chemical',   2, Color(0xFFE53E3E)),
  ];

  static const _barData = [
    ('Electronic Components', 24, AppTheme.primaryGreen),
    ('Plastic Polymers',      18, Color(0xFF3182CE)),
    ('Glassware',             14, Color(0xFFD69E2E)),
    ('Metal Alloys',           9, Color(0xFF805AD5)),
    ('Chemical Reagents',      6, Color(0xFFE53E3E)),
  ];

  static const _gapData = [
    ('Electronic Components', 24, 38, 'Surplus',  'Low',      Color(0xFF38A169)),
    ('Plastic Polymers',      18,  7, 'Deficit',  'High',     Color(0xFFE53E3E)),
    ('Glassware',             14, 12, 'Deficit',  'Medium',   Color(0xFFD69E2E)),
    ('Metal Alloys',           9,  3, 'Critical', 'Critical', Color(0xFFE53E3E)),
    ('Chemical Reagents',      6,  6, 'Balanced', 'Low',      Color(0xFF3182CE)),
    ('Optical Fibres',         5,  2, 'Deficit',  'High',     Color(0xFFE53E3E)),
    ('Safety Equipment',       4,  8, 'Surplus',  'Low',      Color(0xFF38A169)),
  ];

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/scm-dashboard',
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Supply Chain',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  DESKTOP
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(children: [
        // ── Hero Header ──
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primaryGreen, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 46),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.hub_outlined, size: 14, color: Colors.white70),
                            SizedBox(width: 6),
                            Text('Supply Chain', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SCM Analytics Dashboard',
                          style: TextStyle(
                            color: Colors.white, fontSize: 32,
                            fontWeight: FontWeight.w800, height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Monitor inventory health, demand patterns & supply gaps across all materials',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        Row(children: [
                          _heroCta(context, 'Lab Dashboard', Icons.science_outlined,
                              () => context.go('/lab-dashboard'), true),
                          const SizedBox(width: 14),
                          _heroCta(context, 'Inventory', Icons.inventory_2_outlined,
                              () => context.go('/inventory'), true),
                          const SizedBox(width: 14),
                          _heroCta(context, 'Shop', Icons.storefront_outlined,
                              () => context.go('/shop'), false),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  // SCM badge
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.hub, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      const Text('Supply Chain',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const Text('Management',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Live',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),

        // ── Content ──
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 1) INVENTORY HEALTH REPORT CARD
                _sectionTitle('Inventory Health Report'),
                const SizedBox(height: 16),
                _healthStatsRow(),
                const SizedBox(height: 20),
                _lowStockList(),
                const SizedBox(height: 44),

                // 2) MOST-REQUESTED MATERIALS BAR CHART
                _sectionTitle('Most-Requested Materials'),
                const SizedBox(height: 6),
                const Text(
                  'Top material categories by total student requests this semester',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                _barChart(),
                const SizedBox(height: 44),

                // 3) SUPPLY VS DEMAND GAP TABLE
                _sectionTitle('Supply vs Demand Gap'),
                const SizedBox(height: 6),
                const Text(
                  'Compares active request volume against available stock per material category',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                _gapTable(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),

        const WebFooter(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  MOBILE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Gradient header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SCM Analytics',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('Inventory · Demand · Gaps',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ),
            const Icon(Icons.hub, color: Colors.white60, size: 36),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Health stats 2×2
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: _healthStats.map((s) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EFE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(s.$3, color: s.$4, size: 22),
                    const SizedBox(height: 8),
                    Text(s.$1,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
                    Text(s.$2,
                        style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )).toList(),
            ),

            const SizedBox(height: 24),
            const Text('Low Stock Alert',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _lowStockList(),

            const SizedBox(height: 28),
            const Text('Most-Requested Materials',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _barChart(mobile: true),

            const SizedBox(height: 28),
            const Text('Supply vs Demand Gap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _gapTableMobile(),

            const SizedBox(height: 24),
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _heroCta(BuildContext context, String label, IconData ic, VoidCallback onTap, bool outline) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(ic, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: outline ? Colors.transparent : Colors.white,
          foregroundColor: outline ? Colors.white : AppTheme.primaryGreen,
          elevation: 0,
          side: outline ? const BorderSide(color: Colors.white54) : null,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800));

  // ─── 1. INVENTORY HEALTH STATS ROW ─────────────────────────────────────

  Widget _healthStatsRow() => Row(
    children: _healthStats.map((s) => Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EFE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: s.$4.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.$3, color: s.$4, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.$1,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: s.$4)),
                const SizedBox(height: 2),
                Text(s.$2,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ]),
      ),
    )).toList(),
  );

  // ─── LOW STOCK LIST ─────────────────────────────────────────────────────

  Widget _lowStockList() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD69E2E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD69E2E), size: 16),
          ),
          const SizedBox(width: 12),
          const Text('Low Stock / Out of Stock Items',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${_lowStockItems.length} items',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      // Items
      ..._lowStockItems.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F5F1))),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: item.$4.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.$3 <= 2 ? Icons.error_outline : Icons.warning_amber_rounded,
              color: item.$4,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(item.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: item.$4.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.$3 == 0 ? 'Out of Stock' : '${item.$3} left',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: item.$4),
            ),
          ),
        ]),
      )),
    ]),
  );

  // ─── 2. MOST-REQUESTED BAR CHART ───────────────────────────────────────

  Widget _barChart({bool mobile = false}) => Container(
    padding: EdgeInsets.all(mobile ? 16 : 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: SizedBox(
      height: mobile ? 220 : 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 30,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${_barData[group.x.toInt()].$1}\n',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} requests',
                      style: const TextStyle(
                        color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w400),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: mobile ? 50 : 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _barData.length) return const SizedBox();
                  final label = _barData[idx].$1;
                  // show abbreviated label
                  final short = label.length > 10 ? '${label.substring(0, 9)}…' : label;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      mobile ? short : label,
                      style: TextStyle(fontSize: mobile ? 9 : 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 6,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 6,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFEAF1EB),
              strokeWidth: 1,
            ),
          ),
          barGroups: List.generate(_barData.length, (i) {
            final d = _barData[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.$2.toDouble(),
                  width: mobile ? 22 : 36,
                  color: d.$3,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 30,
                    color: d.$3.withValues(alpha: 0.06),
                  ),
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    ),
  );

  // ─── 3. SUPPLY vs DEMAND GAP TABLE ─────────────────────────────────────

  Widget _gapTable() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(children: [
      // Header row
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FAF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: const Row(children: [
          Expanded(flex: 3, child: Text('MATERIAL TYPE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('REQUESTS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('STOCK',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('STATUS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 0.8))),
          Expanded(flex: 2, child: Text('PRIORITY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 0.8))),
        ]),
      ),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      // Rows
      ..._gapData.map((g) {
        final statusColor = _statusColor(g.$4);
        final priorityColor = _priorityColor(g.$5);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF0F5F1))),
          ),
          child: Row(children: [
            Expanded(flex: 3, child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: g.$6.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_categoryIcon(g.$1), color: g.$6, size: 16),
              ),
              const SizedBox(width: 12),
              Flexible(child: Text(g.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ])),
            Expanded(flex: 2, child: _countChip(g.$2, 'requests', const Color(0xFF3182CE))),
            Expanded(flex: 2, child: _countChip(g.$3, 'in stock', AppTheme.primaryGreen)),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(g.$4,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            )),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: priorityColor.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_priorityIcon(g.$5), size: 12, color: priorityColor),
                const SizedBox(width: 4),
                Text(g.$5,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: priorityColor)),
              ]),
            )),
          ]),
        );
      }),
      // Summary footer
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FAF8),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
        child: Row(children: [
          const Expanded(flex: 3, child: Text('TOTAL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
          Expanded(flex: 2, child: Text(
            '${_gapData.fold<int>(0, (sum, g) => sum + g.$2)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF3182CE)),
          )),
          Expanded(flex: 2, child: Text(
            '${_gapData.fold<int>(0, (sum, g) => sum + g.$3)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
          )),
          const Expanded(flex: 2, child: SizedBox()),
          const Expanded(flex: 2, child: SizedBox()),
        ]),
      ),
    ]),
  );

  // ─── MOBILE GAP TABLE (card-based) ──────────────────────────────────────

  Widget _gapTableMobile() => Column(
    children: _gapData.map((g) {
      final statusColor = _statusColor(g.$4);
      final priorityColor = _priorityColor(g.$5);
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EFE8)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: g.$6.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_categoryIcon(g.$1), color: g.$6, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(g.$1,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_priorityIcon(g.$5), size: 10, color: priorityColor),
                const SizedBox(width: 3),
                Text(g.$5, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _miniStat('Requests', '${g.$2}', const Color(0xFF3182CE)),
            const SizedBox(width: 12),
            _miniStat('Stock', '${g.$3}', AppTheme.primaryGreen),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(g.$4,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ]),
        ]),
      );
    }).toList(),
  );

  // ─── HELPERS ────────────────────────────────────────────────────────────

  Widget _countChip(int count, String label, Color color) => Row(
    children: [
      Text('$count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    ],
  );

  Widget _miniStat(String label, String value, Color color) => Row(
    children: [
      Text('$label: ', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    ],
  );

  static Color _statusColor(String status) {
    switch (status) {
      case 'Critical': return const Color(0xFFE53E3E);
      case 'Deficit':  return const Color(0xFFD69E2E);
      case 'Balanced': return const Color(0xFF3182CE);
      case 'Surplus':  return const Color(0xFF38A169);
      default:         return AppTheme.textSecondary;
    }
  }

  static Color _priorityColor(String priority) {
    switch (priority) {
      case 'Critical': return const Color(0xFFE53E3E);
      case 'High':     return const Color(0xFFE53E3E);
      case 'Medium':   return const Color(0xFFD69E2E);
      case 'Low':      return const Color(0xFF38A169);
      default:         return AppTheme.textSecondary;
    }
  }

  static IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'Critical': return Icons.priority_high;
      case 'High':     return Icons.arrow_upward;
      case 'Medium':   return Icons.remove;
      case 'Low':      return Icons.arrow_downward;
      default:         return Icons.remove;
    }
  }

  static IconData _categoryIcon(String category) {
    if (category.contains('Electronic'))       return Icons.memory;
    if (category.contains('Plastic'))          return Icons.recycling;
    if (category.contains('Glass'))            return Icons.science;
    if (category.contains('Metal'))            return Icons.hardware;
    if (category.contains('Chemical'))         return Icons.biotech;
    if (category.contains('Optical'))          return Icons.light_mode;
    if (category.contains('Safety'))           return Icons.health_and_safety;
    return Icons.category;
  }
}
