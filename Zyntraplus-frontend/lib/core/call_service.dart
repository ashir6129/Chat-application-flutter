import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'media_url_utils.dart';
import 'call_permissions.dart';
import 'call_ui.dart';
import 'socket_service.dart';

enum CallState { idle, outgoing, incoming, connected, ended }
enum CallType { voice, video }

class CallService {
  static final CallService _instance = CallService._internal();
  static CallService get instance => _instance;

  CallService._internal() {
    _setupSocketListeners();
  }

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final StreamController<CallState> _callStateController =
      StreamController<CallState>.broadcast();
  Stream<CallState> get onCallStateChanged => _callStateController.stream;

  final StreamController<void> _remoteStreamController =
      StreamController<void>.broadcast();
  Stream<void> get onRemoteStreamReady => _remoteStreamController.stream;

  CallState _state = CallState.idle;
  CallState get state => _state;

  CallType _callType = CallType.voice;
  CallType get callType => _callType;
  bool get isVideoCall => _callType == CallType.video;

  String? currentPeerId;
  String? currentPeerName;
  String? currentPeerAvatar;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoEnabled = true;
  bool get isVideoEnabled => _isVideoEnabled;

  bool _isSpeaker = false;
  bool get isSpeaker => _isSpeaker;

  bool _remoteDescriptionSet = false;
  bool _renderersReady = false;
  String _facingMode = 'user';

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  final List<Map<String, dynamic>> _pendingCandidates = [];
  RTCSessionDescription? _remoteOffer;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  void _setState(CallState newState) {
    _state = newState;
    _callStateController.add(newState);
    if (newState == CallState.connected && !isVideoCall) {
      _enableSpeakerByDefault();
    }
    if (newState == CallState.incoming) {
      CallUi.showFromRoot();
    }
  }

  /// Sync — sets peer info and outgoing state. Call [CallUi.show] right after.
  void prepareOutgoing({
    required String peerId,
    required String peerName,
    CallType callType = CallType.voice,
    String? peerAvatar,
  }) {
    _callType = callType;
    currentPeerId = peerId;
    currentPeerName = peerName;
    currentPeerAvatar = peerAvatar;
    _setState(CallState.outgoing);
  }

  /// Async WebRTC + signaling after [prepareOutgoing] and [CallUi.show].
  /// Mic/camera is requested FIRST (must run while browser user-gesture is active).
  Future<void> completeOutgoingCall() async {
    if (_state != CallState.outgoing || currentPeerId == null) {
      throw StateError('Call not prepared');
    }
    final peerId = currentPeerId!;
    try {
      await _acquireLocalMedia();
      await _ensureSocket();
      await _initPeerConnection();

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideoCall,
      });
      await _peerConnection!.setLocalDescription(offer);

