import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lock_in/features/stats/presentation/providers/stats_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final urge = ref.watch(urgeProvider);
    final c = AppColorScheme.of(ref.watch(themeProvider));

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
                _MilestoneProgressCard(stats: stats),
                const SizedBox(height: 16),

                // ─── Urge Heatmap ───
                _UrgeHeatmapCard(events: urge.events),
                const SizedBox(height: 16),

                // Resets info
                _ResetsInfoCard(stats: stats),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetsInfoCard extends StatelessWidget {
  final StatsState stats;

  const _ResetsInfoCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
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
                      stats.topTrigger != null
                          ? '${stats.topTriggerPercentage!.toStringAsFixed(0)}% of your resets are caused by ${stats.topTrigger}.'
                          : 'Every reset is a new beginning',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (stats.triggerCounts.isNotEmpty) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: _TriggerPieChart(
                triggerCounts: stats.triggerCounts,
                totalTriggers: stats.validTriggers,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MilestoneProgressCard extends StatelessWidget {
  final StatsState stats;

  const _MilestoneProgressCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final nextMilestone = stats.nextMilestone;
    if (nextMilestone.isEmpty) {
      return const SizedBox.shrink(); // Safety check
    }

    final nextDays = nextMilestone['days'] as int;
    final progress = stats.milestoneProgress;

    return GlassCard(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${nextDays - stats.currentStreak} days to go',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Day ${stats.currentStreak}/$nextDays',
                style: const TextStyle(
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
              backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgeHeatmapCard extends StatelessWidget {
  final List<UrgeEvent> events;

  const _UrgeHeatmapCard({required this.events});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsDuotone.fire,
                size: 18,
                color: Color(0xFFEF5350),
              ),
              const SizedBox(width: 8),
              Text(
                'Urge Clock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Radial view of the times you experience the most urges.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Center(child: _UrgeHeatmapChart(events: events)),
        ],
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
    // 24 hours
    final List<int> hourlyCounts = List.filled(24, 0);
    int maxCount = 0;

    for (final e in events) {
      final int hour = e.timestamp.hour;
      hourlyCounts[hour]++;
      if (hourlyCounts[hour] > maxCount) {
        maxCount = hourlyCounts[hour];
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // make sure it fits
        final maxRadius = (availableWidth / 2) - 40;
        final baseRadius = maxRadius * 0.4;
        final variableRadius = maxRadius * 0.6;

        return SizedBox(
          height: availableWidth, // Make it square
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clockface background labels (12a, 6a, 12p, 6p)
              Positioned(top: 0, child: _buildClockLabel('12 AM')),
              Positioned(bottom: 0, child: _buildClockLabel('12 PM')),
              Positioned(right: 0, child: _buildClockLabel('6 AM')),
              Positioned(left: 0, child: _buildClockLabel('6 PM')),

              // The Radial Heatmap / Polar Area Chart
              SizedBox(
                width: maxRadius * 2,
                height: maxRadius * 2,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90, // Start at 12 o'clock
                    sectionsSpace: 2,
                    centerSpaceRadius: baseRadius,
                    sections: List.generate(24, (i) {
                      final count = hourlyCounts[i];

                      // Calculate radius: base + extension based on count
                      final double radiusExt = maxCount == 0
                          ? 10.0
                          : (count / maxCount) * variableRadius;

                      final radius = radiusExt < 10.0 ? 10.0 : radiusExt;

                      return PieChartSectionData(
                        value: 1, // Equal width for all 24 hours
                        radius: radius,
                        color: _getColorForCount(count, maxCount),
                        showTitle: false,
                        badgeWidget: _buildTooltipBadge(i, count),
                        badgePositionPercentageOffset: 1.2,
                      );
                    }),
                  ),
                ),
              ),

              // Center Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${events.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Urges',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClockLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTooltipBadge(int hour, int count) {
    if (count == 0) return const SizedBox.shrink();

    // Only show badge when tapped/hovered? fl_chart PieChart tooltip
    // requires touchData or custom badges. Since touchData is complex for PieChart
    // without a stateful widget, we'll let the user tap and see an invisible badge
    // or just leave it clean and beautiful.
    return const SizedBox.shrink();
  }

  Color _getColorForCount(int count, int maxCount) {
    if (count == 0 || maxCount == 0) {
      return AppColors.surfaceLight.withValues(alpha: 0.3);
    }

    final ratio = count / maxCount;
    if (ratio <= 0.25) {
      return const Color(0xFFEF9A9A).withValues(alpha: 0.8);
    } else if (ratio <= 0.5) {
      return const Color(0xFFEF5350).withValues(alpha: 0.9);
    } else if (ratio <= 0.75) {
      return const Color(0xFFD32F2F);
    } else {
      return const Color(0xFFB71C1C);
    }
  }
}

class _TriggerPieChart extends StatelessWidget {
  final Map<String, int> triggerCounts;
  final int totalTriggers;

  const _TriggerPieChart({
    required this.triggerCounts,
    required this.totalTriggers,
  });

  Color _getColorForTrigger(int index) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.warning,
      AppColors.success,
      const Color(0xFFEF5350), // Red
      const Color(0xFFAB47BC), // Purple
      const Color(0xFF26C6DA), // Cyan
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final entries = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 25,
              sections: List.generate(entries.length, (i) {
                final entry = entries[i];
                final percentage = (entry.value / totalTriggers) * 100;

                return PieChartSectionData(
                  color: _getColorForTrigger(i),
                  value: entry.value.toDouble(),
                  title: '${percentage.toInt()}%',
                  radius: 30.0,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((entry) {
              final i = entries.indexOf(entry);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getColorForTrigger(i),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
