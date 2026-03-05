import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);
    final c = AppColorScheme.of(ref.watch(themeProvider));

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'ACHIEVEMENTS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 4,
                    fontSize: 12,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),

                // Current rank display
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            PhosphorIconsDuotone.lightning,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Rank',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.currentRank,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${state.unlockedCount}/${state.achievements.length}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            'Unlocked',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Achievements list
                ...state.achievements.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementCard(achievement: a),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: achievement.unlocked ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        borderColor: achievement.unlocked
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.cardBorder,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  achievement.unlocked
                      ? achievement.icon
                      : PhosphorIconsDuotone.lockKey,
                  size: 22,
                  color: achievement.unlocked
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
