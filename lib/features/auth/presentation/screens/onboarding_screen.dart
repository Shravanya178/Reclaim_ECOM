import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reclaim/core/services/email_campaign_service.dart';
import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _heroAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _customerLifecycle = 'New User';
  String _customerValue = 'Beginner User';
  String? _personalizedBanner;
  String? _reEngagementMessage;

  String _segmentLabel(String value) {
    return switch (value) {
      'Frequent Buyer' => 'High Value User',
      'Active Builder' => 'Growing Value User',
      _ => 'Emerging User',
    };
  }

  static const _pages = [
    _OPage(icon: Icons.recycling, title: 'Welcome to ReClaim',
      headline: 'Where Waste Becomes\nOpportunity',
      body: 'Discover how discarded lab materials can become the foundation for your next innovative project. Join the campus circular economy.'),
    _OPage(icon: Icons.psychology_outlined, title: 'AI-Powered Detection',
      headline: 'Smart Material\nIdentification',
      body: 'Our advanced AI instantly identifies, categorizes, and values materials — making every lab item discoverable and tradeable across campus.'),
    _OPage(icon: Icons.eco_outlined, title: 'Impact Tracking',
      headline: 'Measure Your\nEco Impact',
      body: 'Every reused material saves CO2 and avoids landfill. Track your personal and lab-wide sustainability score in real time.'),
    _OPage(icon: Icons.store_outlined, title: 'Campus Marketplace',
      headline: 'Buy, Sell &\nBarter Materials',
      body: 'A verified marketplace exclusively for your campus. List surplus equipment, find rare chemicals, and trade with trusted labs.'),
  ];

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _fadeAnim = CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut));
    _loadCrmInsights();
  }

  Future<void> _loadCrmInsights() async {
    final intelligence = ErpCrmIntelligenceService.instance;
    await intelligence.touchSession();
    final lifecycle = await intelligence.getCustomerLifecycle();
    final value = await intelligence.getCustomerValueIndicator();
    final personalized = await intelligence.getPersonalizedRecommendationBanner();
    final reengagement = await intelligence.getReEngagementMessage();

    if (!mounted) return;
    setState(() {
      _customerLifecycle = lifecycle;
      _customerValue = _segmentLabel(value);
      _personalizedBanner = personalized;
      _reEngagementMessage = reengagement;
    });
  }

  @override
  void dispose() { _heroAnim.dispose(); _pageCtrl.dispose(); super.dispose(); }

  Future<void> _next() async {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      await ErpCrmIntelligenceService.instance.recordOnboardingCompleted();
      context.go('/auth');
    }
  }

  void _openProjectRecommendationTool() {
    int step = 1;
    String? experience;
    String? projectType;

    List<String> recommendationFor(String level, String project) {
      if (level.toLowerCase() == 'beginner' && project.toLowerCase() == 'electronics') {
        return ['Arduino Uno', 'Breadboard', 'Jumper Wires'];
      }
      if (level.toLowerCase() == 'intermediate' && project.toLowerCase() == 'hardware') {
        return ['Raspberry Pi', 'Sensors', 'Project Enclosure'];
      }
      if (level.toLowerCase() == 'advanced' && project.toLowerCase() == 'automation') {
        return ['Microcontroller Kit', 'Relay Module', 'Power Supply'];
      }
      return ['Reusable Components', 'Starter Kit', 'Project Accessories'];
    }

    List<(String, String)> tutorialLinksFor(String project) {
      switch (project.toLowerCase()) {
        case 'electronics':
          return [
            ('Arduino Official Tutorials', 'https://docs.arduino.cc/tutorials/'),
            ('SparkFun Electronics Tutorials', 'https://learn.sparkfun.com/tutorials'),
          ];
        case 'hardware':
          return [
            ('Raspberry Pi Projects', 'https://projects.raspberrypi.org/en/projects'),
            ('Adafruit Learn', 'https://learn.adafruit.com/'),
          ];
        case 'automation':
          return [
            ('ESP32 Getting Started', 'https://randomnerdtutorials.com/getting-started-with-esp32/'),
            ('Home Assistant Guides', 'https://www.home-assistant.io/getting-started/'),
          ];
        default:
          return [
            ('Flutter Codelabs', 'https://docs.flutter.dev/codelabs'),
          ];
      }
    }

    showGeneralDialog(
      context: context,
      barrierLabel: 'Project Recommendation Tool',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, __) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 560,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Project Recommendation Tool',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step == 1 ? 'Choose your experience level' : 'Choose your project type',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      if (step == 1)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['Beginner', 'Intermediate', 'Advanced'].map((value) {
                            final selected = experience == value;
                            return ChoiceChip(
                              label: Text(value),
                              selected: selected,
                              onSelected: (_) => setModalState(() => experience = value),
                            );
                          }).toList(),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['Electronics', 'Hardware', 'Automation'].map((value) {
                            final selected = projectType == value;
                            return ChoiceChip(
                              label: Text(value),
                              selected: selected,
                              onSelected: (_) => setModalState(() => projectType = value),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (step == 2)
                            TextButton(
                              onPressed: () => setModalState(() => step = 1),
                              child: const Text('Back'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (step == 1) {
                                if (experience == null) return;
                                setModalState(() => step = 2);
                                return;
                              }
                              if (projectType == null) return;
                                ErpCrmIntelligenceService.instance
                                  .trackRecommendationSelection(projectType ?? 'IoT');
                              ErpCrmIntelligenceService.instance
                                  .recordAcquisitionChannel('project_recommendation');
                              final items = recommendationFor(experience ?? '', projectType ?? '');
                              final links = tutorialLinksFor(projectType ?? '');
                              Navigator.of(ctx).pop();
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Recommended Components'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(items.join(', ')),
                                      const SizedBox(height: 12),
                                      const Text('Tutorials', style: TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      ...links.map((l) => TextButton.icon(
                                        onPressed: () {
                                          launchUrl(Uri.parse(l.$2), mode: LaunchMode.platformDefault);
                                        },
                                        icon: const Icon(Icons.link, size: 16),
                                        label: Text(l.$1),
                                      )),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text('Close'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        context.go('/shop');
                                      },
                                      child: const Text('Start Shopping'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(step == 1 ? 'Next' : 'Show Recommendation'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) =>
      Breakpoints.isMobile(context) ? _mobile() : _desktop();

  Widget _desktop() => Scaffold(
    backgroundColor: Colors.transparent,
    body: SingleChildScrollView(
      child: Column(children: [
        _DesktopHero(fadeAnim: _fadeAnim, slideAnim: _slideAnim),
        const _DesktopStats(),
        const _DesktopFeatures(),
        const _DesktopHowItWorks(),
        _CrmUserInsightStrip(
          lifecycle: _customerLifecycle,
          valueTier: _customerValue,
          personalizedBanner: _personalizedBanner,
          reEngagementMessage: _reEngagementMessage,
        ),
        _DesktopCTA(onOpenRecommendationTool: _openProjectRecommendationTool),
        _DesktopFooter(),
      ]),
    ),
  );

  Widget _mobile() => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: Column(children: [
        Align(alignment: Alignment.topRight,
          child: TextButton(onPressed: () => context.go('/auth'),
            child: const Text('Skip', style: TextStyle(color: Colors.white70, fontSize: 14)))),
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _MobilePage(_pages[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 Status: $_customerLifecycle',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⭐ Segment: $_customerValue',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            if (_reEngagementMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Text(
                  _reEngagementMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(4))))),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppTheme.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: Text(_page < _pages.length - 1 ? 'Continue' : 'Get Started',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 14),
            TextButton(onPressed: () => context.go('/auth'),
              child: const Text('Already have an account? Sign In',
                style: TextStyle(color: Colors.white70, fontSize: 13))),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openProjectRecommendationTool,
              icon: const Icon(Icons.tune, size: 16, color: Colors.white),
              label: const Text('Find Components for Your Project', style: TextStyle(color: Colors.white)),
            ),
            if (_page == _pages.length - 1) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick actions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ErpCrmIntelligenceService.instance
                                .trackInteraction(productId: 'Arduino Uno Rev3', weight: 2);
                            context.go('/shop');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                          ),
                          child: const Text('Explore Materials'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ErpCrmIntelligenceService.instance
                                .trackInteraction(weight: 1);
                            context.go('/auth');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                          ),
                          child: const Text('Start Shopping'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ErpCrmIntelligenceService.instance
                                .trackInteraction(weight: 1);
                            context.go('/auth');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                          ),
                          child: const Text('List a Material'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ]),
        ),
      ]),
    ),
  );
}

