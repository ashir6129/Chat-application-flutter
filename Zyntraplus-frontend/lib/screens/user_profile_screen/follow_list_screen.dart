import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/chat_service.dart';
import '../../api_services/follow_service.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/feed_refresh.dart';
import '../../models/follow_user.dart';
import '../message_screen/main_message_screen/personal_chat_screen.dart';
import '../user_profile_screen/user_profile_screen.dart';
enum FollowListMode { followers, following }

class FollowListScreen extends StatefulWidget {
  final String userId;
  final FollowListMode mode;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.mode,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<FollowUser> _users = [];
  String? _currentUserId;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await UserService.getMe();
      final users = widget.mode == FollowListMode.followers
          ? await UserService.getFollowers(widget.userId)
          : await UserService.getFollowing(widget.userId);
      if (!mounted) return;
      setState(() {
        _currentUserId = me.id;
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = UserService.errorMessage(e);
      });
    }
  }

  List<FollowUser> get _filtered {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) {
      return u.username.toLowerCase().contains(q) ||
          u.displayName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _toggleFollow(int index) async {
    final user = _filtered[index];
    if (_busyIds.contains(user.id)) return;

    final wasFollowing = user.isFollowing;
    final listIndex = _users.indexWhere((u) => u.id == user.id);
    if (listIndex < 0) return;

    final isOwnFollowingList =
        widget.mode == FollowListMode.following && widget.userId == _currentUserId;

    setState(() {
      _busyIds.add(user.id);
      if (wasFollowing && isOwnFollowingList) {
        _users.removeAt(listIndex);
      } else {
        _users[listIndex] = user.copyWith(isFollowing: !wasFollowing);
      }
    });

    try {
      if (wasFollowing) {
        await FollowService.unfollow(user.id);
        FeedRefresh.trigger();
      } else {
        await FollowService.follow(user.id);
        FeedRefresh.trigger();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasFollowing && isOwnFollowingList) {
          _users.insert(listIndex, user);
        } else {
          _users[listIndex] = user;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FollowService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _busyIds.remove(user.id));
    }
  }

  Future<void> _openMessage(FollowUser user) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final conversationId = await ChatService.startDirect(user.id);
      var isOnline = false;
      try {
        final profile = await UserService.getById(user.id);
        isOnline = profile.isOnline;
      } catch (_) {}
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalChatScreen(
            userId: user.id,
            name: user.displayName,
            avatar: user.avatarUrl ?? '',
            isOnline: isOnline,
            conversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(ChatService.errorMessage(e))),
      );
    }
  }

  String _buttonLabel(FollowUser user) {
    if (user.isFollowing) return 'Following';
    if (user.followsViewer) return 'Follow back';
    return 'Follow';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == FollowListMode.followers ? 'Followers' : 'Following';
    final accent = AppColors.buttonColor(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLine(context)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.search_normal, size: 18, color: AppColors.mutedText(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search',
                        hintStyle: TextStyle(color: AppColors.mutedText(context), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody(context, accent)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color accent) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.secondaryText(context))),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final users = _filtered;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.mode == FollowListMode.followers ? Iconsax.people : Iconsax.user_add,
              size: 48,
              color: AppColors.mutedText(context),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No users found'
                  : widget.mode == FollowListMode.followers
                      ? 'No followers yet'
                      : 'Not following anyone yet',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelf = user.id == _currentUserId;
        final isFollowing = user.isFollowing;
        final busy = _busyIds.contains(user.id);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: user.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondaryBackground(context),
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? Text(
                          user.initials,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isSelf) ...[
                  if (widget.mode == FollowListMode.following) ...[
                    GestureDetector(
                      onTap: () => _openMessage(user),
                      child: Container(
                        width: 36,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLine(context)),
                        ),
                        child: Icon(
                          Iconsax.message,
                          size: 16,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  GestureDetector(
                    onTap: busy ? null : () => _toggleFollow(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? AppColors.secondaryBackground(context)
                            : accent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFollowing ? AppColors.borderLine(context) : accent,
                        ),
                      ),
                      child: busy
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isFollowing ? accent : Colors.white,
                              ),
                            )
                          : Text(
                              _buttonLabel(user),
                              style: TextStyle(
                                color: isFollowing ? AppColors.primaryText(context) : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
