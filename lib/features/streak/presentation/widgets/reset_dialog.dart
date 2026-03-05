import 'package:flutter/material.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';

/// Glassmorphic dialog for streak reset with encouraging language.
class ResetDialog extends StatelessWidget {
  final VoidCallback onReset;

  const ResetDialog({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
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
                Icons.restart_alt_rounded,
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
            GlowButton(
              text: 'I slipped',
              onPressed: () {
                onReset();
                Navigator.of(context).pop();
                _showEncouragement(context);
              },
              color: AppColors.warning,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
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

  void _showEncouragement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Your journey continues. Start again today.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
