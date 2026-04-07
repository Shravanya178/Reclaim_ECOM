import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});
  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _selectedCampus = 'All Campuses';
  String _selectedPeriod = 'This Month';

  final _campuses = ['All Campuses', 'VESIT', 'SPIT', 'DJ Sanghvi'];
  final _periods = ['This Week', 'This Month', 'All Time'];

  // ── Dummy data ──────────────────────────────────────────────────────────────
  final List<_RankEntry> _overall = [
    _RankEntry(1, 'Rahul Sharma', 'VESIT', '15.2 kg', 42, Icons.emoji_events, true),
    _RankEntry(2, 'Sneha Patil', 'SPIT', '13.8 kg', 38, Icons.emoji_events, false),
    _RankEntry(3, 'You', 'VESIT', '12.5 kg', 35, Icons.emoji_events, true),
    _RankEntry(4, 'Amit Desai', 'DJ Sanghvi', '10.1 kg', 29, null, false),
    _RankEntry(5, 'Priya Nair', 'VESIT', '9.4 kg', 26, null, false),
    _RankEntry(6, 'Rohan Mehta', 'SPIT', '8.7 kg', 24, null, false),
    _RankEntry(7, 'Ananya Joshi', 'DJ Sanghvi', '7.9 kg', 22, null, false),
    _RankEntry(8, 'Karan Patel', 'VESIT', '7.2 kg', 20, null, false),
    _RankEntry(9, 'Divya Rao', 'SPIT', '6.5 kg', 18, null, false),
    _RankEntry(10, 'Arjun Singh', 'DJ Sanghvi', '5.8 kg', 16, null, false),
  ];

  final List<_BadgeEntry> _badges = [
    _BadgeEntry('🌱 Eco Warrior', 'Saved 10+ kg CO₂', AppTheme.success, true),
    _BadgeEntry('♻️ Recycling Champion', 'Reused 5+ materials', AppTheme.primaryGreen, true),
    _BadgeEntry('🏆 Top Contributor', 'Ranked in top 3', AppTheme.secondary, true),
    _BadgeEntry('🔬 Lab Hero', 'Donated lab equipment', AppTheme.info, false),
    _BadgeEntry('⚡ Quick Trader', 'Completed 3 barters', AppTheme.warning, false),
    _BadgeEntry('🌍 Campus Legend', 'Top of campus', AppTheme.primaryDark, false),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return ResponsiveScaffold(
      currentRoute: '/rankings',
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Rankings',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      body: isMobile ? _mobile(context) : _desktop(context),
    );
  }

  Widget _desktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(children: [
        _hero(),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
            child: Padding(
              padding: AppTheme.pagePadding(w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Filters row
                Row(children: [
                  _filterDropdown('Campus', _campuses, _selectedCampus,
                      (v) => setState(() => _selectedCampus = v!)),
                  const SizedBox(width: 16),
                  _filterDropdown('Period', _periods, _selectedPeriod,
                      (v) => setState(() => _selectedPeriod = v!)),
                  const Spacer(),
                  _myRankBadge(),
                ]),
                const SizedBox(height: 32),
                // Podium
                _podium(),
                const SizedBox(height: 32),
                // Tabs
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _leaderboardCard()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: Column(children: [
                    _myImpactCard(),
                    const SizedBox(height: 20),
                    _badgesCard(),
                  ])),
                ]),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),
        const WebFooter(),
      ]),
    );
  }

  Widget _mobile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _myRankBadge(),
        const SizedBox(height: 16),
        _podium(),
        const SizedBox(height: 16),
        _leaderboardCard(),
        const SizedBox(height: 16),
        _myImpactCard(),
        const SizedBox(height: 16),
        _badgesCard(),
      ]),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.emoji_events, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Sustainability Leaderboard',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 16),
                Text('Rankings',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text('Compete with peers and track your eco-impact across campuses.',
                    style: GoogleFonts.inter(
                        color: Colors.white70, fontSize: 16, height: 1.5)),
              ])),
              const SizedBox(width: 48),
              Row(children: [
                _heroStat('🥇', 'Rahul', '15.2 kg'),
                const SizedBox(width: 16),
                _heroStat('🥈', 'Sneha', '13.8 kg'),
                const SizedBox(width: 16),
                _heroStat('🥉', 'You', '12.5 kg'),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String emoji, String name, String score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(name,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        Text(score,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }

  Widget _filterDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _myRankBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.accent]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.person, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('Your Rank: #3',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8)),
          child: Text('12.5 kg CO₂',
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _podium() {
    final top3 = _overall.take(3).toList();
    // Reorder: 2nd, 1st, 3rd for podium display
    final podiumOrder = [top3[1], top3[0], top3[2]];
    final heights = [80.0, 110.0, 60.0];
    final medals = ['🥈', '🥇', '🥉'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Text('Top 3 This Month',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: podiumOrder.asMap().entries.map((e) {
            final i = e.key;
            final entry = e.value;
            final isFirst = i == 1;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(medals[i], style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: isFirst ? 30 : 24,
                    backgroundColor: isFirst
                        ? AppTheme.primaryGreen
                        : AppTheme.primaryGreen.withOpacity(0.2),
                    child: Text(
                      entry.name[0],
                      style: GoogleFonts.inter(
                          color: isFirst ? Colors.white : AppTheme.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: isFirst ? 22 : 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.name,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textPrimary),
                      textAlign: TextAlign.center),
                  Text(entry.campus,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    height: heights[i],
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryGreen.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(entry.co2,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _leaderboardCard() {
    final filtered = _selectedCampus == 'All Campuses'
        ? _overall
        : _overall.where((e) => e.campus == _selectedCampus).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            const Icon(Icons.leaderboard, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text('Full Leaderboard',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const Spacer(),
            Text('$_selectedPeriod · $_selectedCampus',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE5EFE8)),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            SizedBox(width: 40, child: Text('Rank', style: _headerStyle())),
            const SizedBox(width: 12),
            Expanded(child: Text('Student', style: _headerStyle())),
            SizedBox(width: 80, child: Text('CO₂ Saved', style: _headerStyle(), textAlign: TextAlign.center)),
            SizedBox(width: 80, child: Text('Materials', style: _headerStyle(), textAlign: TextAlign.center)),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE5EFE8)),
        ...filtered.asMap().entries.map((e) => _leaderboardRow(e.key + 1, e.value)),
      ]),
    );
  }

  TextStyle _headerStyle() => GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppTheme.textSecondary);

  Widget _leaderboardRow(int displayRank, _RankEntry entry) {
    final isUser = entry.isCurrentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.transparent,
        border: isUser
            ? Border(
                left: BorderSide(color: AppTheme.primaryGreen, width: 3))
            : null,
      ),
      child: Row(children: [
        SizedBox(
          width: 40,
          child: Text(
            displayRank <= 3 ? ['🥇', '🥈', '🥉'][displayRank - 1] : '#$displayRank',
            style: GoogleFonts.inter(
                fontSize: displayRank <= 3 ? 18 : 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: isUser
              ? AppTheme.primaryGreen
              : AppTheme.primaryGreen.withOpacity(0.1),
          child: Text(entry.name[0],
              style: GoogleFonts.inter(
                  color: isUser ? Colors.white : AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              entry.name + (isUser ? ' (You)' : ''),
              style: GoogleFonts.inter(
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: isUser ? AppTheme.primaryGreen : AppTheme.textPrimary),
            ),
            Text(entry.campus,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ),
        SizedBox(
          width: 80,
          child: Text(entry.co2,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.success),
              textAlign: TextAlign.center),
        ),
        SizedBox(
          width: 80,
          child: Text('${entry.materials}',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.primaryGreen),
              textAlign: TextAlign.center),
        ),
      ]),
    );
  }

  Widget _myImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.eco, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('Your Impact',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _impactStat('12.5 kg', 'CO₂ Saved')),
          Expanded(child: _impactStat('8', 'Materials\nReused')),
          Expanded(child: _impactStat('#3', 'Campus\nRank')),
        ]),
        const SizedBox(height: 20),
        Text('Monthly Progress',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.75,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
        const SizedBox(height: 6),
        Text('75% towards monthly goal · 2.5 kg to go',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _trendChip('↑ 2 spots', 'vs last week', AppTheme.success)),
          const SizedBox(width: 8),
          Expanded(child: _trendChip('+3.2 kg', 'this month', AppTheme.accentLight)),
        ]),
      ]),
    );
  }

  Widget _impactStat(String value, String label) {
    return Column(children: [
      Text(value,
          style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label,
          style: GoogleFonts.inter(
              color: Colors.white60, fontSize: 11, height: 1.3),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _trendChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(children: [
        Text(value,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        Text(label,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
      ]),
    );
  }

  Widget _badgesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EFE8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.military_tech, color: AppTheme.secondary, size: 20),
          const SizedBox(width: 8),
          Text('Achievements',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const Spacer(),
          Text('${_badges.where((b) => b.earned).length}/${_badges.length} earned',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 16),
        ..._badges.map((b) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: b.earned
                ? b.color.withOpacity(0.05)
                : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: b.earned
                  ? b.color.withOpacity(0.3)
                  : const Color(0xFFE5EFE8),
            ),
          ),
          child: Row(children: [
            Text(b.emoji.split(' ')[0],
                style: TextStyle(
                    fontSize: 20,
                    color: b.earned ? null : Colors.grey)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.emoji.split(' ').skip(1).join(' '),
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: b.earned
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary)),
                Text(b.description,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            )),
            if (b.earned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: b.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Earned',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              )
            else
              Icon(Icons.lock_outline,
                  size: 16, color: AppTheme.textSecondary),
          ]),
        )),
      ]),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _RankEntry {
  final int rank;
  final String name, campus, co2;
  final int materials;
  final IconData? icon;
  final bool isCurrentUser;
  const _RankEntry(this.rank, this.name, this.campus, this.co2, this.materials,
      this.icon, this.isCurrentUser);
}

class _BadgeEntry {
  final String emoji, description;
  final Color color;
  final bool earned;
  const _BadgeEntry(this.emoji, this.description, this.color, this.earned);
}
