// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web audio playback for voice message bubbles.
class VoiceBubblePlayer {
  html.AudioElement? _audio;
  final _endedController = StreamController<void>.broadcast();

  Stream<void> get onEnded => _endedController.stream;

  Stream<Duration>? get positionStream => null;

  bool get isInitialized => _audio != null;

  double get currentTimeSeconds => (_audio?.currentTime ?? 0).toDouble();

  set playbackRate(double rate) {
    if (_audio != null) _audio!.playbackRate = rate;
  }

  Future<void> load(String source) async {
    await dispose();
    _audio = html.AudioElement(source);
    _audio!.onEnded.listen((_) {
      if (!_endedController.isClosed) _endedController.add(null);
    });
  }

  Future<void> loadBytes(List<int> bytes, {String mimeType = 'audio/mp4'}) async {
    // Handled via blob URL from VoiceRecorderService.createAudioUrl on web.
    throw UnsupportedError('Use load(url) on web');
  }

  Future<Duration?> getDuration() async {
    final dur = _audio?.duration;
    if (dur == null || !dur.isFinite || dur <= 0) return null;
    return Duration(milliseconds: (dur * 1000).toInt());
  }

  Future<void> play() async {
    await _audio?.play();
  }

  Future<void> pause() async {
    _audio?.pause();
  }

  Future<void> seek(Duration position) async {
    if (_audio != null) {
      _audio!.currentTime = position.inMilliseconds / 1000.0;
    }
  }

  Future<void> dispose() async {
    _audio?.pause();
    _audio = null;
  }

  Future<void> close() async {
    await dispose();
    _endedController.close();
  }
}
