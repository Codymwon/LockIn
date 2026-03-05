import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/providers/haptics_provider.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/core/utils/date_utils.dart';
import 'package:lock_in/features/journal/presentation/providers/journal_provider.dart';
import 'package:lock_in/services/storage_service.dart';
import 'package:lock_in/shared/widgets/glass_card.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);
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
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        PhosphorIconsDuotone.caretLeft,
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(hapticsProvider.notifier).lightImpact();
                        Navigator.of(context).pop();
                      },
                      color: AppColors.textSecondary,
                    ),
                    const Spacer(),
                    Text(
                      'JOURNAL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 4,
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: journal.entries.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: journal.entries.length,
                        itemBuilder: (context, index) {
                          final entry = journal.entries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: ValueKey(entry.timestamp),
                              direction: DismissDirection.endToStart,
                              background: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    PhosphorIconsDuotone.trash,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(hapticsProvider.notifier)
                                    .mediumImpact();
                                ref
                                    .read(journalProvider.notifier)
                                    .deleteEntry(entry.index);
                              },
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          PhosphorIconsDuotone.fileText,
                                          size: 16,
                                          color: AppColors.accent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppDateUtils.formatDate(
                                            entry.timestamp,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          AppDateUtils.formatTime(
                                            entry.timestamp,
                                          ),
                                          style: TextStyle(
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      entry.text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            height: 1.5,
                                          ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntrySheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(PhosphorIconsDuotone.plus, color: Colors.white),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.cardBorder),
              left: BorderSide(color: AppColors.cardBorder),
              right: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  autofocus: true,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your reflection...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.background.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GlowButton(
                    text: 'SAVE ENTRY',
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        final currentEntries = ref
                            .read(journalProvider)
                            .entries
                            .length;
                        ref
                            .read(journalProvider.notifier)
                            .addEntry(controller.text.trim());
                        Navigator.of(context).pop();

                        if (currentEntries == 0 &&
                            !StorageService.getHasShownJournalDeleteTip()) {
                          StorageService.setHasShownJournalDeleteTip(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    PhosphorIconsDuotone.lightbulb,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Tip: Swipe left on a journal entry to delete it.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.surfaceLight,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    height: 52,
                    icon: PhosphorIconsDuotone.check,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              PhosphorIconsDuotone.bookOpenText,
              size: 36,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text('No entries yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap + to write your first reflection',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
