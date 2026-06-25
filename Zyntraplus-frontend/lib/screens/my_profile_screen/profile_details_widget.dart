import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/models/user_profile.dart';
import 'package:zyntraplus/screens/monetization_screen/monetization_dashboard.dart';
import 'package:zyntraplus/screens/user_profile_screen/follow_list_screen.dart';
import 'package:zyntraplus/screens/my_profile_screen/share_profile_bottom_sheet.dart';
import '../../../core/app_colors.dart';
import '../../../widgets/feed/feed_user_avatar.dart';
import '../create_post/create_content_bottom_sheet.dart';
import '../settings_screen/settings_screen.dart';
import 'edit_profile_screen/edit_profile_screen.dart';

class ProfileDetailsWidget extends StatelessWidget {
  final UserProfile? profile;
  final bool loading;
  final VoidCallback? onProfileUpdated;

  const ProfileDetailsWidget({
    super.key,
    this.profile,
    this.loading = false,
    this.onProfileUpdated,
  });

  String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  Widget _avatar(BuildContext context, UserProfile? p) {
    const size = 80.0;

    return FeedUserAvatar(
      name: p?.displayName ?? 'You',
      initials: p?.initials,
      accentColor: AppColors.buttonColor(context),
      imageUrl: p?.avatarUrl,
      size: size,
      showBorder: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final username = p?.username ?? '...';
    final bio = p?.bio.isNotEmpty == true ? p!.bio : 'Add a bio to tell people about yourself.';
    final posts = p?.stats.posts ?? 0;
    final followers = p?.stats.followers ?? 0;
    final following = p?.stats.following ?? 0;

    Widget statItem(String value, String label, {VoidCallback? onTap}) {
      final child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loading ? '—' : value,
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
              Text(
                '@$username',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _TopBarIconButton(
                icon: Iconsax.add_square,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CreateContentBottomSheet(),
                  );
                },
              ),
              const SizedBox(width: 8),
              _TopBarIconButton(
                icon: Iconsax.menu_1,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                },
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
                  child: _avatar(context, p),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    statItem(formatCount(posts), 'Posts'),
                    statDivider(),
                    statItem(
                      formatCount(followers),
                      'Followers',
                      onTap: p?.id != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FollowListScreen(
                                    userId: p!.id,
                                    mode: FollowListMode.followers,
                                  ),
                                ),
                              ).then((_) => onProfileUpdated?.call())
                          : null,
                    ),
                    statDivider(),
                    statItem(
                      formatCount(following),
                      'Following',
                      onTap: p?.id != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FollowListScreen(
                                    userId: p!.id,
                                    mode: FollowListMode.following,
                                  ),
                                ),
                              ).then((_) => onProfileUpdated?.call())
                          : null,
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
                p?.displayName ?? username,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (p?.location != null && p!.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  p.location!,
                  style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                bio,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MonetizationScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLine(context), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professional Dashboard',
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'View your account insights',
                            style: TextStyle(
                              color: AppColors.mutedText(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ProfileButton(
                      label: 'Edit Profile',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen(initialProfile: p)),
                        );
                        onProfileUpdated?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ProfileButton(
                      label: 'Share Profile',
                      onTap: p == null
                          ? () {}
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ShareProfileBottomSheet(
                                  username: p.username,
                                  imageUrl: p.avatarUrl ?? '',
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
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

class _ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.borderLine(context), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
