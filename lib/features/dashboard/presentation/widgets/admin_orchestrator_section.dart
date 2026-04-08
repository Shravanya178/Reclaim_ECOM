import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';

class AdminOrchestratorSection extends StatefulWidget {
  const AdminOrchestratorSection({super.key});

  @override
  State<AdminOrchestratorSection> createState() => _AdminOrchestratorSectionState();
}

class _ActionItem {
  final String id;
  final String label;
  final int queueDelta;
  final int issuesDelta;
  final int slaDelta;
  final int roasDelta;
  final int csatDelta;
  final int riskDelta;

  const _ActionItem({
    required this.id,
    required this.label,
    this.queueDelta = 0,
    this.issuesDelta = 0,
    this.slaDelta = 0,
    this.roasDelta = 0,
    this.csatDelta = 0,
    this.riskDelta = 0,
  });
}

class _ActionLog {
  final String tab;
  final String action;
  final DateTime time;

  const _ActionLog({required this.tab, required this.action, required this.time});
}

class _Complaint {
  final String customer;
  final String material;
  final String issue;
  final String severity;
  final bool resolved;

  const _Complaint({
    required this.customer,
    required this.material,
    required this.issue,
    required this.severity,
    required this.resolved,
  });

  _Complaint copyWith({bool? resolved}) {
    return _Complaint(
      customer: customer,
      material: material,
      issue: issue,
      severity: severity,
      resolved: resolved ?? this.resolved,
    );
  }
}

class _InteractionPulse {
  final String customer;
  final String material;
  final String trigger;
  final String message;
  final String status;

  const _InteractionPulse({
    required this.customer,
    required this.material,
    required this.trigger,
    required this.message,
    required this.status,
  });

