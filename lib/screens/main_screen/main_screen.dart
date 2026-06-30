import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_screen.dart';
import 'package:zyntraplus/screens/my_profile_screen/profile_landing_screen.dart';
import 'package:zyntraplus/screens/nearby_users_screen/nearby_users_screen.dart';
import 'package:zyntraplus/screens/notification_screen/notification_screen.dart';
import 'package:zyntraplus/screens/reels_screen/reels_screen.dart';
import '../../api_services/user_service.dart';
import '../../api_services/chat_service.dart';
import '../../api_services/notification_service.dart';
import 'package:zyntraplus/core/profile_memory_cache.dart';
import '../../core/app_colors.dart';
import '../../core/profile_refresh.dart';
import '../../core/main_tab_navigation.dart';
import '../../core/socket_service.dart';
import '../../core/notification_helper.dart';
import '../../core/call_service.dart';
import '../../widgets/common/offline_banner.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/home_search_screen.dart';
import '../message_screen/messages_hub_screen.dart';
import '../message_screen/switch_chat_sheet.dart';

import '../../core/tab_scroll_to_top.dart';
import '../../core/home_scroll_notifier.dart';
import '../../core/call_history_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _unreadNotifCount = 3;
  String _userGreeting = 'there';
  late final ProfileRefreshListener _profileRefreshListener;
  StreamSubscription<Map<String, dynamic>>? _socketMessageSub;

  bool _hasUnreadMessages = false;
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profileRefreshListener = ({bool silent = false}) => _loadUserGreeting(silent: silent);
    MainTabNavigation.bind(_onTap);
    ProfileRefresh.register(_profileRefreshListener);
    _userGreeting = ProfileMemoryCache.me?.displayName ?? 'there';
    _loadUserGreeting(silent: ProfileMemoryCache.me != null);
    SocketService.connect();
    // Initialize CallService so it listens to incoming calls globally
    CallService.instance;
    // Initialize call history persistence
    CallHistoryService.instance.init();
    _socketMessageSub = SocketService.onMessage.listen((data) {
      _checkUnreadCounts();
      _handleSocketMessageNotification(data);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ));
    _checkUnreadCounts();
  }

  Future<void> _checkUnreadCounts() async {
    try {
      final chats = await ChatService.getConversations();
      final hasUnreadChat = chats.any((c) => c.unreadCount > 0);
      if (mounted) setState(() => _hasUnreadMessages = hasUnreadChat);

      final notifs = await NotificationService.getNotifications(page: 1, limit: 1);
      final unreadCount = (notifs['unread_count'] as int?) ?? 0;
      if (mounted) setState(() => _hasUnreadNotifications = unreadCount > 0);
    } catch (_) {}
  }

  Future<void> _loadUserGreeting({bool silent = false}) async {
    try {
      final profile = await UserService.getMe();
      ProfileMemoryCache.saveProfile(profile);
      if (!mounted) return;
      setState(() => _userGreeting = profile.displayName);
      NotificationHelper.registerFcmToken();
      if (mounted) {
        NotificationHelper.checkAndPromptPermission(context);
      }
      _checkUnreadCounts();
    } catch (_) {
      if (!mounted) return;
      setState(() => _userGreeting = 'there');
    }
  }

  void _handleSocketMessageNotification(Map<String, dynamic> data) async {
    try {
      final senderId = data['sender_id']?.toString();
      final currentUserId = ProfileMemoryCache.me?.id;
      if (senderId == null || senderId == currentUserId) {
        return;
      }

      final conversationId = data['conversation_id']?.toString();
      if (conversationId == null) return;

      if (NotificationHelper.activeConversationId == conversationId) {
        return;
      }

      ChatConversation? conv;
      final cached = ChatService.getCachedConversations();
      if (cached != null) {
        conv = cached.where((c) => c.id == conversationId).firstOrNull;
      }
      if (conv == null) {
        try {
          conv = await ChatService.getConversation(conversationId);
        } catch (_) {}
      }

      String title = 'New Message';
      if (conv != null) {
        if (conv.type == 'group') {
          title = conv.title ?? 'Group Message';
        } else {
          title = conv.title ?? 'New Message';
        }
      }

      String body = '';
      final msgType = data['message_type']?.toString() ?? 'text';
      final msgBody = data['body']?.toString() ?? '';
      
      if (msgType == 'text') {
        body = msgBody;
      } else if (msgType == 'voice') {
        body = 'Sent you a voice message';
      } else if (msgType == 'image') {
        body = 'Sent you a photo';
      } else if (msgType == 'video') {
        body = 'Sent you a video';
      } else if (msgType == 'reel') {
        body = 'Sent you a reel';
      } else {
        body = 'Sent you a message';
      }

      final type = conv?.type == 'group' ? 'group_message' : 'message';

      NotificationHelper.showMessageNotification(
        messageId: data['id']?.toString() ?? '',
        conversationId: conversationId,
        senderId: senderId,
        title: title,
        body: body,
        type: type,
      );
    } catch (e) {
      debugPrint("[SocketNotification] Error showing notification: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SocketService.connect();
      _checkUnreadCounts();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MainTabNavigation.unbind();
    ProfileRefresh.unregister(_profileRefreshListener);
    _socketMessageSub?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex == index) {
      TabScrollToTop.trigger(index);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) _checkUnreadCounts();
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
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        appBar: _currentIndex == 0 ? _buildAppBar() : null,
        extendBody: true,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final iconColor = AppColors.primaryText(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: ValueListenableBuilder<double>(
        valueListenable: HomeScrollNotifier.instance.scrollOffset,
        builder: (context, offset, _) {
          final isScrolled = _currentIndex == 0 && offset > 20;
          final bgColor = isScrolled
              ? (isDark
                  ? const Color(0xFF161C24).withValues(alpha: 0.98)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.98))
              : AppColors.primaryBackground(context);

          return AppBar(
            backgroundColor: bgColor,
            elevation: isScrolled ? 2 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.15),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MessagesHubScreen(),
                  ),
                ).then((_) => _checkUnreadCounts());
              },
              icon: Icon(Iconsax.message, color: iconColor, size: 24),
            ),
            if (_hasUnreadMessages)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                ).then((_) {
                  setState(() => _hasUnreadNotifications = false);
                });
              },
              icon: Icon(Iconsax.notification, color: iconColor, size: 24),
            ),
            if (_hasUnreadNotifications)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
        },
      ),
    );
  }

  Widget _buildStickyNavBar() {
    final accent = AppColors.buttonColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);

    return Container(
      height: 64 + bottomPadding,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 4, 8, bottomPadding + 4),
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