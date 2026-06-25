import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Mock blocked users — replace with API data
  final List<_BlockedUser> _blocked = [
    _BlockedUser(
      uid: 'b1',
      name: 'Raj Verma',
      username: 'raj.verma',
      avatarUrl: 'https://i.pravatar.cc/80?img=3',
    ),
    _BlockedUser(
      uid: 'b2',
      name: 'Priya Nair',
      username: 'priya.nair',
      avatarUrl: 'https://i.pravatar.cc/80?img=5',
    ),
    _BlockedUser(
      uid: 'b3',
      name: 'Aditya Mehta',
      username: 'aditya.m',
      avatarUrl: null,
    ),
  ];

  void _confirmUnblock(BuildContext ctx, _BlockedUser user) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Unblock ${user.name}?'),
        content: Text(
          '${user.name} will be able to see your posts and interact with you again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _blocked.removeWhere((u) => u.uid == user.uid));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} unblocked'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Unblock',
              style: TextStyle(color: Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Blocked Users',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _blocked.isEmpty
          ? _EmptyState()
          : Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle,
                    size: 16,
                    color: AppColors.secondaryText(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blocked users can\'t see your posts or message you.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _blocked.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: AppColors.borderLine(context),
              ),
              itemBuilder: (ctx, i) {
                final u = _blocked[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: u.avatarUrl != null
                        ? NetworkImage(u.avatarUrl!)
                        : null,
                    backgroundColor:
                    AppColors.secondaryBackground(context),
                    child: u.avatarUrl == null
                        ? Text(
                      _initials(u.name),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText(context),
                      ),
                    )
                        : null,
                  ),
                  title: Text(
                    u.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                  subtitle: Text(
                    '@${u.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _confirmUnblock(context, u),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFE24B4A), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Unblock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE24B4A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedUser {
  final String uid;
  final String name;
  final String username;
  final String? avatarUrl;

  const _BlockedUser({
    required this.uid,
    required this.name,
    required this.username,
    this.avatarUrl,
  });
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.slash,
              size: 48, color: AppColors.mutedText(context)),
          const SizedBox(height: 12),
          Text(
            'No blocked users',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Users you block will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }
}