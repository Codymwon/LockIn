import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final streakStart = ref.watch(streakProvider).streakStartDate;
    final c = AppColorScheme.of(ref.watch(themeProvider));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.background, c.gradientMid],
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

                        bool isClean = false;
                        if (streakStart != null) {
                          final startDay = DateTime(
                            streakStart.year,
                            streakStart.month,
                            streakStart.day,
                          );
                          if (!normalizedDay.isBefore(startDay) &&
                              !normalizedDay.isAfter(today)) {
                            isClean = true;
                          }
                        }

                        if (isClean) {
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