class _OPage {
  final IconData icon;
  final String title, headline, body;
  const _OPage({required this.icon, required this.title, required this.headline, required this.body});
}

class _MobilePage extends StatelessWidget {
  final _OPage page;
  const _MobilePage(this.page);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 120, height: 120,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(page.icon, size: 56, color: Colors.white)),
      const SizedBox(height: 36),
      Text(page.title,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.5),
        textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(page.headline,
        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.2),
        textAlign: TextAlign.center),
      const SizedBox(height: 20),
      Text(page.body,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15, height: 1.6),
        textAlign: TextAlign.center),
    ]),
  );
}

// ─── Desktop Hero ─────────────────────────────────────────────────────────────
class _DesktopHero extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  const _DesktopHero({required this.fadeAnim, required this.slideAnim});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B4332).withOpacity(0.7),
          const Color(0xFF2D6A4F).withOpacity(0.5),
          const Color(0xFF40916C).withOpacity(0.4),
          const Color(0xFF1B4332).withOpacity(0.7),
        ],
      ),
    ),
    child: Stack(children: [
      // Decorative elements (keeping these for visual enhancement)
      Positioned(top: -80, right: -80, child: Container(width: 400, height: 400,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
      Positioned(bottom: -60, left: 100, child: Container(width: 300, height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
      Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
          child: FadeTransition(opacity: fadeAnim, child: SlideTransition(position: slideAnim,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text('Campus Circular Economy Platform',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                const SizedBox(height: 24),
                const Text('Transform Lab Waste\nInto Opportunity',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 52, 
                    fontWeight: FontWeight.w900, 
                    height: 1.15,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black45,
                      ),
                    ],
                  )),
                const SizedBox(height: 20),
                Text('ReClaim connects campus labs, students, and sustainability managers in a verified circular economy. AI-powered material detection, instant marketplace, and real-time eco impact tracking.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9), 
                    fontSize: 17, 
                    height: 1.65,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  )),
                const SizedBox(height: 36),
                Row(children: [
                  _HBtn('Get Started Free', true, () => context.go('/auth')),
                  const SizedBox(width: 16),
                  _HBtn('Learn More', false, () {}),
                ]),
                const SizedBox(height: 40),
                Row(children: [
                  _hStat('1,200+', 'Materials Listed'),
                  const SizedBox(width: 36),
                  _hStat('40+', 'Partner Labs'),
                  const SizedBox(width: 36),
                  _hStat('18,750 kg', 'CO2 Saved'),
                ]),
              ])),
              const SizedBox(width: 64),
              Expanded(flex: 4, child: _HeroCard()),
            ]))),
        ),
      )),
    ]),
  );

  Widget _hStat(String v, String l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(
      color: Colors.white, 
      fontSize: 22, 
      fontWeight: FontWeight.w800,
      shadows: [
        Shadow(
          offset: Offset(0, 1),
          blurRadius: 4,
          color: Colors.black45,
        ),
      ],
    )),
    Text(l, style: TextStyle(
      color: Colors.white.withOpacity(0.8), 
      fontSize: 12, 
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
          offset: Offset(0, 1),
          blurRadius: 3,
          color: Colors.black38,
        ),
      ],
    )),
  ]);
}

