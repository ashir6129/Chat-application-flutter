import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/user_service.dart';
import '../../core/main_tab_navigation.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/profile_refresh.dart';
import '../../models/user_profile.dart';
import '../../widgets/feed/feed_user_avatar.dart';
import '../message_screen/messages_hub_screen.dart';
import '../monetization_screen/in_app_tokens_screen.dart';
import '../monetization_screen/monetization_dashboard.dart';
import 'discover_more_screen.dart';
import 'profile_screen.dart';
import '../../core/tab_scroll_to_top.dart';

/// Profile hub — quick access, tokens promo, and feature grid.
class ProfileLandingScreen extends StatefulWidget {
  const ProfileLandingScreen({super.key});

  @override
  State<ProfileLandingScreen> createState() => _ProfileLandingScreenState();
}

class _ProfileLandingScreenState extends State<ProfileLandingScreen> {
  static const _bg = Color(0xFF121B22);
  static const _card = Color(0xFF1A2332);
  static const _cardBorder = Color(0xFF2A3942);
  static const _accent = Color(0xFF00A884);
  static const _muted = Color(0xFF8696A0);

  UserProfile? _profile;
  bool _loading = true;
  late final ProfileRefreshListener _profileRefreshListener;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _profile = ProfileMemoryCache.me;
    _loading = _profile == null;
    _profileRefreshListener = ({bool silent = false}) => _loadProfile(silent: silent);
    ProfileRefresh.register(_profileRefreshListener);
    _loadProfile(silent: _profile != null);
    TabScrollToTop.register(4, _scrollToTop);
  }

  @override
  void dispose() {
    TabScrollToTop.unregister(4);
    ProfileRefresh.unregister(_profileRefreshListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadProfile({bool silent = false}) async {
    if (silent && ProfileMemoryCache.me != null) {
      setState(() {
        _profile = ProfileMemoryCache.me;
        _loading = false;
      });
    }
    if (_profile == null && !silent) {
      setState(() => _loading = true);
    }
    try {
      final profile = await UserService.getMe();
      ProfileMemoryCache.saveProfile(profile);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 22),
              _buildQuickAccess(context),
              const SizedBox(height: 22),
              _buildTokensCard(context),
              const SizedBox(height: 18),
              _buildFeatureGrid(context),
              const SizedBox(height: 14),
              _buildDiscoverMore(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final p = _profile;
    final name = p?.displayName ?? 'Your profile';
    final bio = p?.bio.isNotEmpty == true ? p!.bio : 'Explore. Connect. Grow.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder.withOpacity(0.6), width: 0.6),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              FeedUserAvatar(
                name: name,
                initials: p?.initials,
                accentColor: _accent,
                imageUrl: p?.avatarUrl,
                size: 56,
                showBorder: true,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: _card, width: 2),
                  ),
                ),
              ),
            ],
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
                        _loading ? 'Loading...' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      _QuickItem(Iconsax.home_2, 'Home', const Color(0xFF3D9BFF), () {
        MainTabNavigation.goTo(0);
      }),
      _QuickItem(Iconsax.message, 'Messages', _accent, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MessagesHubScreen()),
        );
      }),
      _QuickItem(Iconsax.shopping_bag, 'Market', const Color(0xFFFF9800), () {
        MainTabNavigation.goTo(2);
      }),
      _QuickItem(Iconsax.chart_2, 'Dashboard', const Color(0xFF9B59FF), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonetizationScreen()),
        );
      }),
      _QuickItem(Iconsax.more, 'More', _muted, () {}),
    ];

    return Column(
      children: [
        Row(
          children: [
            Icon(Iconsax.flash_1, color: _accent, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Quick access',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'Edit',
              style: TextStyle(
                color: _accent.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
              .map(
                (item) => Expanded(
                  child: GestureDetector(
                    onTap: item.onTap,
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: item.color.withOpacity(0.25),
                              width: 0.6,
                            ),
                          ),
                          child: Icon(item.icon, color: item.color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTokensCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2B22), Color(0xFF122A24)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.2), width: 0.8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Unlock more with '),
                          TextSpan(
                            text: 'TURQ TOKENS',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use tokens for premium calls, chats & exclusive gifts.',
                      style: TextStyle(
                        color: _muted.withOpacity(0.95),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InAppTokensScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'Buy tokens',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 72),
            ],
          ),
          Positioned(
            right: -4,
            top: -8,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.35),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: _accent,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _Feature(Iconsax.people, 'Friends', 'Connect with people', const Color(0xFF3D9BFF)),
      _Feature(Iconsax.chart_21, 'Dashboard', 'Professional tools', const Color(0xFF00A884)),
      _Feature(Iconsax.bookmark, 'Saved', 'Your saved posts', const Color(0xFFFF5252)),
      _Feature(Iconsax.people, 'Communities', 'Find & join groups', const Color(0xFF7C4DFF)),
      _Feature(Iconsax.people, 'Groups', 'Group chats', const Color(0xFF3D9BFF)),
      _Feature(Iconsax.gallery, 'Memories', 'Your moments', const Color(0xFF9B59FF)),
      _Feature(Iconsax.bag, 'Marketplace', 'Buy & sell products', const Color(0xFFFFB300)),
      _Feature(Iconsax.document_text, 'Feeds', 'Latest from network', const Color(0xFF00A884)),
      _Feature(Iconsax.calendar, 'Events', 'Upcoming events', const Color(0xFF26C6DA)),
      _Feature(Iconsax.location, 'Nearby', 'People around you', const Color(0xFFFF6584)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.35,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return GestureDetector(
          onTap: () => _onFeatureTap(context, f.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder.withOpacity(0.5), width: 0.6),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: f.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(f.icon, color: f.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        f.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverMore(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DiscoverMoreScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder.withOpacity(0.5), width: 0.6),
        ),
        child: Row(
          children: [
            Icon(Iconsax.discover, color: _accent, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Discover more',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _muted.withOpacity(0.8), size: 22),
          ],
        ),
      ),
    );
  }

  void _onFeatureTap(BuildContext context, String title) {
    switch (title) {
      case 'Dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonetizationScreen()),
        );
      case 'Marketplace':
        MainTabNavigation.goTo(2);
      case 'Feeds':
        MainTabNavigation.goTo(0);
      case 'Nearby':
        MainTabNavigation.goTo(3);
      default:
        break;
    }
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickItem(this.icon, this.label, this.color, this.onTap);
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _Feature(this.icon, this.title, this.subtitle, this.color);
}
