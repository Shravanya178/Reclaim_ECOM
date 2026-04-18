import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/services/customer_voice_service.dart';
import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/impact/widgets/impact_dashboard.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  static const _stats = [
    ('12', 'Materials Donated',    Icons.recycling,             AppTheme.primaryGreen),
    ('8',  'Active Requests',      Icons.pending_actions,       Color(0xFF3182CE)),
    ('3',  'Orders Placed',        Icons.shopping_bag_outlined, Color(0xFFD69E2E)),
    ('24.5 kg', 'CO₂ Saved',      Icons.eco,                   Color(0xFF38A169)),
  ];

  static const _recentActivity = [
    ('Donated: Arduino Uno Rev3',      '2 min ago',  Icons.volunteer_activism, AppTheme.primaryGreen),
    ('Request approved: Copper Wire',  '1 hour ago', Icons.check_circle,       Color(0xFF38A169)),
    ('Order placed: LED Strip 5m',     '3 hours ago', Icons.shopping_bag_outlined, Color(0xFF3182CE)),
    ('Inventory updated: 5 items',     'Yesterday',  Icons.inventory_2_outlined, Color(0xFFD69E2E)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/student-dashboard',
      mobileAppBar: isMobile ? AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: () => context.go('/student-projects'),
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 16, color: Colors.white)),
          const SizedBox(width: 12),
        ],
      ) : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  // ─── DESKTOP ─────────────────────────────────────────
  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(child: Column(children: [
      _heroSection(context),
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats row
            _statsRow(),
            const SizedBox(height: 40),
            // Main content
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Left (main content)
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _quickActions(context),
                const SizedBox(height: 32),
                const Text('My Recent Materials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _materialsGrid(context),
                const SizedBox(height: 24),
                const _CustomerVoiceFlowSection(),
              ])),
              const SizedBox(width: 28),
              // Right sidebar
              SizedBox(width: 300, child: Column(children: [
                _activityFeed(),
                const SizedBox(height: 20),
                _ecoScore(),
                const SizedBox(height: 20),
                const ImpactDashboard(),
              ])),
            ]),
          ]),
        ),
      )),
      const WebFooter(),
    ]));
  }

  Widget _heroSection(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [AppTheme.primaryDark, AppTheme.primaryGreen, AppTheme.accent],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 50),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.white70),
                SizedBox(width: 6),
                Text('Good morning!', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            const SizedBox(height: 16),
            const Text('Welcome back,\nShravanya 👋', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 10),
            const Text('VESIT Mumbai · Environmental Eng.', style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 28),
            Wrap(spacing: 14, runSpacing: 10, children: [
              _heroCta(context, 'Browse Shop', Icons.store_outlined, () => context.go('/shop')),
              _heroCta(context, 'My Inventory', Icons.inventory_2_outlined, () => context.go('/inventory'), outline: true),
              _heroCta(context, 'Projects Hub', Icons.auto_graph_outlined, () => context.go('/student-projects'), outline: true),
            ]),
          ])),
          const SizedBox(width: 48),
          // Profile card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24)),
            child: Column(children: [
              Container(width: 72, height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                child: const Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(height: 14),
              const Text('Shravanya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const Text('Student', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Eco Score: 840 pts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
            ]),
          ),
        ]),
      ),
    )),
  );

  Widget _heroCta(BuildContext context, String label, IconData ic, VoidCallback onTap, {bool outline = false}) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(ic, size: 16),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: outline ? Colors.transparent : Colors.white,
      foregroundColor: outline ? Colors.white : AppTheme.primaryGreen,
      elevation: 0,
      side: outline ? const BorderSide(color: Colors.white54) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _statsRow() {
    return Row(children: _stats.map((s) => Expanded(child: Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: s.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(s.$3, color: s.$4, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.$1, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.$4)),
          Text(s.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ]),
    ))).toList());
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      ('Donate Material', 'Upload surplus materials to the network', Icons.volunteer_activism, AppTheme.primaryGreen, '/capture', 'donation_intent'),
      ('Browse Shop', 'Find parts and materials you need', Icons.store_outlined, Color(0xFF3182CE), '/shop', 'shop_discovery'),
      ('Make Request', 'Request specific materials from labs', Icons.pending_actions, Color(0xFFD69E2E), '/requests', 'request_intent'),
      ('My Orders', 'Track and manage your purchases', Icons.receipt_long_outlined, Color(0xFF805AD5), '/orders', 'order_followup'),
    ];
    return Row(children: actions.map((a) => Expanded(child: GestureDetector(
      onTap: () {
        ErpCrmIntelligenceService.instance.recordAcquisitionChannel(a.$6);
        context.go(a.$5);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EFE8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(a.$3, color: a.$4, size: 22)),
          const SizedBox(height: 14),
          Text(a.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(a.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
        ]),
      ),
    ))).toList());
  }

  Widget _materialsGrid(BuildContext context) {
    const items = [
      ('Arduino Uno', 'Electronic', 'Available', AppTheme.primaryGreen),
      ('Copper Wire', 'Metal', 'Donated', Color(0xFF3182CE)),
      ('LED Strip', 'Electronic', 'In Cart', Color(0xFFD69E2E)),
      ('Flask 500ml', 'Chemical', 'Available', AppTheme.primaryGreen),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.8,
      children: items.map((it) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EFE8))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: it.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.inventory_2_outlined, color: it.$4, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(it.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: it.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(it.$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: it.$4))),
        ]),
      )).toList(),
    );
  }

  Widget _activityFeed() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0,3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(18,18,18,12),
        child: Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      const Divider(height: 1, color: Color(0xFFEAF1EB)),
      ..._recentActivity.map((a) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: a.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(a.$3, color: a.$4, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(a.$2, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
        ]),
      )),
    ]),
  );

  Widget _ecoScore() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      const Icon(Icons.eco, color: Colors.white, size: 28),
      const SizedBox(height: 10),
      const Text('Eco Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
      const Text('840 pts', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      LinearProgressIndicator(value: 0.84, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation(Colors.white), borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 6),
      const Text('160 pts to Gold tier', style: TextStyle(color: Colors.white60, fontSize: 11)),
    ]),
  );

  // ─── MOBILE ───────────────────────────────────────────
  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Mobile hero
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('Shravanya', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const Text('VESIT Mumbai', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          const CircleAvatar(radius: 28, backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 32, color: Colors.white)),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stats 2x2
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
          children: _stats.map((s) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
            child: Row(children: [
              Icon(s.$3, color: s.$4, size: 22),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
                Text(s.$2, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.3)),
              ]),
            ]),
          )).toList()),
        const SizedBox(height: 24),
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        // 2x2 action grid
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _mobileAction(context, 'Shop', Icons.store_outlined, const Color(0xFF3182CE), '/shop'),
            _mobileAction(context, 'Donate', Icons.volunteer_activism, AppTheme.primaryGreen, '/capture'),
            _mobileAction(context, 'Requests', Icons.pending_actions, const Color(0xFFD69E2E), '/requests'),
            _mobileAction(context, 'Orders', Icons.receipt_long_outlined, const Color(0xFF805AD5), '/orders'),
          ]),
        const SizedBox(height: 24),
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        _activityFeed(),
        const SizedBox(height: 18),
        const _CustomerVoiceFlowSection(),
      ])),
    ]));
  }

  Widget _mobileAction(BuildContext context, String label, IconData ic, Color col, String route) => GestureDetector(
    onTap: () => context.go(route),
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5EFE8))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(ic, color: col, size: 22)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    ),
  );
}

