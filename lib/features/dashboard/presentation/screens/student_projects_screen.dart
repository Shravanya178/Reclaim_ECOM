import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class StudentProjectsScreen extends StatefulWidget {
  const StudentProjectsScreen({super.key});

  @override
  State<StudentProjectsScreen> createState() => _StudentProjectsScreenState();
}

class _ProjectIdea {
  final String title;
  final String domain;
  final String level;
  final String description;
  final String stack;
  final List<String> steps;
  final List<_ProjectLink> links;

  const _ProjectIdea({
    required this.title,
    required this.domain,
    required this.level,
    required this.description,
    required this.stack,
    required this.steps,
    required this.links,
  });
}

class _ProjectLink {
  final String label;
  final String url;

  const _ProjectLink(this.label, this.url);
}

class _StudentProjectsScreenState extends State<StudentProjectsScreen> {
  String _domain = 'all';
  String _level = 'all';

  static final List<_ProjectIdea> _ideas = _seedProjects();

  static List<_ProjectIdea> _seedProjects() {
    const templates = {
      'ai': {
        'beginner': ['Material Sort Classifier', 'Image Labeling Assistant', 'Defect Tagger', 'Reuse Score Predictor'],
        'intermediate': ['E-Waste Vision Pipeline', 'Demand Forecast Model', 'Intent Segmentation Engine', 'Anomaly Detector for Intake'],
        'advanced': ['Multimodal ReClaim Copilot', 'Graph Recommendation Engine', 'Auto-Triage Agent', 'Lifecycle Digital Twin Predictor'],
      },
      'iot': {
        'beginner': ['Bin Fill Sensor Node', 'Smart Shelf Counter', 'RFID Batch Tracker', 'Low-Stock Beacon'],
        'intermediate': ['Pickup Route Telemetry', 'Cold-Storage Monitor', 'Edge Alert Gateway', 'Campus Node Health Monitor'],
        'advanced': ['Autonomous Sort Line Controller', 'Predictive Maintenance Mesh', 'Cross-Campus Sensor Fabric', 'Real-time Queue Optimizer'],
      },
      'fullstack': {
        'beginner': ['Campus Reuse Board', 'Material Request Portal', 'Donation Intake App', 'Inventory Check-in Panel'],
        'intermediate': ['Auction and Allocation Engine', 'Supplier SLA Dashboard', 'Ops Incident Workbench', 'Role-based Compliance Console'],
        'advanced': ['Multi-tenant ReClaim Platform', 'Realtime Collaboration Hub', 'Workflow Automation Studio', 'Finance and Settlement Core'],
      },
      'sustainability': {
        'beginner': ['CO2 Savings Calculator', 'Waste Audit Tracker', 'Circularity Scorecard', 'Energy Impact Logbook'],
        'intermediate': ['Material Flow Sankey Dashboard', 'Repair-vs-Replace Analyzer', 'Reuse Program Evaluator', 'Sustainability KPI Explorer'],
        'advanced': ['Scenario Planning Simulator', 'Net-zero Pathway Model', 'Circular Supply Optimizer', 'Impact Attribution Engine'],
      },
    };

    const stackByDomain = {
      'ai': 'Python, FastAPI, TensorFlow/PyTorch',
      'iot': 'ESP32, MQTT, Node-RED, Flutter',
      'fullstack': 'Flutter Web, Supabase, Riverpod',
      'sustainability': 'Python, SQL, BI (Plotly/Power BI)',
    };

    const baseLinksByDomain = {
      'ai': [
        _ProjectLink('TensorFlow Tutorials', 'https://www.tensorflow.org/tutorials'),
        _ProjectLink('scikit-learn Guide', 'https://scikit-learn.org/stable/user_guide.html'),
        _ProjectLink('FastAPI Tutorial', 'https://fastapi.tiangolo.com/tutorial/'),
      ],
      'iot': [
        _ProjectLink('ESP32 Getting Started', 'https://randomnerdtutorials.com/getting-started-with-esp32/'),
        _ProjectLink('MQTT Essentials', 'https://www.hivemq.com/mqtt-essentials/'),
        _ProjectLink('Node-RED Docs', 'https://nodered.org/docs/'),
      ],
      'fullstack': [
        _ProjectLink('Flutter Codelabs', 'https://docs.flutter.dev/codelabs'),
        _ProjectLink('Supabase Flutter Quickstart', 'https://supabase.com/docs/guides/getting-started/quickstarts/flutter'),
        _ProjectLink('Riverpod Docs', 'https://riverpod.dev/'),
      ],
      'sustainability': [
        _ProjectLink('Pandas Tutorials', 'https://pandas.pydata.org/docs/getting_started/intro_tutorials/'),
        _ProjectLink('Plotly Python', 'https://plotly.com/python/'),
        _ProjectLink('GHG Protocol Guidance', 'https://ghgprotocol.org/standards'),
      ],
    };

    final out = <_ProjectIdea>[];

    for (final domain in templates.keys) {
      final levelMap = templates[domain]!;
      for (final level in levelMap.keys) {
        for (final title in levelMap[level]!) {
          out.add(
            _ProjectIdea(
              title: title,
              domain: domain,
              level: level,
              description:
                  'Build $title for ReClaim workflows with measurable impact on recovery, allocation, and student operations.',
              stack: stackByDomain[domain]!,
              steps: [
                'Define objective, scope, and success metric for campus deployment.',
                'Set up project repository and baseline data schema.',
                'Implement core module and test with sample material datasets.',
                'Integrate UI/dashboard and validate end-to-end flow.',
                'Document results, limitations, and next sprint improvements.',
              ],
              links: baseLinksByDomain[domain]!,
            ),
          );
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final width = MediaQuery.of(context).size.width;

    final filtered = _ideas.where((p) {
      final byDomain = _domain == 'all' || p.domain == _domain;
      final byLevel = _level == 'all' || p.level == _level;
      return byDomain && byLevel;
    }).toList();

    return ResponsiveScaffold(
      currentRoute: '/student-projects',
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              title: const Text('Projects'),
              actions: [
                IconButton(
                  onPressed: () => context.go('/student-dashboard'),
                  icon: const Icon(Icons.dashboard_outlined),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Student Projects Hub',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(width)),
                child: Padding(
                  padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Recommender',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Explore practical ReClaim-aligned project ideas with realistic implementation stacks.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _dropdown(
                            label: 'Domain',
                            value: _domain,
                            options: const {
                              'all': 'All domains',
                              'ai': 'AI/ML',
                              'iot': 'IoT/Embedded',
                              'fullstack': 'Full-stack',
                              'sustainability': 'Sustainability',
                            },
                            onChanged: (v) => setState(() => _domain = v),
                          ),
                          _dropdown(
                            label: 'Level',
                            value: _level,
                            options: const {
                              'all': 'All levels',
                              'beginner': 'Beginner',
                              'intermediate': 'Intermediate',
                              'advanced': 'Advanced',
                            },
                            onChanged: (v) => setState(() => _level = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...filtered.map(_projectCard),
                      if (!isMobile) const SizedBox(height: 24),
                      if (!isMobile) const WebFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E6DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            items: options.entries
                .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _projectCard(_ProjectIdea idea) {
    return InkWell(
      onTap: () => _openGuide(idea),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EFE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 3),
            Text(idea.description, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text('Stack: ${idea.stack}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(idea.domain.toUpperCase()),
                _chip(idea.level.toUpperCase()),
                const _LinkHint(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _openGuide(_ProjectIdea idea) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Text(idea.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(idea.description, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              Text('Stack: ${idea.stack}', style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 12),
              const Text('Build Steps', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...idea.steps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text('${e.key + 1}. ${e.value}'),
                  )),
              const SizedBox(height: 12),
              const Text('Tutorial / Article / Video Links', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...idea.links.map((l) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link, size: 18, color: AppTheme.primaryGreen),
                    title: Text(l.label, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(l.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _openLink(l.url),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }
}

class _LinkHint extends StatelessWidget {
  const _LinkHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Open for steps + links', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
    );
  }
}
