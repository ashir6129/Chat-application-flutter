import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'core/app_colors.dart';
import 'widgets/message/chat_theme.dart';
import 'widgets/message/message_action_sheet.dart';
import 'screens/message_screen/chat/chat_attach_sheet.dart';

// ─── Main Chat Screen ─────────────────────────────────────────────────────────
class EmilyChatScreen extends StatelessWidget {
  const EmilyChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatTheme.background,
      body: Column(
        children: [
          _TopBar(),
          _ProfileCard(),
          _TipBanner(),
          Expanded(child: _ChatList()),
          _RoseNotification(),
          _BottomInputBar(),
          _BottomNavBar(),
        ],
      ),
    );
  }
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondaryBackground(context),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 8,
        left: 8,
        right: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
            onPressed: () {
              Navigator.pop(context);
              },
          ),
          Stack(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A884),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryBackground(context),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Emily Johnson',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified,
                        color: AppColors.verifiedBadge(context), size: 16),
                  ],
                ),
                Text(
                  'Online now',
                  style: TextStyle(
                    color: const Color(0xFF00A884),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.call_outlined, color: AppColors.primaryText(context)),
          const SizedBox(width: 18),
          Icon(Icons.videocam_outlined, color: AppColors.primaryText(context)),
          const SizedBox(width: 18),
          Icon(Icons.more_vert, color: AppColors.primaryText(context)),
        ],
      ),
    );
  }
}

// ─── Profile Info Card ────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage:
                NetworkImage('https://i.pravatar.cc/150?img=47'),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✦ Spotlight',
                    style: TextStyle(
                        fontSize: 6,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Emily Johnson',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.favorite,
                        color: AppColors.heartColor(context), size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '23',
                      style: TextStyle(
                          color: AppColors.heartColor(context), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.secondaryText(context), size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '0.8 km away',
                      style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Just for fun 😊',
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.buttonColor(context)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: () {},
            child: Text(
              'View Profile',
              style: TextStyle(
                  color: AppColors.buttonColor(context), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tip Banner ───────────────────────────────────────────────────────────────
class _TipBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1654), Color(0xFF1A1035)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6A3DB8), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.heartColor(context).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite, color: AppColors.heartColor(context), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip to unlock magic!',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Show your interest and get noticed ✨',
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: () {},
            child: Text(
              'Send Tip',
              style: TextStyle(
                  color: AppColors.buttonTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Messages List ───────────────────────────────────────────────────────
class _ChatList extends StatelessWidget {
  final List<_Msg> messages = const [
    _Msg(
        text: 'Hey there! 😊\nHow\'s your day going?',
        isMe: false,
        time: '10:30 AM'),
    _Msg(
        text: 'Hey Emily! It\'s going great 😊\nHow about yours?',
        isMe: true,
        time: '10:31 AM',
        isRead: true),
    _Msg(
        text: 'Pretty good! Just finished a\nworkout and now relaxing 🧘',
        isMe: false,
        time: '10:32 AM'),
    _Msg(
        text: 'Nice! I should start working\nout again too 💪',
        isMe: true,
        time: '10:33 AM',
        isRead: true),
    _Msg(
        text: 'You totally should! I can be\nyour motivation 😁',
        isMe: false,
        time: '10:34 AM'),
    _Msg(
        text: 'Haha deal! Maybe we can\nchallenge each other? 😁',
        isMe: true,
        time: '10:35 AM',
        isRead: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // "Today" divider
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Today',
              style: TextStyle(
                  color: AppColors.mutedText(context), fontSize: 12),
            ),
          ),
        ),
        ...messages.map((msg) => _ChatBubble(msg: msg)).toList(),
      ],
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;
  const _Msg(
      {required this.text,
        required this.isMe,
        required this.time,
        this.isRead = false});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onLongPress: () => showMessageActionSheet(
        context,
        messageText: msg.text,
        isMine: msg.isMe,
        onReply: () {},
        onPin: () {},
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: msg.isMe ? ChatTheme.outgoingBubble : ChatTheme.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: const TextStyle(
                    color: ChatTheme.mutedText,
                    fontSize: 10,
                  ),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: msg.isRead ? ChatTheme.readTick : ChatTheme.mutedText,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (msg.isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: bubble,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
          ),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

// ─── Rose Notification Bar ────────────────────────────────────────────────────
class _RoseNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You sent a Rose 🌹',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Emily Johnson',
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.buttonColor(context)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            onPressed: () {},
            child: Text(
              'View Gift',
              style: TextStyle(
                  color: AppColors.buttonColor(context), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Input Bar ─────────────────────────────────────────────────────────
class _BottomInputBar extends StatefulWidget {
  @override
  State<_BottomInputBar> createState() => _BottomInputBarState();
}

class _BottomInputBarState extends State<_BottomInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ChatTheme.barBackground,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => showChatAttachSheet(context),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ChatTheme.inputField,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: ChatTheme.mutedText),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Iconsax.emoji_happy,
                      color: ChatTheme.mutedText, size: 22),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, v, __) {
                      if (v.text.trim().isNotEmpty) {
                        return const SizedBox.shrink();
                      }
                      return const Icon(Iconsax.camera,
                          color: ChatTheme.mutedText, size: 22);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, v, __) {
              final hasText = v.text.trim().isNotEmpty;
              return Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: ChatTheme.micButton,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasText ? Iconsax.send_1 : Iconsax.microphone_2,
                  color: Colors.white,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground(context),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.photo_library_outlined, label: 'Gallery'),
          _NavItem(icon: Icons.camera_alt_outlined, label: 'Camera'),
          _NavItem(icon: Icons.card_giftcard_outlined, label: 'Gift'),
          _NavItem(icon: Icons.mic_none, label: 'Audio'),
          _NavItem(icon: Icons.location_on_outlined, label: 'Location'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52, // 🔥 same width for all items
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondaryText(context),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.secondaryText(context),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center, // helps alignment
              style: TextStyle(
                color: AppColors.mutedText(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}