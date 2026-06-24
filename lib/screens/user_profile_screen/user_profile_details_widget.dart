import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/api_services/chat_service.dart';
import 'package:zyntraplus/models/user_profile.dart';
import 'package:zyntraplus/screens/message_screen/main_message_screen/personal_chat_screen.dart';
import '../../../core/app_colors.dart';

class UserProfileDetailsWidget extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;
  final VoidCallback onFollowTap;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  const UserProfileDetailsWidget({
    super.key,
    required this.profile,
    required this.isOwnProfile,
    required this.onFollowTap,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalChatScreen(
          userId: profile.id,
          name: profile.displayName,
          avatar: profile.avatarUrl ?? '',
          isOnline: profile.isOnline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;

    Widget statItem(String value, String label, VoidCallback? onTap) {
      final child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );

      if (onTap == null) return child;
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: child);
    }

    Widget statDivider() => Container(
      width: 1,
      height: 28,
      color: AppColors.borderLine(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              _TopBarIconButton(
                icon: Iconsax.arrow_left,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              Text(
                '@${profile.username}',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              if (!isOwnProfile)
                _TopBarIconButton(
                  icon: Iconsax.more,
                  onTap: () => _showMoreOptions(context),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.buttonColor(context), width: 2),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBackground(context),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.secondaryBackground(context),
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Text(
                            profile.initials,
                            style: TextStyle(
                              color: AppColors.buttonColor(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    statItem(_formatCount(profile.stats.posts), 'Posts', null),
                    statDivider(),
                    statItem(
                      _formatCount(profile.stats.followers),
                      'Followers',
                      onFollowersTap,
                    ),
                    statDivider(),
                    statItem(
                      _formatCount(profile.stats.following),
                      'Following',
                      onFollowingTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  profile.bio,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),
              ],
              if (!isOwnProfile) ...[
                const SizedBox(height: 14),
                _ProfileActionButtons(
                  isFollowing: profile.isFollowing,
                  onFollowTap: onFollowTap,
                  onMessageTap: () => _openChat(context),
                  onSendBoxTap: () {},
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserMoreOptionsSheet(
        isFollowing: profile.isFollowing,
        onUnfollow: onFollowTap,
      ),
    );
  }
}

class _ProfileActionButtons extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onMessageTap;
  final VoidCallback onSendBoxTap;

  const _ProfileActionButtons({
    required this.isFollowing,
    required this.onFollowTap,
    required this.onMessageTap,
    required this.onSendBoxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProfileButton(
                label: 'Message',
                icon: Iconsax.message,
                onTap: onMessageTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProfileButton(
                label: 'Send me a box',
                icon: Iconsax.box,
                onTap: onSendBoxTap,
                trailingIcon: Icons.auto_awesome_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _FollowButton(isFollowing: isFollowing, onTap: onFollowTap),
      ],
    );
  }
}

class _UserMoreOptionsSheet extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onUnfollow;

  const _UserMoreOptionsSheet({
    required this.isFollowing,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.borderLine(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (isFollowing)
            _OptionTile(
              icon: Iconsax.user_minus,
              label: 'Unfollow',
              onTap: () {
                Navigator.pop(context);
                onUnfollow();
              },
            ),
          _OptionTile(
            icon: Iconsax.slash,
            label: 'Block',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Iconsax.info_circle,
            label: 'Report',
            isDestructive: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.primaryText(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLine(context), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryText(context), size: 20),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFollowing ? AppColors.borderLine(context) : AppColors.buttonColor(context),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFollowing ? Iconsax.user_tick : Iconsax.user_add,
              size: 17,
              color: isFollowing ? AppColors.primaryText(context) : AppColors.buttonColor(context),
            ),
            const SizedBox(width: 7),
            Text(
              isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                color: isFollowing ? AppColors.primaryText(context) : AppColors.buttonColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    this.icon,
    this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLine(context), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: AppColors.primaryText(context)),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 5),
              Icon(trailingIcon, size: 13, color: AppColors.secondaryText(context)),
            ],
          ],
        ),
      ),
    );
  }
}
