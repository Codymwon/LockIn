import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

class StreakSettingsState {
  final bool isStrictMode;
  final int slipPenaltyDays;

  const StreakSettingsState({
    this.isStrictMode = true,
    this.slipPenaltyDays = 1,
  });

  StreakSettingsState copyWith({bool? isStrictMode, int? slipPenaltyDays}) {
    return StreakSettingsState(
      isStrictMode: isStrictMode ?? this.isStrictMode,
      slipPenaltyDays: slipPenaltyDays ?? this.slipPenaltyDays,
    );
  }
}

class StreakSettingsNotifier extends Notifier<StreakSettingsState> {
  @override
  StreakSettingsState build() {
    return StreakSettingsState(
      isStrictMode: StorageService.getStrictMode(),
      slipPenaltyDays: StorageService.getSlipPenaltyDays(),
    );
  }

  Future<void> toggleStrictMode(bool value) async {
    await StorageService.setStrictMode(value);
    state = state.copyWith(isStrictMode: value);
  }

  Future<void> setSlipPenaltyDays(int days) async {
    await StorageService.setSlipPenaltyDays(days);
    state = state.copyWith(slipPenaltyDays: days);
  }
}

final streakSettingsProvider =
    NotifierProvider<StreakSettingsNotifier, StreakSettingsState>(
      StreakSettingsNotifier.new,
    );
