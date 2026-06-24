import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Mobile/desktop audio playback for voice message bubbles.
class VoiceBubblePlayer {
  final AudioPlayer _player = AudioPlayer();
  final _endedController = StreamController<void>.broadcast();
  StreamSubscription<void>? _completeSub;

  VoiceBubblePlayer() {
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!_endedController.isClosed) _endedController.add(null);
    });
  }

  Stream<void> get onEnded => _endedController.stream;

  Stream<Duration> get positionStream => _player.onPositionChanged;

  bool get isInitialized => true;

  double get currentTimeSeconds => 0;

  set playbackRate(double rate) {
    _player.setPlaybackRate(rate);
  }

  Future<void> load(String source) async {
    await _player.stop();
    if (source.startsWith('http')) {
      await _player.setSource(UrlSource(source));
    } else {
      await _player.setSource(DeviceFileSource(source));
    }
  }

  Future<void> loadBytes(List<int> bytes, {String mimeType = 'audio/mp4'}) async {
    await _player.stop();
    await _player.setSource(BytesSource(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      mimeType: mimeType,
    ));
  }

  Future<Duration?> getDuration() async {
    return _player.getDuration();
  }

  Future<void> play() async {
    await _player.resume();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.stop();
  }

  Future<void> close() async {
    await _completeSub?.cancel();
    await _player.dispose();
    await _endedController.close();
  }
}
