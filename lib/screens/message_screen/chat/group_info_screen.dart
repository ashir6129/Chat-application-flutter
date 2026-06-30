import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../api_services/chat_service.dart';
import '../../../api_services/user_service.dart';
import '../../../core/cached_image.dart';
import '../../../core/app_colors.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAvatar;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupAvatar = '',
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  ChatConversation? _conversation;
  String? _currentUserId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final me = await UserService.getMe();
      _currentUserId = me.id;
      
      final conversation = await ChatService.getConversation(widget.groupId);
      if (!mounted) return;
      setState(() {
        _conversation = conversation;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group info: $e')),
      );
    }
  }

  bool get _isAdmin {
    if (_currentUserId == null || _conversation == null) return false;
    final member = _conversation!.members.firstWhere(
      (m) => m.userId == _currentUserId,
      orElse: () => _conversation!.members.first,
    );
    return member.isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Group Info',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
     ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversation == null
              ? const Center(child: Text('Failed to load group info'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: widget.groupAvatar.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        widget.groupAvatar,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Iconsax.people, size: 50, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Iconsax.people, size: 50, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.groupName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_conversation!.members.length} members',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Members section
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._conversation!.members.map((member) => _MemberTile(
                            member: member,
                            isCurrentUser: member.userId == _currentUserId,
                            isAdmin: _isAdmin,
                            onRemove: _isAdmin && member.userId != _currentUserId
                                ? () => _removeMember(member)
                                : null,
                          )),
                    ],
                  ),
                ),
    );
  }

  Future<void> _removeMember(ChatMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.displayName} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement remove member API call
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove member feature coming soon')),
      );
    }
  }
}

class _MemberTile extends StatelessWidget {
  final ChatMember member;
  final bool isCurrentUser;
  final bool isAdmin;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.member,
    required this.isCurrentUser,
    required this.isAdmin,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
            ),
            child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      member.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          member.displayName.isNotEmpty
                              ? member.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      member.displayName.isNotEmpty
                          ? member.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (member.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Iconsax.verify5, size: 16, color: Colors.blue),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (member.isOnline) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ] else if (member.lastSeenAt != null) ...[
                      Icon(Iconsax.clock, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _formatLastSeen(member.lastSeenAt!),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ] else ...[
                      Text(
                        'Offline',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                    if (member.isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Iconsax.user_remove, color: Colors.red),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastSeen.month}/${lastSeen.day}/${lastSeen.year}';
  }
}
