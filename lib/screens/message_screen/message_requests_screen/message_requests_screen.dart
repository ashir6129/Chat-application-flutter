import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';
import '../../../../api_services/chat_service.dart';

class MessageRequestsScreen extends StatefulWidget {
  const MessageRequestsScreen({super.key});

  @override
  State<MessageRequestsScreen> createState() => _MessageRequestsScreenState();
}

class _MessageRequestsScreenState extends State<MessageRequestsScreen> {
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final data = await ChatService.getMessageRequests();
      if (mounted) {
        setState(() {
          _requests = data['conversations'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _acceptRequest(String conversationId) async {
    try {
      await ChatService.acceptMessageRequest(conversationId);
      await _loadRequests();
    } catch (e) {
      // Show error
    }
  }

  Future<void> _declineRequest(String conversationId) async {
    try {
      await ChatService.declineMessageRequest(conversationId);
      await _loadRequests();
    } catch (e) {
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Message requests',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? _buildEmptyState()
              : _buildRequestsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.direct_inbox, size: 56, color: AppColors.mutedText(context)),
          const SizedBox(height: 16),
          Text(
            'No message requests',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When someone you don\'t follow messages you, it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _buildRequestItem(request);
      },
    );
  }

  Widget _buildRequestItem(dynamic request) {
    final members = request['members'] as List<dynamic>? ?? [];
    final sender = members.isNotEmpty ? members[0] : null;
    final senderName = sender?['username']?.toString() ?? 'Unknown';
    final senderAvatar = sender?['avatar_url']?.toString();
    final conversationId = request['id']?.toString() ?? '';
    final lastMessage = request['last_message'];
    final messageText = lastMessage?['body']?.toString() ?? 'No message';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
        child: senderAvatar == null ? Text(senderName[0].toUpperCase()) : null,
      ),
      title: Text(senderName, style: TextStyle(color: AppColors.primaryText(context))),
      subtitle: Text(
        messageText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.secondaryText(context)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _declineRequest(conversationId),
            child: Text(
              'Decline',
              style: TextStyle(color: AppColors.secondaryText(context)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _acceptRequest(conversationId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
