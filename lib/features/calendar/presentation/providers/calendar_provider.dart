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
    final Map<DateTime, bool> statuses = {};

    if (streakStart != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var current = DateTime(
        streakStart.year,
        streakStart.month,
        streakStart.day,
      );

      while (!current.isAfter(today)) {
        statuses[current] = true;
        current = current.add(const Duration(days: 1));
      }
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
