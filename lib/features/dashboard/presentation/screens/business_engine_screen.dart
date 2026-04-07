import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reclaim/core/services/inventory_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class BusinessEngineScreen extends StatefulWidget {
  final String initialRole;

  const BusinessEngineScreen({
    super.key,
    this.initialRole = 'customer',
  });

  @override
  State<BusinessEngineScreen> createState() => _BusinessEngineScreenState();
}

class _BusinessEngineScreenState extends State<BusinessEngineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  String _roleLens = 'customer';
  String _crmStage = 'selection';
  double _leadVolume = 600;
  double _acquisitionRate = 55;
  double _conversionRate = 34;
  double _retentionRate = 62;
  double _loyaltyRate = 38;

  String _demandPattern = 'predictable';
  double _stockHealth = 68;
  double _leadTimeDays = 4;

  double _monthlyOrders = 240;
  double _avgOrderValue = 499;
  double _platformFeePercent = 8;
  double _repeatRate = 36;

  String _competitor = 'marketplace';

  String _projectDomain = 'all';
  String _projectLevel = 'all';

  bool _loadingLiveMetrics = false;
  bool _liveConnected = false;
  String? _liveError;
  DateTime? _lastLiveSync;

  static const List<String> scmSharedFlow = [
    'Sourcing',
    'Intake',
    'Quality Check',
    'Inventory',
    'Demand Matching',
    'Fulfillment',
    'Reverse Loop',
  ];

  static const List<String> _tabs = [
    'CRM',
    'SCM',
    'Revenue',
    'Competitors',
    'Projects',
  ];

  static const List<String> _crmStages = [
    'selection',
    'acquisition',
    'conversion',
    'retention',
    'loyalty',
  ];

  static const Map<String, String> _crmStageLabel = {
    'selection': 'Reaching Potential Customer (Selection)',
    'acquisition': 'Customer Acquisition',
    'conversion': 'Conversion',
    'retention': 'Retention (Personalized Engagement)',
    'loyalty': 'Loyalty (Points/Benefits)',
  };

  static const Map<String, Map<String, String>> _crmActions = {
    'selection': {
      'customer': 'User selects role/campus/interests for a relevant first experience.',
      'admin': 'Admin configures segments and first-touch campaigns by campus and role.',
    },
    'acquisition': {
      'customer': 'Guided discovery and prompts drive first meaningful action.',
      'admin': 'Campaign hooks and targeted entry points are optimized for activation.',
    },
    'conversion': {
      'customer': 'Low-friction request and checkout paths convert intent to orders.',
      'admin': 'Drop-off points are monitored and fixed with workflow interventions.',
    },
    'retention': {
      'customer': 'Re-engagement alerts and personalized nudges bring users back.',
      'admin': 'Lifecycle communication rules are tuned by category and behavior.',
    },
    'loyalty': {
      'customer': 'Points, badges, and benefits reward recurring sustainable behavior.',
      'admin': 'Loyalty rules are tuned to maximize repeat activity and advocacy.',
    },
  };

  static const Map<String, String> _competitorTitle = {
    'marketplace': 'Generic Marketplace',
    'spreadsheet': 'Spreadsheet Tracking',
    'singleapp': 'Single-Function Recycling App',
  };

  static const Map<String, List<String>> _competitorWeakness = {
    'marketplace': [
      'Weak lifecycle depth beyond listing and buying',
      'No push/pull SCM planning layer',
      'Limited institutional ERP workflow support',
    ],
    'spreadsheet': [
      'Manual updates and no real-time process control',
      'No customer-facing journey integration',
      'No live operational triggers or transaction flow',
    ],
    'singleapp': [
      'Strong in one niche but weak cross-module operations',
      'No full CRM funnel coverage',
      'Revenue and SCM explainability usually missing',
    ],
  };

  static const List<_ProjectIdea> _projectIdeas = [
    _ProjectIdea(
      title: 'Smart E-Waste Classifier',
      domain: 'ai',
      level: 'intermediate',
      description: 'Classify reusable electronics and suggest recovery actions.',
      stack: 'Python, TensorFlow, OpenCV',
      tutorials: [
        _TutorialLink('TensorFlow image classification', 'https://www.tensorflow.org/tutorials/images/classification'),
        _TutorialLink('OpenCV Python tutorials', 'https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html'),
      ],
    ),
    _ProjectIdea(
      title: 'Campus Reuse Marketplace',
      domain: 'fullstack',
      level: 'beginner',
      description: 'Build a reuse marketplace with listing, cart, and checkout.',
      stack: 'Flutter, Firebase, Supabase',
      tutorials: [
        _TutorialLink('Flutter codelabs', 'https://docs.flutter.dev/codelabs'),
        _TutorialLink('Supabase Flutter quickstart', 'https://supabase.com/docs/guides/getting-started/quickstarts/flutter'),
      ],
    ),
    _ProjectIdea(
      title: 'IoT Bin Monitoring and Pickup Planner',
      domain: 'iot',
      level: 'intermediate',
      description: 'Track bin fill levels and optimize collection routes.',
      stack: 'ESP32, MQTT, Dashboard',
      tutorials: [
        _TutorialLink('ESP32 getting started', 'https://randomnerdtutorials.com/getting-started-with-esp32/'),
        _TutorialLink('MQTT essentials', 'https://www.hivemq.com/mqtt-essentials/'),
      ],
    ),
    _ProjectIdea(
      title: 'Circular Supply Chain Analytics',
      domain: 'sustainability',
      level: 'advanced',
      description: 'Model push/pull SCM impact on cost, speed, and stockouts.',
      stack: 'Python, SQL, BI Dashboard',
      tutorials: [
        _TutorialLink('Pandas tutorials', 'https://pandas.pydata.org/docs/getting_started/intro_tutorials/'),
        _TutorialLink('Plotly Dash tutorial', 'https://dash.plotly.com/tutorial'),
      ],
    ),
    _ProjectIdea(
      title: 'Project Recommendation Engine',
      domain: 'ai',
      level: 'advanced',
      description: 'Recommend student projects from skills, budget, and materials.',
      stack: 'FastAPI, embeddings, vector search',
      tutorials: [
        _TutorialLink('FastAPI tutorial', 'https://fastapi.tiangolo.com/tutorial/'),
        _TutorialLink('Scikit-learn user guide', 'https://scikit-learn.org/stable/user_guide.html'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _roleLens = widget.initialRole == 'admin' ? 'admin' : 'customer';
    _loadLiveMetrics();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final width = MediaQuery.of(context).size.width;

    return ResponsiveScaffold(
      currentRoute: '/business-engine',
      cartItemCount: 0,
      mobileAppBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('Business Engine', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Back to dashboard',
            onPressed: () => context.go(_roleLens == 'admin' ? '/admin-dashboard' : '/student-dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) _buildHeroHeader(context),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(width)),
                child: Padding(
                  padding: isMobile
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(horizontal: 42, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRoleLensCard(),
                      const SizedBox(height: 18),
                      _buildTabBar(),
                      const SizedBox(height: 18),
                      _buildTabView(),
                    ],
                  ),
                ),
              ),
            ),
            if (!isMobile) const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 56),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Engine Lab',
            style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Explainable implementation of CRM, SCM, Revenue and competitor differentiation.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleLensCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_outlined, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          const Text('Lens', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'customer', label: Text('Customer')),
              ButtonSegment(value: 'admin', label: Text('Admin')),
            ],
            selected: {_roleLens},
            onSelectionChanged: (value) {
              setState(() => _roleLens = value.first);
            },
          ),
          const Spacer(),
          if (_loadingLiveMetrics)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              tooltip: 'Refresh live data',
              onPressed: _loadLiveMetrics,
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryGreen),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: TabBar(
        controller: _tab,
        isScrollable: true,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryGreen,
        indicatorWeight: 3,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildTabView() {
    return SizedBox(
      height: 760,
      child: TabBarView(
        controller: _tab,
        children: [
          _buildCrmTab(),
          _buildScmTab(),
          _buildRevenueTab(),
          _buildCompetitorTab(),
          _buildProjectsTab(),
        ],
      ),
    );
  }

  Widget _buildCrmTab() {
    final acquired = (_leadVolume * (_acquisitionRate / 100)).round();
    final converted = (acquired * (_conversionRate / 100)).round();
    final retained = (converted * (_retentionRate / 100)).round();
    final loyal = (retained * (_loyaltyRate / 100)).round();

    return _panel(
      title: 'CRM Stage Simulator',
      subtitle: 'Adjust funnel parameters to see stage outcomes and role-specific implementation actions. ${_liveStatusText()}',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _dropdownCard(
                label: 'Active Stage',
                value: _crmStage,
                options: _crmStages,
                labelMap: _crmStageLabel,
                onChanged: (v) => setState(() => _crmStage = v ?? 'selection'),
              ),
              _sliderCard('Lead Volume', _leadVolume, 100, 2000, (v) => setState(() => _leadVolume = v), isInt: true),
              _sliderCard('Acquisition %', _acquisitionRate, 5, 95, (v) => setState(() => _acquisitionRate = v)),
              _sliderCard('Conversion %', _conversionRate, 5, 90, (v) => setState(() => _conversionRate = v)),
              _sliderCard('Retention %', _retentionRate, 5, 95, (v) => setState(() => _retentionRate = v)),
              _sliderCard('Loyalty %', _loyaltyRate, 5, 95, (v) => setState(() => _loyaltyRate = v)),
            ],
          ),
          const SizedBox(height: 16),
          _statsGrid([
            _tileStat('Leads', '$acquired / ${_leadVolume.round()}'),
            _tileStat('Converted', '$converted'),
            _tileStat('Retained', '$retained'),
            _tileStat('Loyal', '$loyal'),
          ]),
          const SizedBox(height: 12),
          _actionCard(
            title: _crmStageLabel[_crmStage]!,
            content: _crmActions[_crmStage]![_roleLens]!,
          ),
        ],
      ),
    );
  }

  Widget _buildScmTab() {
    final route = _recommendedScmRoute();
    final reorderQty = ((100 - _stockHealth) * 1.8 + _leadTimeDays * 5).round();

    return _panel(
      title: 'SCM Push/Pull Planner',
      subtitle: 'Decision logic runs from demand pattern, stock health, and lead time. ${_liveStatusText()}',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _dropdownCard(
                label: 'Demand Pattern',
                value: _demandPattern,
                options: const ['predictable', 'spike', 'mixed'],
                labelMap: const {
                  'predictable': 'Predictable semester demand',
                  'spike': 'Sudden project spikes',
                  'mixed': 'Mixed demand behavior',
                },
                onChanged: (v) => setState(() => _demandPattern = v ?? 'predictable'),
              ),
              _sliderCard('Stock Health %', _stockHealth, 10, 100, (v) => setState(() => _stockHealth = v)),
              _sliderCard('Lead Time (days)', _leadTimeDays, 1, 15, (v) => setState(() => _leadTimeDays = v), isInt: true),
            ],
          ),
          const SizedBox(height: 16),
          _statsGrid([
            _tileStat('Recommended Route', route),
            _tileStat('Reorder Quantity', '$reorderQty units'),
            _tileStat('Admin Priority', route == 'Pull' ? 'Dynamic allocation' : 'Planned replenishment'),
            _tileStat('Customer View', 'Live stage tracking'),
          ]),
          const SizedBox(height: 12),
          _actionCard(
            title: 'Shared SCM Execution Stages',
            content: scmSharedFlow.join('  ->  '),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    final gmv = _monthlyOrders * _avgOrderValue;
    final platformRevenue = gmv * (_platformFeePercent / 100);
    final repeatContribution = platformRevenue * (_repeatRate / 100);

    return _panel(
      title: 'Revenue Estimator',
      subtitle: 'Interactive model from live inputs. Tune pricing and volume to evaluate financial outcomes. ${_liveStatusText()}',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _sliderCard('Monthly Orders', _monthlyOrders, 20, 1500, (v) => setState(() => _monthlyOrders = v), isInt: true),
              _sliderCard('Avg Order Value (INR)', _avgOrderValue, 100, 3000, (v) => setState(() => _avgOrderValue = v), isInt: true),
              _sliderCard('Platform Fee %', _platformFeePercent, 1, 20, (v) => setState(() => _platformFeePercent = v)),
              _sliderCard('Repeat Purchase %', _repeatRate, 1, 90, (v) => setState(() => _repeatRate = v)),
            ],
          ),
          const SizedBox(height: 16),
          _statsGrid([
            _tileStat('Projected GMV', 'INR ${gmv.toStringAsFixed(0)}'),
            _tileStat('Platform Revenue', 'INR ${platformRevenue.toStringAsFixed(0)}'),
            _tileStat('Repeat Contribution', 'INR ${repeatContribution.toStringAsFixed(0)}'),
            _tileStat('Revenue Driver', _roleLens == 'admin' ? 'Margin + retention ops' : 'Savings + loyalty value'),
          ]),
          const SizedBox(height: 12),
          _actionCard(
            title: 'Explainability',
            content: 'Revenue is modeled as Orders x AOV x Fee%. Repeat contribution is estimated from repeat-rate share of platform revenue.',
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorTab() {
    final weaknesses = _competitorWeakness[_competitor]!;

    return _panel(
      title: 'Competitor Gap Explorer',
      subtitle: 'Select competitor class to see where ReClaim is uniquely stronger.',
      child: Column(
        children: [
          _dropdownCard(
            label: 'Competitor Type',
            value: _competitor,
            options: const ['marketplace', 'spreadsheet', 'singleapp'],
            labelMap: _competitorTitle,
            onChanged: (v) => setState(() => _competitor = v ?? 'marketplace'),
          ),
          const SizedBox(height: 16),
          _statsGrid([
            _tileStat('CRM', '5-stage lifecycle implementation'),
            _tileStat('SCM', 'Push/Pull decision support'),
            _tileStat('Revenue', 'Dynamic estimator and KPI linkage'),
            _tileStat('Differentiator', 'ERP + project tutorials in one platform'),
          ]),
          const SizedBox(height: 12),
          ...weaknesses.map((w) => _actionCard(title: 'Competitor Gap', content: w)),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    final filtered = _projectIdeas.where((p) {
      final domainOk = _projectDomain == 'all' || p.domain == _projectDomain;
      final levelOk = _projectLevel == 'all' || p.level == _projectLevel;
      return domainOk && levelOk;
    }).toList();

    return _panel(
      title: 'Student Project Recommender',
      subtitle: 'Recommendations include implementation stack and tutorial links, not only project names.',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _dropdownCard(
                label: 'Domain',
                value: _projectDomain,
                options: const ['all', 'ai', 'iot', 'fullstack', 'sustainability'],
                labelMap: const {
                  'all': 'All domains',
                  'ai': 'AI/ML',
                  'iot': 'IoT/Embedded',
                  'fullstack': 'Full-stack',
                  'sustainability': 'Sustainability analytics',
                },
                onChanged: (v) => setState(() => _projectDomain = v ?? 'all'),
              ),
              _dropdownCard(
                label: 'Level',
                value: _projectLevel,
                options: const ['all', 'beginner', 'intermediate', 'advanced'],
                labelMap: const {
                  'all': 'All levels',
                  'beginner': 'Beginner',
                  'intermediate': 'Intermediate',
                  'advanced': 'Advanced',
                },
                onChanged: (v) => setState(() => _projectLevel = v ?? 'all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const _EmptyHint(text: 'No project matches this filter. Try a broader level/domain.')
          else
            ...filtered.map(_projectCard),
        ],
      ),
    );
  }

  Widget _projectCard(_ProjectIdea idea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(idea.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          Text(idea.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 8),
          Text('Stack: ${idea.stack}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: idea.tutorials
                .map((t) => ActionChip(
                      label: Text(t.label, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.link, size: 16),
                      onPressed: () => _openLink(t.url),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open tutorial link.')),
      );
    }
  }

  String _liveStatusText() {
    if (_loadingLiveMetrics) return 'Loading live metrics...';
    if (_liveConnected && _lastLiveSync != null) {
      final h = _lastLiveSync!.hour.toString().padLeft(2, '0');
      final m = _lastLiveSync!.minute.toString().padLeft(2, '0');
      return 'Live metrics connected at $h:$m';
    }
    if (_liveError != null) {
      return 'Using fallback values (${_liveError!})';
    }
    return 'Using default values';
  }

  Future<void> _loadLiveMetrics() async {
    if (!mounted) return;
    setState(() {
      _loadingLiveMetrics = true;
      _liveError = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final orders = await _safeOrdersFetch(supabase);
      final requestsCount = await _safeCountRequests(supabase);
      final inventory = await InventoryService(supabase).getInventoryReport();

      final now = DateTime.now();
      final windowStart = now.subtract(const Duration(days: 30));

      final monthlyOrders = orders.where((o) {
        final created = o['created_at'];
        if (created is String) {
          final dt = DateTime.tryParse(created);
          if (dt != null) return dt.isAfter(windowStart);
        }
        return true;
      }).toList();

      final monthlyOrderCount = monthlyOrders.length;
      final orderCount = orders.length;

      double totalAmount = 0;
      for (final order in monthlyOrders) {
        totalAmount += _num(order['total_amount']);
      }
      final avgOrderValue = monthlyOrderCount > 0 ? totalAmount / monthlyOrderCount : _avgOrderValue;

      final userOrderFrequency = <String, int>{};
      for (final order in orders) {
        final userId = (order['user_id'] ?? '').toString();
        if (userId.isEmpty) continue;
        userOrderFrequency[userId] = (userOrderFrequency[userId] ?? 0) + 1;
      }
      final uniqueUsers = userOrderFrequency.length;
      final repeatUsers = userOrderFrequency.values.where((v) => v > 1).length;
      final repeatRate = uniqueUsers > 0 ? (repeatUsers / uniqueUsers) * 100 : _repeatRate;

      final leadVolume = _clampDouble(
        (requestsCount > 0 ? requestsCount * 3.0 : orderCount * 4.0).clamp(180.0, 3200.0),
        100,
        4000,
      );

      final acquisitionRate = _clampDouble(
        leadVolume > 0 ? (requestsCount / leadVolume) * 100 : 40,
        5,
        95,
      );

      final conversionRate = _clampDouble(
        requestsCount > 0 ? (orderCount / requestsCount) * 100 : 25,
        5,
        90,
      );

      final retentionRate = _clampDouble((repeatRate + 24) / 1.2, 10, 95);
      final loyaltyRate = _clampDouble(repeatRate * 0.85, 5, 95);

      final stockHealth = inventory.totalProducts > 0
          ? (((inventory.totalProducts - inventory.outOfStockCount) / inventory.totalProducts) * 100)
          : _stockHealth;

      final lowStockPressure = inventory.totalProducts > 0
          ? (inventory.lowStockCount / inventory.totalProducts) * 100
          : 20;
      final leadTime = _clampDouble(3 + (lowStockPressure / 18), 1, 15);

      String demandPattern = 'predictable';
      if (lowStockPressure > 35 || requestsCount > orderCount * 2) {
        demandPattern = 'spike';
      } else if (lowStockPressure > 20) {
        demandPattern = 'mixed';
      }

      if (!mounted) return;
      setState(() {
        _leadVolume = leadVolume;
        _acquisitionRate = acquisitionRate;
        _conversionRate = conversionRate;
        _retentionRate = retentionRate;
        _loyaltyRate = loyaltyRate;

        _demandPattern = demandPattern;
        _stockHealth = _clampDouble(stockHealth, 10, 100);
        _leadTimeDays = leadTime;

        _monthlyOrders = _clampDouble(monthlyOrderCount.toDouble().clamp(20, 1500), 20, 1500);
        _avgOrderValue = _clampDouble(avgOrderValue, 100, 3000);
        _repeatRate = _clampDouble(repeatRate, 1, 90);

        _liveConnected = true;
        _lastLiveSync = DateTime.now();
        _loadingLiveMetrics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _liveConnected = false;
        _liveError = 'unable to fetch metrics';
        _loadingLiveMetrics = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _safeOrdersFetch(SupabaseClient supabase) async {
    try {
      final rows = await supabase
          .from('orders')
          .select('total_amount,user_id,created_at,status');
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      final rows = await supabase
          .from('orders')
          .select('total_amount,user_id,status');
      return List<Map<String, dynamic>>.from(rows);
    }
  }

  Future<int> _safeCountRequests(SupabaseClient supabase) async {
    try {
      final rows = await supabase.from('requests').select('id');
      return (rows as List).length;
    } catch (_) {
      try {
        final rows = await supabase.from('material_requests').select('id');
        return (rows as List).length;
      } catch (_) {
        return 0;
      }
    }
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  String _recommendedScmRoute() {
    if (_demandPattern == 'spike' || _stockHealth < 45 || _leadTimeDays > 8) {
      return 'Pull';
    }
    if (_demandPattern == 'mixed') {
      return 'Hybrid';
    }
    return 'Push';
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(List<Widget> tiles) {
    return GridView.count(
      crossAxisCount: Breakpoints.isMobile(context) ? 1 : 2,
      childAspectRatio: Breakpoints.isMobile(context) ? 3.7 : 2.9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  Widget _tileStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E6DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
        ],
      ),
    );
  }

  Widget _actionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(content, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.45)),
        ],
      ),
    );
  }

  Widget _dropdownCard({
    required String label,
    required String value,
    required List<String> options,
    required Map<String, String> labelMap,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: Breakpoints.isMobile(context) ? double.infinity : 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E6DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(labelMap[o] ?? o)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sliderCard(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    bool isInt = false,
  }) {
    final showValue = isInt ? value.round().toString() : value.toStringAsFixed(1);
    return Container(
      width: Breakpoints.isMobile(context) ? double.infinity : 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E6DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
              Text(showValue, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProjectIdea {
  final String title;
  final String domain;
  final String level;
  final String description;
  final String stack;
  final List<_TutorialLink> tutorials;

  const _ProjectIdea({
    required this.title,
    required this.domain,
    required this.level,
    required this.description,
    required this.stack,
    required this.tutorials,
  });
}

class _TutorialLink {
  final String label;
  final String url;

  const _TutorialLink(this.label, this.url);
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E6DA)),
        color: const Color(0xFFF8FCF9),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
    );
  }
}
