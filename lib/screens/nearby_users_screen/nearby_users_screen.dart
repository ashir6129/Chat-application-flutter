import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/core/socket_service.dart';
import 'package:zyntraplus/api_services/chat_service.dart';
import 'package:zyntraplus/api_services/user_service.dart';
import 'package:zyntraplus/screens/message_screen/main_message_screen/personal_chat_screen.dart';
import 'package:zyntraplus/screens/message_screen/switch_chat_sheet.dart';
import 'package:zyntraplus/screens/message_screen/messages_hub_screen.dart';
import 'nearby_extras.dart';
import '../my_profile_screen/become_spotlight_screen.dart';
import 'explore_map_screen.dart';
import 'location_helper.dart';

import '../../core/app_colors.dart';
import '../../core/main_tab_navigation.dart';
import '../../core/tab_scroll_to_top.dart';
import '../../boxes/send_box_screen.dart';
import '../../boxes/receive_box.dart';

class SpotlightUser {
  final String name;
  final String distance;
  final String avatarUrl;
  final bool isVerified;

  const SpotlightUser({
    required this.name,
    required this.distance,
    required this.avatarUrl,
    this.isVerified = true,
  });
}

class NearbyUser {
  final String userId;
  final String name;
  final String distance;
  final String followers;
  final String bio;
  final String avatarUrl;
  final bool isVerified;
  final bool isSpotlight;
  final bool isOnline;
  final bool isHighlighted;
  final String? boxStatus;
  final String? boxSenderId;
  final String? boxRequestId;

  const NearbyUser({
    this.userId = '',
    required this.name,
    required this.distance,
    required this.followers,
    required this.bio,
    required this.avatarUrl,
    this.isVerified = true,
    this.isSpotlight = false,
    this.isOnline = true,
    this.isHighlighted = false,
    this.boxStatus,
    this.boxSenderId,
    this.boxRequestId,
  });
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class PeopleNearbyScreen extends StatefulWidget {
  const PeopleNearbyScreen({super.key});

  @override
  State<PeopleNearbyScreen> createState() => _PeopleNearbyScreenState();
}

class _PeopleNearbyScreenState extends State<PeopleNearbyScreen> {
  int _selectedFilterIndex = 0;
  String _genderFilter = 'Everyone';
  bool _loadingUsers = true;

  double? _latitude;
  double? _longitude;
  String _currentLocationName = 'Lekki Phase 1, Lagos, Nigeria';

  List<SpotlightUser> _spotlightUsers = [];
  List<NearbyUser> _nearbyUsers = [];

  StreamSubscription? _boxReceivedSubscription;
  StreamSubscription? _boxStatusChangedSubscription;

  bool _hasUnreadMessages = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNearbyUsers();
    _subscribeToBoxEvents();
    _checkUnreadCounts();
    TabScrollToTop.register(3, _scrollToTop);
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

  Future<void> _checkUnreadCounts() async {
    try {
      final chats = await ChatService.getConversations();
      final hasUnreadChat = chats.any((c) => c.unreadCount > 0);
      if (mounted) setState(() => _hasUnreadMessages = hasUnreadChat);
    } catch (_) {}
  }

