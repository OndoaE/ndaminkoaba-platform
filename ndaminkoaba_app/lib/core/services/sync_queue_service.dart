import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/data/enrollment_repository.dart';
import '../../features/progress/data/progress_repository.dart';

enum SyncOpType { markLessonComplete, ensureEnrolled }

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.queuedAt,
  });

  final String id;
  final SyncOpType type;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'queuedAt': queuedAt.toIso8601String(),
  };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] ?? '',
      type: SyncOpType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SyncOpType.markLessonComplete,
      ),
      payload: (json['payload'] as Map).cast<String, dynamic>(),
      queuedAt: DateTime.tryParse(json['queuedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// A `shared_preferences`-backed queue of writes that failed because the
/// device had no connectivity — `POST /progress` (lesson completion) and
/// `POST /enrollments` are both idempotent server-side (upsert / swallowed
/// 409), so replaying a queued op that already landed is harmless. Replay
/// is driven externally (connectivity restore, app resume — see
/// `main.dart`), not by a timer here.
class SyncQueueService {
  static const _key = 'sync_queue_items';

  Future<List<Map<String, dynamic>>> _readRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeRaw(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  Future<void> enqueue(SyncOpType type, Map<String, dynamic> payload) async {
    final items = await _readRaw();
    items.add(
      SyncQueueItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 32)}',
        type: type,
        payload: payload,
        queuedAt: DateTime.now(),
      ).toJson(),
    );
    await _writeRaw(items);
  }

  Future<List<SyncQueueItem>> getAll() async {
    final raw = await _readRaw();
    return raw.map(SyncQueueItem.fromJson).toList();
  }

  Future<void> _remove(String id) async {
    final items = await _readRaw();
    items.removeWhere((item) => item['id'] == id);
    await _writeRaw(items);
  }

  /// Replays every queued op against the server, in original order,
  /// removing each on success. An op that's still failing (still offline,
  /// or a genuine server error) is left queued for the next replay attempt
  /// rather than dropped.
  Future<void> replayAll() async {
    final items = await getAll();
    for (final item in items) {
      try {
        switch (item.type) {
          case SyncOpType.markLessonComplete:
            await ProgressRepository().markLessonComplete(
              userId: item.payload['userId'] as String,
              lessonId: item.payload['lessonId'] as String,
              score: item.payload['score'] as int?,
            );
          case SyncOpType.ensureEnrolled:
            await EnrollmentRepository().ensureEnrolled(
              userId: item.payload['userId'] as String,
              courseId: item.payload['courseId'] as String,
            );
        }
        await _remove(item.id);
      } catch (_) {
        // Still failing — leave it queued for the next replay attempt.
      }
    }
  }
}
