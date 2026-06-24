import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/call_service.dart';
import '../../core/call_permissions.dart';
import '../../core/cached_image.dart';

/// Full-screen call UI for voice and video (WhatsApp-style).
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  int _seconds = 0;
  StreamSubscription<CallState>? _stateSub;
  StreamSubscription<void>? _remoteSub;
  bool _hadActiveCall = false;

  @override
  void initState() {
    super.initState();
    final initial = CallService.instance.state;
    _hadActiveCall = initial != CallState.idle;
    if (initial == CallState.connected) _startTimer();
    _stateSub = CallService.instance.onCallStateChanged.listen((state) {
      if (!mounted) return;
      if (state != CallState.idle) _hadActiveCall = true;
      if (state == CallState.connected && _timer == null) {
        _startTimer();
      } else if (state == CallState.ended || state == CallState.idle) {
        _timer?.cancel();
        _timer = null;
      }
      setState(() {});
    });
    _remoteSub = CallService.instance.onRemoteStreamReady.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stateSub?.cancel();
    _remoteSub?.cancel();
    super.dispose();
  }

  String _formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final service = CallService.instance;
    final isVideo = service.isVideoCall;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<CallState>(
          stream: service.onCallStateChanged,
          initialData: service.state,
          builder: (context, snapshot) {
            final state = snapshot.data ?? CallState.idle;

            if (state != CallState.idle) _hadActiveCall = true;

            if (state == CallState.idle && _hadActiveCall) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo && state == CallState.connected)
                  _RemoteVideoView(renderer: service.remoteRenderer)
                else
                  _VoiceBackground(state: state),

                if (isVideo && state == CallState.connected)
                  _LocalVideoPip(renderer: service.localRenderer),

                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      if (!isVideo || state != CallState.connected)
                        _Header(state: state, seconds: _seconds),
                      const Spacer(),
                      _Controls(state: state),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RemoteVideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const _RemoteVideoView({required this.renderer});

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: false,
    );
  }
}

class _LocalVideoPip extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const _LocalVideoPip({required this.renderer});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            mirror: true,
          ),
        ),
      ),
    );
  }
}

class _VoiceBackground extends StatelessWidget {
  final CallState state;

  const _VoiceBackground({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F1C2C), Color(0xFF000000)],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CallState state;
  final int seconds;

  const _Header({required this.state, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final service = CallService.instance;
    final isVideo = service.isVideoCall;

    String statusText;
    switch (state) {
      case CallState.incoming:
        statusText = isVideo ? 'Incoming video call' : 'Incoming voice call';
      case CallState.outgoing:
        statusText = isVideo ? 'Video calling...' : 'Calling...';
      case CallState.connected:
        statusText = _formatDuration(seconds);
      case CallState.ended:
        statusText = 'Call ended';
      case CallState.idle:
        statusText = '';
    }

    return Column(
      children: [
        if (!isVideo || state != CallState.connected) ...[
          if (service.currentPeerAvatar != null)
            ClipOval(
              child: appCachedImage(
                service.currentPeerAvatar!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
          const SizedBox(height: 20),
        ],
        Text(
          service.currentPeerName ?? 'Unknown',
          style: TextStyle(
            color: Colors.white,
            fontSize: isVideo && state == CallState.connected ? 20 : 28,
            fontWeight: FontWeight.bold,
            shadows: isVideo
                ? const [Shadow(color: Colors.black54, blurRadius: 8)]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            shadows: isVideo
                ? const [Shadow(color: Colors.black54, blurRadius: 6)]
                : null,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Controls extends StatefulWidget {
  final CallState state;

  const _Controls({required this.state});

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state == CallState.ended || state == CallState.idle) {
      return const SizedBox();
    }

    final service = CallService.instance;

    if (state == CallState.incoming) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ControlBtn(
              icon: Icons.call_end,
              label: 'Decline',
              color: Colors.red,
              iconColor: Colors.white,
              size: 72,
              onTap: service.rejectCall,
            ),
            _ControlBtn(
              icon: service.isVideoCall ? Icons.videocam : Icons.call,
              label: 'Accept',
              color: Colors.green,
              iconColor: Colors.white,
              size: 72,
              onTap: () async {
                try {
                  await service.acceptCall();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e is CallPermissionException
                              ? e.message
                              : 'Could not join call. Allow mic/camera access.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    final buttons = <Widget>[
      _ControlBtn(
        icon: service.isMuted ? Icons.mic_off : Icons.mic,
        label: 'Mute',
        isActive: service.isMuted,
        onTap: () {
          service.toggleMute();
          setState(() {});
        },
      ),
    ];

    if (service.isVideoCall) {
      buttons.addAll([
        _ControlBtn(
          icon: service.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
          label: 'Camera',
          isActive: !service.isVideoEnabled,
          onTap: () {
            service.toggleVideo();
            setState(() {});
          },
        ),
        _ControlBtn(
          icon: Icons.cameraswitch,
          label: 'Flip',
          onTap: () async {
            await service.switchCamera();
            setState(() {});
          },
        ),
      ]);
    } else {
      buttons.add(
        _ControlBtn(
          icon: service.isSpeaker ? Icons.volume_up : Icons.volume_down,
          label: 'Speaker',
          isActive: service.isSpeaker,
          onTap: () async {
            await service.toggleSpeaker();
            setState(() {});
          },
        ),
      );
    }

    buttons.add(
      _ControlBtn(
        icon: Icons.call_end,
        label: 'End',
        color: Colors.red,
        iconColor: Colors.white,
        size: 72,
        onTap: service.endCall,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;
  final double size;
  final bool isActive;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
    this.size = 56,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color ?? (isActive ? Colors.white : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? (isActive ? Colors.black : Colors.white),
              size: size * 0.45,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
