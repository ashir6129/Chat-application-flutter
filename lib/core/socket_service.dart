import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_config.dart';
import 'secure_storage_service.dart';

class SocketService {
  SocketService._();

  static io.Socket? _socket;
  static final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _typingStartController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _typingStopController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _voiceMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _callOfferController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _callAnswerController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _callIceCandidateController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _callEndController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _callRejectController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _messageReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _messageReceiptsController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _presenceController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _conversationUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _boxReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _boxStatusChangedController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  static Stream<Map<String, dynamic>> get onTypingStart => _typingStartController.stream;
  static Stream<Map<String, dynamic>> get onTypingStop => _typingStopController.stream;
  static Stream<Map<String, dynamic>> get onVoiceMessage => _voiceMessageController.stream;
  static Stream<Map<String, dynamic>> get onCallOffer => _callOfferController.stream;
  static Stream<Map<String, dynamic>> get onCallAnswer => _callAnswerController.stream;
  static Stream<Map<String, dynamic>> get onCallIceCandidate => _callIceCandidateController.stream;
  static Stream<Map<String, dynamic>> get onCallEnd => _callEndController.stream;
  static Stream<Map<String, dynamic>> get onCallReject => _callRejectController.stream;
  static Stream<Map<String, dynamic>> get onMessageRead => _messageReadController.stream;
  static Stream<Map<String, dynamic>> get onMessageReceipts => _messageReceiptsController.stream;
  static Stream<Map<String, dynamic>> get onPresenceChanged => _presenceController.stream;
  static Stream<Map<String, dynamic>> get onConversationUpdated => _conversationUpdatedController.stream;
  static Stream<Map<String, dynamic>> get onBoxReceived => _boxReceivedController.stream;
  static Stream<Map<String, dynamic>> get onBoxStatusChanged => _boxStatusChangedController.stream;

  static bool get isConnected => _socket?.connected == true;

  static Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await SecureStorageService.getAccessToken();
    if (token == null || token.isEmpty) return;

    _socket?.dispose();
    _socket = io.io(
      ApiConfig.socketOrigin,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(ApiConfig.socketPath)
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!
      ..onConnect((_) {})
      ..onDisconnect((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_socket != null && _socket!.connected != true) {
            _socket!.connect();
          }
        });
      })
      ..on('message:new', (data) {
        if (data is Map) {
          final d = Map<String, dynamic>.from(data);
          _messageController.add(d);
          if (d['message_type'] == 'voice') {
            _voiceMessageController.add(d);
          }
        }
      })
      ..on('message:read', (data) {
        if (data is Map) {
          _messageReadController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('message:receipts', (data) {
        if (data is Map) {
          _messageReceiptsController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('presence:changed', (data) {
        if (data is Map) {
          _presenceController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('conversation:updated', (data) {
        if (data is Map) {
          _conversationUpdatedController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('box:received', (data) {
        if (data is Map) {
          _boxReceivedController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('box:status_changed', (data) {
        if (data is Map) {
          _boxStatusChangedController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('typing:start', (data) {
        if (data is Map) {
          _typingStartController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('typing:stop', (data) {
        if (data is Map) {
          _typingStopController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('call:offer', (data) {
        if (data is Map) _callOfferController.add(Map<String, dynamic>.from(data));
      })
      ..on('call:answer', (data) {
        if (data is Map) _callAnswerController.add(Map<String, dynamic>.from(data));
      })
      ..on('call:ice-candidate', (data) {
        if (data is Map) _callIceCandidateController.add(Map<String, dynamic>.from(data));
      })
      ..on('call:end', (data) {
        if (data is Map) _callEndController.add(Map<String, dynamic>.from(data));
      })
      ..on('call:reject', (data) {
        if (data is Map) _callRejectController.add(Map<String, dynamic>.from(data));
      })
      ..connect();

    await _waitUntilConnected();
  }

  static Future<void> _waitUntilConnected() async {
    if (_socket == null) return;
    if (_socket!.connected) return;

    final completer = Completer<void>();
    void handler(_) {
      if (!completer.isCompleted) completer.complete();
    }

    _socket!.onConnect(handler);
    try {
      await completer.future.timeout(const Duration(seconds: 6));
    } on TimeoutException {
      // REST fallback remains available.
    }
  }

  static Future<bool> joinConversation(String conversationId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    if (_socket == null || !_socket!.connected) return false;

    final completer = Completer<bool>();
    _socket!.emitWithAck(
      'conversation:join',
      {'conversation_id': conversationId},
      ack: (response) {
        if (response is Map && response['success'] == true) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return false;
    }
  }

  static void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', {'conversation_id': conversationId});
  }

  static void sendTypingStart(String conversationId) {
    _socket?.emit('typing:start', {'conversation_id': conversationId});
  }

  static void sendTypingStop(String conversationId) {
    _socket?.emit('typing:stop', {'conversation_id': conversationId});
  }

  static Future<void> markConversationRead(String conversationId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    _socket?.emit('message:read', {'conversation_id': conversationId});
  }

  static void emitCallOffer(Map<String, dynamic> payload) {
    _socket?.emit('call:offer', payload);
  }

  static void emitCallAnswer(Map<String, dynamic> payload) {
    _socket?.emit('call:answer', payload);
  }

  static void emitCallIceCandidate(Map<String, dynamic> payload) {
    _socket?.emit('call:ice-candidate', payload);
  }

  static void emitCallEnd(String toId) {
    _socket?.emit('call:end', {'to_id': toId});
  }

  static void emitCallReject(String callerId) {
    _socket?.emit('call:reject', {'caller_id': callerId});
  }

  static void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