  @override
  void dispose() {
    TabScrollToTop.unregister(3);
    _boxReceivedSubscription?.cancel();
    _boxStatusChangedSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToBoxEvents() {
    _boxReceivedSubscription = SocketService.onBoxReceived.listen((data) {
      if (mounted) {
        _loadNearbyUsers();
        final sender = data['sender_username'] ?? 'Someone';
        final coins = data['coins'] ?? 50;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎁 Received a new Box request from $sender with $coins coins!'),
            backgroundColor: AppColors.buttonColor(context),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    _boxStatusChangedSubscription = SocketService.onBoxStatusChanged.listen((data) {
      if (mounted) {
        _loadNearbyUsers();
        final status = data['status'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎁 Box request was $status!'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _loadNearbyUsers({double? lat, double? lng, String? locName}) async {
    if (!mounted) return;
    setState(() => _loadingUsers = true);

    try {
      double latitude = lat ?? _latitude ?? 6.4281;
      double longitude = lng ?? _longitude ?? 3.4219;
      String locationName = locName ?? _currentLocationName;

      if (lat == null && lng == null) {
        final position = await LocationHelper.getCurrentPosition();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          locationName = 'Current Location';
        }
      }

      _latitude = latitude;
      _longitude = longitude;
      _currentLocationName = locationName;

      try {
        await UserService.updateLocation(
          latitude: latitude,
          longitude: longitude,
          location: locationName,
        );
      } catch (e) {
        debugPrint('Failed to update location on backend: $e');
      }

      final users = await UserService.getNearbyUsers(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        _spotlightUsers = users
            .where((u) => u.isVerified)
            .take(6)
            .map(
              (u) => SpotlightUser(
                name: u.username,
                distance: u.distanceKm != null
                    ? '${u.distanceKm!.toStringAsFixed(1)} km away'
                    : 'On ZyntraPlus',
                avatarUrl: u.avatarUrl ?? '',
              ),
            )
            .toList();

        _nearbyUsers = users
            .map(
              (u) => NearbyUser(
                userId: u.id,
                name: u.username,
                distance: u.distanceKm != null
                    ? '${u.distanceKm!.toStringAsFixed(1)} km away'
                    : 'Nearby',
                followers: u.followsViewer ? 'Follows you' : 'New member',
                bio: (u.bio != null && u.bio!.isNotEmpty) ? u.bio! : 'Explore. Connect. Grow.',
                avatarUrl: u.avatarUrl ?? '',
                isVerified: u.isVerified,
                isOnline: true,
                boxStatus: u.boxStatus,
                boxSenderId: u.boxSenderId,
                boxRequestId: u.boxRequestId,
              ),
            )
            .toList();

        _loadingUsers = false;
      });
    } catch (e) {
      debugPrint('Failed to load nearby users: $e');
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  final List<SpotlightUser> _fallbackSpotlight = const [
    SpotlightUser(
      name: 'Jessica',
      distance: '1.2 km away',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    SpotlightUser(
      name: 'Aron Smith',
      distance: '1.5 km away',
      avatarUrl: 'https://i.pravatar.cc/150?img=68',
    ),
    SpotlightUser(
      name: 'Sarah Davis',
      distance: '1.8 km away',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
    ),
    SpotlightUser(
      name: 'Michael',
      distance: '2.1 km away',
      avatarUrl: 'https://i.pravatar.cc/150?img=57',
    ),
  ];

  final List<NearbyUser> _fallbackNearby = const [
    NearbyUser(
      name: 'Emily Johnson',
      distance: '0.8 km away',
      followers: '6.5k followers',
      bio: 'Just for fun 😊',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isOnline: true,
    ),
    NearbyUser(
      name: 'David Wilson',
      distance: '1.1 km away',
      followers: '5.2k followers',
      bio: 'Lifestyle creator',
      avatarUrl: 'https://i.pravatar.cc/150?img=69',
      isVerified: true,
      isOnline: true,
    ),
    NearbyUser(
      name: 'Olivia Brown',
      distance: '1.3 km away',
      followers: '4.9k followers',
      bio: 'Coffee lover ☕',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      isOnline: true,
    ),
    NearbyUser(
      name: 'James Miller',
      distance: '1.5 km away',
      followers: '3.8k followers',
      bio: 'Adventure creator',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      isOnline: true,
    ),
    NearbyUser(
      name: 'Sophia Taylor',
      distance: '2.0 km away',
      followers: '2.4k followers',
      bio: 'Music vibes 🎵',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      isOnline: true,
    ),
  ];

  // ─── Spotlight brand colors (not in AppColors — intentional gold palette) ──
  static const Color _spotlightGold = Color(0xFFFFD700);
  static const Color _spotlightOrange = Color(0xFFFFA500);
  static const Color _onlineGreen = Color(0xFF00C853);

  List<NearbyUser> get _activeNearbyUsers =>
      _nearbyUsers.isNotEmpty ? _nearbyUsers : _fallbackNearby;

  List<SpotlightUser> get _activeSpotlightUsers =>
      _spotlightUsers.isNotEmpty ? _spotlightUsers : _fallbackSpotlight;

  List<NearbyUser> get _filteredNearbyUsers {
    var list = List<NearbyUser>.from(_activeNearbyUsers);
    switch (_selectedFilterIndex) {
      case 1:
        break;
      case 2:
        list = list.where((u) => u.isOnline).toList();
        break;
      case 3:
        list = list.reversed.toList();
        break;
      case 4:
        list = list.where((u) => u.isVerified).toList();
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSpotlightBanner(context),
            const SizedBox(height: 16),
            _buildSpotlightSection(context),
            const SizedBox(height: 20),
            _buildCreatorsNearbyHeader(context),
            const SizedBox(height: 16),
            ..._filteredNearbyUsers.map((user) => _buildNearbyUserCard(context, user)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      leading: IconButton(
        onPressed: () => MainTabNavigation.goTo(0),
        icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
      ),

      title: Text(
        'People Nearby',
        style: TextStyle(
          color: AppColors.primaryText(context),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      actions: [
        // Filter/Map icon
        IconButton(
          onPressed: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
            );
            if (result != null) {
              final locName = result['location'] as String;
              final lat = result['latitude'] as double;
              final lng = result['longitude'] as double;
              _loadNearbyUsers(lat: lat, lng: lng, locName: locName);
            }
          },
          icon: Icon(
            Iconsax.filter_search,
            color: AppColors.primaryText(context),
            size: 22,
          ),
        ),

        // Message icon with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MessagesHubScreen(
                      initialSpace: ChatSpace.creators,
                    ),
                  ),
                ).then((_) => _checkUnreadCounts());
              },
              icon: Icon(
                Iconsax.message,
                color: AppColors.primaryText(context),
                size: 22,
              ),
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

        // Add user icon
        IconButton(
          onPressed: () {
            // Add user action - can be wired to create connection or invite
          },
          icon: Icon(
            Iconsax.user_add,
            color: AppColors.primaryText(context),
            size: 22,
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Spotlight Banner ─────────────────────────────────────────────────────

  Widget _buildSpotlightBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BecomeSpotlightScreen()),
          );
        },
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Dark gradient is intentional branding — kept as brand colors
          gradient: const LinearGradient(
            colors: [Color(0xFF1A2A1A), Color(0xFF0D1F2D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E4A2E), width: 1),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Upgrade to ',
                          style: TextStyle(
                            // Banner has a forced dark background — white reads correctly here
                            color: AppColors.primaryText(
                                context).withOpacity(1.0) ==
                                AppColors.primaryText(context)
                                ? const Color(0xFFE9EDEF)
                                : const Color(0xFFE9EDEF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Spotlight',
                          style: TextStyle(
                            color: _spotlightGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stand out. Get noticed.\nMore views. More chats.',
                    style: TextStyle(
                      color: AppColors.mutedText(context),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildSpotlightButton(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSpotlightButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BecomeSpotlightScreen()),
        );
      },
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_spotlightGold, _spotlightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _spotlightGold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            'Become Spotlight',
            style: TextStyle(
              // Dark text on gold background — use buttonTextColor (dark mode = 0xFF0D0D0D)
              color: AppColors.buttonTextColor(context) == const Color(0xFFFFFFFF)
                  ? const Color(0xFF1A1A00)
                  : AppColors.buttonTextColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ─── Spotlight Section ────────────────────────────────────────────────────

  Widget _buildSpotlightSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Spotlight Users',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SpotlightCreatorsScreen(
                        users: _activeSpotlightUsers,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.buttonColor(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.buttonColor(context),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _activeSpotlightUsers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _buildSpotlightCard(context, _activeSpotlightUsers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildSpotlightCard(BuildContext context, SpotlightUser user) {
    return Container(
      width: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A24), // matching the dark teal background from the image
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.buttonColor(context),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildSpotlightBadge(),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.buttonColor(context),
                    width: 2.5,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                  backgroundColor: AppColors.secondaryBackground(context),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _spotlightGold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F1A24),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.verifiedBadge(context),
                  size: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.distance,
            style: TextStyle(
              color: AppColors.mutedText(context),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSpotlightBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _spotlightGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.black, size: 12),
          const SizedBox(width: 4),
          const Text(
            'Spotlight',
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsNearbyHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Creators Nearby',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showNearbyGenderFilter(context, _genderFilter,
                  (g) => setState(() => _genderFilter = g));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.borderLine(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.people,
                    color: AppColors.secondaryText(context),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _genderFilter == 'Everyone' ? 'All Gender' : _genderFilter,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryText(context),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyList(BuildContext context) {
    return Column(
      children: _filteredNearbyUsers
          .map((user) => _buildNearbyUserCard(context, user))
          .toList(),
    );
  }

  Widget _buildNearbyUserCard(BuildContext context, NearbyUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: user.isHighlighted
              ? _spotlightGold.withOpacity(0.05)
              : AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: user.isHighlighted
                ? _spotlightGold.withOpacity(0.6)
                : AppColors.borderLine(context),
            width: user.isHighlighted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.avatarUrl),
                  backgroundColor: AppColors.borderLine(context),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: _onlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryBackground(context),
                          width: 2,
                        ),
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
                          user.name,
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (user.isVerified)
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.verifiedBadge(context),
                          size: 15,
                        ),
                      if (user.isSpotlight) ...[
                        const SizedBox(width: 6),
                        _buildSpotlightBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.followers,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.bio,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChatButton(context, user),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, NearbyUser user) {
    final hasAccepted = user.boxStatus == 'accepted';
    final hasPending = user.boxStatus == 'pending';
    final isReceiver = user.boxSenderId == user.userId;

    String labelText = 'Send 🎁';
    if (hasAccepted) {
      labelText = 'Chat';
    } else if (hasPending) {
      labelText = isReceiver ? 'Open 🎁' : 'Pending';
    }

    return GestureDetector(
      onTap: () async {
        if (user.userId.isEmpty) return;

        if (hasAccepted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PersonalChatScreen(
                userId: user.userId,
                name: user.name,
                avatar: user.avatarUrl,
                isOnline: user.isOnline,
              ),
            ),
          );
        } else if (hasPending) {
          if (isReceiver) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiveBoxScreen(
                  request: {
                    'id': user.boxRequestId ?? '',
                    'sender_id': user.userId,
                    'sender_username': user.name,
                    'sender_avatar': user.avatarUrl,
                    'coins': 50,
                    'note': 'Wants to unlock chat with you!',
                  },
                ),
              ),
            );
            if (result == true) {
              _loadNearbyUsers();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your Box request is pending their acceptance.')),
            );
          }
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SendBoxScreen(
                targetUserId: user.userId,
                username: user.name,
                avatarUrl: user.avatarUrl,
                distance: user.distance,
              ),
            ),
          );
          if (result == true) {
            _loadNearbyUsers();
          }
        }
      },
      child: Container(
        width: 86,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.buttonColor(context),
              AppColors.buttonColor(context).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonColor(context).withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            labelText,
            style: TextStyle(
              color: AppColors.buttonTextColor(context),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}