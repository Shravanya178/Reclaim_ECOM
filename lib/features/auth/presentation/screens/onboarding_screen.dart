import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

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
  }

  @override
  void dispose() { _heroAnim.dispose(); _pageCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      context.go('/auth');
    }
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
        _DesktopCTA(),
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
class _DesktopCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
    child: Center(child: Column(children: [
      const Text('Ready to Build a Greener Campus?',
        style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Text('Join 284+ students and 40 labs already making a difference.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 17), textAlign: TextAlign.center),
      const SizedBox(height: 40),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(onTap: () => context.go('/auth'),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Text('Start for Free', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w800, fontSize: 16)))),
        const SizedBox(width: 16),
        GestureDetector(onTap: () => context.go('/auth'),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(12)),
            child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))),
      ]),
    ])),
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
