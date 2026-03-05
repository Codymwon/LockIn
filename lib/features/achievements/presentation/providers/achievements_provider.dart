import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/features/journal/presentation/providers/journal_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String type; // 'streak', 'activity', 'time'
  final IconData icon;
  final bool unlocked;
  final String? label; // e.g. '30d', '5 urges', etc.

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.unlocked,
    this.label,
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
    final urge = ref.watch(urgeProvider);
    final journal = ref.watch(journalProvider);
    final longestStreak = streak.longestStreak;

    final achievements = AppConstants.achievements.map((a) {
      final type = a['type'] as String? ?? 'streak';
      bool unlocked = false;
      String? label;

      switch (type) {
        case 'streak':
          final days = a['days'] as int;
          unlocked = longestStreak >= days;
          label = '${days}d';
          break;

        case 'activity':
          final requirement = a['requirement'] as int;
          final category = a['category'] as String;
          switch (category) {
            case 'urge':
              unlocked = urge.events.length >= requirement;
              label = '$requirement urge${requirement > 1 ? 's' : ''}';
              break;
            case 'journal':
              unlocked = journal.entries.length >= requirement;
              label = '$requirement entry${requirement > 1 ? 's' : ''}';
              break;
            case 'relapse':
              unlocked = streak.relapseCount >= requirement;
              label = 'comeback';
              break;
          }
          break;

        case 'time':
          final timeCheck = a['timeCheck'] as String;
          switch (timeCheck) {
            case 'night':
              // Check if any urge was logged between midnight and 5 AM
              unlocked = urge.events.any((e) {
                final hour = e.timestamp.hour;
                return hour >= 0 && hour < 5;
              });
              label = 'midnight';
              break;
            case 'morning':
              // Check if any journal was logged before 8 AM
              unlocked = journal.entries.any((e) {
                final hour = e.timestamp.hour;
                return hour < 8;
              });
              label = 'early';
              break;
          }
          break;
      }

      return Achievement(
        id: a['id'] as String,
        title: a['title'] as String,
        description: a['description'] as String,
        type: type,
        icon: a['icon'] as IconData,
        unlocked: unlocked,
        label: label,
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
