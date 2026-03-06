import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/services/storage_service.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StatsState {
  final int currentStreak;
  final int longestStreak;
  final int totalCleanDays;
  final int relapseCount;
  final double successRate;
  final int totalUrges;
  final List<int> weeklyData; // last 7 days streak values
  final String? topTrigger;
  final double? topTriggerPercentage;
  final Map<String, int> triggerCounts;
  final int validTriggers;
  final Map<String, dynamic> nextMilestone;
  final Map<String, dynamic>? currentMilestone;
  final double milestoneProgress;

  const StatsState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCleanDays = 0,
    this.relapseCount = 0,
    this.successRate = 0.0,
    this.totalUrges = 0,
    this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
    this.topTrigger,
    this.topTriggerPercentage,
    this.triggerCounts = const {},
    this.validTriggers = 0,
    this.nextMilestone = const {},
    this.currentMilestone,
    this.milestoneProgress = 0.0,
  });
}

class StatsNotifier extends Notifier<StatsState> {
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

    // Compute top trigger insight
    final resetEvents = StorageService.getResetEvents();
    String? topTrigger;
    double? topTriggerPercentage;
    Map<String, int> triggerCounts = {};
    int validTriggers = 0;

    if (resetEvents.isNotEmpty) {
      for (final event in resetEvents) {
        final trigger = event['trigger'] as String?;
        if (trigger != null) {
          triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
          validTriggers++;
        }
      }

      if (triggerCounts.isNotEmpty && validTriggers > 0) {
        var maxCount = 0;
        var maxTrigger = '';
        for (final entry in triggerCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            maxTrigger = entry.key;
          }
        }

        topTrigger = maxTrigger;
        topTriggerPercentage = (maxCount / validTriggers) * 100;
      }
    }

    final nextMilestone = _getNextMilestone(streak.currentStreak);
    final currentMilestone = _getCurrentMilestone(streak.currentStreak);
    final nextDays = nextMilestone['days'] as int;
    final prevDays = currentMilestone != null
        ? (currentMilestone['days'] as int)
        : 0;
    final progress = nextDays > prevDays
        ? (streak.currentStreak - prevDays) / (nextDays - prevDays)
        : 0.0;

    return StatsState(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      totalCleanDays: totalDays,
      relapseCount: streak.relapseCount,
      successRate: successRate,
      totalUrges: urge.events.length,
      weeklyData: weeklyData,
      topTrigger: topTrigger,
      topTriggerPercentage: topTriggerPercentage,
      triggerCounts: triggerCounts,
      validTriggers: validTriggers,
      nextMilestone: nextMilestone,
      currentMilestone: currentMilestone,
      milestoneProgress: progress,
    );
  }
}

final statsProvider = NotifierProvider<StatsNotifier, StatsState>(
  StatsNotifier.new,
);
