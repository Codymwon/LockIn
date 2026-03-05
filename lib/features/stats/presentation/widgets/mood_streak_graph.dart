import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/features/journal/presentation/providers/journal_provider.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';

class MoodStreakGraph extends ConsumerWidget {
  const MoodStreakGraph({super.key});

  int _moodToScore(String mood) {
    switch (mood) {
      case '😡':
        return 1;
      case '🙁':
        return 2;
      case '😐':
        return 3;
      case '🙂':
        return 4;
      case '🤩':
        return 5;
      default:
        return 3;
    }
  }

  String _scoreToMood(int score) {
    switch (score) {
      case 1:
        return '😡';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final journal = ref.watch(journalProvider);

    // Filter journal entries for the current streak and only those with a mood
    final streakStartDate = streak.streakStartDate;
    if (streakStartDate == null) {
      return const SizedBox.shrink();
    }

    final currentStreakEntries = journal.entries.where((entry) {
      return entry.mood != null && entry.timestamp.isAfter(streakStartDate);
    }).toList();

    // Group by streak day to average out daily moods if there are multiple
    final Map<int, List<int>> dailyMoods = {};

    for (final entry in currentStreakEntries) {
      final daysDiff = entry.timestamp.difference(streakStartDate).inDays;
      // Streak day 1 corresponds to daysDiff == 0.
      final streakDay = daysDiff + 1;

      if (!dailyMoods.containsKey(streakDay)) {
        dailyMoods[streakDay] = [];
      }
      dailyMoods[streakDay]!.add(_moodToScore(entry.mood!));
    }

    // Sort by day and calculate average mood
    final sortedDays = dailyMoods.keys.toList()..sort();
    final List<FlSpot> spots = [];

    for (final day in sortedDays) {
      final scores = dailyMoods[day]!;
      final double averageMood = scores.reduce((a, b) => a + b) / scores.length;
      spots.add(FlSpot(day.toDouble(), averageMood));
    }

    if (spots.isEmpty) {
      return const SizedBox.shrink(); // Hide graph if no mood data for the streak
    }

    double minX = spots.first.x;
    double maxX = spots.last.x;
    if (minX == maxX) {
      maxX += 1; // Give it some width if there's only one data point
      minX -= 1;
      if (minX < 1) minX = 1;
    }

    // Add some padding to x-axis
    maxX += 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood vs Streak Length',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'As your streak grows, so does your baseline happiness.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.surfaceLight.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: ((maxX - minX) / 5).ceilToDouble().clamp(
                      1.0,
                      double.infinity,
                    ),
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value < 1 || value > 5) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _scoreToMood(value.toInt()),
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: minX,
              maxX: maxX,
              minY: 1,
              maxY: 5,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.background,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceLight,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final day = touchedSpot.x.toInt();
                      final score = touchedSpot.y;
                      final emoji = _scoreToMood(score.round());
                      return LineTooltipItem(
                        'Day $day\nMood: $emoji',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
