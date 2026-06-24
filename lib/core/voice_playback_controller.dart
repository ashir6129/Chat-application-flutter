import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global controller for voice message playback.
/// - Ensures only one voice message plays at a time.
/// - Shares playback speed across all voice messages (like WhatsApp).
/// - Tracks which conversationId is currently playing.
/// - Persists played voice message ids for chat-list preview color.
class VoicePlaybackController extends ChangeNotifier {
  VoicePlaybackController._();
  static final VoicePlaybackController instance = VoicePlaybackController._();

  static const _prefsKey = 'played_voice_message_ids';

  /// The id of the currently playing voice message bubble (null if none).
  String? _currentlyPlayingId;
  String? get currentlyPlayingId => _currentlyPlayingId;

  /// The conversationId whose voice note is currently playing.
  String? _playingConversationId;
  String? get playingConversationId => _playingConversationId;

  /// Global playback speed shared across all voice messages.
  double _speed = 1.0;
  double get speed => _speed;

  final Set<String> _playedMessageIds = {};
  bool _loadedPrefs = false;

  Future<void> _ensureLoaded() async {
    if (_loadedPrefs) return;
    final prefs = await SharedPreferences.getInstance();
    _playedMessageIds.addAll(prefs.getStringList(_prefsKey) ?? const []);
    _loadedPrefs = true;
  }

  bool isMessagePlayed(String? messageId) {
    if (messageId == null || messageId.isEmpty) return false;
    return _playedMessageIds.contains(messageId);
  }

  Future<void> markMessagePlayed(String messageId) async {
    if (messageId.isEmpty || _playedMessageIds.contains(messageId)) return;
    await _ensureLoaded();
    _playedMessageIds.add(messageId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _playedMessageIds.toList());
  }

  /// Called by a bubble when it wants to start playing.
  bool requestPlay(String id, {String? conversationId}) {
    _currentlyPlayingId = id;
    _playingConversationId = conversationId;
    notifyListeners();
    return true;
  }

  /// Called by a bubble when it stops or pauses.
  void notifyStop(String id) {
    if (_currentlyPlayingId == id) {
      _currentlyPlayingId = null;
      _playingConversationId = null;
      notifyListeners();
    }
  }

  /// Cycle speed 1x -> 1.5x -> 2x -> 1x
  void cycleSpeed() {
    if (_speed == 1.0) {
      _speed = 1.5;
    } else if (_speed == 1.5) {
      _speed = 2.0;
    } else {
      _speed = 1.0;
    }
    notifyListeners();
  }

  String get speedLabel {
    if (_speed == _speed.roundToDouble()) {
      return '${_speed.toInt()}x';
    }
    return '${_speed}x';
  }
}
