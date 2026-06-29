import '../core/api_exception.dart';
import '../core/api_methods.dart';
import '../core/media_url_utils.dart';
import '../core/offline_cache_service.dart';
import '../core/socket_service.dart';

enum MessageReceiptStatus { sent, delivered, read }

class ChatMember {
  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final String role;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const ChatMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.role = 'member',
    this.isOnline = false,
    this.lastSeenAt,
  });

  factory ChatMember.fromApi(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: MediaUrlUtils.resolveUrl(json['avatar_url']?.toString()),
      isVerified: json['is_verified'] == true,
      role: json['role']?.toString() ?? 'member',
      isOnline: json['is_online'] == true,
      lastSeenAt: DateTime.tryParse(json['last_seen_at']?.toString() ?? ''),
    );
  }

  bool get isAdmin => role == 'admin';

  String get displayName {
    if (username.isEmpty) return 'User';
    return username
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class ChatLastMessage {
  final String id;
  final String body;
  final String senderId;
  final DateTime createdAt;
  final String messageType;

  const ChatLastMessage({
    this.id = '',
    required this.body,
    required this.senderId,
    required this.createdAt,
    this.messageType = 'text',
  });

  bool get isVoice => messageType == 'voice';

  factory ChatLastMessage.fromApi(Map<String, dynamic>? json) {
    if (json == null) {
      return ChatLastMessage(body: '', senderId: '', createdAt: DateTime.now());
    }
    return ChatLastMessage(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      messageType: json['message_type']?.toString() ?? 'text',
    );
  }
}

class ChatConversation {
  final String id;
  final String type;
  final String? title;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final ChatLastMessage? lastMessage;
  final List<ChatMember> members;
  final Map<String, dynamic> metadata;

  const ChatConversation({
    required this.id,
    required this.type,
    this.title,
    this.unreadCount = 0,
    this.lastMessageAt,
    this.lastMessage,
    this.members = const [],
    this.metadata = const {},
  });

  factory ChatConversation.fromApi(Map<String, dynamic> json) {
    final members = (json['members'] as List<dynamic>? ?? [])
        .map((m) => ChatMember.fromApi(Map<String, dynamic>.from(m as Map)))
        .toList();
    final lastMsg = json['last_message'] as Map<String, dynamic>?;
    final meta = json['metadata'];
    return ChatConversation(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'direct',
      title: json['title']?.toString(),
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: DateTime.tryParse(json['last_message_at']?.toString() ?? ''),
      lastMessage: lastMsg != null ? ChatLastMessage.fromApi(lastMsg) : null,
      members: members,
      metadata: meta is Map ? Map<String, dynamic>.from(meta) : {},
    );
  }

  bool get isGroup => type == 'group';
  bool get isDirect => type == 'direct';
  bool get isChannel => metadata['kind']?.toString() == 'channel';
  String get channelPrivacy => metadata['privacy']?.toString() ?? 'public';

  ChatMember? peerFor(String myUserId) {
    for (final m in members) {
      if (m.userId != myUserId) return m;
    }
    return members.isNotEmpty ? members.first : null;
  }

  String displayName(String myUserId) {
    if (isGroup) return title ?? 'Group';
    return peerFor(myUserId)?.displayName ?? 'Chat';
  }

  String? avatarFor(String myUserId) => peerFor(myUserId)?.avatarUrl;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String? senderUsername;
  final String? senderAvatar;
  final String body;
  final String messageType; // 'text' | 'voice'
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final List<Map<String, dynamic>> receipts;

  const ChatMessage({
    required this.id,
    required this.senderId,
    this.senderUsername,
    this.senderAvatar,
    required this.body,
    this.messageType = 'text',
    this.metadata = const {},
    required this.createdAt,
    this.receipts = const [],
  });

  factory ChatMessage.fromApi(Map<String, dynamic> json) {
    final receipts = (json['receipts'] as List<dynamic>? ?? [])
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    final meta = json['metadata'];
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderUsername: json['sender_username']?.toString(),
      senderAvatar: MediaUrlUtils.resolveUrl(json['sender_avatar']?.toString()),
      body: json['body']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      metadata: meta is Map ? Map<String, dynamic>.from(meta) : {},
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      receipts: receipts,
    );
  }

  bool get isVoice => messageType == 'voice';

  MessageReceiptStatus statusForRecipient(String recipientId) {
    for (final receipt in receipts) {
      if (receipt['user_id']?.toString() == recipientId) {
        final status = receipt['status']?.toString() ?? 'sent';
        if (status == 'read') return MessageReceiptStatus.read;
        if (status == 'delivered') return MessageReceiptStatus.delivered;
        return MessageReceiptStatus.sent;
      }
    }
    return MessageReceiptStatus.sent;
  }
}

class ChatService {
  ChatService._();

  static String _conversationsCacheKey(int page, int limit) =>
      'conversations_p${page}_l$limit';
  static String _messagesCacheKey(String conversationId) =>
      'chat_messages_$conversationId';

