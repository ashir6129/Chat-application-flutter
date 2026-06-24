import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Mobile/desktop voice recorder using the [record] package.
class VoiceRecorderService {
  VoiceRecorderService._();

  static final AudioRecorder _recorder = AudioRecorder();
  static String? _filePath;
  static StreamController<Duration>? _durationController;
  static Timer? _durationTimer;
  static Duration _elapsed = Duration.zero;
  static String? _lastError;
  static bool _recording = false;

  static Stream<Duration>? get durationStream => _durationController?.stream;
  static bool get isRecording => _recording;
  static String? get lastError => _lastError;

  static Future<bool> startRecording() async {
    try {
      _lastError = null;
      if (!await _recorder.hasPermission()) {
        _lastError = 'Microphone permission denied';
        return false;
      }

      final dir = await getTemporaryDirectory();
      _filePath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _filePath!,
      );

      _recording = true;
      _elapsed = Duration.zero;
      _durationController?.close();
      _durationController = StreamController<Duration>.broadcast();
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed += const Duration(seconds: 1);
        _durationController?.add(_elapsed);
      });
      return true;
    } catch (e) {
      _lastError = 'start() error: $e';
      _recording = false;
      return false;
    }
  }

  static Future<Uint8List?> stopRecording() async {
    _durationTimer?.cancel();
    _durationController?.close();
    _durationController = null;

    if (!_recording) return null;

    try {
      final path = await _recorder.stop();
      _recording = false;
      final filePath = path ?? _filePath;
      if (filePath == null || !File(filePath).existsSync()) {
        _lastError = 'Recording file missing';
        return null;
      }
      return File(filePath).readAsBytes();
    } catch (e) {
      _lastError = 'stop() error: $e';
      _recording = false;
      return null;
    } finally {
      _filePath = null;
    }
  }

  static void cancelRecording() {
    _cancelRecordingImpl();
  }

  static Future<void> _cancelRecordingImpl() async {
    _durationTimer?.cancel();
    _durationController?.close();
    _durationController = null;

    if (_recording) {
      try {
        await _recorder.stop();
      } catch (_) {}
      _recording = false;
    }

    if (_filePath != null) {
      try {
        final f = File(_filePath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
      _filePath = null;
    }
  }

  static String createAudioUrl(Uint8List bytes) {
    final dir = Directory.systemTemp;
    final file = File(
      '${dir.path}/voice_play_${DateTime.now().microsecondsSinceEpoch}.m4a',
    );
    file.writeAsBytesSync(bytes);
    return file.path;
  }

  static String formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