class _HBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _HBtn(this.label, this.primary, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    decoration: BoxDecoration(
      color: primary ? Colors.white : Colors.transparent,
      border: primary ? null : Border.all(color: Colors.white54),
      borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: TextStyle(
      color: primary ? AppTheme.primaryDark : Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15), 
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.science_outlined, color: AppTheme.primaryGreen, size: 20)),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Borosilicate Beakers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textPrimary)),
              Text('Chemistry Lab A', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(20)),
              child: const Text('Available', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen))),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Rs.180', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(7)),
              child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ])),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF40916C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), 
              blurRadius: 12, 
              offset: const Offset(0,6)
            )
          ]),
        child: Row(children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Scan Complete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
            Text('Identified: Lab Glassware (98%)', style: TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
        ])),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1B5E3B), Color(0xFF2D6A4F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), 
              blurRadius: 12, 
              offset: const Offset(0,6)
            )
          ]),
        child: Row(children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.eco, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Eco Impact Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
            Text('12.4 kg CO₂ saved', style: TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
        ])),
    ]),
  );
}

// ─── Stats bar ────────────────────────────────────────────────────────────────
class _DesktopStats extends StatelessWidget {
  const _DesktopStats();
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.primaryDark,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _s('1,200+', 'Materials Listed'),
        _s('284', 'Active Users'),
        _s('40+', 'Partner Labs'),
        _s('18,750 kg', 'CO2 Saved'),
        _s('96%', 'Satisfaction'),
      ]),
    )),
  );
  Widget _s(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
    const SizedBox(height: 4),
    Text(l, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, fontWeight: FontWeight.w500)),
  ]);
}