  static Future<List<ChatConversation>> getConversations({int page = 1, int limit = 50}) async {
    final cacheKey = _conversationsCacheKey(page, limit);
    try {
      final data = await ApiMethods.authorizedGet(
        'conversations?page=$page&limit=$limit',
      );
      final conversations = data['data']?['conversations'] as List<dynamic>? ?? [];
      await OfflineCacheService.setJson(cacheKey, conversations);
      return conversations
          .map((c) => ChatConversation.fromApi(Map<String, dynamic>.from(c as Map)))
          .toList();
    } catch (e) {
      final cached = OfflineCacheService.getJsonList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((c) => ChatConversation.fromApi(c)).toList();
      }
      rethrow;
    }
  }

  static List<ChatConversation>? getCachedConversations({int page = 1, int limit = 50}) {
    final cached = OfflineCacheService.getJsonList(_conversationsCacheKey(page, limit));
    if (cached == null || cached.isEmpty) return null;
    return cached.map((c) => ChatConversation.fromApi(c)).toList();
  }

  static Future<ChatConversation> getConversation(String conversationId) async {
    final data = await ApiMethods.authorizedGet('conversations/$conversationId');
    final conversation = data['data']?['conversation'] as Map<String, dynamic>?;
    if (conversation == null) throw ApiException('Conversation not found');
    return ChatConversation.fromApi(conversation);
  }

  static Future<String> startDirect(String userId) async {
    final data = await ApiMethods.authorizedPost('conversations/direct', {
      'user_id': userId,
    });
    final conversation = data['data']?['conversation'] as Map<String, dynamic>?;
    final id = conversation?['id']?.toString();
    if (id == null || id.isEmpty) throw ApiException('Could not start chat');
    return id;
  }

  static Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final cacheKey = _messagesCacheKey(conversationId);
    try {
      final data = await ApiMethods.authorizedGet(
        'conversations/$conversationId/messages?limit=$limit',
      );
      final messages = data['data']?['messages'] as List<dynamic>? ?? [];
      await OfflineCacheService.setJson(cacheKey, messages);
      return messages
          .map((m) => ChatMessage.fromApi(Map<String, dynamic>.from(m as Map)))
          .toList();
    } catch (e) {
      final cached = OfflineCacheService.getJsonList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((m) => ChatMessage.fromApi(m)).toList();
      }
      rethrow;
    }
  }

  static List<ChatMessage>? getCachedMessages(String conversationId) {
    final cached = OfflineCacheService.getJsonList(_messagesCacheKey(conversationId));
    if (cached == null || cached.isEmpty) return null;
    return cached.map((m) => ChatMessage.fromApi(m)).toList();
  }

  static Future<ChatMessage> sendMessage(
    String conversationId,
    String body, {
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final payload = <String, dynamic>{
      'body': body,
      'message_type': messageType,
    };
    if (metadata != null) {
      payload['metadata'] = metadata;
    }
    
    final data = await ApiMethods.authorizedPost(
      'conversations/$conversationId/messages',
      payload,
    );
    final message = data['data']?['message'] as Map<String, dynamic>?;
    if (message == null) throw ApiException('Failed to send message');
    return ChatMessage.fromApi(message);
  }

  static Future<void> markRead(String conversationId) async {
    await ApiMethods.authorizedPost('conversations/$conversationId/read', {});
    await SocketService.markConversationRead(conversationId);
  }

  static Future<String> createGroup({
    required String title,
    required List<String> memberIds,
    String kind = 'group',
    String privacy = 'public',
  }) async {
    final data = await ApiMethods.authorizedPost('conversations/group', {
      'title': title,
      'member_ids': memberIds,
      'kind': kind,
      'privacy': privacy,
    });
    final conversation = data['data']?['conversation'] as Map<String, dynamic>?;
    final id = conversation?['id']?.toString();
    if (id == null || id.isEmpty) throw ApiException('Could not create group');
    return id;
  }

  static Future<void> leaveConversation(String conversationId) async {
    await ApiMethods.authorizedDelete('conversations/$conversationId');
  }

  static Future<void> addMember(String conversationId, String userId) async {
    await ApiMethods.authorizedPost('conversations/$conversationId/members', {
      'user_id': userId,
    });
  }

  static String formatMessageTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(local.year, local.month, local.day);
    final h = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$h:$m $ampm';
    if (msgDay == today) return timeStr;
    if (msgDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (now.difference(local).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[local.weekday - 1];
    }
    return '${local.day}/${local.month}/${local.year}';
  }

  static String formatLastSeen(DateTime? lastSeen, {bool isOnline = false}) {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Last seen recently';
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 2) return 'Last seen just now';
    final h = lastSeen.hour > 12 ? lastSeen.hour - 12 : (lastSeen.hour == 0 ? 12 : lastSeen.hour);
    final m = lastSeen.minute.toString().padLeft(2, '0');
    final ampm = lastSeen.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$h:$m $ampm';
    final today = DateTime(now.year, now.month, now.day);
    final seenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    if (seenDay == today) return 'Last seen today at $timeStr';
    if (seenDay == today.subtract(const Duration(days: 1))) {
      return 'Last seen yesterday at $timeStr';
    }
    if (diff.inDays < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return 'Last seen ${days[lastSeen.weekday - 1]} at $timeStr';
    }
    return 'Last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
