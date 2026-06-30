import 'package:flutter/material.dart';
import 'package:zyntraplus/api_services/follow_service.dart';
import 'package:zyntraplus/api_services/user_service.dart';
import 'package:zyntraplus/models/user_profile.dart';
import 'package:zyntraplus/screens/user_profile_screen/follow_list_screen.dart';
import 'package:zyntraplus/screens/user_profile_screen/tabs/all_reels.dart';
import 'package:zyntraplus/screens/user_profile_screen/tabs/all_products.dart';
import 'package:zyntraplus/widgets/profile/profile_posts_list.dart';
import 'user_profile_details_widget.dart';
import '../../../core/app_colors.dart';
import '../../../core/feed_refresh.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _options = ['All', 'Photos', 'Reels', 'Products'];

  UserProfile? _profile;
  String? _currentUserId;
  bool _loading = true;
  String? _error;
  bool _followBusy = false;

  static const _tabTypes = ['all', 'photos', 'reels', 'products'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _options.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await UserService.getMe();
      final profile = await UserService.getById(widget.userId);
      if (!mounted) return;
      setState(() {
        _currentUserId = me.id;
        _profile = profile;
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

  Future<void> _toggleFollow() async {
    final profile = _profile;
    if (profile == null || _followBusy) return;

    final wasFollowing = profile.isFollowing;
    setState(() {
      _followBusy = true;
      _profile = profile.copyWith(
        isFollowing: !wasFollowing,
        stats: UserProfileStats(
          posts: profile.stats.posts,
          followers: profile.stats.followers + (wasFollowing ? -1 : 1),
          following: profile.stats.following,
        ),
      );
    });

    try {
      if (wasFollowing) {
        await FollowService.unfollow(profile.id);
        FeedRefresh.trigger();
      } else {
        await FollowService.follow(profile.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _profile = profile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FollowService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  void _openFollowList(FollowListMode mode) {
    final profile = _profile;
    if (profile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowListScreen(userId: profile.id, mode: mode),
      ),
    ).then((_) => _loadProfile());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOptions() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_options.length, (index) {
              final isSelected = _tabController.index == index;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 12 : 8, right: 4),
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.buttonColor(context).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _options[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? AppColors.buttonColor(context)
                            : AppColors.secondaryText(context),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        body: Center(child: CircularProgressIndicator(color: AppColors.buttonColor(context))),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground(context),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Profile not found', style: TextStyle(color: AppColors.secondaryText(context))),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadProfile, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final isOwnProfile = _currentUserId == profile.id;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: UserProfileDetailsWidget(
                profile: profile,
                isOwnProfile: isOwnProfile,
                onFollowTap: _toggleFollow,
                onFollowersTap: () => _openFollowList(FollowListMode.followers),
                onFollowingTap: () => _openFollowList(FollowListMode.following),
              ),
            ),
          ],
          body: Column(
            children: [
              _buildOptions(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProfilePostsList(
                      type: 'all',
                      username: profile.username,
                      readOnly: true,
                    ),
                    ProfilePostsList(
                      type: 'photos',
                      username: profile.username,
                      readOnly: true,
                    ),
                    UserAllReelsTab(
                      username: profile.username,
                      isOwnProfile: isOwnProfile,
                    ),
                    UserAllProductsTab(
                      userId: profile.id,
                      isOwnProfile: isOwnProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
