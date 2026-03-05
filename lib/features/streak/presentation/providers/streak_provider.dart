import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/core/utils/date_utils.dart';
import 'package:lock_in/services/storage_service.dart';

/// The state representing the user's streak data.
class StreakState {
  final int currentStreak;
  final int longestStreak;
  final int totalCleanDays;
  final int relapseCount;
  final DateTime? streakStartDate;
  final String rank;
  final IconData progressIcon;

  const StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCleanDays = 0,
    this.relapseCount = 0,
    this.streakStartDate,
    this.rank = 'Recruit',
    this.progressIcon = PhosphorIconsDuotone.drop,
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalCleanDays,
    int? relapseCount,
    DateTime? streakStartDate,
    String? rank,
    IconData? progressIcon,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      relapseCount: relapseCount ?? this.relapseCount,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      rank: rank ?? this.rank,
      progressIcon: progressIcon ?? this.progressIcon,
    );
  }
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    return _loadFromStorage();
  }

  StreakState _loadFromStorage() {
    final startDate = StorageService.getStreakStartDate();
    final longestStreak = StorageService.getLongestStreak();
    final totalCleanDays = StorageService.getTotalCleanDays();
    final relapseCount = StorageService.getRelapseCount();

    int currentStreak = 0;
    if (startDate != null) {
      currentStreak = AppDateUtils.calculateStreak(startDate);
    }

    // Update longest streak if current beats it
    if (currentStreak > longestStreak) {
      StorageService.setLongestStreak(currentStreak);
    }

    return StreakState(
      currentStreak: currentStreak,
      longestStreak: currentStreak > longestStreak
          ? currentStreak
          : longestStreak,
      totalCleanDays: totalCleanDays,
      relapseCount: relapseCount,
      streakStartDate: startDate,
      rank: _getRank(currentStreak),
      progressIcon: _getProgressIcon(currentStreak),
    );
  }

  /// Start a new streak (first time or after relapse).
  Future<void> startStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await StorageService.setStreakStartDate(
      now,
    ); // Keep precise time to show realistic countdown
    await StorageService.setLastCheckIn(today);
    state = _loadFromStorage();
  }

  /// Reset the streak (relapse).
  Future<void> resetStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Save current streak as total clean days
    final newTotal = state.totalCleanDays + state.currentStreak;
    await StorageService.setTotalCleanDays(newTotal);
    await StorageService.setRelapseCount(state.relapseCount + 1);

    // Start fresh
    await StorageService.setStreakStartDate(
      now,
    ); // Keep precise time to show realistic countdown
    await StorageService.setLastCheckIn(today);

    state = _loadFromStorage();
  }

  /// Update the streak start date (e.g., user backdating their streak).
  Future<void> updateStreakStartDate(DateTime newDate) async {
    await StorageService.setStreakStartDate(newDate);
    final today = DateTime(newDate.year, newDate.month, newDate.day);
    await StorageService.setLastCheckIn(today);
    state = _loadFromStorage();
  }

  /// Refresh state (e.g., on app resume to recalculate streak).
  void refresh() {
    state = _loadFromStorage();
  }

  String _getRank(int days) {
    String rank = 'Recruit';
    for (final entry in AppConstants.ranks.entries) {
      if (days >= entry.key) rank = entry.value;
    }
    return rank;
  }

  IconData _getProgressIcon(int days) {
    IconData icon = PhosphorIconsDuotone.drop;
    for (final entry in AppConstants.progressIcons.entries) {
      if (days >= entry.key) icon = entry.value;
    }
    return icon;
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(
  StreakNotifier.new,
);
