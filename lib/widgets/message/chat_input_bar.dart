import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/voice_recorder_service.dart';
import 'chat_theme.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final Widget? leading;
  final String hintText;
  final void Function(Uint8List bytes, Duration duration)? onVoiceSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.leading,
    this.hintText = 'Message...',
    this.onVoiceSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _cancelled = false;
  Duration _recordDuration = Duration.zero;
  StreamSubscription<Duration>? _durSub;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.stop();
  }

  @override
  void dispose() {
    _durSub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final ok = await VoiceRecorderService.startRecording();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission denied. Please allow mic access in browser.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _isRecording = true;
      _cancelled = false;
      _recordDuration = Duration.zero;
    });
    _pulseCtrl.repeat(reverse: true);
    _durSub?.cancel();
    _durSub = VoiceRecorderService.durationStream?.listen((d) {
      if (mounted) setState(() => _recordDuration = d);
    });
  }

  Future<void> _stopRecording() async {
    _durSub?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();

    final bytes = await VoiceRecorderService.stopRecording();
    if (!mounted) return;
    final wasCancelled = _cancelled;
    setState(() {
      _isRecording = false;
      _cancelled = false;
    });

    if (!wasCancelled) {
      if (bytes != null && bytes.isNotEmpty) {
        widget.onVoiceSend?.call(bytes, _recordDuration);
      } else {
        final err = VoiceRecorderService.lastError ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record audio ($err). Please try again.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _cancelRecording() {
    _cancelled = true;
    VoiceRecorderService.cancelRecording();
    _durSub?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    if (mounted) setState(() { _isRecording = false; _cancelled = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      decoration: const BoxDecoration(
        color: ChatTheme.barBackground,
        border: Border(top: BorderSide(color: ChatTheme.divider)),
      ),
      child: SafeArea(
        top: false,
        child: _isRecording ? _buildRecordingBar() : _buildNormalBar(),
      ),
    );
  }

  Widget _buildNormalBar() {
    return Row(
      children: [
        widget.leading ??
            GestureDetector(
              onTap: widget.onAttach,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 14, right: 8),
            decoration: BoxDecoration(
              color: ChatTheme.inputField,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(color: ChatTheme.mutedText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Iconsax.emoji_happy, color: ChatTheme.mutedText, size: 22),
                const SizedBox(width: 6),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder: (_, v, __) {
                    if (v.text.trim().isNotEmpty) return const SizedBox.shrink();
                    return const Padding(
                      padding: EdgeInsets.only(left: 4, right: 4),
                      child: Icon(Iconsax.camera, color: ChatTheme.mutedText, size: 22),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Send / Mic button
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (_, v, __) {
            final hasText = v.text.trim().isNotEmpty;
            if (hasText) {
              return GestureDetector(
                onTap: widget.onSend,
                child: _circleButton(Icons.send_rounded, ChatTheme.micButton),
              );
            }
            // Mic: tap to start recording
            return GestureDetector(
              onTap: _startRecording,
              child: _circleButton(Iconsax.microphone_2, ChatTheme.micButton),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        // Cancel button
        GestureDetector(
          onTap: _cancelRecording,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ChatTheme.inputField,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // Pulsing red dot
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  VoiceRecorderService.formatDuration(_recordDuration),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Text(
                  'Tap ■ to send',
                  style: TextStyle(color: ChatTheme.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Stop & send
        GestureDetector(
          onTap: _stopRecording,
          child: _circleButton(Icons.stop_rounded, ChatTheme.micButton),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, Color color) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
