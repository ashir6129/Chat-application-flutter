import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/app_colors.dart';

/// Page / Channel chat — announcements, join, bottom nav (design reference).
class ChannelChatScreen extends StatefulWidget {
  final String channelId;
  final String name;
  final String avatar;
  final int subscriberCount;
  final bool isVerified;
  final bool isJoined;
  final bool isAnonymous;

  const ChannelChatScreen({
    super.key,
    required this.channelId,
    required this.name,
    required this.avatar,
    this.subscriberCount = 4200,
    this.isVerified = true,
    this.isJoined = false,
    this.isAnonymous = false,
  });

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  int _navIndex = 0;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _joined = widget.isJoined;
  }

  String get _subsLabel {
    if (widget.subscriberCount >= 1000) {
      return '${(widget.subscriberCount / 1000).toStringAsFixed(1)}K subscribers';
    }
    return '${widget.subscriberCount} subscribers';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.avatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF30D5C8),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    widget.isAnonymous
                        ? 'Anonymous · no subscriber info shown'
                        : _subsLabel,
                    style: const TextStyle(
                      color: Color(0xFF8696A0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export_3, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPinnedAnnouncement(),
          Expanded(child: _buildUpdatesTab()),
          if (!_joined) _buildJoinButton(),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildPinnedAnnouncement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2E28),
        border: Border(
          bottom: BorderSide(color: Color(0xFF30D5C8), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin, color: Color(0xFF30D5C8), size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PINNED ANNOUNCEMENT',
                  style: TextStyle(
                    color: Color(0xFF30D5C8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'New listing rewards are live — check your dashboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2C34),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Color(0xFF30D5C8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(color: Color(0xFF8696A0), fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'We are excited to announce our Spring Creator Rewards program! '
                'Eligible creators can earn bonus tokens for every verified sale '
                'made through the marketplace this month. 🙏',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _reactionChip('❤️', '48'),
                  const SizedBox(width: 8),
                  _reactionChip('👍', '32'),
                  const SizedBox(width: 8),
                  _reactionChip('🔥', '12'),
                  const Spacer(),
                  const Icon(Iconsax.eye, color: Color(0xFF8696A0), size: 14),
                  const Text(
                    ' 243',
                    style: TextStyle(color: Color(0xFF8696A0), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'edited 2h ago',
                  style: TextStyle(color: Color(0xFF8696A0), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2C34),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: Color(0xFF5E5CE6)),
                    Positioned(left: 18, child: CircleAvatar(radius: 14, backgroundColor: Color(0xFF30D5C8))),
                    Positioned(left: 36, child: CircleAvatar(radius: 14, backgroundColor: Color(0xFFFFB800))),
                  ],
                ),
                const SizedBox(width: 48),
                const Expanded(
                  child: Text(
                    '15 comments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Iconsax.arrow_right_3, color: Color(0xFF8696A0), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reactionChip(String emoji, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$emoji $count', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildJoinButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => setState(() => _joined = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF30D5C8),
            foregroundColor: const Color(0xFF0B0E11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'JOIN CHANNEL',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Iconsax.notification, 'Updates'),
      (Iconsax.search_normal, 'Search'),
      (Iconsax.people, 'Members'),
      (Iconsax.info_circle, 'About'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12141D),
        border: Border(top: BorderSide(color: Color(0xFF2C2C2E))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = _navIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _navIndex = i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$1,
                      size: 22,
                      color: active
                          ? const Color(0xFF30D5C8)
                          : const Color(0xFF8696A0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? const Color(0xFF30D5C8)
                            : const Color(0xFF8696A0),
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
