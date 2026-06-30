import 'package:flutter/material.dart';

import 'package:zyntraplus/api_services/user_service.dart';

import 'package:zyntraplus/core/cached_image.dart';

import 'package:zyntraplus/core/profile_memory_cache.dart';

import 'package:zyntraplus/core/profile_refresh.dart';

import 'package:zyntraplus/models/feed_post.dart';
import 'package:zyntraplus/models/user_profile.dart';

import 'package:zyntraplus/screens/my_profile_screen/profile_details_widget.dart';

import 'package:zyntraplus/screens/my_profile_screen/tabs/all_products.dart';

import 'package:zyntraplus/screens/user_profile_screen/tabs/all_reels.dart';

import 'package:zyntraplus/screens/user_profile_screen/tabs/all_products.dart' as user_products;

import 'package:zyntraplus/widgets/profile/profile_posts_list.dart';

import '../../../core/app_colors.dart';



class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});



  @override

  State<ProfileScreen> createState() => _ProfileScreenState();

}



class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  UserProfile? _profile;

  List<PostModel> _posts = [];

  bool _loadingProfile = false;

  bool _loadingPosts = false;

  late final ProfileRefreshListener _profileRefreshListener;



  final List<String> _options = ['All', 'Photos', 'Reels', 'Products'];

  static const _tabTypes = ['all', 'photos', 'reels'];



  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: _options.length, vsync: this);

    _tabController.addListener(() => setState(() {}));



    _profile = ProfileMemoryCache.me;

    _posts = List<PostModel>.from(ProfileMemoryCache.myPosts);

    _loadingProfile = _profile == null;

    _loadingPosts = _posts.isEmpty;



    _profileRefreshListener = ({bool silent = false}) => _reload(silent: true);

    ProfileRefresh.register(_profileRefreshListener);



    _reload(silent: _profile != null || _posts.isNotEmpty);

  }



  @override

  void dispose() {

    ProfileRefresh.unregister(_profileRefreshListener);

    _tabController.dispose();

    super.dispose();

  }



  Future<void> _reload({bool silent = false}) async {

    if (silent && ProfileMemoryCache.me != null) {

      setState(() {

        _profile = ProfileMemoryCache.me;

        _posts = List<PostModel>.from(ProfileMemoryCache.myPosts);

      });

    }

    await Future.wait([

      _loadProfile(silent: silent),

      _loadPosts(silent: silent),

    ]);

  }



  Future<void> _loadProfile({bool silent = false}) async {

    if (!silent && _profile == null) {

      setState(() => _loadingProfile = true);

    }

    try {

      final profile = await UserService.getMe();

      ProfileMemoryCache.saveProfile(profile);

      if (!mounted) return;

      setState(() {

        _profile = profile;

        _loadingProfile = false;

      });

    } catch (_) {

      if (!mounted) return;

      setState(() => _loadingProfile = false);

    }

  }



  Future<void> _loadPosts({bool silent = false}) async {

    if (!silent && _posts.isEmpty) {

      setState(() => _loadingPosts = true);

    }

    try {

      final posts = await UserService.getMyPosts(type: 'all', limit: 50);

      ProfileMemoryCache.savePosts(posts);

      if (!mounted) return;

      setState(() {

        _posts = posts;

        _loadingPosts = false;

      });

      prefetchMediaUrls(

        posts.expand((p) => [

          ...p.images,

          if (p.authorAvatarUrl != null && p.authorAvatarUrl!.isNotEmpty) p.authorAvatarUrl!,

        ]),

      );

    } catch (_) {

      if (!mounted) return;

      setState(() => _loadingPosts = false);

    }

  }



  void _onPostsChanged(List<PostModel> posts) {

    setState(() => _posts = posts);

    ProfileMemoryCache.savePosts(posts);

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

                          ? AppColors.buttonColor(context).withValues(alpha: 0.15)

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

    return Scaffold(

      backgroundColor: AppColors.primaryBackground(context),

      body: SafeArea(

        child: NestedScrollView(

          headerSliverBuilder: (context, _) => [

            SliverToBoxAdapter(

              child: ProfileDetailsWidget(

                profile: _profile,

                loading: _loadingProfile && _profile == null,

                onProfileUpdated: () => _reload(silent: true),

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

                      managed: true,

                      posts: _posts,

                      loading: _loadingPosts,

                      onPostsChanged: _onPostsChanged,

                    ),

                    ProfilePostsList(

                      type: 'photos',

                      managed: true,

                      posts: _posts,

                      loading: _loadingPosts,

                      onPostsChanged: _onPostsChanged,

                    ),

                    UserAllReelsTab(
                      isOwnProfile: true,
                    ),

                    user_products.UserAllProductsTab(
                      userId: _profile?.id,
                      isOwnProfile: true,
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


