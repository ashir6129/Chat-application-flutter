import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/follow_service.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/cached_image.dart';
import '../../core/feed_refresh.dart';
import '../../models/follow_user.dart';
import '../../widgets/feed/feed_user_avatar.dart';
import '../user_profile_screen/user_profile_screen.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TabController _tabs;
  Timer? _debounce;
  List<FollowUser> _userResults = [];
  List<FollowUser> _browseUsers = [];
  bool _usersLoading = false;
  String? _usersError;

  static const _trendingHashtags = [
    '#fashion',
    '#crypto',
    '#tech',
    '#motivation',
    '#fitness',
    '#food',
    '#travel',
    '#music',
  ];

  static const _products = [
    _ProductData(name: 'iPhone 15 Pro', price: '₦867,500', image: 'https://picsum.photos/seed/iphone15/400/400'),
    _ProductData(name: 'Smart Watch S8', price: '₦85,000', image: 'https://picsum.photos/seed/watchs8/400/400'),
    _ProductData(name: 'Canon EOS 2500', price: '₦680,000', image: 'https://picsum.photos/seed/canon2500/400/400'),
    _ProductData(name: 'Air Pegasus 40', price: '₦120,000', image: 'https://picsum.photos/seed/pegasus40/400/400'),
  ];

  static const _reels = [
    'https://picsum.photos/seed/reel1/400/700',
    'https://picsum.photos/seed/reel2/400/700',
    'https://picsum.photos/seed/reel3/400/700',
    'https://picsum.photos/seed/reel4/400/700',
  ];

  static const _hashtags = [
    _HashtagData(tag: '#fashion', count: '14K posts'),
    _HashtagData(tag: '#crypto', count: '28K posts'),
    _HashtagData(tag: '#tech', count: '42K posts'),
    _HashtagData(tag: '#motivation', count: '56K posts'),
    _HashtagData(tag: '#fitness', count: '70K posts'),
    _HashtagData(tag: '#food', count: '84K posts'),
    _HashtagData(tag: '#travel', count: '98K posts'),
    _HashtagData(tag: '#music', count: '112K posts'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _loadBrowseUsers();
  }

  Future<void> _loadBrowseUsers() async {
    setState(() {
      _usersLoading = true;
      _usersError = null;
    });
    try {
      final users = await UserService.browseUsers(limit: 30);
      if (!mounted) return;
      setState(() {
        _browseUsers = users;
        _usersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usersLoading = false;
        _usersError = UserService.errorMessage(e);
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() => _userResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _searchUsers(q));
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _usersLoading = true;
      _usersError = null;
    });
    try {
      final users = await UserService.searchUsers(query);
      if (!mounted || _query.text.trim() != query) return;
      setState(() {
        _userResults = users;
        _usersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usersLoading = false;
        _usersError = UserService.errorMessage(e);
      });
    }
  }

  Future<void> _toggleFollowUser(FollowUser user) async {
    try {
      if (user.isFollowing) {
        await FollowService.unfollow(user.id);
      } else {
        await FollowService.follow(user.id);
      }
      FeedRefresh.trigger();
      if (!mounted) return;
      setState(() {
        FollowUser updated = user.copyWith(isFollowing: !user.isFollowing);
        _userResults = _userResults.map((u) => u.id == user.id ? updated : u).toList();
        _browseUsers = _browseUsers.map((u) => u.id == user.id ? updated : u).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FollowService.errorMessage(e))),
      );
    }
  }

  void _openUserProfile(FollowUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileScreen(userId: user.id)),
    );
  }

  List<FollowUser> get _visibleUsers =>
      _hasQuery ? _userResults : _browseUsers;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focusNode.dispose();
    _tabs.dispose();
    super.dispose();
  }

  bool get _hasQuery => _query.text.trim().isNotEmpty;

  static const Color _listDivider = Color(0xFF232D36);

  Color _searchFieldBackground(BuildContext context) =>
      AppColors.composerBackground(context);

  String _followLabel(FollowUser user) {
    if (user.isFollowing) return 'Following';
    if (user.followsViewer) return 'Follow back';
    return 'Follow';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchHeader(context),
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildAllTab(context),
                  _buildUsersTab(context),
                  _buildProductsTab(context),
                  _buildReelsTab(context),
                  _buildHashtagsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _searchField(context)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 8, right: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _searchFieldBackground(context),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: _query,
        focusNode: _focusNode,
        autofocus: true,
        style: TextStyle(
          color: AppColors.primaryText(context),
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        decoration: InputDecoration(
          hintText: 'Search for users, products...',
          hintStyle: TextStyle(
            color: AppColors.mutedText(context),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            size: 20,
            color: AppColors.mutedText(context),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 44),
          suffixIcon: _hasQuery
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.mutedText(context),
                  ),
                  onPressed: () {
                    _query.clear();
                    setState(() => _userResults = []);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Column(
      children: [
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.only(left: 8, right: 16),
          labelColor: accent,
          unselectedLabelColor: AppColors.secondaryText(context),
          indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: accent, width: 3),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.3,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Users'),
            Tab(text: 'Products'),
            Tab(text: 'Reels'),
            Tab(text: 'Hashtags'),
          ],
        ),
        const Divider(
          height: 1,
          thickness: 0.5,
          color: _listDivider,
        ),
      ],
    );
  }

  Widget _buildAllTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        if (_hasQuery) ...[
          _buildCreatorsSection(
            context,
            title: 'Search results',
            users: _userResults,
            showSeeAll: false,
          ),
          const SizedBox(height: 28),
          _buildPopularProducts(context),
          const SizedBox(height: 28),
          _buildPopularReels(context),
        ] else ...[
          _buildTrendingSearches(context),
          const SizedBox(height: 28),
          _buildCreatorsSection(
            context,
            title: 'Suggested Creators',
            users: _browseUsers,
          ),
          const SizedBox(height: 28),
          _buildPopularProducts(context),
          const SizedBox(height: 28),
          _buildPopularReels(context),
        ],
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    if (_usersLoading && _visibleUsers.isEmpty) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.buttonColor(context),
          ),
        ),
      );
    }

    if (_usersError != null && _visibleUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _usersError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _hasQuery
                    ? () => _searchUsers(_query.text.trim())
                    : _loadBrowseUsers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_visibleUsers.isEmpty) {
      return Center(
        child: Text(
          _hasQuery
              ? 'No users found for "${_query.text.trim()}"'
              : 'No users yet',
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _visibleUsers.length,
      separatorBuilder: (context, _) => const Divider(
        height: 1,
        thickness: 0.5,
        color: _listDivider,
      ),
      itemBuilder: (context, index) =>
          _buildUserListRow(context, _visibleUsers[index]),
    );
  }

  Widget _buildUserListRow(BuildContext context, FollowUser user) {
    final accent = AppColors.buttonColor(context);
    final following = user.isFollowing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openUserProfile(user),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FeedUserAvatar(
                name: user.displayName,
                initials: user.initials,
                accentColor: feedAccentColorForName(user.displayName),
                imageUrl: user.avatarUrl,
                size: 48,
                showBorder: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _toggleFollowUser(user),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 84,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: following ? Colors.transparent : accent,
                    borderRadius: BorderRadius.circular(8),
                    border: following
                        ? Border.all(color: _listDivider, width: 1)
                        : null,
                  ),
                  child: Text(
                    _followLabel(user),
                    style: TextStyle(
                      color: following
                          ? AppColors.primaryText(context)
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorsSection(
    BuildContext context, {
    required String title,
    required List<FollowUser> users,
    bool showSeeAll = true,
    bool useGrid = false,
  }) {
    if (_usersLoading && users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
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

    if (_usersError != null && users.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _sectionHeader(context, title: title, showSeeAll: showSeeAll),
          const SizedBox(height: 14),
          Text(
            _usersError!,
            style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
          ),
          TextButton(
            onPressed: _hasQuery ? () => _searchUsers(_query.text.trim()) : _loadBrowseUsers,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (users.isEmpty) {
      return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          _sectionHeader(context, title: title, showSeeAll: showSeeAll),
          const SizedBox(height: 14),
                    Text(
            _hasQuery ? 'No users found for "${_query.text.trim()}"' : 'No users yet',
            style: TextStyle(color: AppColors.secondaryText(context), fontSize: 14),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, title: title, showSeeAll: showSeeAll),
        const SizedBox(height: 14),
        if (useGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) =>
                _buildCreatorCard(context, users[index], expand: true),
          )
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildCreatorCard(context, users[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildCreatorCard(
    BuildContext context,
    FollowUser user, {
    bool expand = false,
  }) {
    final accent = AppColors.buttonColor(context);
    return GestureDetector(
      onTap: () => _openUserProfile(user),
      onLongPress: () => _toggleFollowUser(user),
      child: Container(
        width: expand ? null : 108,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLine(context).withOpacity(0.4),
            width: 0.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: accent.withValues(alpha: 0.15),
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? appCachedImageProvider(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.initials,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
                    ),
            const SizedBox(height: 10),
                    Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
                      style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '@${user.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.mutedText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLine(context).withOpacity(0.6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.secondaryBackground(context),
                    child: Icon(
                      Iconsax.image,
                      color: AppColors.mutedText(context),
                      size: 28,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.price,
                      style: TextStyle(
                        color: AppColors.buttonColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReelsTab(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: _reels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                _reels[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.secondaryBackground(context),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHashtagsTab(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: _hashtags.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final hashtag = _hashtags[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLine(context).withOpacity(0.6)),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Iconsax.hashtag,
                  color: AppColors.buttonColor(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  hashtag.tag,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                hashtag.count,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    bool showSeeAll = true,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText(context),
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (showSeeAll)
          GestureDetector(
            onTap: () {},
            child: Text(
              'See all',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.buttonColor(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingSearches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, title: 'Trending Searches', showSeeAll: false),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _trendingHashtags.map((tag) {
            return GestureDetector(
              onTap: () {
                _query.text = tag.replaceFirst('#', '');
                _onSearchChanged(_query.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderLine(context).withOpacity(0.7),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, title: 'Popular Products'),
        const SizedBox(height: 14),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = _products[index];
              return Container(
                width: 148,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLine(context).withOpacity(0.5),
                    width: 0.6,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                      product.image,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110,
                        color: AppColors.secondaryBackground(context),
                        child: Icon(
                          Iconsax.image,
                          color: AppColors.mutedText(context),
                          size: 28,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.price,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.buttonColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularReels(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, title: 'Popular Reels'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.62,
          ),
          itemCount: _reels.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                    _reels[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.secondaryBackground(context),
                      child: Icon(
                        Iconsax.video,
                        color: AppColors.mutedText(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProductData {
  const _ProductData({
    required this.name,
    required this.price,
    required this.image,
  });

  final String name;
  final String price;
  final String image;
}

class _HashtagData {
  const _HashtagData({
    required this.tag,
    required this.count,
  });

  final String tag;
  final String count;
}