  _InteractionPulse copyWith({String? message, String? status}) {
    return _InteractionPulse(
      customer: customer,
      material: material,
      trigger: trigger,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}

class _MaterialControl {
  final String material;
  final double rating;
  final int likes;
  final String reviewTrend;
  final String placement;
  final String supplierAction;
  final bool highlighted;
  final bool mainLanding;
  final bool contactSupplier;
  final bool discount;

  const _MaterialControl({
    required this.material,
    required this.rating,
    required this.likes,
    required this.reviewTrend,
    required this.placement,
    required this.supplierAction,
    required this.highlighted,
    required this.mainLanding,
    required this.contactSupplier,
    required this.discount,
  });

  _MaterialControl copyWith({
    bool? highlighted,
    bool? mainLanding,
    bool? contactSupplier,
    bool? discount,
    String? placement,
    String? supplierAction,
  }) {
    return _MaterialControl(
      material: material,
      rating: rating,
      likes: likes,
      reviewTrend: reviewTrend,
      placement: placement ?? this.placement,
      supplierAction: supplierAction ?? this.supplierAction,
      highlighted: highlighted ?? this.highlighted,
      mainLanding: mainLanding ?? this.mainLanding,
      contactSupplier: contactSupplier ?? this.contactSupplier,
      discount: discount ?? this.discount,
    );
  }
}

class _AdminOrchestratorSectionState extends State<AdminOrchestratorSection> {
  static const List<String> _tabs = [
    'Overview',
    'SCM',
    'Revenue',
    'Marketing',
    'CRM',
    'Security',
    'ERP',
  ];

  static const Map<String, List<_ActionItem>> _actionsByTab = {
    'Overview': [
      _ActionItem(id: 'ov1', label: 'Refresh cross-module signals', queueDelta: -1, slaDelta: 1),
      _ActionItem(id: 'ov2', label: 'Escalate top open blockers', issuesDelta: -1, csatDelta: 1),
    ],
    'SCM': [
      _ActionItem(id: 's1', label: 'Fast-track verification', queueDelta: -4, slaDelta: 2),
      _ActionItem(id: 's2', label: 'SLA routing rebalance', queueDelta: -2, issuesDelta: -1, slaDelta: 3),
      _ActionItem(id: 's3', label: 'Legal desk burst mode', slaDelta: 2, csatDelta: 1),
    ],
    'Revenue': [
      _ActionItem(id: 'r1', label: 'Boost spotlight package', roasDelta: 2),
      _ActionItem(id: 'r2', label: 'Optimize commission rule', issuesDelta: -1, roasDelta: 1),
      _ActionItem(id: 'r3', label: 'Flag payout anomalies', riskDelta: -1, issuesDelta: -1),
    ],
    'Marketing': [
      _ActionItem(id: 'm1', label: 'Pause low CTR creatives', roasDelta: 1, issuesDelta: -1),
      _ActionItem(id: 'm2', label: 'Increase referral bonus', roasDelta: 2, csatDelta: 1),
      _ActionItem(id: 'm3', label: 'SEO quick-win push', queueDelta: 1, roasDelta: 1),
    ],
    'CRM': [
      _ActionItem(id: 'c1', label: 'Run complaint SLA escalation', issuesDelta: -2, slaDelta: 2),
      _ActionItem(id: 'c2', label: 'Launch retention recovery flow', csatDelta: 2, riskDelta: -1),
      _ActionItem(id: 'c3', label: 'Auto-route unresolved tickets', queueDelta: -2, issuesDelta: -1),
    ],
    'Security': [
      _ActionItem(id: 'sec1', label: 'Lock high-risk sessions', riskDelta: -2),
      _ActionItem(id: 'sec2', label: 'Run audit log scan', issuesDelta: -1, slaDelta: 1),
      _ActionItem(id: 'sec3', label: 'Revalidate RBAC mappings', riskDelta: -1),
    ],
    'ERP': [
      _ActionItem(id: 'erp1', label: 'Reconcile procurement queues', queueDelta: -2, slaDelta: 1),
      _ActionItem(id: 'erp2', label: 'Close finance posting exceptions', issuesDelta: -2),
    ],
  };

  static const List<_Complaint> _seedComplaints = [
    _Complaint(customer: 'Aditi Shah', material: 'Copper Wire Batch CW-14', issue: 'Weight mismatch in intake log', severity: 'Critical', resolved: false),
    _Complaint(customer: 'Rohit Nair', material: 'PCB Salvage Kit PK-22', issue: 'Duplicate allocation in request board', severity: 'High', resolved: false),
    _Complaint(customer: 'Nisha Iyer', material: 'Glassware Bundle GB-09', issue: 'Document upload failed for transfer', severity: 'Moderate', resolved: false),
    _Complaint(customer: 'Aman Verma', material: 'Lithium Cell Lot LC-31', issue: 'Settlement timeline mismatch', severity: 'High', resolved: false),
  ];

  static const List<_InteractionPulse> _seedInteractions = [
    _InteractionPulse(customer: 'Aditi Shah', material: 'Copper Wire Batch CW-14', trigger: 'Low stock alert', message: 'Alternative batch recommendation sent', status: 'Open'),
    _InteractionPulse(customer: 'Rohit Nair', material: 'PCB Salvage Kit PK-22', trigger: 'Transfer request callback', message: 'Ops follow-up queued', status: 'In Progress'),
    _InteractionPulse(customer: 'Nisha Iyer', material: 'Glassware Bundle GB-09', trigger: 'Reuse quality sentiment dip', message: 'Retention guidance issued', status: 'Open'),
    _InteractionPulse(customer: 'Aman Verma', material: 'Lithium Cell Lot LC-31', trigger: 'Checkout abandonment', message: 'Incentive reminder sent', status: 'Open'),
  ];

  static const List<_MaterialControl> _seedMaterialControls = [
    _MaterialControl(
      material: 'Copper Wire Batch CW-14',
      rating: 4.4,
      likes: 182,
      reviewTrend: 'Rising',
      placement: 'Category Featured',
      supplierAction: 'Awaiting supplier confirmation',
      highlighted: false,
      mainLanding: false,
      contactSupplier: false,
      discount: false,
    ),
    _MaterialControl(
      material: 'PCB Salvage Kit PK-22',
      rating: 4.1,
      likes: 134,
      reviewTrend: 'Stable',
      placement: 'Search Result Tier 2',
      supplierAction: 'Supplier active in chat',
      highlighted: true,
      mainLanding: false,
      contactSupplier: true,
      discount: false,
    ),
    _MaterialControl(
      material: 'Glassware Bundle GB-09',
      rating: 3.9,
      likes: 92,
      reviewTrend: 'Recovering',
      placement: 'Campaign Carousel',
      supplierAction: 'Compliance docs pending',
      highlighted: false,
      mainLanding: true,
      contactSupplier: false,
      discount: false,
    ),
  ];

  String _activeTab = 'Overview';

  int _verificationQueue = 39;
  int _paymentIssues = 11;
  int _agentSla = 88;
  int _roas = 315;
  int _csat = 83;
  int _riskUsers = 7;
  int _scmBoost = 0;
  int _marketingLeadLift = 0;
  int _securityMitigationCount = 0;
  double _revenueFactor = 1.0;

  String _lastActionStatus = 'No action executed yet';
  final List<_ActionLog> _recentActions = [];

  List<_Complaint> _complaints = List<_Complaint>.from(_seedComplaints);
  List<_InteractionPulse> _interactions = List<_InteractionPulse>.from(_seedInteractions);
  List<_MaterialControl> _materialControls = List<_MaterialControl>.from(_seedMaterialControls);

  int _memoVersion = 0;
  int _memoLastVersion = -1;
  Map<String, int> _memoDerived = const {};

  void _invalidateMemo() {
    _memoVersion += 1;
  }

  Map<String, int> _derived() {
    if (_memoVersion == _memoLastVersion) {
      return _memoDerived;
    }

    final unresolved = _complaints.where((c) => !c.resolved).toList();
    _memoDerived = {
      'critical': unresolved.where((c) => c.severity == 'Critical').length,
      'high': unresolved.where((c) => c.severity == 'High').length,
      'moderate': unresolved.where((c) => c.severity == 'Moderate').length,
    };
    _memoLastVersion = _memoVersion;
    return _memoDerived;
  }

  void _executeAction(_ActionItem action) {
    setState(() {
      _verificationQueue = (_verificationQueue + action.queueDelta).clamp(0, 999);
      _paymentIssues = (_paymentIssues + action.issuesDelta).clamp(0, 999);
      _agentSla = (_agentSla + action.slaDelta).clamp(0, 100);
      _roas = (_roas + action.roasDelta).clamp(0, 999);
      _csat = (_csat + action.csatDelta).clamp(0, 100);
      _riskUsers = (_riskUsers + action.riskDelta).clamp(0, 999);
      switch (_activeTab) {
        case 'SCM':
          _scmBoost += 2;
          break;
        case 'Revenue':
          _revenueFactor = (_revenueFactor + 0.02).clamp(1.0, 1.5);
          break;
        case 'Marketing':
          _marketingLeadLift += 22;
          break;
        case 'CRM':
          final idx = _complaints.indexWhere((c) => !c.resolved);
          if (idx != -1) {
            _complaints[idx] = _complaints[idx].copyWith(resolved: true);
          }
          break;
        case 'Security':
          _securityMitigationCount += 1;
          break;
        case 'ERP':
          _paymentIssues = (_paymentIssues - 1).clamp(0, 999);
          _agentSla = (_agentSla + 1).clamp(0, 100);
          break;
      }
      _lastActionStatus = '${action.label} executed in $_activeTab';
      _recentActions.insert(0, _ActionLog(tab: _activeTab, action: action.label, time: DateTime.now()));
      if (_recentActions.length > 14) {
        _recentActions.removeLast();
      }
      _invalidateMemo();
    });
  }

  void _resolveComplaint(int index) {
    if (_complaints[index].resolved) {
      return;
    }

    setState(() {
      _complaints[index] = _complaints[index].copyWith(resolved: true);
      _paymentIssues = (_paymentIssues - 1).clamp(0, 999);
      _csat = (_csat + 1).clamp(0, 100);
      _lastActionStatus = 'Complaint resolved for ${_complaints[index].customer}';
      _recentActions.insert(0, _ActionLog(tab: 'CRM', action: 'Resolve complaint', time: DateTime.now()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resolved complaint for ${_complaints[index].customer}')),
        );
      }
      _invalidateMemo();
    });
  }

  void _toggleMaterialAction(int index, String action) {
    final control = _materialControls[index];
    _MaterialControl next = control;

    if (action == 'Highlight') {
      next = control.copyWith(highlighted: !control.highlighted, placement: 'Category Featured');
    } else if (action == 'Priority Queue') {
      next = control.copyWith(mainLanding: !control.mainLanding, placement: 'Priority Queue');
    } else if (action == 'Contact Supplier') {
      next = control.copyWith(contactSupplier: !control.contactSupplier, supplierAction: 'Supplier contacted for faster closure');
    } else if (action == 'Give Discount') {
      final nowDiscount = !control.discount;
      next = control.copyWith(discount: nowDiscount, supplierAction: nowDiscount ? 'Discount approved by supplier' : 'Discount revoked');

      final pulseIndex = _interactions.indexWhere((i) => i.material == control.material);
      if (pulseIndex != -1) {
        _interactions[pulseIndex] = _interactions[pulseIndex].copyWith(
          message: nowDiscount ? 'Discount offer auto-shared with customer' : 'Discount offer withdrawn',
          status: nowDiscount ? 'Resolved' : 'In Progress',
        );
      }
    }

    setState(() {
      _materialControls[index] = next;
      _lastActionStatus = '$action updated for ${control.material}';
      _recentActions.insert(0, _ActionLog(tab: 'CRM', action: action, time: DateTime.now()));
      if (_recentActions.length > 14) {
        _recentActions.removeLast();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action applied to ${control.material}')),
        );
      }
    });
  }

  String _timeString(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(dt.hour)}:${p(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 980;
    final derived = _derived();

    return _panel(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.primarySurface,
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Global Admin Orchestrator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      SizedBox(height: 2),
                      Text('State machine + conditional renderer for SCM, Revenue, Marketing, CRM, Security, and ERP.',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isMobile)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tabs
                    .map((t) => ChoiceChip(
                          label: Text(t),
                          selected: _activeTab == t,
                          onSelected: (_) => setState(() => _activeTab = t),
                        ))
                    .toList(),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _leftSidebar(),
                  const SizedBox(width: 14),
                  Expanded(child: _mainArea(derived)),
                ],
              ),
            if (isMobile) ...[
              const SizedBox(height: 10),
              _mainArea(derived),
            ],
          ],
        ),
      ),
    );
  }

  Widget _leftSidebar() {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE9E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Navigation', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          ..._tabs.map(
            (tab) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _activeTab = tab),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: _activeTab == tab ? AppTheme.primaryGreen.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _activeTab == tab ? AppTheme.primaryGreen.withValues(alpha: 0.35) : const Color(0xFFD9E4DC),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: _activeTab == tab ? AppTheme.primaryGreen : AppTheme.textSecondary,
                      fontWeight: _activeTab == tab ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainArea(Map<String, int> derived) {
    final actions = _actionsByTab[_activeTab] ?? const <_ActionItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _actionCenter(actions),
        const SizedBox(height: 10),
        _operationCards(),
        const SizedBox(height: 10),
        _recentActionsCard(),
        const SizedBox(height: 10),
        _advancedWebFeaturesCard(),
        const SizedBox(height: 10),
        _tabBody(derived),
      ],
    );
  }

  Widget _advancedWebFeaturesCard() {
    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Advanced Web Features', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 5),
            const Text(
              'SCM automated triggers, SCM pull/push controls, and CRM lifecycle tracking are available as dedicated web features.',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/scm-dashboard'),
                  icon: const Icon(Icons.hub_outlined, size: 16),
                  label: const Text('SCM Triggers Console'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/business-engine?role=admin'),
                  icon: const Icon(Icons.swap_horiz_outlined, size: 16),
                  label: const Text('SCM Pull/Push Planner'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/business-engine?role=admin'),
                  icon: const Icon(Icons.track_changes_outlined, size: 16),
                  label: const Text('CRM Lifecycle Tracking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCenter(List<_ActionItem> actions) {
    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Action Center', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map(
                    (a) => OutlinedButton.icon(
                      onPressed: () => _executeAction(a),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(a.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text('Last action status: $_lastActionStatus', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _operationCards() {
    final cards = [
      ('Verification Queue', '$_verificationQueue', Icons.timelapse_outlined, AppTheme.warning),
      ('Payment Issues', '$_paymentIssues', Icons.error_outline, AppTheme.error),
      ('Agent SLA', '$_agentSla%', Icons.rule_folder_outlined, AppTheme.primaryGreen),
      ('ROAS', '$_roas', Icons.trending_up, AppTheme.info),
      ('CSAT', '$_csat%', Icons.mood_outlined, AppTheme.success),
      ('Risk Users', '$_riskUsers', Icons.shield_outlined, const Color(0xFF6A1B9A)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cards.map((c) => _metricCard(c.$1, c.$2, c.$3, c.$4)).toList(),
    );
  }

  Widget _recentActionsCard() {
    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Executed Actions', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            if (_recentActions.isEmpty)
              const Text('No simulated actions yet.', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary))
            else
              ..._recentActions.take(6).map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${_timeString(a.time)}  ${a.tab}: ${a.action}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tabBody(Map<String, int> derived) {
    return switch (_activeTab) {
      'Overview' => _buildOverviewTab(),
      'SCM' => _buildScmTab(),
      'Revenue' => _buildRevenueTab(),
      'Marketing' => _buildMarketingTab(),
      'CRM' => _buildCrmTab(derived),
      'Security' => _buildSecurityTab(),
      _ => _buildErpTab(),
    };
  }

  Widget _buildOverviewTab() {
    const monthlyRevenue = [88, 96, 110, 117, 121, 136, 140, 149, 157, 166, 174, 188];
    const citySales = [
      ('VESIT', 138),
      ('TSEC', 92),
      ('SPIT', 74),
      ('VJTI', 68),
      ('ICT', 59),
    ];
    const typeSplit = [
      ('Electronics', 42),
      ('Metals', 24),
      ('Chemicals', 18),
      ('Glassware', 16),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _KpiCard(title: 'Total Revenue', value: 'Rs 38.4M', change: '+13%'),
            _KpiCard(title: 'Active Material Batches', value: '1,284', change: '+8%'),
            _KpiCard(title: 'New Users (Month)', value: '432', change: '+16%'),
            _KpiCard(title: 'Avg Deal Value', value: 'Rs 1.82L', change: '+5%'),
          ],
        ),
        const SizedBox(height: 10),
        _chartCard(
          'Monthly Revenue (12 months)',
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text('M${v.toInt() + 1}', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(monthlyRevenue.length, (i) => FlSpot(i.toDouble(), monthlyRevenue[i].toDouble())),
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryGreen.withValues(alpha: 0.14)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 500,
              child: _chartCard(
                'Materials Processed by Campus',
                SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= citySales.length) return const SizedBox.shrink();
                              return Text(citySales[i].$1, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        citySales.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(toY: citySales[i].$2.toDouble(), width: 18, color: const Color(0xFF2E7D32))],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 360,
              child: _chartCard(
                'Material Category Distribution',
                SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(value: typeSplit[0].$2.toDouble(), title: 'Elec', color: const Color(0xFF2E7D32)),
                        PieChartSectionData(value: typeSplit[1].$2.toDouble(), title: 'Metal', color: const Color(0xFF1976D2)),
                        PieChartSectionData(value: typeSplit[2].$2.toDouble(), title: 'Chem', color: const Color(0xFFEF6C00)),
                        PieChartSectionData(value: typeSplit[3].$2.toDouble(), title: 'Glass', color: const Color(0xFF6A1B9A)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScmTab() {
    const funnel = [
      ('Submitted', 220),
      ('Verified', 168),
      ('Live', 132),
      ('Sold', 86),
    ];
    const legalTat = [
      ('KYC Check', 18),
      ('Stamp Duty', 26),
      ('Agreement', 34),
      ('Compliance Review', 22),
    ];
    const vendorRows = [
      ('EcoMetals Cooperative', 'Verified', 32, '94%', 'Low'),
      ('CircuitLoop Works', 'Pending', 18, '86%', 'Medium'),
      ('GlassCycle Hub', 'Verified', 27, '91%', 'Low'),
      ('BioReuse Labs', 'Verified', 14, '88%', 'Medium'),
      ('PowerRecover Cells', 'Flagged', 9, '74%', 'High'),
    ];
    const escrowTimeline = [
      ('Escrow Open', 2.2),
      ('Document Match', 1.8),
      ('Payment Clear', 3.1),
      ('Settlement', 2.4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Automation uplift from actions: +$_scmBoost throughput points', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('SCM Supply Flow', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 5),
                Text('Tracks onboarding to settlement with queue pressure, legal turnaround, and closure logistics.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _KpiCard(title: 'Vendors Onboarded', value: '146', change: '+11%'),
            _KpiCard(title: 'Verification Queue', value: '39', change: '-7%'),
            _KpiCard(title: 'Agent SLA Compliance', value: '88%', change: '+4%'),
            _KpiCard(title: 'Avg Legal TAT', value: '26h', change: '-9%'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 500,
              child: _chartCard(
                'Material Supply Funnel',
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= funnel.length) return const SizedBox.shrink();
                              return Text(funnel[i].$1, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        funnel.length,
                        (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: funnel[i].$2.toDouble(), width: 20, color: const Color(0xFF2E7D32))]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 360,
              child: _chartCard(
                'Legal Document Turnaround (hours)',
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= legalTat.length) return const SizedBox.shrink();
                              return Text(legalTat[i].$1.split(' ').first, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        legalTat.length,
                        (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: legalTat[i].$2.toDouble(), width: 16, color: const Color(0xFF1976D2))]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Vendor Onboarding Table',
          DataTable(
            columns: const [
              DataColumn(label: Text('Vendor')),
              DataColumn(label: Text('KYC')),
              DataColumn(label: Text('Batches')),
              DataColumn(label: Text('SLA')),
              DataColumn(label: Text('Risk')),
            ],
            rows: vendorRows
                .map((v) => DataRow(cells: [
                      DataCell(Text(v.$1)),
                      DataCell(Text(v.$2)),
                      DataCell(Text('${v.$3}')),
                      DataCell(Text(v.$4)),
                      DataCell(Text(v.$5)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _chartCard(
          'Escrow and Settlement Timeline (avg days)',
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= escrowTimeline.length) return const SizedBox.shrink();
                        return Text(escrowTimeline[i].$1.split(' ').first, style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  escrowTimeline.length,
                  (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: escrowTimeline[i].$2, width: 18, color: const Color(0xFFEF6C00))]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueTab() {
    final tunedRevenue = (50.4 * _revenueFactor).toStringAsFixed(1);
    final tunedCommission = (6.4 * _revenueFactor).toStringAsFixed(1);
    final tunedSettlement = (42.8 * _revenueFactor).toStringAsFixed(1);
    const commissionVsBuilder = [
      ('Copper Wire', 24, 176),
      ('PCB Kit', 19, 142),
      ('Glassware', 16, 118),
      ('Li-Ion Cells', 21, 154),
    ];
    const streamSplit = [
      ('Website Commission', 52),
      ('Supplier Settlement Delta', 18),
      ('Spotlight Ads', 17),
      ('Affiliate', 13),
    ];

    const txnRows = [
      ('Copper Wire CW-14', 'EcoMetals', 'Rs 8,40,000', '4.2%', 'Rs 35,280', 'Rs 8,04,720'),
      ('PCB Kit PK-22', 'CircuitLoop', 'Rs 6,20,000', '4.0%', 'Rs 24,800', 'Rs 5,95,200'),
      ('Glassware GB-09', 'GlassCycle', 'Rs 5,10,000', '3.8%', 'Rs 19,380', 'Rs 4,90,620'),
      ('Li-Ion Cells LC-31', 'PowerRecover', 'Rs 7,30,000', '4.1%', 'Rs 29,930', 'Rs 7,00,070'),
    ];

    const spotlightRows = [
      ('Copper Wire Campaign', 'Karan Patil', 'Gold 30 Days', 'Rs 72,000', '218'),
      ('PCB Recovery Campaign', 'Pooja Nair', 'Silver 20 Days', 'Rs 46,000', '144'),
      ('Glassware Reuse Campaign', 'Isha Shah', 'Gold 30 Days', 'Rs 58,000', '176'),
    ];

    const affiliateRows = [
      ('LoanKart', 'Equipment Finance', 'Aditi Shah', 'Copper Wire CW-14', 'Rs 8,40,000', 'Rs 18,000', 'Rs 26,000'),
      ('InteriorPlus', 'Lab Retrofit', 'Rohit Nair', 'PCB Kit PK-22', 'Rs 6,20,000', 'Rs 9,500', 'Rs 15,000'),
      ('InsureHub', 'Hazard Coverage', 'Nisha Iyer', 'Glassware GB-09', 'Rs 5,10,000', 'Rs 8,800', 'Rs 12,600'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiCard(title: 'Website Commission', value: 'Rs ${tunedCommission}M', change: '+12%'),
            _KpiCard(title: 'Supplier Settlement', value: 'Rs ${tunedSettlement}M', change: '+9%'),
            _KpiCard(title: 'Spotlight Ad Revenue', value: 'Rs 1.2M', change: '+17%'),
            _KpiCard(title: 'Total Revenue Tracked', value: 'Rs ${tunedRevenue}M', change: '+11%'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 520,
              child: _chartCard(
                'Commission vs Supplier Settlement',
                SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= commissionVsBuilder.length) return const SizedBox.shrink();
                              return Text(commissionVsBuilder[i].$1.split(' ').first, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        commissionVsBuilder.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(toY: commissionVsBuilder[i].$2.toDouble(), width: 10, color: const Color(0xFF2E7D32)),
                            BarChartRodData(toY: commissionVsBuilder[i].$3.toDouble(), width: 10, color: const Color(0xFF1976D2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 340,
              child: _chartCard(
                'Revenue Streams Distribution',
                SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: [
                        PieChartSectionData(value: streamSplit[0].$2.toDouble(), title: 'Com', color: const Color(0xFF2E7D32)),
                        PieChartSectionData(value: streamSplit[1].$2.toDouble(), title: 'Build', color: const Color(0xFF1976D2)),
                        PieChartSectionData(value: streamSplit[2].$2.toDouble(), title: 'Ads', color: const Color(0xFFEF6C00)),
                        PieChartSectionData(value: streamSplit[3].$2.toDouble(), title: 'Aff', color: const Color(0xFF6A1B9A)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Transaction Breakdown',
          DataTable(
            columns: const [
              DataColumn(label: Text('Material Batch')),
              DataColumn(label: Text('Supplier')),
              DataColumn(label: Text('Transaction Value')),
              DataColumn(label: Text('Commission %')),
              DataColumn(label: Text('NestBridge Commission')),
              DataColumn(label: Text('Supplier Amount')),
            ],
            rows: txnRows
                .map((t) => DataRow(cells: [
                      DataCell(Text(t.$1)),
                      DataCell(Text(t.$2)),
                      DataCell(Text(t.$3)),
                      DataCell(Text(t.$4)),
                      DataCell(Text(t.$5)),
                      DataCell(Text(t.$6)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Spotlight Advertising Revenue',
          DataTable(
            columns: const [
              DataColumn(label: Text('Promoted Material Campaign')),
              DataColumn(label: Text('Agent')),
              DataColumn(label: Text('Spotlight Package')),
              DataColumn(label: Text('Ad Revenue')),
              DataColumn(label: Text('Leads')),
            ],
            rows: spotlightRows
                .map((s) => DataRow(cells: [
                      DataCell(Text(s.$1)),
                      DataCell(Text(s.$2)),
                      DataCell(Text(s.$3)),
                      DataCell(Text(s.$4)),
                      DataCell(Text(s.$5)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Affiliate Model',
          DataTable(
            columns: const [
              DataColumn(label: Text('Affiliate Partner')),
              DataColumn(label: Text('Model')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Linked Material Batch')),
              DataColumn(label: Text('Transaction Value')),
              DataColumn(label: Text('Partner Payout')),
              DataColumn(label: Text('NestBridge Earning')),
            ],
            rows: affiliateRows
                .map((a) => DataRow(cells: [
                      DataCell(Text(a.$1)),
                      DataCell(Text(a.$2)),
                      DataCell(Text(a.$3)),
                      DataCell(Text(a.$4)),
                      DataCell(Text(a.$5)),
                      DataCell(Text(a.$6)),
                      DataCell(Text(a.$7)),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketingTab() {
    final paidLeads = 1263 + _marketingLeadLift;
    const creatives = [
      ('Campus Resale Sprint', 'Video', '120k', '7.4k', '310'),
      ('Zero Waste Drive', 'Carousel', '98k', '5.6k', '274'),
      ('Reclaim Rewards', 'Static', '84k', '4.9k', '193'),
      ('Smart Supplier Weekend', 'Video', '76k', '4.1k', '182'),
      ('Verified Deals Push', 'Carousel', '64k', '3.7k', '141'),
      ('Student Referral Week', 'Static', '58k', '3.5k', '138'),
    ];

    const framework = [
      ('Digital Marketing', 'Strong reach among student clusters.'),
      ('Paid Ads', 'Fast demand generation with creative testing.'),
      ('SEO', 'Compounding intent-driven traffic.'),
      ('Referral', 'High-trust low-CAC acquisition channel.'),
    ];

    const platformPerf = [
      ('Instagram', 82),
      ('YouTube', 61),
      ('LinkedIn', 43),
      ('X', 35),
    ];

    const paidAds = [
      ('Google', 74, 260),
      ('Meta', 63, 224),
    ];

    const seoTable = [
      ('reclaimed electronic components', 7, '18k'),
      ('verified material intake', 4, '11k'),
      ('campus circular economy', 3, '6k'),
      ('sustainable lab sourcing', 8, '9k'),
    ];

    const seoGrowth = [18, 22, 26, 28, 31, 36, 42, 47, 50, 54, 58, 63];
    const referralGrowth = [12, 14, 16, 18, 20, 24, 27, 29, 33, 36, 39, 43];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ad Creatives', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: creatives
                      .map(
                        (c) => Container(
                          width: 260,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE1ECE4)),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 78,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE6F4EA), Color(0xFFD7EAF8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(child: Icon(Icons.image_outlined, color: AppTheme.primaryGreen)),
                              ),
                              const SizedBox(height: 6),
                              Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('Type: ${c.$2}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              const SizedBox(height: 4),
                              Text('Impressions ${c.$3}  |  Clicks ${c.$4}  |  Leads ${c.$5}', style: const TextStyle(fontSize: 12.5)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marketing Framework', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: framework
                      .map((f) => _miniInfoCard(f.$1, f.$2, Icons.hub_outlined, AppTheme.primaryGreen))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiCard(title: 'Digital Reach', value: '564k', change: '+18%'),
            _KpiCard(title: 'Digital Likes', value: '41k', change: '+11%'),
            _KpiCard(title: 'Digital Inquiries', value: '2,184', change: '+14%'),
            _KpiCard(title: 'Paid Leads', value: '$paidLeads', change: '+9%'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 450,
              child: _chartCard(
                'Digital Marketing Performance by Platform',
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= platformPerf.length) return const SizedBox.shrink();
                              return Text(platformPerf[i].$1, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(platformPerf.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: platformPerf[i].$2.toDouble(), width: 18, color: const Color(0xFF2E7D32))])),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 430,
              child: _chartCard(
                'Paid Advertising (Google + Meta)',
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= paidAds.length) return const SizedBox.shrink();
                              return Text(paidAds[i].$1, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        paidAds.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(toY: paidAds[i].$2.toDouble(), width: 12, color: const Color(0xFF1976D2)),
                            BarChartRodData(toY: paidAds[i].$3.toDouble(), width: 12, color: const Color(0xFFEF6C00)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tableCard(
          'SEO Keywords',
          DataTable(
            columns: const [
              DataColumn(label: Text('Keyword')),
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text('Monthly Searches')),
            ],
            rows: seoTable
                .map((s) => DataRow(cells: [
                      DataCell(Text(s.$1)),
                      DataCell(Text('${s.$2}')),
                      DataCell(Text(s.$3)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 430,
              child: _chartCard('SEO Organic Traffic Growth', _line12Chart(seoGrowth, const Color(0xFF2E7D32))),
            ),
            SizedBox(
              width: 430,
              child: _chartCard('Referral Marketing Growth', _line12Chart(referralGrowth, const Color(0xFF1565C0))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Paid Search Example Insight', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 6),
                Text('Keyword: verified reclaimed components', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Impressions: 42,800  |  Clicks: 2,460  |  Leads: 318', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                SizedBox(height: 2),
                Text('Conversion note: Leads from this cluster show 1.4x higher booking value.', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrmTab(Map<String, int> derived) {
    const feedbackCategories = [
      ('Payments', 30),
      ('Support Delay', 24),
      ('Material Quality', 18),
      ('Negotiation', 16),
      ('Platform UX', 12),
    ];
    const issueHotspots = [
      ('Payment mismatch', 12, 'Open', 'High'),
      ('Document rejection', 8, 'In Progress', 'Medium'),
      ('Agent delay', 10, 'Open', 'High'),
      ('Escrow status lag', 6, 'Resolved', 'Low'),
    ];
    const supportCats = [
      ('Billing', 31),
      ('KYC', 22),
      ('Escrow', 17),
      ('Supplier Comms', 14),
    ];
    const csatTrend = [69, 71, 73, 74, 76, 78, 79, 80, 81, 82, 83, 84];
    const workflow = [
      ('Ingestion', 320, '96%'),
      ('Classification', 314, '95%'),
      ('Priority scoring', 304, '93%'),
      ('Escalation', 148, '88%'),
      ('Fix SLA', 132, '86%'),
      ('Post-fix CSAT', 122, '84%'),
    ];
    const rules = [
      ('Payment mismatch > Rs 10k', 'Auto-escalate to finance desk', 'Finance Ops'),
      ('Complaint unresolved > 24h', 'SLA ping + manager alert', 'Support Lead'),
      ('Low sentiment + high value customer', 'Retention incentive push', 'CRM Automation'),
      ('Supplier no response in 4h', 'Auto call task + message fallback', 'Service Desk'),
    ];
    const impact = [
      ('Avg resolution time', '36h', '19h'),
      ('First response SLA', '68%', '89%'),
      ('CSAT', '72%', '84%'),
      ('Escalation backlog', '41', '17'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CRM Command Center', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                const Text('Live service quality and retention control layer', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _severityCard('Critical', '${derived['critical']}', const Color(0xFFC62828)),
                    _severityCard('High', '${derived['high']}', const Color(0xFFEF6C00)),
                    _severityCard('Moderate', '${derived['moderate']}', const Color(0xFF1976D2)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Complaint Triage', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _complaints.length,
            (i) => Container(
              width: 290,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2ECE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_complaints[i].customer, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(_complaints[i].material, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_complaints[i].issue, style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text('Severity: ${_complaints[i].severity}', style: const TextStyle(fontSize: 12.5)),
                  Text('Status: ${_complaints[i].resolved ? 'Resolved' : 'Open'}', style: const TextStyle(fontSize: 12.5)),
                  const SizedBox(height: 6),
                  FilledButton.tonal(
                    onPressed: _complaints[i].resolved ? null : () => _resolveComplaint(i),
                    child: const Text('Resolve Now'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Interaction Pulse', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interactions
              .map(
                (x) => Container(
                  width: 290,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2ECE6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(x.customer, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Material: ${x.material}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Trigger: ${x.trigger}', style: const TextStyle(fontSize: 12.5)),
                      Text('Message: ${x.message}', style: const TextStyle(fontSize: 12.5)),
                      Text('Status: ${x.status}', style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        const Text('Review Momentum and Material Controls', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        ...List.generate(
          _materialControls.length,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2ECE6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_materialControls[i].material, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Rating ${_materialControls[i].rating}  |  Likes ${_materialControls[i].likes}  |  Trend ${_materialControls[i].reviewTrend}'),
                Text('Placement: ${_materialControls[i].placement}'),
                Text('Supplier Action: ${_materialControls[i].supplierAction}'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _toggleChip('Highlight', _materialControls[i].highlighted, () => _toggleMaterialAction(i, 'Highlight')),
                    _toggleChip('Priority Queue', _materialControls[i].mainLanding, () => _toggleMaterialAction(i, 'Priority Queue')),
                    _toggleChip('Contact Supplier', _materialControls[i].contactSupplier, () => _toggleMaterialAction(i, 'Contact Supplier')),
                    _toggleChip('Give Discount', _materialControls[i].discount, () => _toggleMaterialAction(i, 'Give Discount')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 420,
              child: _chartCard(
                'Feedback Categories',
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 34,
                      sections: List.generate(
                        feedbackCategories.length,
                        (i) => PieChartSectionData(
                          value: feedbackCategories[i].$2.toDouble(),
                          title: feedbackCategories[i].$1.split(' ').first,
                          color: [
                            const Color(0xFF2E7D32),
                            const Color(0xFF1976D2),
                            const Color(0xFFEF6C00),
                            const Color(0xFF6A1B9A),
                            const Color(0xFFC62828),
                          ][i],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 430,
              child: _panel(
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actions Taken + NPS', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Action Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('- Auto-routed high severity tickets to finance queue'),
                      const Text('- Triggered recovery coupons for payment-failed cohort'),
                      const Text('- Escalated unresolved SLA breaches to support leads'),
                      const SizedBox(height: 10),
                      const Text('NPS Split', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      _npsBar('Promoters', 62, const Color(0xFF2E7D32)),
                      _npsBar('Passives', 24, const Color(0xFF1976D2)),
                      _npsBar('Detractors', 14, const Color(0xFFC62828)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Issue Hotspots', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: issueHotspots
                      .map((h) => Container(
                            width: 260,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: h.$4 == 'High' ? const Color(0xFFFFF3E0) : const Color(0xFFF6FAF7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE1ECE4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('Frequency: ${h.$2}'),
                                Text('Status: ${h.$3}'),
                                Text('Priority: ${h.$4}'),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(width: 430, child: _chartCard('CSAT Trend', _line12Chart(csatTrend, const Color(0xFF2E7D32)))),
            SizedBox(
              width: 430,
              child: _chartCard(
                'Support Ticket Categories',
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= supportCats.length) return const SizedBox.shrink();
                              return Text(supportCats[i].$1, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        supportCats.length,
                        (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: supportCats[i].$2.toDouble(), width: 18, color: const Color(0xFF1976D2))]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Loyalty and CRM Programs', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 6),
                Text('Rewards Tiers: Bronze 1,204  |  Silver 618  |  Gold 221  |  Platinum 74'),
                Text('Segment Counts: New 432  |  Repeat 982  |  At-Risk 166'),
                Text('Ticket Resolution Summary: 84% resolved under SLA this month.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _tableCard(
          'CRM Automated Workflow',
          DataTable(
            columns: const [
              DataColumn(label: Text('Stage')),
              DataColumn(label: Text('Volume')),
              DataColumn(label: Text('SLA')),
            ],
            rows: workflow
                .map((w) => DataRow(cells: [
                      DataCell(Text(w.$1)),
                      DataCell(Text('${w.$2}')),
                      DataCell(Text(w.$3)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Automation Rules',
          DataTable(
            columns: const [
              DataColumn(label: Text('Rule')),
              DataColumn(label: Text('Auto action')),
              DataColumn(label: Text('Owner')),
            ],
            rows: rules
                .map((r) => DataRow(cells: [
                      DataCell(SizedBox(width: 260, child: Text(r.$1))),
                      DataCell(SizedBox(width: 260, child: Text(r.$2))),
                      DataCell(Text(r.$3)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Before vs After Impact',
          DataTable(
            columns: const [
              DataColumn(label: Text('KPI')),
              DataColumn(label: Text('Before')),
              DataColumn(label: Text('After')),
            ],
            rows: impact
                .map((i) => DataRow(cells: [
                      DataCell(Text(i.$1)),
                      DataCell(Text(i.$2)),
                      DataCell(Text(i.$3)),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTab() {
    const practices = [
      ('Data Encryption', 'AES-256 at rest and TLS in transit.'),
      ('Authentication', 'MFA for all privileged users.'),
      ('Data Validation', 'Strict schema checks on ingestion APIs.'),
      ('Data Privacy', 'Consent tracking and PII minimization.'),
      ('Payment Security', 'Tokenized payment flow + fraud checks.'),
      ('RBAC + Audit Logs', 'Role-bound access with immutable audit trail.'),
    ];

    const auditLogs = [
      ('2026-04-08 10:11', 'ops_admin@reclaim', 'Escalate payment mismatch', '49.32.11.20', 'Success'),
      ('2026-04-08 09:43', 'sec_ops@reclaim', 'Locked suspicious sessions', '49.32.11.21', 'Success'),
      ('2026-04-08 09:07', 'crm_lead@reclaim', 'Resolved high severity complaint', '49.32.11.19', 'Success'),
      ('2026-04-08 08:54', 'finance_ops@reclaim', 'Updated payout threshold', '49.32.11.22', 'Review'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: practices
              .map((p) => _miniInfoCard(p.$1, p.$2, Icons.security_outlined, AppTheme.primaryGreen))
              .toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiCard(title: 'SSL Certificate', value: 'Valid', change: '365d'),
            _KpiCard(title: 'Last Pen Test', value: '21 days ago', change: 'Pass'),
            _KpiCard(title: 'Data Breaches', value: '0', change: 'No incidents'),
            _KpiCard(title: 'Uptime', value: '99.95%', change: '+0.03%'),
            _KpiCard(title: 'Mitigations Applied', value: '$_securityMitigationCount', change: '+$_securityMitigationCount'),
          ],
        ),
        const SizedBox(height: 10),
        _tableCard(
          'Audit Logs',
          DataTable(
            columns: const [
              DataColumn(label: Text('Timestamp')),
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('IP')),
              DataColumn(label: Text('Status')),
            ],
            rows: auditLogs
                .map((a) => DataRow(cells: [
                      DataCell(Text(a.$1)),
                      DataCell(Text(a.$2)),
                      DataCell(Text(a.$3)),
                      DataCell(Text(a.$4)),
                      DataCell(Text(a.$5)),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        _panel(
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Policy Documents', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () => _openPolicy('Privacy Policy'), child: const Text('Privacy Policy')),
                    OutlinedButton(onPressed: () => _openPolicy('Terms of Service'), child: const Text('Terms of Service')),
                    OutlinedButton(onPressed: () => _openPolicy('Cookie Policy'), child: const Text('Cookie Policy')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErpTab() {
    const modules = [
      ('SCM Control Hub', 'Material replenishment and flow orchestration', 'Queue SLA 88%', '/scm-dashboard'),
      ('Inventory Ledger', 'Live stock, low-stock alerts, and variance control', 'Stock health 84%', '/lab-dashboard/inventory'),
      ('Order Operations', 'Order-to-settlement lifecycle tracking', 'Order closure 92%', '/orders'),
      ('CRM Notifications', 'Lifecycle communication and escalation cues', 'Engagement uplift +12%', '/notifications'),
      ('ERP Admin Console', 'Procurement, finance, and audit coordination', 'Exception rate 3.1%', '/ecom-admin'),
    ];

    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ERP Modules', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'Mapped from Business Engine into Global Admin Orchestrator for direct operational access.',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            ...modules.map(
              (m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2ECE6)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(m.$2, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                          Text(m.$3, style: const TextStyle(fontSize: 12.5, color: AppTheme.primaryGreen)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go(m.$4),
                      child: const Text('Open Module'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPolicy(String type) {
    final text = switch (type) {
      'Privacy Policy' =>
        'We process account, material, and transaction data for fulfillment, compliance, and platform safety. Personally identifiable information is minimized, encrypted in transit and at rest, and retained only as long as legally required.',
      'Terms of Service' =>
        'By using this platform, users agree to lawful use, truthful material data, and timely communication with requestors and suppliers. Fraudulent behavior, payment abuse, or unauthorized access attempts may result in account restriction or legal escalation.',
      _ =>
        'We use strictly necessary cookies for session continuity and security controls, and optional analytics cookies for product insights. Users can manage cookie preferences while core authentication cookies remain required for secure operation.',
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type),
        content: SingleChildScrollView(child: Text(text, style: const TextStyle(height: 1.5))),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _line12Chart(List<int> data, Color color) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (v, _) => Text('M${v.toInt() + 1}', style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].toDouble())),
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget chart) {
    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _tableCard(String title, DataTable table) {
    return _panel(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: table,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2ECE6)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _severityCard(String label, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _npsBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12.5))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE9EEF3),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value%'),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool active, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: active ? AppTheme.primaryGreen : const Color(0xFFD7E4DB)),
        backgroundColor: active ? AppTheme.primaryGreen.withValues(alpha: 0.12) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppTheme.primaryGreen : AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _miniInfoCard(String title, String text, IconData icon, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2ECE6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2ECE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;

  const _KpiCard({required this.title, required this.value, required this.change});

  @override
  Widget build(BuildContext context) {
    final good = change.startsWith('+') || change == 'Pass' || change == 'No incidents' || change == '365d';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2ECE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: good ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: good ? const Color(0xFF2E7D32) : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


