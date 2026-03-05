import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredDays;
  final IconData icon;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredDays,
    required this.icon,
    required this.unlocked,
  });
}

class AchievementsState {
  final List<Achievement> achievements;
  final String currentRank;
  final int unlockedCount;

  const AchievementsState({
    this.achievements = const [],
    this.currentRank = 'Recruit',
    this.unlockedCount = 0,
  });
}

class AchievementsNotifier extends Notifier<AchievementsState> {
  @override
  AchievementsState build() {
    final streak = ref.watch(streakProvider);
    final longestStreak = streak.longestStreak;

    final achievements = AppConstants.achievements.map((a) {
      return Achievement(
        id: a['id'] as String,
        title: a['title'] as String,
        description: a['description'] as String,
        requiredDays: a['days'] as int,
        icon: a['icon'] as IconData,
        unlocked: longestStreak >= (a['days'] as int),
      );
    }).toList();

    return AchievementsState(
      achievements: achievements,
      currentRank: streak.rank,
      unlockedCount: achievements.where((a) => a.unlocked).length,
    );
  }
}

final achievementsProvider =
    NotifierProvider<AchievementsNotifier, AchievementsState>(
      AchievementsNotifier.new,
    );
