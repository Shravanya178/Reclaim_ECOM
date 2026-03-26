import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reclaim/core/theme/app_theme.dart';

class ImpactDashboard extends StatefulWidget {
  const ImpactDashboard({super.key});

  @override
  State<ImpactDashboard> createState() => _ImpactDashboardState();
}

class _ImpactDashboardState extends State<ImpactDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final List<ImpactMetric> metrics = [
    ImpactMetric(
      icon: Icons.eco,
      value: '12.5',
      unit: 'kg',
      label: 'CO₂ Saved',
      color: AppTheme.success,
    ),
    ImpactMetric(
      icon: Icons.recycling,
      value: '8',
      unit: '',
      label: 'Materials Reused',
      color: AppTheme.primaryGreen,
    ),
    ImpactMetric(
      icon: Icons.emoji_events,
      value: '#3',
      unit: '',
      label: 'VESIT Campus Rank',
      color: AppTheme.secondary,
    ),
  ];

  final List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(1, 'Rahul', '15kg', false),
    LeaderboardEntry(2, 'Sneha', '13kg', false),
    LeaderboardEntry(3, 'You', '12.5kg', true),
    LeaderboardEntry(4, 'Amit', '10kg', false),
    LeaderboardEntry(5, 'Priya', '9kg', false),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Sustainability Impact',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your contribution and compete with peers',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Metrics Cards
          Row(
            children: metrics.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < metrics.length - 1 ? 16 : 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: metric.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: metric.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: metric.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          metric.icon,
                          color: metric.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: metric.value,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: metric.color,
                              ),
                            ),
                            if (metric.unit.isNotEmpty)
                              TextSpan(
                                text: metric.unit,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: metric.color,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Progress Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EFE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EFE8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.75 * _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.success, AppTheme.primaryGreen],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '75% towards your monthly sustainability goal',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Leaderboard
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 20,
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Leaderboard (Top 5)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...leaderboard.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: entry.isUser 
                    ? AppTheme.primaryGreen.withOpacity(0.05)
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: entry.isUser 
                      ? AppTheme.primaryGreen.withOpacity(0.3)
                      : const Color(0xFFE5EFE8),
                  width: entry.isUser ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getRankColor(entry.rank).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getRankEmoji(entry.rank),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.name + (entry.isUser ? ' (You)' : ''),
                      style: GoogleFonts.inter(
                        fontWeight: entry.isUser ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                        color: entry.isUser 
                            ? AppTheme.primaryGreen 
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    entry.score,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: entry.isUser 
                          ? AppTheme.primaryGreen 
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Achievement Badges
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.success.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Achievements',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAchievementBadge('🌱 Eco Warrior', AppTheme.success),
                    _buildAchievementBadge('♻️ Recycling Champion', AppTheme.primaryGreen),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return AppTheme.textSecondary;
    }
  }
}

class ImpactMetric {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  ImpactMetric({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String score;
  final bool isUser;

  LeaderboardEntry(this.rank, this.name, this.score, this.isUser);
}