import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/api_services/chat_service.dart';
import 'package:zyntraplus/api_services/follow_service.dart';
import 'package:zyntraplus/api_services/user_service.dart';
import 'package:zyntraplus/core/app_colors.dart';
import 'package:zyntraplus/core/feed_refresh.dart';
import 'package:zyntraplus/models/follow_user.dart';
import 'package:zyntraplus/screens/message_screen/main_message_screen/personal_chat_screen.dart';
import 'package:zyntraplus/screens/user_profile_screen/user_profile_screen.dart';

class UserSuggestionsStrip extends StatefulWidget {
  /// When provided, uses this list instead of fetching (for embedded feed strips).
  final List<FollowUser>? users;
  final ValueChanged<List<FollowUser>>? onUsersUpdated;

  const UserSuggestionsStrip({
    super.key,
    this.users,
    this.onUsersUpdated,
  });

  @override
  State<UserSuggestionsStrip> createState() => _UserSuggestionsStripState();
}

class _UserSuggestionsStripState extends State<UserSuggestionsStrip> {
  List<FollowUser> _users = [];
  bool _loading = true;

  bool get _isControlled => widget.users != null;

  @override
  void initState() {
    super.initState();
    if (_isControlled) {
      _users = List<FollowUser>.from(widget.users!);
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void didUpdateWidget(UserSuggestionsStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled && widget.users != null) {
      _users = List<FollowUser>.from(widget.users!);
    }
  }

  void _updateUsers(List<FollowUser> next) {
    setState(() => _users = next);
    widget.onUsersUpdated?.call(next);
  }

  Future<void> _load() async {
    try {
      final users = await UserService.getSuggestions(limit: 12);
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow(FollowUser user) async {
    try {
      if (user.isFollowing) {
        await FollowService.unfollow(user.id);
      } else {
        await FollowService.follow(user.id);
      }
      FeedRefresh.trigger();
      if (!mounted) return;
      _updateUsers(
        _users
            .map((u) => u.id == user.id ? u.copyWith(isFollowing: !user.isFollowing) : u)
            .toList(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FollowService.errorMessage(e))),
      );
    }
  }

  void _openChat(FollowUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalChatScreen(
          userId: user.id,
          name: user.displayName,
          avatar: user.avatarUrl ?? '',
          isOnline: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.buttonColor(context),
            ),
          ),
        ),
      );
    }

    if (_users.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Text(
            'People to follow',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _users.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final user = _users[index];
              return _SuggestionCard(
                user: user,
                onFollow: () => _toggleFollow(user),
                onMessage: () => _openChat(user),
                onProfile: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(userId: user.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final FollowUser user;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onProfile;

  const _SuggestionCard({
    required this.user,
    required this.onFollow,
    required this.onMessage,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    return GestureDetector(
      onTap: onProfile,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLine(context)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: accent.withValues(alpha: 0.15),
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.initials,
                      style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (user.followsViewer)
              Text(
                'Follows you',
                style: TextStyle(color: AppColors.secondaryText(context), fontSize: 11),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: onFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing ? AppColors.secondaryBackground(context) : accent,
                  foregroundColor: user.isFollowing ? AppColors.primaryText(context) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: user.isFollowing
                        ? BorderSide(color: AppColors.borderLine(context))
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  user.isFollowing
                      ? 'Following'
                      : user.followsViewer
                          ? 'Follow back'
                          : 'Follow',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton.icon(
                onPressed: onMessage,
                icon: Icon(Iconsax.message, size: 14, color: accent),
                label: Text('Message', style: TextStyle(color: accent, fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
