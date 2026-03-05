import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/core/theme/app_theme.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              Color(0xFF12082A),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App title
                Text(
                  'LOCK IN',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 6,
                    fontSize: 13,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 40),

                // Streak ring
                StreakRing(
                  currentStreak: streak.currentStreak,
                  icon: streak.progressIcon,
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 28),

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
                const SizedBox(height: 36),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Best',
                        value: '${streak.longestStreak}',
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Days',
                        value:
                            '${streak.totalCleanDays + streak.currentStreak}',
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Resets',
                        value: '${streak.relapseCount}',
                        icon: Icons.refresh_rounded,
                        iconColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Action buttons
                if (streak.streakStartDate == null) ...[
                  GlowButton(
                    text: 'START YOUR JOURNEY',
                    onPressed: () {
                      ref.read(streakProvider.notifier).startStreak();
                    },
                    width: double.infinity,
                    height: 56,
                    icon: Icons.play_arrow_rounded,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: GlowButton(
                          text: 'I FEEL AN URGE',
                          onPressed: () {
                            context.push('/urge');
                          },
                          color: AppColors.accent,
                          height: 52,
                          icon: Icons.warning_amber_rounded,
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
                          icon: Icons.edit_note_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ResetDialog(
                          onReset: () {
                            ref.read(streakProvider.notifier).resetStreak();
                            setState(() {
                              _quote = _randomQuote();
                            });
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    label: const Text(
                      'Reset Streak',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
