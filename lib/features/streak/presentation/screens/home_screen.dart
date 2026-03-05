import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';
import 'package:lock_in/features/streak/presentation/widgets/streak_ring.dart';
import 'package:lock_in/features/streak/presentation/widgets/reset_dialog.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String _quote;

  @override
  void initState() {
    super.initState();
    _quote = _randomQuote();
  }

  String _randomQuote() {
    final random = Random();
    return AppConstants.quotes[random.nextInt(AppConstants.quotes.length)];
  }

  int _getNextMilestone(int currentStreak) {
    for (final achievement in AppConstants.achievements) {
      if (achievement['type'] != 'streak') continue;
      final days = achievement['days'] as int;
      if (days > currentStreak) {
        return days;
      }
    }
    return currentStreak + 365;
  }

  int _getPreviousMilestone(int currentStreak) {
    int prev = 0;
    for (final achievement in AppConstants.achievements) {
      if (achievement['type'] != 'streak') continue;
      final days = achievement['days'] as int;
      if (days <= currentStreak) {
        prev = days;
      }
    }
    return prev;
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final c = AppColorScheme.of(ref.watch(themeProvider));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.background, c.gradientMid, c.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // App header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          PhosphorIconsDuotone.gearSix,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () => context.push('/settings'),
                        tooltip: 'Settings',
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'LOCK IN',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 6,
                          fontSize: 13,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    if (streak.streakStartDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            PhosphorIconsDuotone.arrowCounterClockwise,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ResetDialog(
                                onReset: () {
                                  ref
                                      .read(streakProvider.notifier)
                                      .resetStreak();
                                  setState(() {
                                    _quote = _randomQuote();
                                  });
                                },
                              ),
                            );
                          },
                          tooltip: 'Reset Streak',
                          splashRadius: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Streak ring (combined view)
                StreakRing(
                  currentStreak: streak.currentStreak,
                  targetDays: _getNextMilestone(streak.currentStreak),
                  previousMilestone: _getPreviousMilestone(
                    streak.currentStreak,
                  ),
                  icon: streak.progressIcon,
                  streakStartDate: streak.streakStartDate,
                ),
                const SizedBox(height: 12),

                // Next goal
                if (streak.streakStartDate != null) ...[
                  Text(
                    'Goal: ${_getNextMilestone(streak.currentStreak)} Days',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Rank badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    streak.rank.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Motivational quote
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '"$_quote"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Best',
                        value: '${streak.longestStreak}',
                        icon: PhosphorIconsDuotone.trophy,
                        iconColor: const Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Days',
                        value:
                            '${streak.totalCleanDays + streak.currentStreak}',
                        icon: PhosphorIconsDuotone.chartBar,
                        iconColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Resets',
                        value: '${streak.relapseCount}',
                        icon: PhosphorIconsDuotone.arrowCounterClockwise,
                        iconColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                if (streak.streakStartDate == null) ...[
                  GlowButton(
                    text: 'START YOUR JOURNEY',
                    onPressed: () {
                      ref.read(streakProvider.notifier).startStreak();
                    },
                    width: double.infinity,
                    height: 56,
                    icon: PhosphorIconsDuotone.play,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: GlowButton(
                          text: 'URGE',
                          onPressed: () {
                            context.push('/urge');
                          },
                          color: AppColors.accent,
                          height: 52,
                          icon: PhosphorIconsDuotone.warningOctagon,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlowButton(
                          text: 'JOURNAL',
                          onPressed: () {
                            context.push('/journal');
                          },
                          color: AppColors.surfaceLight,
                          height: 52,
                          icon: PhosphorIconsDuotone.bookOpenText,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: 14,
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
