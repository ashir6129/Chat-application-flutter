import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../api_services/chat_service.dart';
import '../../../../api_services/user_service.dart';
import '../../../../api_services/media_service.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/connectivity_service.dart';
import '../../../../core/chat_memory_cache.dart';
import '../../../../core/profile_memory_cache.dart';
import '../../../../core/offline_message_queue.dart';
import '../../../../core/cached_image.dart';
import '../../../../core/socket_service.dart';
import '../../../../core/voice_recorder_service.dart';
import '../../../../widgets/message/chat_input_bar.dart';
import '../../../../widgets/message/chat_message_bubble.dart';
import '../../../../widgets/message/chat_theme.dart';
import '../chat/chat_attach_sheet.dart';
import '../../../../core/call_service.dart';
import '../../../../core/call_permissions.dart';
import '../../../../core/call_ui.dart';
import '../../../../core/notification_helper.dart';
import '../../../../core/secure_storage_service.dart';
import '../../../../core/offline_cache_service.dart';
import '../../user_profile_screen/user_profile_screen.dart';

class PersonalChatScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String avatar;
  final bool isOnline;
  final String? conversationId;

  const PersonalChatScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.isOnline,
    this.conversationId,
  });

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _replyingTo;
  String? _conversationId;
  String? _currentUserId;
  String? _peerUserId;
  bool _loading = false;
  bool _sending = false;
  bool _peerOnline = false;
  bool _isPeerTyping = false;
  bool _loadingMore = false;
  DateTime? _peerLastSeen;
  Timer? _refreshTimer;
  Timer? _typingTimer;
  DateTime? _lastTypingStart;
  String? _pinnedMessageId;
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  StreamSubscription<Map<String, dynamic>>? _typingStartSub;
  StreamSubscription<Map<String, dynamic>>? _typingStopSub;
  StreamSubscription<Map<String, dynamic>>? _receiptSub;
  StreamSubscription<Map<String, dynamic>>? _readSub;
  StreamSubscription<Map<String, dynamic>>? _presenceSub;
  StreamSubscription<void>? _connectedSub;

  final List<_UiMessage> _messages = [];
  String? _oldestMessageId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _peerUserId = widget.userId;
    _peerOnline = widget.isOnline;
    _inputController.addListener(_onInputChanged);
    _scrollController.addListener(_onScroll);
    _bootstrap();
  }

  void _onInputChanged() {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    if (_inputController.text.isNotEmpty) {
      final now = DateTime.now();
      if (_lastTypingStart == null || now.difference(_lastTypingStart!).inSeconds > 2) {
        SocketService.sendTypingStart(_conversationId!);
        _lastTypingStart = now;
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        SocketService.sendTypingStop(_conversationId!);
        _lastTypingStart = null;
      });
    } else {
      SocketService.sendTypingStop(_conversationId!);
      _typingTimer?.cancel();
      _lastTypingStart = null;
    }
  }

  void _onScroll() {
    if (_loadingMore || _messages.isEmpty) return;
    // Load more when scrolled to near top (for reversed ListView)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_loadingMore || _conversationId == null || _conversationId!.isEmpty) return;
    if (_oldestMessageId == null && _messages.isNotEmpty) {
      _oldestMessageId = _messages.last.id;
    }
    
    setState(() => _loadingMore = true);
    
    try {
      final messages = await ChatService.getMessages(
        _conversationId!, 
        limit: 20,
        before: _oldestMessageId,
      );
      
      if (messages.isEmpty) {
        setState(() => _loadingMore = false);
        return;
      }
      
      if (!mounted) return;
      
      final newMessages = messages.map(_mapApiMessage).toList();
      setState(() {
        _messages.addAll(newMessages);
        _sortMessages(); // Ensure proper ordering after pagination
        _oldestMessageId = newMessages.last.id;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _bootstrap() async {
    // Always resolve currentUserId FIRST so _mapApiMessage is accurate
    _currentUserId = ProfileMemoryCache.me?.id ?? ChatMemoryCache.currentUserId;
    _peerUserId = widget.userId;

    if (_currentUserId == null) {
      _currentUserId = await SecureStorageService.getUserUid();
      if (_currentUserId == null) {
        setState(() => _loading = true);
        try {
          final me = await UserService.getMe();
          _currentUserId = me.id;
          ProfileMemoryCache.saveProfile(me);
        } catch (_) {
          if (mounted) setState(() => _loading = false);
          return;
        }
      }
    }

    // Now that we know who the current user is, show cached messages correctly
    if (_conversationId != null && _conversationId!.isNotEmpty) {
      final cached = ChatService.getCachedMessages(_conversationId!);
      if (cached != null && cached.isNotEmpty) {
        if (mounted) {
          setState(() {
            _messages.addAll(cached.map(_mapApiMessage));
            _sortMessages(); // Ensure proper ordering
            _loading = false;
          });
        }
      }
    }

    if (_messages.isEmpty) {
      if (mounted) setState(() => _loading = true);
    }

    try {
      if (_conversationId == null || _conversationId!.isEmpty) {
        _conversationId = await ChatService.startDirect(widget.userId);
      }
      
      _pinnedMessageId = OfflineCacheService.getJson('pinned_$_conversationId')?.toString();

      NotificationHelper.activeConversationId = _conversationId;

      // Start socket and presence in background
      SocketService.connect().then((_) => SocketService.joinConversation(_conversationId!));
      _loadPeerPresence();

      // Only wait for messages (which clears the loading state internally)
      await _loadMessages(silent: _messages.isNotEmpty);

      _socketSub?.cancel();
      _typingStartSub?.cancel();
      _typingStopSub?.cancel();
      _receiptSub?.cancel();
      _readSub?.cancel();
      _presenceSub?.cancel();
      _connectedSub?.cancel();
      
      _socketSub = SocketService.onMessage.listen(_onSocketMessage);
      _typingStartSub = SocketService.onTypingStart.listen(_onTypingStartEvent);
      _typingStopSub = SocketService.onTypingStop.listen(_onTypingStopEvent);
      _receiptSub = SocketService.onMessageReceipts.listen(_onReceiptUpdate);
      _readSub = SocketService.onMessageRead.listen(_onReadUpdate);
      _presenceSub = SocketService.onPresenceChanged.listen(_onPresenceChanged);
      _connectedSub = SocketService.onConnected.listen((_) {
        if (_conversationId != null && _conversationId!.isNotEmpty) {
          SocketService.joinConversation(_conversationId!);
        }
      });
      
      // Mark existing messages as read when opening the chat screen
      if (_conversationId != null && _conversationId!.isNotEmpty) {
        try {
          await ChatService.markRead(_conversationId!);
          // Optimistically update local state to mark own messages as read
          if (!mounted) return;
          setState(() {
            for (var i = 0; i < _messages.length; i++) {
              final msg = _messages[i];
              if (msg.isMine) {
                _messages[i] = msg.copyWith(receiptStatus: MessageReceiptStatus.read);
              }
            }
          });
        } catch (e) {
          // Log error but don't block UI - will retry via socket or next load
          debugPrint('Failed to mark read: $e');
        }
      }

      if (!mounted) return;
      setState(() => _loading = false);
      _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (!mounted) return;
        if (!SocketService.isConnected) {
          _loadMessages(silent: true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.errorMessage(e))),
      );
    }
  }

  void _onSocketMessage(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != _conversationId) return;
    final msg = ChatMessage.fromApi(data);
    if (!mounted) return;
    setState(() {
      // Replace optimistic message with server-confirmed message by matching temp ID
      final tempIdx = _messages.indexWhere((m) => m.pending && m.id == msg.id);
      if (tempIdx != -1) {
        // Replace the temp message in place to preserve position
        _messages[tempIdx] = _mapApiMessage(msg);
      } else if (msg.senderId == _currentUserId) {
        // Fallback: remove by text if temp ID not found (for voice messages)
        _messages.removeWhere((m) => m.pending && m.text == msg.body);
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(_mapApiMessage(msg));
        }
      } else {
        // Other user's message: add if not already present
        if (_messages.any((m) => m.id == msg.id)) return;
        _messages.add(_mapApiMessage(msg));
      }
      _sortMessages();
    });
    _scrollToEnd();
    if (msg.senderId != _currentUserId) {
      ChatService.markRead(_conversationId!);
    }
  }

  void _onTypingStartEvent(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != _conversationId) return;
    if (data['user_id']?.toString() == _currentUserId) return;
    if (!mounted) return;
    setState(() => _isPeerTyping = true);
  }

  void _onTypingStopEvent(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != _conversationId) return;
    if (data['user_id']?.toString() == _currentUserId) return;
    if (!mounted) return;
    setState(() => _isPeerTyping = false);
  }

  void _onReceiptUpdate(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != _conversationId) return;
    final statusStr = data['status']?.toString() ?? 'delivered';
    final messageIds = (data['message_ids'] as List<dynamic>? ?? [])
        .map((id) => id.toString())
        .toSet();
    final newStatus = statusStr == 'read'
        ? MessageReceiptStatus.read
        : MessageReceiptStatus.delivered;

    if (!mounted) return;
    setState(() {
      for (var i = 0; i < _messages.length; i++) {
        final msg = _messages[i];
        if (!msg.isMine) continue;
        if (messageIds.isNotEmpty && !messageIds.contains(msg.id)) continue;
        _messages[i] = msg.copyWith(receiptStatus: newStatus);
      }
    });
  }

  void _onReadUpdate(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != _conversationId) return;
    if (data['user_id']?.toString() == _currentUserId) return;
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < _messages.length; i++) {
        final msg = _messages[i];
        if (msg.isMine) {
          _messages[i] = msg.copyWith(receiptStatus: MessageReceiptStatus.read);
        }
      }
    });
  }

  void _onPresenceChanged(Map<String, dynamic> data) {
    if (data['user_id']?.toString() != _peerUserId) return;
    if (!mounted) return;
    setState(() {
      _peerOnline = data['is_online'] == true;
      if (!_peerOnline && data['last_seen_at'] != null) {
        _peerLastSeen =
            DateTime.tryParse(data['last_seen_at']?.toString() ?? '');
      }
    });
  }

  Future<void> _loadPeerPresence() async {
    try {
      final profile = await UserService.getById(widget.userId);
      if (!mounted) return;
      setState(() {
        _peerOnline = profile.isOnline;
        _peerLastSeen = profile.lastSeenAt;
      });
    } catch (_) {}
  }

  Future<void> _loadMessages({bool silent = false, bool loadMore = false}) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;

    // Show cached messages immediately for instant feel
    if (!silent && _messages.isEmpty) {
      final cached = ChatService.getCachedMessages(_conversationId!);
      if (cached != null && cached.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _messages
            ..clear()
            ..addAll(cached.map(_mapApiMessage));
          _sortMessages(); // Ensure proper ordering
          _loading = false;
        });
        _scrollToEnd();
      }
    }

    try {
      final messages = await ChatService.getMessages(_conversationId!, limit: 30);
      if (!mounted) return;
      
      final newMessages = messages.map(_mapApiMessage).toList();
      
      if (loadMore) {
        // Load more: add older messages and re-sort
        setState(() {
          _messages.addAll(newMessages);
          _sortMessages(); // Ensure proper ordering
          _loading = false;
        });
      } else {
        // Initial load: only update if we have no messages or if cache was empty
        if (_messages.isEmpty) {
          setState(() {
            _messages
              ..clear()
              ..addAll(newMessages);
            _sortMessages(); // Ensure proper ordering
            _loading = false;
          });
          _scrollToEnd();
        } else {
          // We already have messages from cache/socket, don't clear them
          setState(() => _loading = false);
        }
      }
    } catch (_) {
      if (!silent && mounted && _messages.isEmpty) setState(() => _loading = false);
    }
  }

  _UiMessage _mapApiMessage(ChatMessage msg) {
    MessageReceiptStatus? receiptStatus;
    if (msg.senderId == _currentUserId && _peerUserId != null) {
      receiptStatus = msg.statusForRecipient(_peerUserId!);
    }
    // Voice message
    String? voiceUrl;
    Duration voiceDuration = Duration.zero;
    if (msg.isVoice) {
      final b64 = msg.metadata['audio_base64'] as String?;
      if (b64 != null && b64.isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          voiceUrl = VoiceRecorderService.createAudioUrl(bytes);
        } catch (_) {}
      }
      final sec = msg.metadata['duration_seconds'] as int? ?? 0;
      voiceDuration = Duration(seconds: sec);
    }
    return _UiMessage(
      id: msg.id,
      text: msg.body,
      isMine: msg.senderId == _currentUserId,
      time: _formatTime(msg.createdAt),
      timestamp: msg.createdAt, // Use actual server timestamp for sorting
      receiptStatus: receiptStatus,
      isVoice: msg.isVoice,
      voiceAudioUrl: voiceUrl,
      voiceDuration: voiceDuration,
    );
  }

  void _sortMessages() {
    // Sort messages by timestamp descending (newest first for reversed ListView)
    // Since ListView is reversed, newest at index 0 = at bottom of screen
    // Use message ID as secondary sort key for timestamp ties
    _messages.sort((a, b) {
      final timestampCompare = b.timestamp.compareTo(a.timestamp);
      if (timestampCompare != 0) return timestampCompare;
      // If timestamps are equal, sort by ID to maintain stable order
      return b.id.compareTo(a.id);
    });
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    final h = localDt.hour > 12 ? localDt.hour - 12 : (localDt.hour == 0 ? 12 : localDt.hour);
    final m = localDt.minute.toString().padLeft(2, '0');
    final ampm = localDt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String get _presenceLabel {
    if (_isPeerTyping) {
      return 'typing...';
    }
    return ChatService.formatLastSeen(_peerLastSeen, isOnline: _peerOnline);
  }

  Future<void> _sendVoiceMessage(List<int> bytes, Duration duration) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    final base64Audio = base64Encode(bytes);
    final durationSec = duration.inSeconds;

    // Optimistic local voice bubble
    final tempId = 'voice_temp_${DateTime.now().millisecondsSinceEpoch}';
    final voiceUrl = VoiceRecorderService.createAudioUrl(Uint8List.fromList(bytes));
    setState(() {
      _messages.insert(0, _UiMessage(
        id: tempId,
        text: '[Voice message]',
        isMine: true,
        time: _currentTime(),
        timestamp: DateTime.now(), // Use current time for temp message
        isVoice: true,
        voiceAudioUrl: voiceUrl,
        voiceDuration: duration,
        pending: true,
      ));
      _sortMessages(); // Ensure proper ordering
    });
    _scrollToEnd();

    // Send via REST API to guarantee saving
    try {
      final msg = await ChatService.sendMessage(
        _conversationId!,
        '[Voice message]',
        messageType: 'voice',
        metadata: {
          'audio_base64': base64Audio,
          'duration_seconds': durationSec,
        },
      );
      if (!mounted) return;
      setState(() {
        // Replace optimistic message with server-confirmed message by matching temp ID
        final tempIdx = _messages.indexWhere((m) => m.pending && m.id == tempId);
        if (tempIdx != -1) {
          _messages[tempIdx] = _mapApiMessage(msg);
        } else {
          // Fallback: remove by text if temp ID not found
          _messages.removeWhere((m) => m.pending && m.text == msg.body);
          if (!_messages.any((m) => m.id == msg.id)) {
            _messages.add(_mapApiMessage(msg));
          }
        }
        _sortMessages(); // Ensure proper ordering
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send voice message')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    if (_conversationId == null || _conversationId!.isEmpty) return;

    setState(() => _sending = true);
    _inputController.clear();
    SocketService.sendTypingStop(_conversationId!);

    final replyMetadata = _replyingTo != null ? {
      'reply_to': {
        'message_id': _replyingTo!['message_id'],
        'text': _replyingTo!['text'],
        'sender_id': _replyingTo!['sender_id'],
      }
    } : null;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = _UiMessage(
      id: tempId,
      text: text,
      isMine: true,
      time: _currentTime(),
      timestamp: DateTime.now(), // Use current time for temp message
      pending: true,
      failed: false,
    );

    setState(() {
      _messages.insert(0, tempMsg);
      _sortMessages(); // Ensure proper ordering
      _replyingTo = null;
    });
    _scrollToEnd();

    try {
      final sent = await ChatService.sendMessage(
        _conversationId!,
        text,
        metadata: replyMetadata,
      );
      if (!mounted) return;
      setState(() {
        // Replace optimistic message with server-confirmed message by matching temp ID
        final tempIdx = _messages.indexWhere((m) => m.pending && m.id == tempId);
        if (tempIdx != -1) {
          _messages[tempIdx] = _mapApiMessage(sent);
        } else {
          // Fallback: remove temp message and add server-confirmed
          _messages.removeWhere((m) => m.id == tempId);
          if (!_messages.any((m) => m.id == sent.id)) {
            _messages.add(_mapApiMessage(sent));
          }
        }
        _sortMessages(); // Ensure proper ordering
        _sending = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        // Mark temp message as failed for retry option
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(failed: true);
        }
      });
      if (!ConnectivityService.isOnline) {
        await OfflineMessageQueue.enqueue(
          conversationId: _conversationId!,
          body: text,
        );
        if (!mounted) return;
        setState(() {
          _messages.removeWhere((m) => m.id == tempId);
        });
      }
    }
  }

  Future<void> _retryMessage(_UiMessage msg) async {
    setState(() {
      // Remove failed message and mark as pending again
      _messages.removeWhere((m) => m.id == msg.id);
      _sending = true;
    });
    
    // Set the text in input controller and send
    _inputController.text = msg.text;
    await _sendMessage();
  }

  Future<void> _handleImageSelected(String imagePath) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final bytes = await File(imagePath).readAsBytes();
    
    // Show image immediately from local cache
    final localUrl = 'file://$imagePath';
    final tempMsg = _UiMessage(
      id: tempId,
      text: '[Image]',
      isMine: true,
      time: _currentTime(),
      timestamp: DateTime.now(), // Use current time for temp message
      pending: true,
      failed: false,
      isVoice: false,
      voiceAudioUrl: localUrl, // Using voiceAudioUrl field for image URL temporarily
    );

    setState(() {
      _messages.insert(0, tempMsg);
      _sortMessages(); // Ensure proper ordering
    });
    _scrollToEnd();

    try {
      // Upload in background
      final urls = await MediaService.uploadFiles(
        bytesList: [bytes],
        filenames: [imagePath.split('/').last],
      );
      
      if (urls.isEmpty) throw Exception('Upload failed');
      
      // Send message with CDN URL
      final sent = await ChatService.sendMessage(
        _conversationId!,
        '',
        messageType: 'image',
        metadata: {'image_url': urls[0]},
      );
      
      if (!mounted) return;
      setState(() {
        // Replace optimistic message with server-confirmed message by matching temp ID
        final tempIdx = _messages.indexWhere((m) => m.pending && m.id == tempId);
        if (tempIdx != -1) {
          _messages[tempIdx] = _mapApiMessage(sent);
        } else {
          // Fallback: remove temp message and add server-confirmed
          _messages.removeWhere((m) => m.id == tempId);
          if (!_messages.any((m) => m.id == sent.id)) {
            _messages.add(_mapApiMessage(sent));
          }
        }
        _sortMessages(); // Ensure proper ordering
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(failed: true);
        }
      });
    }
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  void _setReply(_UiMessage msg) {
    setState(() => _replyingTo = {
      'text': msg.text,
      'message_id': msg.id,
      'sender_id': msg.isMine ? _currentUserId : _peerUserId,
    });
  }

  String _callErrorMessage(Object error, bool isVideo) {
    if (error is CallPermissionException) return error.message;
    final msg = error.toString().toLowerCase();
    if (msg.contains('call server') || msg.contains('socket')) {
      return 'Could not connect to call server. Check your internet connection.';
    }
    return isVideo
        ? 'Video call failed. Allow camera & microphone when prompted.'
        : 'Voice call failed. Click Allow when the browser asks for microphone.';
  }

  void _confirmCall(BuildContext context, {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatTheme.barBackground,
        title: Text(
          isVideo ? 'Start Video Call?' : 'Start Voice Call?',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          isVideo
              ? 'Start a video call with ${widget.name}?'
              : 'Start a voice call with ${widget.name}?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SocketService.connect();
              } catch (_) {}
              if (!mounted) return;
              final callType =
                  isVideo ? CallType.video : CallType.voice;
              CallService.instance.prepareOutgoing(
                peerId: widget.userId,
                peerName: widget.name,
                peerAvatar:
                    widget.avatar.isNotEmpty ? widget.avatar : null,
                callType: callType,
              );
              CallUi.show(context);
              CallService.instance.completeOutgoingCall().then((_) {
                // connected when callee answers
              }).catchError((Object e) {
                CallService.instance.endCall(emit: false);
                CallUi.close(context);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_callErrorMessage(e, isVideo))),
                );
              });
            },
            child: Text(
              isVideo ? 'Video Call' : 'Call',
              style: TextStyle(
                color: AppColors.buttonColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _typingTimer?.cancel();
    _socketSub?.cancel();
    _typingStartSub?.cancel();
    _typingStopSub?.cancel();
    _receiptSub?.cancel();
    _readSub?.cancel();
    _presenceSub?.cancel();
    _connectedSub?.cancel();
    _inputController.removeListener(_onInputChanged);
    if (_conversationId != null && _conversationId!.isNotEmpty) {
      SocketService.leaveConversation(_conversationId!);
    }
    NotificationHelper.activeConversationId = null;
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    final avatar = widget.avatar.isNotEmpty
        ? widget.avatar
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.name)}';

    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: AppBar(
        backgroundColor: ChatTheme.barBackground,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: widget.userId),
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: appCachedImageProvider(avatar),
                  ),
                  if (_peerOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: ChatTheme.barBackground, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _presenceLabel,
                      style: TextStyle(
                        color: _isPeerTyping ? accent : (_peerOnline ? accent : ChatTheme.mutedText),
                        fontSize: _isPeerTyping ? 13 : 11,
                        fontStyle: _isPeerTyping ? FontStyle.italic : FontStyle.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.video, color: Colors.white70, size: 24),
            onPressed: () => _confirmCall(context, isVideo: true),
          ),
          IconButton(
            icon: const Icon(Iconsax.call, color: Colors.white70, size: 22),
            onPressed: () => _confirmCall(context, isVideo: false),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_pinnedMessageId != null) _buildPinnedBar(accent),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Say hello 👋',
                          style: TextStyle(color: ChatTheme.mutedText, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: _messages.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) return _buildTodayPill();
                          final msg = _messages[i - 1];
                          return ChatMessageBubble(
                            messageId: msg.id,
                            text: msg.text,
                            time: msg.time,
                            isMine: msg.isMine,
                            receiptStatus: msg.receiptStatus,
                            avatarUrl: msg.isMine ? null : avatar,
                            avatarColor: const Color(0xFF7C4DFF),
                            isVoice: msg.isVoice,
                            voiceAudioUrl: msg.voiceAudioUrl,
                            voiceDuration: msg.voiceDuration,
                            conversationId: _conversationId,
                            onReply: () => _setReply(msg),
                            onReaction: (emoji) => _addReaction(msg.id, emoji),
                            onPin: () => _pinMessage(msg.id),
                            onUnsend: () => _unsendMessage(msg.id),
                            onSilent: () => _sendSilentMessage(msg.text),
                            onForward: () => _forwardMessage(msg),
                            onEffect: (effect) => _sendMessageWithEffect(msg.text, effect),
                            onRetry: msg.failed ? () => _retryMessage(msg) : null,
                          );
                        },
                      ),
          ),
          if (_replyingTo != null) _buildReplyBar(accent),
          ChatInputBar(
            controller: _inputController,
            onSend: _sendMessage,
            onAttach: () => showChatAttachSheet(context, onImageSelected: _handleImageSelected),
            onVoiceSend: (bytes, dur) => _sendVoiceMessage(bytes, dur),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPill() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: ChatTheme.datePill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Today',
          style: TextStyle(
            color: ChatTheme.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: ChatTheme.barBackground,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _replyingTo!['text'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ChatTheme.mutedText, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _replyingTo = null),
            child: const Icon(Icons.close, color: ChatTheme.mutedText, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedBar(Color accent) {
    final msg = _messages.cast<_UiMessage?>().firstWhere(
          (m) => m?.id == _pinnedMessageId,
          orElse: () => null,
        );
    final text = msg?.text ?? 'Pinned Message';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: ChatTheme.barBackground,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pinned Message', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: ChatTheme.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_conversationId != null) {
                OfflineCacheService.remove('pinned_$_conversationId');
              }
              setState(() => _pinnedMessageId = null);
            },
            child: const Icon(Icons.close, color: ChatTheme.mutedText, size: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _unsendMessage(String messageId) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    
    try {
      await ChatService.unsendMessage(_conversationId!, messageId);
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == messageId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message unsent')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsend: ${ChatService.errorMessage(e)}')),
      );
    }
  }

  Future<void> _sendSilentMessage(String text) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    
    try {
      await ChatService.sendMessage(
        _conversationId!,
        text,
        messageType: 'text',
        metadata: {'silent': true},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silent message sent')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${ChatService.errorMessage(e)}')),
      );
    }
  }

  Future<void> _forwardMessage(_UiMessage msg) async {
    // Show conversation picker for forwarding
    final conversations = await ChatService.getConversations(limit: 50);
    if (!mounted) return;
    
    final selectedConversation = await showModalBottomSheet<ChatConversation>(
      context: context,
      builder: (ctx) => Container(
        height: 400,
        color: Colors.grey[900],
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Forward to...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return ListTile(
                    title: Text(
                      conv.title ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(ctx, conv);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    
    if (selectedConversation != null && mounted) {
      try {
        await ChatService.sendMessage(
          selectedConversation.id,
          msg.text,
          messageType: 'text',
          metadata: {
            'forwarded_from': {
              'message_id': msg.id,
              'sender_id': msg.isMine ? _currentUserId : _peerUserId,
            }
          },
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message forwarded')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to forward: ${ChatService.errorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    
    try {
      await ChatService.addReaction(_conversationId!, messageId, emoji);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reacted with $emoji'), duration: const Duration(seconds: 1)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to react: ${ChatService.errorMessage(e)}')),
      );
    }
  }

  Future<void> _pinMessage(String messageId) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    
    try {
      await ChatService.pinMessage(_conversationId!, messageId);
      if (!mounted) return;
      setState(() => _pinnedMessageId = messageId);
      OfflineCacheService.setJson('pinned_$_conversationId', messageId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message pinned'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pin: ${ChatService.errorMessage(e)}')),
      );
    }
  }

  Future<void> _sendMessageWithEffect(String text, String effect) async {
    if (_conversationId == null || _conversationId!.isEmpty) return;
    
    try {
      await ChatService.sendMessageWithEffect(
        _conversationId!,
        text,
        effect: effect,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent with $effect effect'), duration: const Duration(seconds: 1)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${ChatService.errorMessage(e)}')),
      );
    }
  }
}

