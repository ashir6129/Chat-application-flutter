import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/chat_service.dart';
import '../../api_services/user_service.dart';
import '../../api_services/box_service.dart';
import 'package:zyntraplus/core/app_colors.dart';
import 'package:zyntraplus/core/cached_image.dart';
import 'package:zyntraplus/core/chat_memory_cache.dart';
import 'package:zyntraplus/widgets/feed/feed_user_avatar.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/secure_storage_service.dart';
import '../../core/socket_service.dart';
import '../../core/offline_cache_service.dart';
import '../../core/voice_playback_controller.dart';
import '../../core/call_history_service.dart';
import '../../core/channel_service.dart';
import '../../core/call_service.dart';
import '../../screens/message_screen/chat/group_chat_screen.dart';
import '../../screens/message_screen/main_message_screen/personal_chat_screen.dart';

class ConversationsListView extends StatefulWidget {
  final bool embedded;
  final bool groupsOnly;
  final bool directOnly;
  final String? spaceType; // 'marketplace' or 'creators'

  const ConversationsListView({
    super.key,
    this.embedded = false,
    this.groupsOnly = false,
    this.directOnly = false,
    this.spaceType,
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
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<Map<String, dynamic>>? _messageReadSub;

  @override
  void initState() {
    super.initState();
    _restoreFromCache();
    _load(silent: _conversations.isNotEmpty);
    SocketService.connect();
    _presenceSub = SocketService.onPresenceChanged.listen(_onPresenceChanged);
    _conversationUpdatedSub =
        SocketService.onConversationUpdated.listen(_onConversationUpdated);
    _messageSub = SocketService.onMessage.listen((_) => _load(silent: true));
    _messageReadSub = SocketService.onMessageRead.listen((_) => _load(silent: true));
  }

  @override
  void dispose() {
    _presenceSub?.cancel();
    _conversationUpdatedSub?.cancel();
    _messageSub?.cancel();
    _messageReadSub?.cancel();
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
    // Always show cached data immediately for instant feel
    if (!silent && _conversations.isEmpty) {
      final cached = ChatService.getCachedConversations(limit: 30);
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _conversations = cached;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = true;
          _error = null;
        });
      }
    }