class _CustomerVoiceFlowSection extends StatefulWidget {
  const _CustomerVoiceFlowSection();

  @override
  State<_CustomerVoiceFlowSection> createState() => _CustomerVoiceFlowSectionState();
}

class _CustomerVoiceSnapshot {
  final int feedbackCount;
  final int complaintCount;
  final Map<String, int> feedbackBuckets;
  final Map<String, int> complaintBuckets;

  const _CustomerVoiceSnapshot({
    required this.feedbackCount,
    required this.complaintCount,
    required this.feedbackBuckets,
    required this.complaintBuckets,
  });
}

class _CustomerVoiceFlowSectionState extends State<_CustomerVoiceFlowSection> {
  final _customerCtrl = TextEditingController(text: 'Demo Student');
  final _feedbackCtrl = TextEditingController();
  final _complaintCtrl = TextEditingController();

  String _material = 'Copper Wire Batch CW-14';
  int _rating = 5;
  String _severity = 'High';
  int _reloadKey = 0;

  static const List<String> _materials = [
    'Copper Wire Batch CW-14',
    'PCB Salvage Kit PK-22',
    'Glassware Bundle GB-09',
    'Arduino Uno Rev3',
    'Copper Wire Spool 1kg',
    'LED Strip 5m RGB',
    'Borosilicate Flask 500ml',
  ];

