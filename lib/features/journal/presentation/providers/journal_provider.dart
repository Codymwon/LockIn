import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

class JournalEntry {
  final int index;
  final String text;
  final DateTime timestamp;

  const JournalEntry({
    required this.index,
    required this.text,
    required this.timestamp,
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
    for (int i = 0; i < raw.length; i++) {
      final e = raw[i];
      entries.add(
        JournalEntry(
          index: i,
          text: e['text'] as String? ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
        ),
      );
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return JournalState(entries: entries);
  }

  Future<void> addEntry(String text) async {
    await StorageService.addJournalEntry({
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    state = _loadEntries();
  }

  Future<void> updateEntry(int index, String text) async {
    final entry = StorageService.getJournalEntries()[index];
    await StorageService.updateJournalEntry(index, {
      'text': text,
      'timestamp': entry['timestamp'],
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
