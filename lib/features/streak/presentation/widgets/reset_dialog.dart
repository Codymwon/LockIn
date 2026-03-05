import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';
import 'package:lock_in/features/settings/presentation/providers/streak_settings_provider.dart';

/// Glassmorphic dialog for streak reset with encouraging language.
class ResetDialog extends ConsumerStatefulWidget {
  final ValueChanged<String> onReset;
  final ValueChanged<String> onSlip;

  const ResetDialog({super.key, required this.onReset, required this.onSlip});

  @override
  ConsumerState<ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends ConsumerState<ResetDialog> {
  String? _selectedTrigger;
  final List<String> _triggers = [
    'Stress',
    'Boredom',
    'Late Night',
    'Social Media',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Text(
              'What triggered this?',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _triggers.map((trigger) {
                final isSelected = _selectedTrigger == trigger;
                return ChoiceChip(
                  label: Text(trigger),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTrigger = selected ? trigger : null;
                    });
                  },
                  backgroundColor: AppColors.surfaceLight,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            if (isStrict) ...[
              GlowButton(
                text: 'I Relapsed (Reset to 0)',
                onPressed: _selectedTrigger == null
                    ? () {}
                    : () {
                        widget.onReset(_selectedTrigger!);
                        Navigator.of(context).pop();
                        _showEncouragement(context);
                      },
                color: _selectedTrigger == null
                    ? AppColors.surfaceLight
                    : AppColors.warning,
                textColor: _selectedTrigger == null
                    ? AppColors.textSecondary
                    : Colors.white,
                width: double.infinity,
              ),
            ] else ...[
              GlowButton(
                text: 'I Slipped (-$penalty Day${penalty == 1 ? '' : 's'})',
                onPressed: _selectedTrigger == null
                    ? () {}
                    : () {
                        widget.onSlip(_selectedTrigger!);
                        Navigator.of(context).pop();
                        _showEncouragement(
                          context,
                          text: 'Dust yourself off. Keep going.',
                        );
                      },
                color: _selectedTrigger == null
                    ? AppColors.surfaceLight
                    : AppColors.warning,
                textColor: _selectedTrigger == null
                    ? AppColors.textSecondary
                    : Colors.white,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _selectedTrigger == null
                    ? null
                    : () {
                        widget.onReset(_selectedTrigger!);
                        Navigator.of(context).pop();
                        _showEncouragement(context);
                      },
                child: Text(
                  'Total Relapse (Reset to 0)',
                  style: TextStyle(
                    color: _selectedTrigger == null
                        ? AppColors.textSecondary
                        : AppColors.warning,
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
