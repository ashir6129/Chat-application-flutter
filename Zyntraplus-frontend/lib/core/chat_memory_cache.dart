import '../api_services/chat_service.dart';

/// Session cache for inbox list — instant reopen.
class ChatMemoryCache {
  ChatMemoryCache._();

  static List<ChatConversation> conversations = [];
  static String? currentUserId;

  static void save({
    required List<ChatConversation> items,
    String? userId,
  }) {
    conversations = List<ChatConversation>.from(items);
    if (userId != null) currentUserId = userId;
  }

  static void clear() {
    conversations = [];
    currentUserId = null;
  }
}
