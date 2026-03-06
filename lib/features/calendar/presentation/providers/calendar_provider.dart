import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

class CalendarState {
  final Map<DateTime, bool> dayStatuses; // true = clean, false = relapse
  final DateTime focusedMonth;

  CalendarState({this.dayStatuses = const {}, DateTime? focusedMonth})
    : focusedMonth = focusedMonth ?? DateTime.now();

  CalendarState copyWith({
    Map<DateTime, bool>? dayStatuses,
    DateTime? focusedMonth,
  }) {
    return CalendarState(
      dayStatuses: dayStatuses ?? this.dayStatuses,
      focusedMonth: focusedMonth ?? this.focusedMonth,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    return _buildCalendarData();
  }

  CalendarState _buildCalendarData() {
    final streakStart = StorageService.getStreakStartDate();
    final resetEvents = StorageService.getResetEvents();
    final journalEntries = StorageService.getJournalEntries();

    final Map<DateTime, bool> statuses = {};

    if (streakStart == null && resetEvents.isEmpty && journalEntries.isEmpty) {
      return CalendarState(dayStatuses: statuses, focusedMonth: DateTime.now());
    }

    // Determine the very first day of app usage
    DateTime? earliestDate;

    if (streakStart != null) {
      earliestDate = streakStart;
    }

    for (final event in resetEvents) {
      final ts = event['timestamp'] as int?;
      if (ts != null) {
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        if (earliestDate == null || d.isBefore(earliestDate)) {
          earliestDate = d;
        }
      }
    }

    for (final entry in journalEntries) {
      final ts = entry['timestamp'] as int?;
      if (ts != null) {
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        if (earliestDate == null || d.isBefore(earliestDate)) {
          earliestDate = d;
        }
      }
    }

    if (earliestDate == null) {
      return CalendarState(dayStatuses: statuses, focusedMonth: DateTime.now());
    }

    // Standardize all dates to midnight for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Set of days where a relapse/reset occurred
    final Set<DateTime> relapseDays = {};
    for (final event in resetEvents) {
      final ts = event['timestamp'] as int?;
      if (ts != null) {
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        relapseDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    var current = DateTime(
      earliestDate.year,
      earliestDate.month,
      earliestDate.day,
    );

    while (!current.isAfter(today)) {
      if (relapseDays.contains(current)) {
        statuses[current] = false; // Relapse day
      } else {
        statuses[current] = true; // Clean day
      }
      current = current.add(const Duration(days: 1));
    }

    return CalendarState(dayStatuses: statuses, focusedMonth: DateTime.now());
  }

  void changeFocusedMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
  }

  void refresh() {
    state = _buildCalendarData();
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);