  @override
  void dispose() {
    _customerCtrl.dispose();
    _feedbackCtrl.dispose();
    _complaintCtrl.dispose();
    super.dispose();
  }

  Future<_CustomerVoiceSnapshot> _loadSnapshot() async {
    final svc = CustomerVoiceService.instance;
    await svc.ensureSeeded();
    final feedback = await svc.getEntriesByType(VoiceType.feedback);
    final complaints = await svc.getEntriesByType(VoiceType.complaint);
    final feedbackBuckets = await svc.getThreeSectionCounts(VoiceType.feedback);
    final complaintBuckets = await svc.getThreeSectionCounts(VoiceType.complaint);

    return _CustomerVoiceSnapshot(
      feedbackCount: feedback.length,
      complaintCount: complaints.length,
      feedbackBuckets: feedbackBuckets,
      complaintBuckets: complaintBuckets,
    );
  }

  Future<void> _submitFeedback() async {
    final message = _feedbackCtrl.text.trim();
    if (message.isEmpty) {
      return;
    }
    await CustomerVoiceService.instance.submitFeedback(
      customer: _customerCtrl.text.trim().isEmpty ? 'Demo Student' : _customerCtrl.text.trim(),
      material: _material,
      message: message,
      rating: _rating,
    );

    if (!mounted) return;
    setState(() {
      _feedbackCtrl.clear();
      _reloadKey++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted. It is now visible in admin orchestrator flow.')),
    );
  }

  Future<void> _submitComplaint() async {
    final message = _complaintCtrl.text.trim();
    if (message.isEmpty) {
      return;
    }
    await CustomerVoiceService.instance.submitComplaint(
      customer: _customerCtrl.text.trim().isEmpty ? 'Demo Student' : _customerCtrl.text.trim(),
      material: _material,
      message: message,
      severity: _severity,
    );

    if (!mounted) return;
    setState(() {
      _complaintCtrl.clear();
      _reloadKey++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted. Admin side now receives this issue.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: FutureBuilder<_CustomerVoiceSnapshot>(
        key: ValueKey(_reloadKey),
        future: _loadSnapshot(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Feedback + Complaint Flow Demo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create one feedback and one complaint here. Admin orchestrator receives it, and product-level actions can be applied.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statChip('Total Feedback', '${data?.feedbackCount ?? 0}+'),
                  _statChip('Total Complaints', '${data?.complaintCount ?? 0}+'),
                  _statChip('Combined Voice', '${(data?.feedbackCount ?? 0) + (data?.complaintCount ?? 0)}+'),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _material,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  border: OutlineInputBorder(),
                ),
                items: _materials
                    .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _material = v);
                },
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _formCard(
                      title: 'Material Feedback',
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _rating,
                            decoration: const InputDecoration(
                              labelText: 'Rating',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [1, 2, 3, 4, 5]
                                .map((r) => DropdownMenuItem(value: r, child: Text('$r / 5')))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _rating = v);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _feedbackCtrl,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Write feedback for this material',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitFeedback,
                              child: const Text('Submit Feedback'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _formCard(
                      title: 'Complaint Box',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _severity,
                            decoration: const InputDecoration(
                              labelText: 'Severity',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const ['Critical', 'High', 'Moderate']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _severity = v);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _complaintCtrl,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Describe your complaint',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: _submitComplaint,
                              child: const Text('Submit Complaint'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _bucketRow('Feedback Auto Sections', data?.feedbackBuckets ?? const {}),
              const SizedBox(height: 8),
              _bucketRow('Complaint Auto Sections', data?.complaintBuckets ?? const {}),
            ],
          );
        },
      ),
    );
  }

  Widget _formCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _bucketRow(String title, Map<String, int> buckets) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ...buckets.entries.map((e) => _statChip(e.key, '${e.value}')),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD4E6DA)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }
}
