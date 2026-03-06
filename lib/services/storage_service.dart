import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central service for initializing and accessing local storage.
class StorageService {
  static late SharedPreferences _prefs;
  static late Box<Map> _urgeBox;
  static late Box<Map> _journalBox;
  static late Box<Map> _resetsBox;

  // ─── Keys ───
  static const _streakStartKey = 'streak_start_date';
  static const _longestStreakKey = 'longest_streak';
  static const _totalDaysKey = 'total_clean_days';
  static const _relapseCountKey = 'relapse_count';
  static const _lastCheckInKey = 'last_check_in';
  static const _amoledThemeKey = 'amoled_theme';
  static const _strictModeKey = 'strict_mode';
  static const _slipPenaltyDaysKey = 'slip_penalty_days';

  /// Initialize Hive and SharedPreferences.
  static Future<void> init() async {
    await Hive.initFlutter();
    _urgeBox = await Hive.openBox<Map>('urge_events');
    _journalBox = await Hive.openBox<Map>('journal_entries');
    _resetsBox = await Hive.openBox<Map>('reset_events');
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Streak Data ───

  static DateTime? getStreakStartDate() {
    final ms = _prefs.getInt(_streakStartKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> setStreakStartDate(DateTime date) async {
    await _prefs.setInt(_streakStartKey, date.millisecondsSinceEpoch);
  }

  static int getLongestStreak() => _prefs.getInt(_longestStreakKey) ?? 0;

  static Future<void> setLongestStreak(int days) async {
    await _prefs.setInt(_longestStreakKey, days);
  }

  static int getTotalCleanDays() => _prefs.getInt(_totalDaysKey) ?? 0;

  static Future<void> setTotalCleanDays(int days) async {
    await _prefs.setInt(_totalDaysKey, days);
  }

  static int getRelapseCount() => _prefs.getInt(_relapseCountKey) ?? 0;

  static Future<void> setRelapseCount(int count) async {
    await _prefs.setInt(_relapseCountKey, count);
  }

  static DateTime? getLastCheckIn() {
    final ms = _prefs.getInt(_lastCheckInKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> setLastCheckIn(DateTime date) async {
    await _prefs.setInt(_lastCheckInKey, date.millisecondsSinceEpoch);
  }

  // ─── Streak Settings ───

  static bool getStrictMode() => _prefs.getBool(_strictModeKey) ?? true;

  static Future<void> setStrictMode(bool enabled) async {
    await _prefs.setBool(_strictModeKey, enabled);
  }

  static int getSlipPenaltyDays() => _prefs.getInt(_slipPenaltyDaysKey) ?? 1;

  static Future<void> setSlipPenaltyDays(int days) async {
    await _prefs.setInt(_slipPenaltyDaysKey, days);
  }

  // ─── Urge Events ───

  static Box<Map> get urgeBox => _urgeBox;

  static Future<void> addUrgeEvent(Map<String, dynamic> event) async {
    await _urgeBox.add(event);
  }

  static Future<void> pruneOldUrges(int daysToKeep) async {
    final now = DateTime.now();
    final threshold = now
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;
    final keysToDelete = <dynamic>[];

    for (var key in _urgeBox.keys) {
      final event = _urgeBox.get(key);
      if (event != null && (event['timestamp'] as int) < threshold) {
        keysToDelete.add(key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _urgeBox.deleteAll(keysToDelete);
    }
  }

  static List<Map<dynamic, dynamic>> getUrgeEvents() {
    return _urgeBox.values.toList();
  }

  // ─── Journal Entries ───

  static Box<Map> get journalBox => _journalBox;

  static Future<void> addJournalEntry(Map<String, dynamic> entry) async {
    await _journalBox.add(entry);
  }

  static Future<void> updateJournalEntry(
    int index,
    Map<String, dynamic> entry,
  ) async {
    await _journalBox.putAt(index, entry);
  }

  static Future<void> deleteJournalEntry(int index) async {
    await _journalBox.deleteAt(index);
  }

  static List<Map<dynamic, dynamic>> getJournalEntries() {
    return _journalBox.values.toList();
  }

  // ─── Reset Events (Relapse Autopsy) ───

  static Box<Map> get resetsBox => _resetsBox;

  static Future<void> addResetEvent(Map<String, dynamic> event) async {
    await _resetsBox.add(event);
  }

  static List<Map<dynamic, dynamic>> getResetEvents() {
    return _resetsBox.values.toList();
  }

  // ─── Reset All Data ───

  /// Clears all streak, stats, urges, and journal data.
  /// Preserves user preferences (e.g. AMOLED theme).
  static Future<void> resetAllData() async {
    await _prefs.remove(_streakStartKey);
    await _prefs.remove(_longestStreakKey);
    await _prefs.remove(_totalDaysKey);
    await _prefs.remove(_relapseCountKey);
    await _prefs.remove(_lastCheckInKey);
    await _urgeBox.clear();
    await _journalBox.clear();
    await _resetsBox.clear();
  }

  // ─── App Preferences / Tips ───

  static const _journalDeleteTipKey = 'journal_delete_tip_shown';

  static bool getHasShownJournalDeleteTip() =>
      _prefs.getBool(_journalDeleteTipKey) ?? false;

  static Future<void> setHasShownJournalDeleteTip(bool shown) async {
    await _prefs.setBool(_journalDeleteTipKey, shown);
  }

  // ─── Theme ───

  static bool getAmoledTheme() => _prefs.getBool(_amoledThemeKey) ?? false;

  static Future<void> setAmoledTheme(bool enabled) async {
    await _prefs.setBool(_amoledThemeKey, enabled);
  }

  // ─── Haptics ───

  static const _hapticsEnabledKey = 'haptics_enabled';

  static bool getHapticsEnabled() => _prefs.getBool(_hapticsEnabledKey) ?? true;

  static Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(_hapticsEnabledKey, enabled);
  }
}
