import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class FlowTimelineScreen extends StatefulWidget {
  const FlowTimelineScreen({super.key});

  @override
  State<FlowTimelineScreen> createState() => _FlowTimelineScreenState();
}

class _FlowTimelineScreenState extends State<FlowTimelineScreen> {
  String _roleFilter = 'all';

  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    final supabase = Supabase.instance.client;
    final q = supabase
        .from('business_flow_events')
        .select('created_at,actor_role,aspect,stage,action,metadata')
        .order('created_at', ascending: false)
        .limit(150);

    final rows = await q;
    final events = List<Map<String, dynamic>>.from(rows);
    if (_roleFilter == 'all') return events;
    return events.where((e) => (e['actor_role'] ?? '') == _roleFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return ResponsiveScaffold(
      currentRoute: '/flow-timeline',
      cartItemCount: 0,
      mobileAppBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('Flow Timeline', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) _buildHeader(),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(MediaQuery.of(context).size.width)),
                child: Padding(
                  padding: isMobile
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(horizontal: 42, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilter(),
                      const SizedBox(height: 14),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchEvents(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ));
                          }

                          if (snapshot.hasError) {
                            return _hint('Could not load timeline. Ensure business_flow_events table exists and user is authenticated.');
                          }

                          final events = snapshot.data ?? const [];
                          if (events.isEmpty) {
                            return _hint('No events yet. Complete onboarding, create request, checkout, and admin actions to populate this timeline.');
                          }

                          return Column(
                            children: events.map(_eventTile).toList(),
                          );
                        },
                      ),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 52),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Flow Replay', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Chronological evidence of CRM, SCM, ERP, revenue, and competitor edge events.', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          const Text('Actor', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'customer', label: Text('Customer')),
              ButtonSegment(value: 'admin', label: Text('Admin')),
            ],
            selected: {_roleFilter},
            onSelectionChanged: (v) => setState(() => _roleFilter = v.first),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh timeline',
          ),
        ],
      ),
    );
  }

  Widget _eventTile(Map<String, dynamic> e) {
    final aspect = (e['aspect'] ?? 'crm').toString();
    final role = (e['actor_role'] ?? 'system').toString();
    final action = (e['action'] ?? '').toString();
    final stage = (e['stage'] ?? '').toString();
    final ts = DateTime.tryParse((e['created_at'] ?? '').toString()) ?? DateTime.now();
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');

    IconData icon;
    Color c;
    switch (aspect) {
      case 'scm':
        icon = Icons.hub_outlined;
        c = const Color(0xFFD69E2E);
        break;
      case 'erp':
        icon = Icons.apartment_outlined;
        c = const Color(0xFF3182CE);
        break;
      case 'revenue':
        icon = Icons.payments_outlined;
        c = const Color(0xFF2D6A4F);
        break;
      case 'competitor':
        icon = Icons.emoji_events_outlined;
        c = const Color(0xFF805AD5);
        break;
      default:
        icon = Icons.people_outline;
        c = const Color(0xFF2D6A4F);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${aspect.toUpperCase()} • ${action.replaceAll('_', ' ')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stage: ${stage.isEmpty ? '-': stage}  |  Actor: $role  |  Time: $hh:$mm',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
    );
  }
}
