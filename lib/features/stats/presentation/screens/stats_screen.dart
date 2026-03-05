import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lock_in/features/stats/presentation/providers/stats_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/features/stats/presentation/widgets/mood_streak_graph.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  Map<String, dynamic> _getNextMilestone(int currentStreak) {
    for (final a in AppConstants.achievements) {
      if (a['type'] != 'streak') continue;
      if ((a['days'] as int) > currentStreak) return a;
    }
    return {
      'title': 'Beyond Legend',
      'days': currentStreak + 365,
      'icon': PhosphorIconsDuotone.crown,
    };
  }

  Map<String, dynamic>? _getCurrentMilestone(int currentStreak) {
    Map<String, dynamic>? current;
    for (final a in AppConstants.achievements) {
      if (a['type'] != 'streak') continue;
      if ((a['days'] as int) <= currentStreak) current = a;
    }
    return current;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final urge = ref.watch(urgeProvider);
    final c = AppColorScheme.of(ref.watch(themeProvider));

    final nextMilestone = _getNextMilestone(stats.currentStreak);
    final currentMilestone = _getCurrentMilestone(stats.currentStreak);
    final nextDays = nextMilestone['days'] as int;
    final prevDays = currentMilestone != null
        ? (currentMilestone['days'] as int)
        : 0;
    final progress = nextDays > prevDays
        ? (stats.currentStreak - prevDays) / (nextDays - prevDays)
        : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.background, c.gradientMid],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'STATISTICS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 4,
                    fontSize: 12,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),

                // Stat cards grid
                Row(
                  children: [
                    Expanded(
                      child: _BigStatCard(
                        title: 'Success Rate',
                        value: '${stats.successRate.toStringAsFixed(0)}%',
                        icon: PhosphorIconsDuotone.trendUp,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BigStatCard(
                        title: 'Longest Streak',
                        value: '${stats.longestStreak}',
                        icon: PhosphorIconsDuotone.trophy,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BigStatCard(
                        title: 'Total Clean',
                        value: '${stats.totalCleanDays}',
                        icon: PhosphorIconsDuotone.sunHorizon,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BigStatCard(
                        title: 'Urges Beat',
                        value: '${stats.totalUrges}',
                        icon: PhosphorIconsDuotone.barbell,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ─── Milestone Progress ───
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsDuotone.target,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Milestone',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Milestone title & icon
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              nextMilestone['icon'] as IconData,
                              size: 22,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nextMilestone['title'] as String,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${nextDays - stats.currentStreak} days to go',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Day ${stats.currentStreak}/$nextDays',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceLight.withValues(
                            alpha: 0.4,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Urge Heatmap ───
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsDuotone.fire,
                            size: 18,
                            color: const Color(0xFFEF5350),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Urge Heatmap',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Time of day when you experience the most urges.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: _UrgeHeatmapChart(events: urge.events),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Mood vs Streak Graph ───
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: const MoodStreakGraph(),
                ),
                const SizedBox(height: 16),

                // Resets info
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          PhosphorIconsDuotone.arrowCounterClockwise,
                          color: AppColors.warning,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stats.relapseCount} Resets',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Every reset is a new beginning',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgeHeatmapChart extends StatelessWidget {
  final List<UrgeEvent> events;

  const _UrgeHeatmapChart({required this.events});

  @override
  Widget build(BuildContext context) {
    // 8 bins of 3 hours each
    final List<int> bins = List.filled(8, 0);
    for (final e in events) {
      final hour = e.timestamp.hour;
      final binIndex = hour ~/ 3;
      bins[binIndex]++;
    }

    int maxCount = 0;
    for (final count in bins) {
      if (count > maxCount) maxCount = count;
    }

    final maxY = maxCount == 0 ? 1.0 : (maxCount + 1).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.surfaceLight,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} urges\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: _getBinLabel(groupIndex),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _getBinShortLabel(value.toInt()),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCount > 0
              ? (maxCount / 4).clamp(1, double.infinity).ceilToDouble()
              : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceLight.withValues(alpha: 0.2),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(8, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: bins[i].toDouble(),
                color: const Color(0xFFEF5350), // Reddish
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.surfaceLight.withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getBinLabel(int index) {
    switch (index) {
      case 0:
        return '12 AM - 3 AM';
      case 1:
        return '3 AM - 6 AM';
      case 2:
        return '6 AM - 9 AM';
      case 3:
        return '9 AM - 12 PM';
      case 4:
        return '12 PM - 3 PM';
      case 5:
        return '3 PM - 6 PM';
      case 6:
        return '6 PM - 9 PM';
      case 7:
        return '9 PM - 12 AM';
      default:
        return '';
    }
  }

  String _getBinShortLabel(int index) {
    switch (index) {
      case 0:
        return '12a';
      case 1:
        return '3a';
      case 2:
        return '6a';
      case 3:
        return '9a';
      case 4:
        return '12p';
      case 5:
        return '3p';
      case 6:
        return '6p';
      case 7:
        return '9p';
      default:
        return '';
    }
  }
}
