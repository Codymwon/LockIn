import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';
import 'package:lock_in/features/settings/presentation/providers/streak_settings_provider.dart';

/// Glassmorphic dialog for streak reset with encouraging language.
class ResetDialog extends ConsumerWidget {
  final VoidCallback onReset;
  final VoidCallback onSlip;

  const ResetDialog({super.key, required this.onReset, required this.onSlip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakSettings = ref.watch(streakSettingsProvider);
    final isStrict = streakSettings.isStrictMode;
    final penalty = streakSettings.slipPenaltyDays;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
        useBlur: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.15),
              ),
              child: const Icon(
                PhosphorIconsDuotone.arrowClockwise,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reset your streak?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your journey continues.\nEvery restart is a new opportunity.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (isStrict) ...[
              GlowButton(
                text: 'I Relapsed (Reset to 0)',
                onPressed: () {
                  onReset();
                  Navigator.of(context).pop();
                  _showEncouragement(context);
                },
                color: AppColors.warning,
                width: double.infinity,
              ),
            ] else ...[
              GlowButton(
                text: 'I Slipped (-$penalty Day${penalty == 1 ? '' : 's'})',
                onPressed: () {
                  onSlip();
                  Navigator.of(context).pop();
                  _showEncouragement(
                    context,
                    text: 'Dust yourself off. Keep going.',
                  );
                },
                color: AppColors.warning,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  onReset();
                  Navigator.of(context).pop();
                  _showEncouragement(context);
                },
                child: const Text(
                  'Total Relapse (Reset to 0)',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEncouragement(
    BuildContext context, {
    String text = 'Your journey continues. Start again today.',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              PhosphorIconsDuotone.barbell,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