      SocketService.emitCallOffer({
        'peer_id': peerId,
        'call_type': isVideoCall ? 'video' : 'voice',
        'type': offer.type,
        'sdp': offer.sdp,
      });
    } catch (e) {
      debugPrint('CallService completeOutgoingCall error: $e');
      await _cleanup();
      rethrow;
    }
  }

  Future<void> _enableSpeakerByDefault() async {
    if (_isSpeaker) return;
    _isSpeaker = true;
    if (!kIsWeb) {
      try {
        await Helper.setSpeakerphoneOn(true);
      } catch (_) {}
    }
  }

  void _setupSocketListeners() {
    SocketService.onCallOffer.listen((data) async {
      if (_state != CallState.idle) {
        SocketService.emitCallReject(data['caller_id']?.toString() ?? '');
        return;
      }
      await _ensureSocket();
      currentPeerId = data['caller_id']?.toString();
      currentPeerName = data['caller_username']?.toString();
      currentPeerAvatar =
          MediaUrlUtils.resolveUrl(data['caller_avatar']?.toString());
      _callType =
          data['call_type'] == 'video' ? CallType.video : CallType.voice;
      _remoteOffer = RTCSessionDescription(
        data['sdp']?.toString() ?? '',
        data['type']?.toString() ?? 'offer',
      );
      _setState(CallState.incoming);
    });

    SocketService.onCallAnswer.listen((data) async {
      if (_state != CallState.outgoing || _peerConnection == null) return;
      try {
        final answer = RTCSessionDescription(
          data['sdp']?.toString() ?? '',
          data['type']?.toString() ?? 'answer',
        );
        await _peerConnection!.setRemoteDescription(answer);
        _remoteDescriptionSet = true;
        await _flushPendingCandidates();
        _setState(CallState.connected);
      } catch (e) {
        debugPrint('CallService: failed to apply answer: $e');
        endCall(emit: true);
      }
    });

    SocketService.onCallIceCandidate.listen((data) async {
      await _addRemoteCandidate(Map<String, dynamic>.from(data));
    });

    SocketService.onCallEnd.listen((_) => endCall(emit: false));
    SocketService.onCallReject.listen((_) => endCall(emit: false));
  }

  Future<void> _ensureSocket() async {
    if (!SocketService.isConnected) {
      await SocketService.connect();
    }
    if (!SocketService.isConnected) {
      throw Exception('Could not connect to call server');
    }
  }

  Future<void> _initRenderers() async {
    if (_renderersReady) return;
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _renderersReady = true;
  }

  Map<String, dynamic> _buildMediaConstraints({String? facingMode}) {
    if (_callType == CallType.video) {
      final facing = facingMode ?? _facingMode;
      return {
        'audio': true,
        'video': kIsWeb
            ? {'facingMode': facing}
            : {
                'facingMode': facing,
                'width': {'ideal': 640},
                'height': {'ideal': 480},
              },
      };
    }
    return {'audio': true, 'video': false};
  }

  Future<void> _acquireLocalMedia() async {
    if (_localStream != null) return;

    await CallPermissions.ensureForCall(_callType);

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        _buildMediaConstraints(),
      );
    } catch (e) {
      debugPrint('CallService getUserMedia error: $e');
      if (isVideoCall) {
        throw const CallPermissionException(
          'Could not access camera or microphone. Allow both in browser settings.',
        );
      }
      throw const CallPermissionException(
        'Could not access microphone. Click Allow when the browser asks.',
      );
    }

    _isVideoEnabled = _callType == CallType.video;
  }

  Future<void> _initPeerConnection() async {
    if (_localStream == null) {
      throw StateError('Local media not acquired');
    }

    await _initRenderers();
    localRenderer.srcObject = _localStream;

    _remoteDescriptionSet = false;
    _pendingCandidates.clear();

    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (currentPeerId == null) return;
      if (candidate.candidate == null || candidate.candidate!.isEmpty) return;
      SocketService.emitCallIceCandidate({
        'to_id': currentPeerId,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _attachRemoteStream(event.streams.first);
      }
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _attachRemoteStream(stream);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('CallService ICE: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        endCall(emit: true);
      }
    };

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }
  }

  void _attachRemoteStream(MediaStream stream) {
    _remoteStream = stream;
    remoteRenderer.srcObject = stream;
    if (!_remoteStreamController.isClosed) {
      _remoteStreamController.add(null);
    }
    if (!isVideoCall) {
      _enableSpeakerByDefault();
    }
  }

  Future<void> _addRemoteCandidate(Map<String, dynamic> data) async {
    final candidateStr = data['candidate']?.toString();
    if (candidateStr == null || candidateStr.isEmpty) return;

    if (_peerConnection == null || !_remoteDescriptionSet) {
      _pendingCandidates.add(data);
      return;
    }

    try {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          candidateStr,
          data['sdpMid']?.toString(),
          data['sdpMLineIndex'] is int
              ? data['sdpMLineIndex'] as int
              : int.tryParse(data['sdpMLineIndex']?.toString() ?? ''),
        ),
      );
    } catch (e) {
      debugPrint('CallService: addCandidate failed: $e');
    }
  }

  Future<void> _flushPendingCandidates() async {
    if (_peerConnection == null) return;
    final pending = List<Map<String, dynamic>>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final data in pending) {
      await _addRemoteCandidate(data);
    }
  }

  Future<void> _createPeerConnection() async {
    await _acquireLocalMedia();
    await _initPeerConnection();
  }

  Future<void> _ensureIdle() async {
    if (_state == CallState.idle) return;
    if (_state == CallState.ended) {
      _state = CallState.idle;
      _callStateController.add(CallState.idle);
      return;
    }
    if (_state == CallState.incoming ||
        _state == CallState.outgoing ||
        _state == CallState.connected) {
      await _cleanup();
    }
    _state = CallState.idle;
    _callStateController.add(CallState.idle);
  }

  Future<void> startCall(
    String peerId,
    String peerName, {
    String? peerAvatar,
    CallType callType = CallType.voice,
  }) async {
    await _ensureIdle();
    prepareOutgoing(
      peerId: peerId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      callType: callType,
    );
    CallUi.showFromRoot();
    await completeOutgoingCall();
  }

  Future<void> startVideoCall(
    String peerId,
    String peerName, {
    String? peerAvatar,
  }) {
    return startCall(
      peerId,
      peerName,
      peerAvatar: peerAvatar,
      callType: CallType.video,
    );
  }

  Future<void> acceptCall() async {
    if (_state != CallState.incoming ||
        _remoteOffer == null ||
        currentPeerId == null) {
      return;
    }

    try {
      await _acquireLocalMedia();
      await _ensureSocket();
      await _initPeerConnection();
      await _peerConnection!.setRemoteDescription(_remoteOffer!);
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();

      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideoCall,
      });
      await _peerConnection!.setLocalDescription(answer);

      SocketService.emitCallAnswer({
        'caller_id': currentPeerId,
        'type': answer.type,
        'sdp': answer.sdp,
      });

      _setState(CallState.connected);
    } catch (e) {
      debugPrint('CallService acceptCall error: $e');
      rejectCall();
      rethrow;
    }
  }

  void rejectCall() {
    if (currentPeerId != null && _state == CallState.incoming) {
      SocketService.emitCallReject(currentPeerId!);
    }
    _cleanup();
  }

  void endCall({bool emit = true}) {
    if (currentPeerId != null && emit && _state != CallState.idle) {
      SocketService.emitCallEnd(currentPeerId!);
    }
    _cleanup();
  }

  void toggleMute() {
    if (_localStream == null) return;
    _isMuted = !_isMuted;
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
  }

  Future<void> toggleSpeaker() async {
    _isSpeaker = !_isSpeaker;
    if (!kIsWeb) {
      try {
        await Helper.setSpeakerphoneOn(_isSpeaker);
      } catch (_) {}
    }
  }

  void toggleVideo() {
    if (!isVideoCall || _localStream == null) return;
    final tracks = _localStream!.getVideoTracks();
    if (tracks.isEmpty) return;
    _isVideoEnabled = !_isVideoEnabled;
    tracks.first.enabled = _isVideoEnabled;
  }

  Future<void> switchCamera() async {
    if (!isVideoCall || _localStream == null || _peerConnection == null) return;

    _facingMode = _facingMode == 'user' ? 'environment' : 'user';

    try {
      final newStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': kIsWeb
            ? {'facingMode': _facingMode}
            : {
                'facingMode': _facingMode,
                'width': {'ideal': 640},
                'height': {'ideal': 480},
              },
      });

      final newVideoTrack = newStream.getVideoTracks().firstOrNull;
      if (newVideoTrack == null) return;

      final oldVideoTrack = _localStream!.getVideoTracks().firstOrNull;
      final senders = await _peerConnection!.getSenders();
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          await sender.replaceTrack(newVideoTrack);
          break;
        }
      }

      if (oldVideoTrack != null) {
        try {
          _localStream!.removeTrack(oldVideoTrack);
        } catch (_) {}
        oldVideoTrack.stop();
      }
      try {
        _localStream!.addTrack(newVideoTrack);
      } catch (_) {}
      if (!_isVideoEnabled) newVideoTrack.enabled = false;

      localRenderer.srcObject = _localStream;
    } catch (e) {
      debugPrint('CallService switchCamera error: $e');
      if (!kIsWeb) {
        final tracks = _localStream!.getVideoTracks();
        if (tracks.isNotEmpty) {
          try {
            await Helper.switchCamera(tracks.first);
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _cleanup() async {
    if (_state != CallState.ended && _state != CallState.idle) {
      _setState(CallState.ended);
    }

    _pendingCandidates.clear();
    _remoteDescriptionSet = false;
    _remoteOffer = null;

    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    _localStream = null;

    _remoteStream?.getTracks().forEach((track) => track.stop());
    await _remoteStream?.dispose();
    _remoteStream = null;

    await _peerConnection?.close();
    _peerConnection = null;

    currentPeerId = null;
    currentPeerName = null;
    currentPeerAvatar = null;

    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    } catch (_) {}

    _isMuted = false;
    _isVideoEnabled = true;
    _isSpeaker = false;
    _facingMode = 'user';
    _callType = CallType.voice;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_state == CallState.ended) {
        _setState(CallState.idle);
      }
    });
  }
}
