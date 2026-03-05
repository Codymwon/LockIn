import 'package:intl/intl.dart';

class AppDateUtils {
  /// Returns true if [a] and [b] are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if [date] is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Returns the number of calendar days between [from] and [to].
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Calculates the current streak given a [startDate].
  /// Based on full 24-hour periods elapsed (not calendar days).
  /// Returns 0 if startDate is in the future.
  static int calculateStreak(DateTime startDate) {
    final diff = DateTime.now().difference(startDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Formats a date like "Mar 5, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Formats a date like "5 Mar"
  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Formats time like "10:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Returns a list of all dates between [start] and [end], inclusive.
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }
}
