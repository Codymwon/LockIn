import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/features/calendar/presentation/providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final statuses = calendarState.dayStatuses;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFF12082A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'CALENDAR',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 4,
                  fontSize: 12,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TableCalendar(
                    firstDay: DateTime(2024, 1, 1),
                    lastDay: DateTime.now().add(const Duration(days: 1)),
                    focusedDay: calendarState.focusedMonth,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.accent,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      weekendTextStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final normalizedDay = DateTime(
                          day.year,
                          day.month,
                          day.day,
                        );
                        final isClean = statuses[normalizedDay];

                        if (isClean == true) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    onPageChanged: (focusedDay) {
                      ref
                          .read(calendarProvider.notifier)
                          .changeFocusedMonth(focusedDay);
                    },
                  ),
                ),
              ),
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      label: 'Clean Day',
                    ),
                    const SizedBox(width: 24),
                    _LegendDot(color: AppColors.primary, label: 'Today'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
