import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../api_services/chat_service.dart';
import '../../../api_services/user_service.dart';
import '../../../core/cached_image.dart';
import '../../../core/connectivity_service.dart';
import '../../../core/offline_message_queue.dart';
import '../../../core/socket_service.dart';
import '../../../widgets/message/chat_input_bar.dart';
import '../../../widgets/message/chat_theme.dart';
import '../../../widgets/message/message_action_sheet.dart';
import '../../../core/app_colors.dart';
import 'chat_attach_sheet.dart';

/// Group chat wired to REST + Socket.IO (same flow as direct chat).
class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String name;
  final String avatar;
  final int memberCount;
  final bool isAnonymous;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.name,
    this.avatar = '',
    this.memberCount = 0,
    this.isAnonymous = false,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String? _currentUserId;
  ChatConversation? _conversation;
  Map<String, ChatMember> _membersById = {};
  bool _loading = true;
  bool _sending = false;
  Timer? _refreshTimer;
  Timer? _typingTimer;
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  StreamSubscription<Map<String, dynamic>>? _typingStartSub;
  StreamSubscription<Map<String, dynamic>>? _typingStopSub;
  final Map<String, String> _typingUsers = {};

  final List<_UiGroupMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _input.addListener(_onInputChanged);
    _bootstrap();
  }

  void _onInputChanged() {
    if (_input.text.isNotEmpty) {
      SocketService.sendTypingStart(widget.groupId);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        SocketService.sendTypingStop(widget.groupId);
      });
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final me = await UserService.getMe();
      _currentUserId = me.id;

      _conversation = await ChatService.getConversation(widget.groupId);
      _membersById = {
        for (final m in _conversation!.members) m.userId: m,
      };

      SocketService.connect().then((_) {
        SocketService.joinConversation(widget.groupId);
      });
      _socketSub?.cancel();
      _typingStartSub?.cancel();
      _typingStopSub?.cancel();
      
      _socketSub = SocketService.onMessage.listen(_onSocketMessage);
      _typingStartSub = SocketService.onTypingStart.listen(_onTypingStartEvent);
      _typingStopSub = SocketService.onTypingStop.listen(_onTypingStopEvent);

      await ChatService.markRead(widget.groupId);
      await _loadMessages();

      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (mounted) _loadMessages(silent: true);
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
    if (data['conversation_id']?.toString() != widget.groupId) return;
    final msg = ChatMessage.fromApi(data);
    if (!mounted) return;
    setState(() {
      // Remove any matching pending/temp message from current user
      if (msg.senderId == _currentUserId) {
        _messages.removeWhere((m) => m.pending && m.text == msg.body);
      }
      // Skip if already in list (by real id)
      if (_messages.any((m) => m.id == msg.id)) return;
      _messages.add(_mapApiMessage(msg));
    });
    _scrollToEnd();
    if (msg.senderId != _currentUserId) {
      ChatService.markRead(widget.groupId);
    }
  }

  void _onTypingStartEvent(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != widget.groupId) return;
    final userId = data['user_id']?.toString();
    final username = data['username']?.toString();
    if (userId == null || userId == _currentUserId) return;
    
    if (!mounted) return;
    setState(() {
      _typingUsers[userId] = username ?? 'User';
    });
  }

  void _onTypingStopEvent(Map<String, dynamic> data) {
    if (data['conversation_id']?.toString() != widget.groupId) return;
    final userId = data['user_id']?.toString();
    if (userId == null || userId == _currentUserId) return;
    
    if (!mounted) return;
    setState(() {
      _typingUsers.remove(userId);
    });
  }

  Future<void> _loadMessages({bool silent = false}) async {
    try {
      final messages = await ChatService.getMessages(widget.groupId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages.map(_mapApiMessage));
        if (!silent) _loading = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  _UiGroupMessage _mapApiMessage(ChatMessage msg) {
    final member = _membersById[msg.senderId];
    final isMine = msg.senderId == _currentUserId;
    final senderName = widget.isAnonymous && !isMine
        ? 'Anonymous'
        : _displayName(msg.senderUsername ?? member?.username ?? 'User');

    return _UiGroupMessage(
      id: msg.id,
      text: msg.body,
      isMine: isMine,
      senderName: senderName,
      isAdmin: member?.isAdmin ?? false,
      avatarUrl: widget.isAnonymous ? null : (msg.senderAvatar ?? member?.avatarUrl),
      time: _formatTime(msg.createdAt),
    );
  }

  String _displayName(String username) {
    if (username.isEmpty) return 'User';
    return username
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    final h = localDt.hour > 12 ? localDt.hour - 12 : (localDt.hour == 0 ? 12 : localDt.hour);
    final m = localDt.minute.toString().padLeft(2, '0');
    final ampm = localDt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  int get _memberCount =>
      _conversation?.members.length ?? widget.memberCount;

  Future<void> _sendMessage() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _input.clear();
    SocketService.sendTypingStop(widget.groupId);

    final tempMsg = _UiGroupMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isMine: true,
      senderName: 'You',
      time: _formatTime(DateTime.now()),
      pending: true,
    );

    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToEnd();

    try {
      final sent = await ChatService.sendMessage(widget.groupId, text);
      if (!mounted) return;
      setState(() {
        // Remove the temp message regardless of whether socket already added the real one
        _messages.removeWhere((m) => m.id == tempMsg.id);
        // Only add if not already in list (socket may have already delivered it)
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages.add(_mapApiMessage(sent));
        }
        _sending = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      if (!ConnectivityService.isOnline) {
        await OfflineMessageQueue.enqueue(
          conversationId: widget.groupId,
          body: text,
        );
        // It's already in the list as pending
        return;
      }
      
      setState(() {
        _messages.removeWhere((m) => m.id == tempMsg.id);
      });
      _input.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.errorMessage(e))),
      );
    }
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _groupAvatar({double radius = 18}) {
    if (widget.avatar.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: appCachedImageProvider(widget.avatar),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2A3942),
      child: Icon(Iconsax.people, color: ChatTheme.mutedText, size: radius),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _typingTimer?.cancel();
    _socketSub?.cancel();
    _typingStartSub?.cancel();
    _typingStopSub?.cancel();
    _input.removeListener(_onInputChanged);
    SocketService.leaveConversation(widget.groupId);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = widget.isAnonymous
        ? 'Anonymous · identities hidden'
        : '$_memberCount members';

    if (_typingUsers.isNotEmpty) {
      final typists = _typingUsers.values.take(2).join(', ');
      subtitle = _typingUsers.length > 2 ? '$typists... typing' : '$typists typing...';
    }

    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: AppBar(
        backgroundColor: ChatTheme.barBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _groupAvatar(),
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
                    subtitle,
                    style: TextStyle(
                      color: _typingUsers.isNotEmpty ? AppColors.buttonColor(context) : const Color(0xFF8696A0),
                      fontSize: 11,
                      fontStyle: _typingUsers.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Start the conversation',
                          style: TextStyle(color: ChatTheme.mutedText, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _buildMessage(_messages[i]),
                      ),
          ),
          ChatInputBar(
            controller: _input,
            hintText: 'Type a message...',
            onSend: _sendMessage,
            onAttach: () => showChatAttachSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_UiGroupMessage msg) {
    if (widget.isAnonymous && !msg.isMine) {
      return _buildAnonymousBubble(msg);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isMine) ...[
            _senderAvatar(msg),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!msg.isMine)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: const TextStyle(
                          color: Color(0xFFFF6584),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (msg.isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E5CE6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Color(0xFF5E5CE6),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                GestureDetector(
                  onLongPress: () => showMessageActionSheet(
                    context,
                    messageText: msg.text,
                    isMine: msg.isMine,
                    onReply: () {},
                    onPin: () {},
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMine
                          ? ChatTheme.outgoingBubble
                          : ChatTheme.incomingBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
                        bottomRight: Radius.circular(msg.isMine ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.pending ? 'Sending…' : msg.time,
                  style: const TextStyle(color: Color(0xFF8696A0), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _senderAvatar(_UiGroupMessage msg) {
    final url = msg.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: appCachedImageProvider(url),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFFF453A),
      child: Text(
        msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildAnonymousBubble(_UiGroupMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ChatTheme.incomingBubble,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onLongPress: () => showMessageActionSheet(
            context,
            messageText: msg.text,
            isMine: false,
            onReply: () {},
            onPin: () {},
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                msg.time,
                style: const TextStyle(color: ChatTheme.mutedText, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UiGroupMessage {
  final String id;
  final String text;
  final bool isMine;
  final String senderName;
  final bool isAdmin;
  final String? avatarUrl;
  final String time;
  final bool pending;

  const _UiGroupMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.senderName,
    this.isAdmin = false,
    this.avatarUrl,
    required this.time,
    this.pending = false,
  });
}
