import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/services/storage_service.dart';

class UrgeEvent {
  final DateTime timestamp;
  final int survivalSeconds;

  const UrgeEvent({required this.timestamp, required this.survivalSeconds});
}

class UrgeState {
  final List<UrgeEvent> events;
  final bool isBreathing;
  final int elapsedSeconds;

  const UrgeState({
    this.events = const [],
    this.isBreathing = false,
    this.elapsedSeconds = 0,
  });

  UrgeState copyWith({
    List<UrgeEvent>? events,
    bool? isBreathing,
    int? elapsedSeconds,
  }) {
    return UrgeState(
      events: events ?? this.events,
      isBreathing: isBreathing ?? this.isBreathing,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class UrgeNotifier extends Notifier<UrgeState> {
  @override
  UrgeState build() {
    return _loadEvents();
  }

  UrgeState _loadEvents() {
    final raw = StorageService.getUrgeEvents();
    final events = raw.map((e) {
      return UrgeEvent(
        timestamp: DateTime.fromMillisecondsSinceEpoch(e['timestamp'] as int),
        survivalSeconds: e['survivalSeconds'] as int? ?? 0,
      );
    }).toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return UrgeState(events: events);
  }

  Future<void> logUrge(int survivalSeconds) async {
    final now = DateTime.now();
    await StorageService.addUrgeEvent({
      'timestamp': now.millisecondsSinceEpoch,
      'survivalSeconds': survivalSeconds,
    });
    state = _loadEvents();
  }

  int get todayUrgeCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.events.where((e) {
      final eventDay = DateTime(
        e.timestamp.year,
        e.timestamp.month,
        e.timestamp.day,
      );
      return eventDay == today;
    }).length;
  }
}

final urgeProvider = NotifierProvider<UrgeNotifier, UrgeState>(
  UrgeNotifier.new,
);