class _UiMessage {
  final String id;
  final String text;
  final bool isMine;
  final String time;
  final DateTime timestamp; // Add DateTime for proper sorting
  final MessageReceiptStatus? receiptStatus;
  
  final bool? _pending;
  bool get pending => _pending ?? false;

  final bool? _failed;
  bool get failed => _failed ?? false;

  final bool? _isVoice;
  bool get isVoice => _isVoice ?? false;

  final String? voiceAudioUrl;
  
  final Duration? _voiceDuration;
  Duration get voiceDuration => _voiceDuration ?? Duration.zero;

  const _UiMessage({
    this.id = '',
    required this.text,
    required this.isMine,
    required this.time,
    required this.timestamp,
    this.receiptStatus,
    bool? pending,
    bool? failed,
    bool? isVoice,
    this.voiceAudioUrl,
    Duration? voiceDuration,
  })  : _pending = pending,
        _failed = failed,
        _isVoice = isVoice,
        _voiceDuration = voiceDuration;

  _UiMessage copyWith({
    String? id,
    String? text,
    bool? isMine,
    String? time,
    DateTime? timestamp,
    MessageReceiptStatus? receiptStatus,
    bool? pending,
    bool? failed,
    bool? isVoice,
    String? voiceAudioUrl,
    Duration? voiceDuration,
  }) {
    return _UiMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMine: isMine ?? this.isMine,
      time: time ?? this.time,
      timestamp: timestamp ?? this.timestamp,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
      isVoice: isVoice ?? this.isVoice,
      voiceAudioUrl: voiceAudioUrl ?? this.voiceAudioUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
    );
  }
}
