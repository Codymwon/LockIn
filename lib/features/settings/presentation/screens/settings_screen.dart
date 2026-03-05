import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/core/utils/date_utils.dart';
import 'package:lock_in/features/streak/presentation/providers/streak_provider.dart';
import 'package:lock_in/features/stats/presentation/providers/stats_provider.dart';
import 'package:lock_in/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:lock_in/features/journal/presentation/providers/journal_provider.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/services/storage_service.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  DateTime? _previewDate;

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('$days day${days == 1 ? '' : 's'}');
    if (hours > 0) parts.add('$hours hr${hours == 1 ? '' : 's'}');
    if (minutes > 0) parts.add('$minutes min');
    if (parts.isEmpty) return 'Just started';
    return parts.join(', ');
  }

  Future<void> _pickDateTime() async {
    final streak = ref.read(streakProvider);
    final now = DateTime.now();
    final initialDate = _previewDate ?? streak.streakStartDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final chosen = combined.isAfter(now) ? now : combined;
    setState(() => _previewDate = chosen);
    await ref.read(streakProvider.notifier).updateStreakStartDate(chosen);
  }

  Future<void> _showResetConfirmation(AppColorScheme c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(PhosphorIconsDuotone.warning, color: c.warning, size: 24),
            const SizedBox(width: 12),
            Text(
              'Reset All Data?',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all your streak history, statistics, badges, journal entries, and urge logs.\n\nThis action cannot be undone.',
          style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: c.warning.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Reset Everything',
              style: TextStyle(color: c.warning, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageService.resetAllData();
      setState(() => _previewDate = null);

      // Wait for the dialog exit animation to fully complete
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      ref.invalidate(streakProvider);
      ref.invalidate(statsProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(journalProvider);
      ref.invalidate(urgeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final isAmoled = ref.watch(themeProvider);
    final c = AppColorScheme.of(isAmoled);
    final startDate = _previewDate ?? streak.streakStartDate;
    final now = DateTime.now();
    final streakDuration = startDate != null
        ? now.difference(startDate)
        : Duration.zero;

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
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          PhosphorIconsDuotone.caretLeft,
                          color: c.textSecondary.withValues(alpha: 0.7),
                          size: 22,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Text(
                      'SETTINGS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 6,
                        fontSize: 13,
                        color: c.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── APPEARANCE ───
                      _SectionLabel(text: 'APPEARANCE', color: c.textSecondary),

                      GlassCard(
                        padding: const EdgeInsets.all(0),
                        borderRadius: 16,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              _SettingIcon(
                                color: isAmoled ? Colors.white : c.primary,
                                icon: PhosphorIconsDuotone.moon,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AMOLED Black',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pure black for OLED displays',
                                      style: TextStyle(
                                        color: c.textSecondary.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: isAmoled,
                                onChanged: (_) {
                                  HapticFeedback.selectionClick();
                                  ref.read(themeProvider.notifier).toggle();
                                },
                                activeColor: c.primary,
                                activeTrackColor: c.primary.withValues(
                                  alpha: 0.3,
                                ),
                                inactiveThumbColor: c.textSecondary,
                                inactiveTrackColor: c.surfaceLight.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── STREAK ───
                      _SectionLabel(text: 'STREAK', color: c.textSecondary),

                      GlassCard(
                        padding: const EdgeInsets.all(0),
                        borderRadius: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickDateTime,
                            borderRadius: BorderRadius.circular(16),
                            splashColor: c.primary.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              child: Row(
                                children: [
                                  _SettingIcon(
                                    color: c.primary,
                                    icon: PhosphorIconsDuotone.calendarBlank,
                                    accentColor: c.accent,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Streak Start Date',
                                          style: TextStyle(
                                            color: c.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          startDate != null
                                              ? '${AppDateUtils.formatDate(startDate)}  •  ${AppDateUtils.formatTime(startDate)}'
                                              : 'Not started yet',
                                          style: TextStyle(
                                            color: c.textSecondary.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    PhosphorIconsDuotone.pencilSimple,
                                    color: c.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (startDate != null) ...[
                        const SizedBox(height: 16),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          borderRadius: 16,
                          child: Row(
                            children: [
                              _SettingIcon(
                                color: c.success,
                                icon: PhosphorIconsDuotone.timer,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Streak',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDuration(streakDuration),
                                      style: TextStyle(
                                        color: c.success,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ─── DANGER ZONE ───
                      _SectionLabel(text: 'DANGER ZONE', color: c.warning),

                      GlassCard(
                        padding: const EdgeInsets.all(0),
                        borderRadius: 16,
                        borderColor: c.warning.withValues(alpha: 0.2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showResetConfirmation(c),
                            borderRadius: BorderRadius.circular(16),
                            splashColor: c.warning.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              child: Row(
                                children: [
                                  _SettingIcon(
                                    color: c.warning,
                                    icon: PhosphorIconsDuotone.trash,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reset All Data',
                                          style: TextStyle(
                                            color: c.warning,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Delete all stats, badges, journals & urges',
                                          style: TextStyle(
                                            color: c.textSecondary.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    PhosphorIconsDuotone.caretRight,
                                    color: c.warning.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Settings Widgets ───

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: color.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color? accentColor;

  const _SettingIcon({
    required this.color,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accentColor ?? color, size: 20),
    );
  }
}
