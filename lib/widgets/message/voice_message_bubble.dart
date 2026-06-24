import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../api_services/chat_service.dart';
import '../../core/voice_bubble_player.dart';
import '../../core/voice_playback_controller.dart';
import '../../core/voice_recorder_service.dart';
import 'chat_theme.dart';

/// A self-contained voice message playback bubble.
class VoiceMessageBubble extends StatefulWidget {
  final String? messageId;
  final String? audioUrl;
  final Uint8List? audioBytes;
  final bool isMine;
  final String time;
  final Duration totalDuration;
  final MessageReceiptStatus? receiptStatus;
  final String? conversationId;

  const VoiceMessageBubble({
    super.key,
    this.messageId,
    this.audioUrl,
    this.audioBytes,
    required this.isMine,
    required this.time,
    this.totalDuration = const Duration(seconds: 0),
    this.receiptStatus,
    this.conversationId,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  VoiceBubblePlayer? _player;
  StreamSubscription<void>? _endedSub;
  StreamSubscription<Duration>? _positionSub;
  bool _playing = false;
  bool _hasBeenPlayed = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;
  Timer? _posTimer;
  String? _resolvedUrl;

  late final String _bubbleId;
  final VoicePlaybackController _ctrl = VoicePlaybackController.instance;

  @override
  void initState() {
    super.initState();
    _bubbleId = widget.messageId ?? UniqueKey().toString();
    _total = widget.totalDuration;
    _resolvedUrl = widget.audioUrl;
    if (_resolvedUrl == null && widget.audioBytes != null) {
      _resolvedUrl = VoiceRecorderService.createAudioUrl(widget.audioBytes!);
    }
    if (!widget.isMine && widget.messageId != null) {
      _hasBeenPlayed = _ctrl.isMessagePlayed(widget.messageId);
    }
    _ctrl.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_ctrl.currentlyPlayingId != _bubbleId && _playing) {
      _pausePlayback();
    }
    if (_player != null) {
      _player!.playbackRate = _ctrl.speed;
    }
  }

  Future<void> _initAudio() async {
    if (_player != null) return;
    if (_resolvedUrl == null && widget.audioBytes == null) return;

    final player = VoiceBubblePlayer();
    if (widget.audioBytes != null) {
      await player.loadBytes(widget.audioBytes!);
    } else if (_resolvedUrl != null) {
      await player.load(_resolvedUrl!);
    }

    player.playbackRate = _ctrl.speed;

    final dur = await player.getDuration();
    if (dur != null && dur > Duration.zero && mounted) {
      setState(() => _total = dur);
    }

    _endedSub = player.onEnded.listen((_) {
      _stopPositionUpdates();
      _ctrl.notifyStop(_bubbleId);
      if (!widget.isMine && widget.messageId != null) {
        _ctrl.markMessagePlayed(widget.messageId!);
      }
      if (mounted) {
        setState(() {
          _playing = false;
          _position = Duration.zero;
          if (!widget.isMine) _hasBeenPlayed = true;
        });
      }
    });

    if (mounted) {
      setState(() => _player = player);
    } else {
      await player.close();
    }
  }

  void _startPositionUpdates() {
    _stopPositionUpdates();
    final stream = _player?.positionStream;
    if (stream != null) {
      _positionSub = stream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
    } else {
      _posTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted || _player == null) return;
        final pos = _player!.currentTimeSeconds;
        setState(() => _position = Duration(milliseconds: (pos * 1000).toInt()));
      });
    }
  }

  void _stopPositionUpdates() {
    _posTimer?.cancel();
    _posTimer = null;
    _positionSub?.cancel();
    _positionSub = null;
  }

  void _pausePlayback() {
    _player?.pause();
    _stopPositionUpdates();
    setState(() => _playing = false);
  }

  Future<void> _togglePlay() async {
    await _initAudio();
    if (_player == null) return;

    if (_playing) {
      await _player!.pause();
      _stopPositionUpdates();
      _ctrl.notifyStop(_bubbleId);
      setState(() => _playing = false);
    } else {
      if (!widget.isMine) _hasBeenPlayed = true;
      _ctrl.requestPlay(_bubbleId, conversationId: widget.conversationId);
      _player!.playbackRate = _ctrl.speed;
      await _player!.play();
      _startPositionUpdates();
      setState(() => _playing = true);
    }
  }

  Future<void> _seek(double ms) async {
    await _initAudio();
    if (_player == null) return;
    final pos = Duration(milliseconds: ms.toInt());
    await _player!.seek(pos);
    setState(() => _position = pos);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _stopPositionUpdates();
    if (_playing) {
      _ctrl.notifyStop(_bubbleId);
    }
    _endedSub?.cancel();
    _player?.close();
    super.dispose();
  }

  IconData _tickIcon(MessageReceiptStatus? status) {
    switch (status) {
      case MessageReceiptStatus.delivered:
      case MessageReceiptStatus.read:
        return Icons.done_all;
      case MessageReceiptStatus.sent:
      default:
        return Icons.done;
    }
  }

  Color _playIconColor() {
    if (_playing) return Colors.lightBlueAccent;
    if (!widget.isMine && _hasBeenPlayed) return const Color(0xFF53BDEB);
    return Colors.white;
  }

  Color _sliderActiveColor() {
    if (_playing || (!widget.isMine && _hasBeenPlayed)) {
      return Colors.lightBlueAccent;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isMine ? ChatTheme.outgoingBubble : ChatTheme.incomingBubble;
    final sliderMax = _total.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final sliderVal = _position.inMilliseconds.toDouble().clamp(0.0, sliderMax);
    final canPlay = _resolvedUrl != null || widget.audioBytes != null;

    final bool micIsBlue = !widget.isMine && (_playing || _hasBeenPlayed);
    final bool tickIsBlue =
        widget.isMine && widget.receiptStatus == MessageReceiptStatus.read;
    final Color metaColor =
        micIsBlue || tickIsBlue ? ChatTheme.readTick : ChatTheme.mutedText;

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(widget.isMine ? 16 : 4),
          bottomRight: Radius.circular(widget.isMine ? 4 : 16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: canPlay ? () => _togglePlay() : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _playing
                        ? Colors.lightBlueAccent.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _playIconColor(),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        activeTrackColor: _sliderActiveColor(),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: _sliderActiveColor(),
                        overlayColor: Colors.lightBlueAccent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: sliderVal,
                        min: 0,
                        max: sliderMax,
                        onChanged: _seek,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            VoiceRecorderService.formatDuration(_position),
                            style: TextStyle(
                              color: _playing ? Colors.lightBlueAccent : Colors.white60,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            VoiceRecorderService.formatDuration(_total),
                            style: const TextStyle(color: Colors.white60, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: _ctrl,
                builder: (_, __) => GestureDetector(
                  onTap: () {
                    _ctrl.cycleSpeed();
                    if (_player != null) _player!.playbackRate = _ctrl.speed;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _ctrl.speedLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic,
                    size: 13,
                    color: micIsBlue ? ChatTheme.readTick : ChatTheme.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.time,
                    style: TextStyle(color: metaColor, fontSize: 9),
                  ),
                  if (widget.isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _tickIcon(widget.receiptStatus),
                      size: 13,
                      color: tickIsBlue ? ChatTheme.readTick : ChatTheme.mutedText,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
