import 'package:flutter/foundation.dart';
import '../core/offline_cache_service.dart';

enum CallHistoryType { incoming, outgoing, missed }
enum CallHistoryCallType { voice, video }

class CallHistoryEntry {
  final String id;
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final CallHistoryType type;
  final CallHistoryCallType callType;
  final DateTime timestamp;
  final Duration? duration;

  const CallHistoryEntry({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    required this.type,
    required this.callType,
    required this.timestamp,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'peer_id': peerId,
        'peer_name': peerName,
        'peer_avatar': peerAvatar,
        'type': type.name,
        'call_type': callType.name,
        'timestamp': timestamp.toIso8601String(),
        'duration_seconds': duration?.inSeconds,
      };

  factory CallHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CallHistoryEntry(
      id: json['id']?.toString() ?? '',
      peerId: json['peer_id']?.toString() ?? '',
      peerName: json['peer_name']?.toString() ?? 'Unknown',
      peerAvatar: json['peer_avatar']?.toString(),
      type: CallHistoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CallHistoryType.incoming,
      ),
      callType: CallHistoryCallType.values.firstWhere(
        (e) => e.name == json['call_type'],
        orElse: () => CallHistoryCallType.voice,
      ),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'] as int)
          : null,
    );
  }

  String get formattedDuration {
    if (duration == null) return '';
    final m = duration!.inMinutes;
    final s = duration!.inSeconds % 60;
    return '${m}m ${s}s';
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (entryDay == today) {
      final h = timestamp.hour > 12
          ? timestamp.hour - 12
          : (timestamp.hour == 0 ? 12 : timestamp.hour);
      final min = timestamp.minute.toString().padLeft(2, '0');
      final ampm = timestamp.hour >= 12 ? 'AM' : 'PM';
      return '$h:$min $ampm';
    } else if (entryDay == yesterday) {
      return 'Yesterday';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[timestamp.weekday - 1];
    }
  }
}

class CallHistoryService {
  CallHistoryService._();
  static final instance = CallHistoryService._();

  static const String _cacheKey = 'call_history_v1';
  static const int _maxEntries = 100;

  final ValueNotifier<List<CallHistoryEntry>> entries =
      ValueNotifier<List<CallHistoryEntry>>([]);

  void init() {
    _loadFromCache();
  }

  void _loadFromCache() {
    try {
      final raw = OfflineCacheService.getJson(_cacheKey);
      if (raw is List) {
        final loaded = raw
            .whereType<Map>()
            .map((e) => CallHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        entries.value = loaded;
      }
    } catch (_) {}
  }

  void _persist() {
    try {
      OfflineCacheService.setJson(
        _cacheKey,
        entries.value.map((e) => e.toJson()).toList(),
      );
    } catch (_) {}
  }

  void record(CallHistoryEntry entry) {
    final updated = [entry, ...entries.value];
    if (updated.length > _maxEntries) {
      entries.value = updated.sublist(0, _maxEntries);
    } else {
      entries.value = updated;
    }
    _persist();
  }

  void clear() {
    entries.value = [];
    OfflineCacheService.remove(_cacheKey);
  }

  void deleteEntry(String id) {
    entries.value = entries.value.where((e) => e.id != id).toList();
    _persist();
  }
}
