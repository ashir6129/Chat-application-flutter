// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Web voice recorder using the browser MediaRecorder API.
class VoiceRecorderService {
  VoiceRecorderService._();

  static html.MediaRecorder? _recorder;
  static html.MediaStream? _stream;
  static final List<html.Blob> _chunks = [];
  static Completer<Uint8List?>? _completer;
  static StreamController<Duration>? _durationController;
  static Timer? _durationTimer;
  static Duration _elapsed = Duration.zero;
  static String? _lastError;

  static Stream<Duration>? get durationStream => _durationController?.stream;
  static bool get isRecording => _recorder?.state == 'recording';
  static String? get lastError => _lastError;

  static Future<bool> startRecording() async {
    try {
      _lastError = null;
      _stream?.getTracks().forEach((t) => t.stop());
      _chunks.clear();
      _completer = null;

      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'audio': true, 'video': false});

      _elapsed = Duration.zero;
      _durationController?.close();
      _durationController = StreamController<Duration>.broadcast();
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed += const Duration(seconds: 1);
        _durationController?.add(_elapsed);
      });

      final mimeType = _bestMime();
      _recorder = mimeType != null
          ? html.MediaRecorder(_stream!, {'mimeType': mimeType})
          : html.MediaRecorder(_stream!);

      _recorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        final data = blobEvent.data;
        if (data != null && data.size > 0) {
          _chunks.add(data);
        }
      });

      _completer = Completer<Uint8List?>();
      _recorder!.start();
      return true;
    } catch (e) {
      _lastError = 'start() error: $e';
      return false;
    }
  }

  static void _finishRecording() {
    if (_completer == null || _completer!.isCompleted) return;

    if (_chunks.isEmpty) {
      _lastError = '_chunks is empty';
      _completer!.complete(null);
      return;
    }

    final mime = _bestMime() ?? 'audio/webm';
    final blob = html.Blob(_chunks, mime);
    final reader = html.FileReader();
    reader.readAsDataUrl(blob);
    reader.onLoadEnd.listen((_) {
      try {
        final result = reader.result as String?;
        if (result != null && result.contains(',')) {
          final b64 = result.split(',').last;
          final bytes = base64Decode(b64);
          if (!_completer!.isCompleted) _completer!.complete(bytes);
        } else {
          _lastError = 'result invalid or no comma';
          if (!_completer!.isCompleted) _completer!.complete(null);
        }
      } catch (e) {
        _lastError = 'base64 decode error: $e';
        if (!_completer!.isCompleted) _completer!.complete(null);
      }
    });
    reader.onError.listen((_) {
      _lastError = 'reader error';
      if (!_completer!.isCompleted) _completer!.complete(null);
    });
  }

  static void _stopStream() {
    if (_stream == null) return;
    try {
      _stream!.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _stream = null;
  }

  static Future<Uint8List?> stopRecording() async {
    _durationTimer?.cancel();
    _durationController?.close();
    _durationController = null;

    if (_recorder == null || _recorder!.state == 'inactive') {
      _stopStream();
      return null;
    }

    try {
      if (_recorder!.state != 'inactive') {
        _recorder!.stop();
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 150));
    _finishRecording();

    try {
      final result = await _completer!.future.timeout(const Duration(seconds: 15));
      _stopStream();
      return result;
    } catch (e) {
      _lastError = 'stop timeout or error: $e';
      _stopStream();
      return null;
    }
  }

  static void cancelRecording() {
    _durationTimer?.cancel();
    _durationController?.close();
    _durationController = null;

    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(null);
    }
    _completer = null;

    try {
      if (_recorder?.state != 'inactive') _recorder?.stop();
    } catch (_) {}

    _stopStream();
    _recorder = null;
    _chunks.clear();
  }

  static String createAudioUrl(Uint8List bytes) {
    final mime = _bestMime() ?? 'audio/webm';
    final blob = html.Blob([bytes], mime);
    return html.Url.createObjectUrlFromBlob(blob);
  }

  static String? _bestMime() {
    const candidates = ['audio/webm;codecs=opus', 'audio/webm', 'audio/ogg'];
    for (final m in candidates) {
      if (html.MediaRecorder.isTypeSupported(m)) return m;
    }
    return null;
  }

  static String formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
