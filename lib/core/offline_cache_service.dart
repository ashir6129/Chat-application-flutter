import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  OfflineCacheService._();

  static const _boxName = 'offline_cache';
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<void> setJson(String key, Object value) async {
    await _box?.put(key, jsonEncode(value));
  }

  static dynamic getJson(String key) {
    final raw = _box?.get(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>>? getJsonList(String key) {
    final decoded = getJson(key);
    if (decoded is! List) return null;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> remove(String key) async {
    await _box?.delete(key);
  }
}
