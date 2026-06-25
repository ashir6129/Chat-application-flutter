import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_screen.dart';
import 'package:zyntraplus/screens/my_profile_screen/profile_landing_screen.dart';
import 'package:zyntraplus/screens/nearby_users_screen/nearby_users_screen.dart';
import 'package:zyntraplus/screens/notification_screen/notification_screen.dart';
import 'package:zyntraplus/screens/reels_screen/reels_screen.dart';
import '../../api_services/user_service.dart';
import 'package:zyntraplus/core/profile_memory_cache.dart';
import '../../core/app_colors.dart';
import '../../core/profile_refresh.dart';
import '../../core/main_tab_navigation.dart';
import '../../core/socket_service.dart';
import '../../widgets/common/offline_banner.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/home_search_screen.dart';
import '../message_screen/messages_hub_screen.dart';
import '../message_screen/switch_chat_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _unreadNotifCount = 3;
  String _userGreeting = 'there';
  late final ProfileRefreshListener _profileRefreshListener;

  @override
  void initState() {
    super.initState();
    _profileRefreshListener = ({bool silent = false}) => _loadUserGreeting(silent: silent);
    MainTabNavigation.bind(_onTap);
    ProfileRefresh.register(_profileRefreshListener);
    _userGreeting = ProfileMemoryCache.me?.displayName ?? 'there';
    _loadUserGreeting(silent: ProfileMemoryCache.me != null);
    SocketService.connect();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _loadUserGreeting({bool silent = false}) async {
    try {
      final profile = await UserService.getMe();
      ProfileMemoryCache.saveProfile(profile);
      if (!mounted) return;
      setState(() => _userGreeting = profile.displayName);
    } catch (_) {
      if (!mounted) return;
      setState(() => _userGreeting = 'there');
    }
  }

  @override
  void dispose() {
    MainTabNavigation.unbind();
    ProfileRefresh.unregister(_profileRefreshListener);
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Reels";
      case 2:
        return "Shop";
      case 3:
        return "Nearby";
      case 4:
        return "Profile";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      extendBody: false,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const HomeScreen(key: PageStorageKey('home_tab')),
                ReelsScreen(
                  key: const PageStorageKey('reels_tab'),
                  isActive: _currentIndex == 1,
                ),
                const MarketplaceScreen(key: PageStorageKey('shop_tab')),
                const PeopleNearbyScreen(key: PageStorageKey('nearby_tab')),
                const ProfileLandingScreen(key: PageStorageKey('profile_tab')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final iconColor = AppColors.primaryText(context);

    return AppBar(
      backgroundColor: AppColors.primaryBackground(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hey, $_userGreeting 👋',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
          Text(
            _getTitle(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText(context),
              height: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MessagesHubScreen(),
              ),
            );
          },
          icon: Icon(Iconsax.message, color: iconColor, size: 24),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeSearchScreen(),
              ),
            );
          },
          icon: Icon(Iconsax.search_normal, color: iconColor, size: 24),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
            );
          },
          icon: Icon(Iconsax.notification, color: iconColor, size: 24),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStickyNavBar() {
    final accent = AppColors.buttonColor(context);

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground(context),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Iconsax.home_1, Iconsax.home_2, 'Home', accent),
              _navItem(1, Iconsax.video_play, Iconsax.video_play, 'Reels', accent),
              _navItem(2, Iconsax.shopping_bag, Iconsax.shopping_bag, 'Shop', accent),
              _navItem(3, Iconsax.location, Iconsax.location, 'Nearby', accent),
              _navItem(4, Iconsax.user, Iconsax.user, 'Profile', accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    Color accent,
  ) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 22,
              color: isActive ? accent : accent.withValues(alpha: 0.55),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}