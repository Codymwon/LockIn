import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';

class StatsState {
  final int currentStreak;
  final int longestStreak;
  final int totalCleanDays;
  final int relapseCount;
  final double successRate;
  final int totalUrges;
  final List<int> weeklyData; // last 7 days streak values

  const StatsState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCleanDays = 0,
    this.relapseCount = 0,
    this.successRate = 0.0,
    this.totalUrges = 0,
    this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
  });
}

class StatsNotifier extends Notifier<StatsState> {
  @override
  StatsState build() {
    final streak = ref.watch(streakProvider);
    final urge = ref.watch(urgeProvider);

    final totalDays = streak.totalCleanDays + streak.currentStreak;
    final totalCalendarDays = totalDays + streak.relapseCount;
    final successRate = totalCalendarDays > 0
        ? (totalDays / totalCalendarDays * 100)
        : 0.0;

    // Build weekly data — simplified: just show current streak progress mapped to 7 days
    final weeklyData = List.generate(7, (i) {
      final daysAgo = 6 - i;
      if (streak.currentStreak > daysAgo) {
        return 1;
      }
      return 0;
    });

    return StatsState(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      totalCleanDays: totalDays,
      relapseCount: streak.relapseCount,
      successRate: successRate,
      totalUrges: urge.events.length,
      weeklyData: weeklyData,
    );
  }
}

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(
  StatsNotifier.new,
);