    try {
      _resolveUserId().then((userId) {
        if (mounted) {
          setState(() => _currentUserId = userId);
          ChatMemoryCache.currentUserId = userId;
        }
      });

      final conversations = await ChatService.getConversations(limit: 30);
      ChatMemoryCache.save(items: conversations, userId: _currentUserId);

      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _seedOnlineFromConversations(conversations);
        _loading = false;
        _error = null;
      });
      await ChannelService.syncFromConversations(conversations);
    } catch (e) {
      if (!mounted) return;
      final cached = ChatService.getCachedConversations(limit: 30);
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

  void _onConversationUpdated(Map<String, dynamic> data) {
    // Instant refresh on conversation updates from socket
    _load(silent: true);
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

  List<String> get _pinnedIds {
    final raw = OfflineCacheService.getJson('pinned_conversation_ids');
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  List<String> get _deletedIds {
    final raw = OfflineCacheService.getJson('deleted_conversation_ids');
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  bool _isChannelConversation(ChatConversation c) =>
      ChannelService.isChannelConversation(c);

  List<ChatConversation> get _filtered {
    final myId = _currentUserId ?? '';
    if (_selectedFilter == 'Channels' || _selectedFilter == 'Calls') return [];

    final deletedIds = _deletedIds;
    final q = _searchQuery.toLowerCase();

    return _conversations.where((c) {
      if (deletedIds.contains(c.id)) return false;
      if (widget.directOnly && !c.isDirect) return false;
      if (widget.groupsOnly && (!c.isGroup || _isChannelConversation(c))) return false;
      if (_selectedFilter == 'Unread' && c.unreadCount <= 0) return false;
      if (_selectedFilter == 'Groups' && (!c.isGroup || _isChannelConversation(c))) {
        return false;
      }
      if ((_selectedFilter == 'All' || _selectedFilter == 'Unread') &&
          _isChannelConversation(c)) {
        return false;
      }
      if (_selectedFilter == 'Completed' && c.metadata['status']?.toString().toLowerCase() != 'completed') return false;
      if (_selectedFilter == 'Pending' && c.metadata['status']?.toString().toLowerCase() != 'pending') return false;
      if (_selectedFilter == 'Direct' && !c.isDirect) return false;
      final name = c.displayName(myId).toLowerCase();
      final username = c.peerFor(myId)?.username.toLowerCase() ?? '';
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
                hintText: 'Search messages',
                hintStyle: TextStyle(color: AppColors.mutedText(context)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!widget.directOnly && !widget.groupsOnly)
          _buildFilterRow(),
        if (widget.directOnly && widget.spaceType == 'marketplace')
          _buildMarketplaceFilterRow(),
        if (widget.directOnly && widget.spaceType == 'creators')
          _buildCreatorsFilterRow(),
        const SizedBox(height: 8),
        Expanded(child: _buildActiveView()),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(child: body),
    );
  }

  bool get _hasAnyUnread {
    final deletedIds = _deletedIds;
    return _conversations.any((c) {
      if (deletedIds.contains(c.id)) return false;
      if (widget.directOnly && !c.isDirect) return false;
      if (widget.groupsOnly && (!c.isGroup || _isChannelConversation(c))) return false;
      return c.unreadCount > 0;
    });
  }

  bool get _hasAnyPendingBoxRequests {
    final deletedIds = _deletedIds;
    return _conversations.any((c) {
      if (deletedIds.contains(c.id)) return false;
      if (!c.isDirect) return false;
      final isBoxRequest = c.metadata['is_box_request'] == true ||
          c.metadata['kind'] == 'box_request' ||
          c.metadata['type'] == 'box_request' ||
          c.metadata['box_request_id'] != null ||
          c.metadata['box_request'] == true;
      if (!isBoxRequest) return false;
      return c.metadata['status']?.toString().toLowerCase() == 'pending';
    });
  }

  Widget _buildFilterRow() {
    final accent = AppColors.buttonColor(context);
    final hasUnread = _hasAnyUnread;
    final filters = [
      ('All', Icons.chat_bubble_outline_rounded, false),
      ('Unread', null, hasUnread), // hasDot
      ('Groups', Icons.people_outline_rounded, false),
      ('Channels', Icons.campaign_outlined, false),
      ('Calls', Icons.phone_outlined, false),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, icon, hasDot) = filters[i];
          final isSelected = _selectedFilter == label;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (hasDot) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceFilterRow() {
    final accent = AppColors.buttonColor(context);
    final hasUnread = _hasAnyUnread;
    final filters = [
      ('All', Icons.chat_bubble_outline_rounded, false),
      ('Unread', null, hasUnread), // hasDot
      ('Completed', Icons.check_circle_outline, false),
      ('Pending', Icons.hourglass_bottom, false),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, icon, hasDot) = filters[i];
          final isSelected = _selectedFilter == label;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (hasDot) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatorsFilterRow() {
    final accent = AppColors.buttonColor(context);
    final hasUnread = _hasAnyUnread;
    final hasPendingBox = _hasAnyPendingBoxRequests;
    final filters = [
      ('All', Icons.chat_bubble_outline_rounded, false),
      ('Unread', null, hasUnread), // hasDot
      ('Box Request', Icons.all_inbox_outlined, hasPendingBox),
      ('Calls', Icons.phone_outlined, false),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, icon, hasDot) = filters[i];
          final isSelected = _selectedFilter == label;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryText(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (hasDot) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveView() {
    if (_selectedFilter == 'Channels') return _buildChannelsView();
    if (_selectedFilter == 'Calls') return _buildCallsView();
    if (_selectedFilter == 'Box Request') return _buildBoxRequestsView();
    return _buildList();
  }

  Widget _buildBoxRequestsView() {
    final myId = _currentUserId ?? '';
    final deletedIds = _deletedIds;
    final q = _searchQuery.toLowerCase();

    // Filter conversations that might be box requests
    final boxRequests = _conversations.where((c) {
      if (deletedIds.contains(c.id)) return false;
      if (!c.isDirect) return false;
      
      final isBoxRequest = c.metadata['is_box_request'] == true ||
          c.metadata['kind'] == 'box_request' ||
          c.metadata['type'] == 'box_request' ||
          c.metadata['box_request_id'] != null ||
          c.metadata['box_request'] == true;
          
      if (!isBoxRequest) return false;
      
      final status = c.metadata['status']?.toString().toLowerCase();
      if (status != 'pending') return false;

      if (q.isEmpty) return true;
      return c.displayName(myId).toLowerCase().contains(q);
    }).toList();

    if (boxRequests.isEmpty) {
      return Center(
        child: Text('No box requests', style: TextStyle(color: AppColors.mutedText(context))),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Pending Box Requests',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...boxRequests.map((c) {
          final peer = c.peerFor(myId);
          final name = c.displayName(myId);
          final avatar = c.avatarFor(myId);
          final coins = c.metadata['coins']?.toString() ?? '50';
          final messageText = c.lastMessage?.body ?? 'Hey! I saw your profile and thought you seem really cool.';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLine(context).withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.buttonColor(context).withValues(alpha: 0.1),
                      backgroundImage: avatar != null && avatar.trim().isNotEmpty ? NetworkImage(avatar) : null,
                      child: avatar == null || avatar.trim().isEmpty
                          ? Icon(Icons.person, color: AppColors.buttonColor(context))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1.5 km away',
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: AppColors.primaryText(context), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$coins coins',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF161C24)
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    messageText,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final reqId = c.metadata['box_request_id']?.toString() ?? c.id;
                          try {
                            await BoxService.updateBoxRequestStatus(reqId, 'declined');
                            c.metadata['status'] = 'declined';
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to decline: $e')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final reqId = c.metadata['box_request_id']?.toString() ?? c.id;
                          try {
                            await BoxService.updateBoxRequestStatus(reqId, 'accepted');
                            c.metadata['status'] = 'accepted';
                            setState(() {});
                            _openConversation(c);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to accept: $e')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Accept &\nReply',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChannelsView() {
    final myId = _currentUserId ?? '';
    final deletedIds = _deletedIds;
    final q = _searchQuery.toLowerCase();

    final channelConversations = _conversations.where((c) {
      if (deletedIds.contains(c.id)) return false;
      if (!_isChannelConversation(c)) return false;
      if (q.isEmpty) return true;
      return c.displayName(myId).toLowerCase().contains(q);
    }).toList();

    if (channelConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text('No channels yet', style: TextStyle(color: AppColors.secondaryText(context), fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text('Create a new page/channel to see it here', style: TextStyle(color: AppColors.mutedText(context), fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: channelConversations.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 76, color: AppColors.borderLine(context)),
      itemBuilder: (_, i) {
        final c = channelConversations[i];
        final name = c.displayName(myId);
        final time = c.lastMessageAt != null
            ? ChatService.formatMessageTime(c.lastMessageAt!)
            : '';
        final lastMsg = c.lastMessage?.body ?? 'No messages yet';
        final color = feedAccentColorForName(name);
        final privacy = c.channelPrivacy;
        final isPrivate = privacy == 'private';
        final subs = '${c.members.length}';
        final isPinned = _pinnedIds.contains(c.id);

        return InkWell(
          onTap: () => _openConversation(c),
          onLongPress: () => _showConversationOptions(c, isPinned),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Channel avatar — gradient circle with megaphone icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.15)]),
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Icon(Icons.campaign_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name, style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Text(time, style: TextStyle(color: AppColors.mutedText(context), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isPrivate
                                ? Icons.lock_outline
                                : (privacy == 'anonymous'
                                    ? Icons.visibility_off_outlined
                                    : Icons.public),
                            size: 12,
                            color: AppColors.mutedText(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPrivate
                                ? 'Private'
                                : (privacy == 'anonymous' ? 'Anonymous' : 'Public'),
                            style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.people_outline, size: 12, color: AppColors.mutedText(context)),
                          const SizedBox(width: 3),
                          Text('$subs subscribers', style: TextStyle(color: AppColors.mutedText(context), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallsView() {
    return ValueListenableBuilder<List<CallHistoryEntry>>(
      valueListenable: CallHistoryService.instance.entries,
      builder: (context, entries, _) {
        final q = _searchQuery.toLowerCase();
        final filtered = q.isEmpty
            ? entries
            : entries.where((e) => e.peerName.toLowerCase().contains(q)).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_missed_outlined, size: 48, color: AppColors.mutedText(context)),
                const SizedBox(height: 12),
                Text('No call history yet', style: TextStyle(color: AppColors.secondaryText(context), fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text('Your calls will appear here', style: TextStyle(color: AppColors.mutedText(context), fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => Divider(height: 1, indent: 76, color: AppColors.borderLine(context)),
          itemBuilder: (_, i) {
            final entry = filtered[i];
            final isMissed = entry.type == CallHistoryType.missed;
            final isVideo = entry.callType == CallHistoryCallType.video;
            final callColor = _callStatusColor(entry.type);
            final nameColor = isMissed ? callColor : AppColors.primaryText(context);

            IconData callIcon;
            String callLabel;
            switch (entry.type) {
              case CallHistoryType.incoming:
                callIcon = Icons.call_received_rounded;
                callLabel = 'Incoming';
                break;
              case CallHistoryType.outgoing:
                callIcon = Icons.call_made_rounded;
                callLabel = 'Outgoing';
                break;
              case CallHistoryType.missed:
                callIcon = Icons.call_missed_rounded;
                callLabel = 'Missed';
                break;
            }

            return InkWell(
              onLongPress: () => _showCallOptions(entry),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeedUserAvatar(
                      name: entry.peerName,
                      accentColor: feedAccentColorForName(entry.peerName),
                      imageUrl: entry.peerAvatar,
                      size: 56,
                      showBorder: false,
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
                                  entry.peerName,
                                  style: TextStyle(
                                    color: nameColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                entry.formattedTime,
                                style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(callIcon, size: 14, color: callColor),
                              const SizedBox(width: 4),
                              Text(
                                callLabel,
                                style: TextStyle(
                                  color: callColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (entry.duration != null) ...[
                                Text(
                                  ' · ${entry.formattedDuration}',
                                  style: TextStyle(
                                    color: AppColors.secondaryText(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              if (isVideo) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBackground(context),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.videocam_outlined, size: 12, color: AppColors.secondaryText(context)),
                                      const SizedBox(width: 3),
                                      Text('Video', style: TextStyle(color: AppColors.secondaryText(context), fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () {
                            CallService.instance.startCall(
                              entry.peerId,
                              entry.peerName,
                              peerAvatar: entry.peerAvatar,
                              callType: isVideo ? CallType.video : CallType.voice,
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBackground(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                              color: callColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _callStatusColor(CallHistoryType type) {
    switch (type) {
      case CallHistoryType.incoming:
        return const Color(0xFF25D366);
      case CallHistoryType.outgoing:
        return const Color(0xFF2196F3);
      case CallHistoryType.missed:
        return const Color(0xFFEF5350);
    }
  }

  void _showCallOptions(CallHistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.mutedText(context),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text(
                  'Delete Call',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  CallHistoryService.instance.deleteEntry(entry.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
    return _buildConversationsList(items);
  }

  Widget _buildConversationsList(List<ChatConversation> items) {
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

    final pinnedIds = _pinnedIds;

    final pinnedItems = items.where((c) => pinnedIds.contains(c.id)).toList();
    final recentItems = items.where((c) => !pinnedIds.contains(c.id)).toList();

    // Sort items by lastMessageAt descending
    pinnedItems.sort((a, b) {
      if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
      if (a.lastMessageAt == null) return 1;
      if (b.lastMessageAt == null) return -1;
      return b.lastMessageAt!.compareTo(a.lastMessageAt!);
    });

    recentItems.sort((a, b) {
      if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
      if (a.lastMessageAt == null) return 1;
      if (b.lastMessageAt == null) return -1;
      return b.lastMessageAt!.compareTo(a.lastMessageAt!);
    });

    return RefreshIndicator(
      onRefresh: () => _load(silent: _conversations.isNotEmpty),
      color: AppColors.buttonColor(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (pinnedItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Pinned',
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...pinnedItems.map((c) => _buildConversationRow(c, isPinned: true, myId: myId)),
            Divider(height: 1, color: AppColors.borderLine(context)),
            const SizedBox(height: 4),
          ],
          if (recentItems.isNotEmpty) ...[
            if (pinnedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  'Recent',
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ...recentItems.map((c) => _buildConversationRow(c, isPinned: false, myId: myId)),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationRow(ChatConversation c, {required bool isPinned, required String myId}) {
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
      onLongPress: () => _showConversationOptions(c, isPinned),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _ConversationAvatar(
              name: name,
              avatarUrl: avatar,
              isGroup: c.isGroup,
              isOnline: !c.isGroup && peerOnline,
              isPinned: isPinned,
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
                      if (c.metadata['status'] != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.metadata['status'].toString().toLowerCase() == 'completed'
                                ? const Color(0xFF00C853).withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c.metadata['status'].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: c.metadata['status'].toString().toLowerCase() == 'completed'
                                  ? const Color(0xFF00C853)
                                  : Colors.orange,
                            ),
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
                  if (c.metadata['product_name'] != null || c.metadata['productTitle'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '# ${c.metadata['product_name'] ?? c.metadata['productTitle'] ?? ''} · ${c.metadata['price'] != null ? '\$${c.metadata['price']}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (c.metadata['role'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.metadata['role'].toString().toLowerCase() == 'selling'
                                  ? const Color(0xFF00C853).withValues(alpha: 0.15)
                                  : const Color(0xFF42A5F5).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              c.metadata['role'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: c.metadata['role'].toString().toLowerCase() == 'selling'
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFF42A5F5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
  }

  void _showConversationOptions(ChatConversation c, bool isPinned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.mutedText(context),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: Icon(
                  isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: AppColors.buttonColor(context),
                ),
                title: Text(
                  isPinned ? 'Unpin Chat' : 'Pin Chat',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pinnedIds = List<String>.from(_pinnedIds);
                  if (isPinned) {
                    pinnedIds.remove(c.id);
                  } else {
                    pinnedIds.add(c.id);
                  }
                  await OfflineCacheService.setJson('pinned_conversation_ids', pinnedIds);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete Chat',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: this.context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.primaryBackground(ctx),
                      title: Text(
                        'Delete Chat',
                        style: TextStyle(color: AppColors.primaryText(ctx)),
                      ),
                      content: Text(
                        'Are you sure you want to delete this chat? This action cannot be undone.',
                        style: TextStyle(color: AppColors.secondaryText(ctx)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.buttonColor(ctx)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await ChatService.leaveConversation(c.id);
                    } catch (_) {
                      // Still hide locally if server leave fails (offline / already left).
                    }

                    final deletedIds = List<String>.from(_deletedIds);
                    if (!deletedIds.contains(c.id)) {
                      deletedIds.add(c.id);
                    }
                    await OfflineCacheService.setJson('deleted_conversation_ids', deletedIds);

                    final pinnedIds = List<String>.from(_pinnedIds)..remove(c.id);
                    await OfflineCacheService.setJson('pinned_conversation_ids', pinnedIds);

                    if (mounted) {
                      setState(() {
                        _conversations = _conversations.where((x) => x.id != c.id).toList();
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
  final String name;
  final String? avatarUrl;
  final bool isGroup;
  final bool isOnline;
  final bool isPinned;

  const _ConversationAvatar({
    required this.name,
    required this.avatarUrl,
    required this.isGroup,
    this.isOnline = false,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    const size = 56.0;

    String? computedInitials;
    if (isGroup) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        computedInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        computedInitials = parts[0][0].toUpperCase();
      }
    }

    Widget avatar;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: appCachedImage(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final color = feedAccentColorForName(name);
      if (isGroup) {
        avatar = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            computedInitials ?? '?',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        avatar = FeedUserAvatar(
          name: name,
          accentColor: color,
          size: size,
          showBorder: false,
        );
      }
    }

    // Only show online dot; the "Pinned" section label already communicates pinned state.
    if (!isOnline) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF00A884),
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
}
