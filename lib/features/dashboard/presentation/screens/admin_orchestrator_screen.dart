import 'package:flutter/material.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/dashboard/presentation/widgets/admin_orchestrator_section.dart';

const Color _orchBg0 = Color(0xFF718F6C);
const Color _orchBg1 = Color(0xFF2F5D3A);
const Color _orchSurface = Color(0xFFF3F1E7);
const Color _orchBorder = Color(0xFF2F5D3A);
const Color _orchText = Color(0xFF2F5D3A);
const Color _orchMuted = Color(0xFF718F6C);
const Color _orchGold = Color(0xFF2F5D3A);

class AdminOrchestratorScreen extends StatelessWidget {
  const AdminOrchestratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final w = MediaQuery.of(context).size.width;

    return ResponsiveScaffold(
      currentRoute: '/admin-orchestrator',
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: _orchSurface,
              foregroundColor: _orchText,
              title: const Text(
                'Admin Orchestrator',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_orchBg0, _orchBg1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: AppTheme.pagePadding(w),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _orchSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _orchBorder),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Orchestrator',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _orchText,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'EXECUTION LAYER',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.1,
                                color: _orchGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Dedicated operational control center for SCM, CRM, Security, Marketing, ERP, and Revenue.',
                              style: TextStyle(
                                fontSize: 13,
                                color: _orchMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    const AdminOrchestratorSection(),
                    const SizedBox(height: 24),
                    if (!isMobile) const WebFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
