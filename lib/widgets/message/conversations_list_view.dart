import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/chat_service.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/cached_image.dart';
import '../../core/chat_memory_cache.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/secure_storage_service.dart';
import '../../core/socket_service.dart';
import '../../core/voice_playback_controller.dart';
import '../../screens/message_screen/chat/group_chat_screen.dart';
import '../../screens/message_screen/main_message_screen/personal_chat_screen.dart';
import 'message_filter_chips.dart';

class ConversationsListView extends StatefulWidget {
  final bool embedded;
  final bool groupsOnly;
  final bool directOnly;

  const ConversationsListView({
    super.key,
    this.embedded = false,
    this.groupsOnly = false,
    this.directOnly = false,
  });

  @override
  State<ConversationsListView> createState() => _ConversationsListViewState();
}

class _ConversationsListViewState extends State<ConversationsListView> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  List<ChatConversation> _conversations = [];
  String? _currentUserId;
  bool _loading = false;
  String? _error;
  final Map<String, bool> _onlineByUserId = {};
  StreamSubscription<Map<String, dynamic>>? _presenceSub;
  StreamSubscription<Map<String, dynamic>>? _conversationUpdatedSub;

  @override
  void initState() {
    super.initState();
    _restoreFromCache();
    _load(silent: _conversations.isNotEmpty);
    SocketService.connect();
    _presenceSub = SocketService.onPresenceChanged.listen(_onPresenceChanged);
    _conversationUpdatedSub =
        SocketService.onConversationUpdated.listen((_) => _load(silent: true));
  }

  @override
  void dispose() {
    _presenceSub?.cancel();
    _conversationUpdatedSub?.cancel();
    super.dispose();
  }

  void _seedOnlineFromConversations(List<ChatConversation> conversations) {
    final myId = _currentUserId ?? '';
    for (final c in conversations) {
      if (c.isGroup) continue;
      final peer = c.peerFor(myId);
      if (peer != null) {
        _onlineByUserId[peer.userId] = peer.isOnline;
      }
    }
  }

  void _onPresenceChanged(Map<String, dynamic> data) {
    final userId = data['user_id']?.toString();
    if (userId == null || userId.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _onlineByUserId[userId] = data['is_online'] == true;
    });
  }

  void _restoreFromCache() {
    _currentUserId =
        ProfileMemoryCache.me?.id ?? ChatMemoryCache.currentUserId;

    var cached = ChatMemoryCache.conversations;
    if (cached.isEmpty) {
      cached = ChatService.getCachedConversations(limit: 50) ?? [];
    }

    if (cached.isNotEmpty) {
      _conversations = cached;
      _loading = false;
    } else {
      _loading = true;
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && _conversations.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      _resolveUserId().then((userId) {
        if (mounted) {
          setState(() => _currentUserId = userId);
          ChatMemoryCache.currentUserId = userId;
        }
      });

      final conversations = await ChatService.getConversations(limit: 50);
      ChatMemoryCache.save(items: conversations, userId: _currentUserId);

      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _seedOnlineFromConversations(conversations);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final cached = ChatService.getCachedConversations(limit: 50);
      setState(() {
        _loading = false;
        if (cached != null && cached.isNotEmpty) {
          _conversations = cached;
          ChatMemoryCache.save(
            items: cached,
            userId: _currentUserId,
          );
          _error = null;
        } else if (_conversations.isEmpty) {
          _error = ChatService.errorMessage(e);
        }
      });
    }
  }

  Future<String?> _resolveUserId() async {
    final cached = ProfileMemoryCache.me?.id ?? ChatMemoryCache.currentUserId;
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final me = await UserService.getMe();
      ProfileMemoryCache.saveProfile(me);
      return me.id;
    } catch (_) {
      return await SecureStorageService.getUserUid();
    }
  }

  List<ChatConversation> get _filtered {
    final myId = _currentUserId ?? '';
    return _conversations.where((c) {
      if (widget.directOnly && !c.isDirect) return false;
      if (widget.groupsOnly && !c.isGroup) return false;
      if (_selectedFilter == 'Unread' && c.unreadCount <= 0) return false;
      if (_selectedFilter == 'Groups' && !c.isGroup) return false;
      if (_selectedFilter == 'Direct' && !c.isDirect) return false;
      final name = c.displayName(myId).toLowerCase();
      final username = c.peerFor(myId)?.username.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      if (q.isEmpty) return true;
      return name.contains(q) || username.contains(q);
    }).toList();
  }

  void _openConversation(ChatConversation conversation) {
    final myId = _currentUserId ?? '';
    if (conversation.isGroup) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            groupId: conversation.id,
            name: conversation.displayName(myId),
            avatar: conversation.avatarFor(myId) ?? '',
            memberCount: conversation.members.length,
          ),
        ),
      ).then((_) => _load(silent: true));
      return;
    }

    final peer = conversation.peerFor(myId);
    if (peer == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalChatScreen(
          userId: peer.userId,
          name: peer.displayName,
          avatar: peer.avatarUrl ?? '',
          isOnline: _onlineByUserId[peer.userId] ?? peer.isOnline,
          conversationId: conversation.id,
        ),
      ),
    ).then((_) => _load(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(fontSize: 14, color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                icon: Icon(Iconsax.search_normal, color: AppColors.secondaryText(context)),
                hintText: 'Search',
                hintStyle: TextStyle(color: AppColors.mutedText(context)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!widget.directOnly && !widget.groupsOnly)
          MessageFilterChips(
            labels: const ['All', 'Unread', 'Direct', 'Groups'],
            selected: _selectedFilter,
            onSelected: (l) => setState(() => _selectedFilter = l),
          ),
        const SizedBox(height: 8),
        Expanded(child: _buildList()),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(child: body),
    );
  }

  Widget _buildList() {
    if (_loading && _conversations.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.buttonColor(context)),
      );
    }

    if (_error != null && _conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.secondaryText(context))),
            const SizedBox(height: 12),
            TextButton(onPressed: () => _load(), child: const Text('Retry')),
          ],
        ),
      );
    }

    final items = _filtered;
    final myId = _currentUserId ?? '';

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.message, size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ? 'No conversations found' : 'No messages yet',
              style: TextStyle(color: AppColors.secondaryText(context), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a chat from someone\'s profile',
              style: TextStyle(color: AppColors.mutedText(context), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(silent: _conversations.isNotEmpty),
      color: AppColors.buttonColor(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 76,
          color: AppColors.borderLine(context),
        ),
        itemBuilder: (context, index) {
          final c = items[index];
          final peer = c.peerFor(myId);
          final name = c.displayName(myId);
          final avatar = c.avatarFor(myId);
          final peerOnline = peer != null &&
              (_onlineByUserId[peer.userId] ?? peer.isOnline);
          final time = c.lastMessageAt != null
              ? ChatService.formatMessageTime(c.lastMessageAt!)
              : '';
          final unread = c.unreadCount;

          return InkWell(
            onTap: () => _openConversation(c),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _ConversationAvatar(
                    avatarUrl: avatar,
                    isGroup: c.isGroup,
                    isOnline: !c.isGroup && peerOnline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.primaryText(context),
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        _LastMessagePreview(
                          lastMessage: c.lastMessage,
                          unread: unread,
                          conversationId: c.id,
                          myUserId: myId,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context)),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// For voice messages shows a mic icon. Turns blue after the voice note is played.
class _LastMessagePreview extends StatelessWidget {
  final ChatLastMessage? lastMessage;
  final int unread;
  final String conversationId;
  final String myUserId;

  const _LastMessagePreview({
    required this.lastMessage,
    required this.unread,
    required this.conversationId,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (lastMessage == null) {
      return Text(
        'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: AppColors.mutedText(context)),
      );
    }

    if (!lastMessage!.isVoice) {
      // Normal text preview
      return Text(
        lastMessage!.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: unread > 0 ? AppColors.primaryText(context) : AppColors.secondaryText(context),
          fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      );
    }

    // Voice message preview — blue only after receiver plays it (WhatsApp style).
    final isMine = lastMessage!.senderId == myUserId;
    return ListenableBuilder(
      listenable: VoicePlaybackController.instance,
      builder: (context, _) {
        final ctrl = VoicePlaybackController.instance;
        final isLivePlaying = ctrl.playingConversationId == conversationId;
        final hasBeenPlayed =
            !isMine && lastMessage!.id.isNotEmpty && ctrl.isMessagePlayed(lastMessage!.id);
        final isBlue = isLivePlaying || hasBeenPlayed;

        final color = isBlue
            ? const Color(0xFF53BDEB)
            : (unread > 0
                ? AppColors.primaryText(context)
                : AppColors.secondaryText(context));

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBlue ? Icons.mic : Icons.mic_none_rounded,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Voice message',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isGroup;
  final bool isOnline;

  const _ConversationAvatar({
    required this.avatarUrl,
    required this.isGroup,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    const size = 56.0;

    Widget avatar;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: appCachedImage(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: _fallback(context, size),
        ),
      );
    } else {
      avatar = _fallback(context, size);
    }

    if (!isOnline) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBackground(context),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isGroup ? Iconsax.people : Iconsax.user,
        color: AppColors.buttonColor(context),
      ),
    );
  }
}
