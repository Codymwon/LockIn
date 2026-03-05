import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

/// Manages the haptics preference state (on/off), persisted in SharedPreferences.
class HapticsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return StorageService.getHapticsEnabled();
  }

  Future<void> toggle() async {
    state = !state;
    await StorageService.setHapticsEnabled(state);
    if (state) {
      HapticFeedback.selectionClick();
    }
  }

  /// Helper to trigger light impact if enabled
  void lightImpact() {
    if (state) HapticFeedback.lightImpact();
  }

  /// Helper to trigger medium impact if enabled
  void mediumImpact() {
    if (state) HapticFeedback.mediumImpact();
  }

  /// Helper to trigger selection click if enabled
  void selectionClick() {
    if (state) HapticFeedback.selectionClick();
  }
}

final hapticsProvider = NotifierProvider<HapticsNotifier, bool>(
  HapticsNotifier.new,
);
