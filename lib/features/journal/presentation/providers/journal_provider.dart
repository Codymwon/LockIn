import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

class JournalEntry {
  final int index;
  final String text;
  final DateTime timestamp;
  final String? mood;

  const JournalEntry({
    required this.index,
    required this.text,
    required this.timestamp,
    this.mood,
  });
}

class JournalState {
  final List<JournalEntry> entries;

  const JournalState({this.entries = const []});
}

class JournalNotifier extends Notifier<JournalState> {
  @override
  JournalState build() {
    return _loadEntries();
  }

  JournalState _loadEntries() {
    final raw = StorageService.getJournalEntries();
    final entries = <JournalEntry>[];
    for (int i = raw.length - 1; i >= 0; i--) {
      final e = raw[i];
      entries.add(
        JournalEntry(
          index: i,
          text: e['text'] as String? ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
          mood: e['mood'] as String?,
        ),
      );
    }
    return JournalState(entries: entries);
  }

  Future<void> addEntry(String text, {String? mood}) async {
    await StorageService.addJournalEntry({
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (mood != null) 'mood': mood,
    });
    state = _loadEntries();
  }

  Future<void> updateEntry(int index, String text, {String? mood}) async {
    final entry = StorageService.getJournalEntries()[index];
    await StorageService.updateJournalEntry(index, {
      'text': text,
      'timestamp': entry['timestamp'],
      'mood': mood ?? entry['mood'],
    });
    state = _loadEntries();
  }

  Future<void> deleteEntry(int index) async {
    await StorageService.deleteJournalEntry(index);
    state = _loadEntries();
  }
}

final journalProvider = NotifierProvider<JournalNotifier, JournalState>(
  JournalNotifier.new,
);
