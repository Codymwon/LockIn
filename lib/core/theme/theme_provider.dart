import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

/// Manages the AMOLED theme state (on/off), persisted in SharedPreferences.
class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return StorageService.getAmoledTheme();
  }

  Future<void> toggle() async {
    state = !state;
    await StorageService.setAmoledTheme(state);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);