// ─── Features ─────────────────────────────────────────────────────────────────
class _DesktopFeatures extends StatelessWidget {
  const _DesktopFeatures();
  static const _f = [
    (Icons.psychology_outlined, 'AI Material Detection', 'Point your camera at any material. Our AI instantly classifies and values it for listing or transfer.'),
    (Icons.storefront_outlined, 'Verified Marketplace', 'Buy, sell, or barter with verified campus labs. Every transaction is transparent and eco-stamped.'),
    (Icons.eco_outlined, 'Real-time Eco Tracking', 'Every material saved contributes to your eco score. Compete for the greenest lab on campus.'),
    (Icons.sync_alt_outlined, 'Cross-lab Transfers', 'Request materials from any campus lab. Automated workflows keep everything smooth.'),
    (Icons.notifications_active_outlined, 'Smart Alerts', 'Get notified when needed materials become available or your stock runs low.'),
    (Icons.bar_chart_outlined, 'Analytics Dashboard', 'Deep insights into material flow, waste reduction, and circular economy metrics.'),
  ];
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.backgroundLight,
    padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(children: [
        const Text('Everything You Need', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('A complete platform for campus circular economy', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 48),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 24, crossAxisSpacing: 24, childAspectRatio: 1.5,
          children: _f.map((f) => _FCard(f.$1, f.$2, f.$3)).toList()),
      ]),
    )),
  );
}

class _FCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _FCard(this.icon, this.title, this.body);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 22)),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      const SizedBox(height: 6),
      Expanded(child: Text(body, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5))),
    ]),
  );
}

// ─── How it works ─────────────────────────────────────────────────────────────
class _DesktopHowItWorks extends StatelessWidget {
  const _DesktopHowItWorks();
  static const _steps = [
    (Icons.person_add_outlined, '1', 'Create Account', 'Sign up with your institutional email. Select your role: student, lab admin, or manager.'),
    (Icons.camera_alt_outlined, '2', 'Scan & List', 'AI scans materials in seconds. Review auto-generated details and publish to marketplace.'),
    (Icons.shopping_bag_outlined, '3', 'Discover & Trade', 'Browse campus inventory. Request transfers, place orders, or propose barters.'),
    (Icons.eco_outlined, '4', 'Track Impact', 'Monitor your eco score and celebrate sustainability milestones campus-wide.'),
  ];
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.primarySurface,
    padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(children: [
        const Text('How ReClaim Works', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('From lab shelf to new hands in minutes', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 48),
        Row(crossAxisAlignment: CrossAxisAlignment.start,
          children: _steps.asMap().entries.map((e) => Expanded(child: Row(children: [
            Flexible(child: _StepCard(e.value)),
            if (e.key < _steps.length - 1)
              Padding(padding: const EdgeInsets.only(top: 28),
                child: const Icon(Icons.arrow_forward, color: AppTheme.primaryLight, size: 24)),
          ]))).toList()),
      ]),
    )),
  );
}


