import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/capture/widgets/ai_material_detection.dart';
import 'package:reclaim/features/materials/widgets/campus_filter.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/detection',
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Detection',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          _hero(),
          Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
              child: Padding(
                padding: AppTheme.pagePadding(w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: AIMaterialDetection()),
                        SizedBox(width: 24),
                        Expanded(child: CampusFilter()),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _howItWorks(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          const WebFooter(),
        ],
      ),
    );
  }

  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          AIMaterialDetection(),
          SizedBox(height: 20),
          CampusFilter(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 14, color: Colors.white70),
                            SizedBox(width: 6),
                            Text('Powered by AI',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Smart Material\nDetection',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Identify materials instantly with AI and find\nwhat\'s available near your campus.',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Stats row
                Row(
                  children: [
                    _heroStat('500+', 'Materials\nDetected'),
                    const SizedBox(width: 24),
                    _heroStat('3', 'Campuses\nCovered'),
                    const SizedBox(width: 24),
                    _heroStat('94%', 'Detection\nAccuracy'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white60, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _howItWorks() {
    final steps = [
      (Icons.camera_alt_outlined, 'Capture', 'Take a photo or upload an image of any material'),
      (Icons.auto_awesome, 'AI Analyzes', 'Our AI identifies the material, condition and value'),
      (Icons.location_on_outlined, 'Find Nearby', 'Discover the same material available on your campus'),
      (Icons.swap_horiz, 'Exchange', 'Buy, barter or request the material directly'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How It Works',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 20),
        Row(
          children: steps.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < steps.length - 1 ? 16 : 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5EFE8)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(s.$1,
                              color: AppTheme.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(s.$2,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    Text(s.$3,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
