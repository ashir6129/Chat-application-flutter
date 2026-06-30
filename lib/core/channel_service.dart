import '../api_services/chat_service.dart';
import 'offline_cache_service.dart';

class ChannelService {
  ChannelService._();

  static List<String> getChannelIds() {
    final list = OfflineCacheService.getJsonList('channel_conversation_ids') ?? [];
    return list.map((e) => e.toString()).toList();
  }

  static Future<void> markAsChannel(String conversationId) async {
    final list = getChannelIds();
    if (!list.contains(conversationId)) {
      list.add(conversationId);
      await OfflineCacheService.setJson('channel_conversation_ids', list);
    }
  }

  static bool isChannel(String conversationId) {
    return getChannelIds().contains(conversationId);
  }

  /// True when the conversation is a channel from API metadata or legacy local cache.
  static bool isChannelConversation(ChatConversation conversation) {
    return conversation.isChannel || isChannel(conversation.id);
  }

  /// Sync legacy locally-marked channel IDs from fetched conversations.
  static Future<void> syncFromConversations(List<ChatConversation> conversations) async {
    final legacyIds = getChannelIds();
    var changed = false;
    for (final c in conversations) {
      if (c.isChannel && !legacyIds.contains(c.id)) {
        legacyIds.add(c.id);
        changed = true;
      }
    }
    if (changed) {
      await OfflineCacheService.setJson('channel_conversation_ids', legacyIds);
    }
  }
}