class _CrmUserInsightStrip extends StatelessWidget {
  const _CrmUserInsightStrip({
    required this.lifecycle,
    required this.valueTier,
    this.personalizedBanner,
    this.reEngagementMessage,
  });

  final String lifecycle;
  final String valueTier;
  final String? personalizedBanner;
  final String? reEngagementMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 980),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ERP + CRM Snapshot',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InsightPill(label: '👤 Status', value: lifecycle),
                _InsightPill(label: '⭐ Segment', value: valueTier),
                if (personalizedBanner != null)
                  _InsightPill(label: 'Personalized', value: personalizedBanner!),
                if (reEngagementMessage != null)
                  _InsightPill(label: 'Re-engagement', value: reEngagementMessage!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
class _StepCard extends StatelessWidget {
  final (IconData, String, String, String) step;
  const _StepCard(this.step);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(children: [
      Stack(alignment: Alignment.center, children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryLight],
            begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle)),
        Icon(step.$1, color: Colors.white, size: 30),
        Positioned(top: 0, right: 0, child: Container(width: 22, height: 22,
          decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle),
          child: Center(child: Text(step.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.white))))),
      ]),
      const SizedBox(height: 14),
      Text(step.$3, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary)),
      const SizedBox(height: 6),
      Text(step.$4, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
    ]),
  );
}

// ─── CTA ──────────────────────────────────────────────────────────────────────
class _DesktopCTA extends StatefulWidget {
  final VoidCallback onOpenRecommendationTool;
  const _DesktopCTA({required this.onOpenRecommendationTool});

  @override
  State<_DesktopCTA> createState() => _DesktopCTAState();
}

class _DesktopCTAState extends State<_DesktopCTA> {
  final TextEditingController _waitlistEmailCtrl = TextEditingController();
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  String? _waitlistMessage;
  bool _waitlistSuccess = false;
  bool _waitlistSending = false;

  @override
  void dispose() {
    _waitlistEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleJoinWaitlist() async {
    final email = _waitlistEmailCtrl.text.trim();

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _waitlistSuccess = false;
        _waitlistMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _waitlistSending = true;
      _waitlistMessage = null;
    });

    try {
      final message = await EmailCampaignService.sendWaitlistAutoReply(email: email);
      if (!mounted) return;

      setState(() {
        _waitlistSuccess = true;
        _waitlistMessage = message;
        _waitlistEmailCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _waitlistSuccess = false;
        _waitlistMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _waitlistSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
    child: Center(
      child: Column(
        children: [
          const Text(
            'Ready to Build a Greener Campus?',
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join 284+ students and 40 labs already making a difference.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 17),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onOpenRecommendationTool,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Find Components for Your Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.go('/shop'),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Explore Materials', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/auth'),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Start Shopping', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/auth'),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
                  child: const Text('List a Material', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Container(
            width: 720,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Stay Updated with ReClaim',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Get updates on reusable components and new features',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _waitlistEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 1.4)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _waitlistSending ? null : _handleJoinWaitlist,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryDark, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _waitlistSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Join Waitlist', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                if (_waitlistMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _waitlistMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _waitlistSuccess ? Colors.lightGreenAccent : Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _DesktopFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.primaryDark,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.recycling, color: Colors.white, size: 16)),
          const SizedBox(width: 8),
          const Text('ReClaim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        Text('2024 ReClaim VESIT Mumbai', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        Row(children: [
          _fl('Privacy'), const SizedBox(width: 20),
          _fl('Terms'), const SizedBox(width: 20),
          _fl('Contact'),
        ]),
      ]),
    )),
  );
  Widget _fl(String t) => Text(t, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13, fontWeight: FontWeight.w500));
}
