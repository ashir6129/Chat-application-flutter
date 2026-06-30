import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';
import '../../../../widgets/message/chat_theme.dart';
import '../../../../widgets/message/message_action_sheet.dart';
import '../../../../core/offline_cache_service.dart';
import '../message_screen/chat/chat_attach_sheet.dart';

class MarketplaceChatScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String avatar;
  final bool isOnline;
  final String productTitle;
  final String productImage;
  final String productPrice;
  final bool iAmSeller;

  const MarketplaceChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.avatar,
    required this.isOnline,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.iAmSeller,
  });

  @override
  State<MarketplaceChatScreen> createState() => _MarketplaceChatScreenState();
}

class _MarketplaceChatScreenState extends State<MarketplaceChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Demo messages
  late List<Map<String, dynamic>> _messages;
  String? _pinnedMessageId;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'id': '1',
        'text': 'Hi! Is this still available?',
        'isMine': !widget.iAmSeller,
        'time': '10:10 AM',
        'type': 'text',
        'status': 'read',
      },
      {
        'id': '2',
        'text': 'Yes it\'s available! In great condition.',
        'isMine': widget.iAmSeller,
        'time': '10:11 AM',
        'type': 'text',
        'status': 'read',
      },
      {
        'id': '3',
        'text': 'Can you share more photos?',
        'isMine': !widget.iAmSeller,
        'time': '10:12 AM',
        'type': 'text',
        'status': 'read',
      },
      {
        'id': 'offer1',
        'isMine': !widget.iAmSeller,
        'time': '10:14 AM',
        'type': 'offer',
        'offerAmount': '₹48,000',
        'offerStatus': 'pending', // pending / accepted / rejected
      },
      {
        'id': '4',
        'text': 'Hmm let me think about it.',
        'isMine': widget.iAmSeller,
        'time': '10:15 AM',
        'type': 'text',
        'status': 'read',
      },
      {
        'id': '5',
        'text': 'Is this still available?',
        'isMine': !widget.iAmSeller,
        'time': '10:15 AM',
        'type': 'text',
        'status': 'sent',
      },
    ];
    _pinnedMessageId = OfflineCacheService.getJson('pinned_${widget.chatId}')?.toString();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'id': DateTime.now().toString(),
        'text': text,
        'isMine': true,
        'time': _currentTime(),
        'type': 'text',
        'status': 'sent',
      });
    });
    _inputController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendQuickReply(String text) {
    setState(() {
      _messages.add({
        'id': DateTime.now().toString(),
        'text': text,
        'isMine': true,
        'time': _currentTime(),
        'type': 'text',
        'status': 'sent',
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _makeOffer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MakeOfferSheet(
        currentPrice: widget.productPrice,
        onSend: (amount) {
          Navigator.pop(context);
          setState(() {
            _messages.add({
              'id': DateTime.now().toString(),
              'isMine': true,
              'time': _currentTime(),
              'type': 'offer',
              'offerAmount': amount,
              'offerStatus': 'pending',
            });
          });
        },
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: AppBar(
        backgroundColor: ChatTheme.barBackground,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.avatar),
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBackground(context),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.iAmSeller ? 'Interested Buyer' : 'Seller',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, color: AppColors.primaryText(context)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.primaryText(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Product Context Card ─────────────────────────────────────────
          _ProductContextCard(
            title: widget.productTitle,
            imageUrl: widget.productImage,
            price: widget.productPrice,
            iAmSeller: widget.iAmSeller,
          ),

          if (_pinnedMessageId != null) _buildPinnedBar(AppColors.buttonColor(context)),

          // ── Messages ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isMine = msg['isMine'] as bool;

                if (msg['type'] == 'offer') {
                  return _OfferBubble(
                    isMine: isMine,
                    offerAmount: msg['offerAmount'],
                    offerStatus: msg['offerStatus'],
                    time: msg['time'],
                    productTitle: widget.productTitle,
                    onAccept: isMine
                        ? null
                        : () {
                      setState(() => msg['offerStatus'] = 'accepted');
                    },
                    onReject: isMine
                        ? null
                        : () {
                      setState(() => msg['offerStatus'] = 'rejected');
                    },
                  );
                }

                return _MessageBubble(
                  text: msg['text'],
                  time: msg['time'],
                  isMine: isMine,
                  status: msg['status'],
                  avatarUrl: isMine ? null : widget.avatar,
                  onPin: () {
                    setState(() => _pinnedMessageId = msg['id']);
                    OfflineCacheService.setJson('pinned_${widget.chatId}', msg['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message pinned'), duration: Duration(seconds: 1)),
                    );
                  },
                );
              },
            ),
          ),

          // ── Quick Replies (only for buyer) ───────────────────────────────
          if (!widget.iAmSeller)
            _QuickReplies(onTap: _sendQuickReply),

          // ── Input Bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            decoration: const BoxDecoration(
              color: ChatTheme.barBackground,
              border: Border(top: BorderSide(color: ChatTheme.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (!widget.iAmSeller)
                    GestureDetector(
                      onTap: _makeOffer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: ChatTheme.micButton),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_offer_outlined,
                                color: ChatTheme.micButton, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Offer',
                              style: TextStyle(
                                color: ChatTheme.micButton,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => showChatAttachSheet(context),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      decoration: BoxDecoration(
                        color: ChatTheme.inputField,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 4,
                              minLines: 1,
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
                            valueListenable: _inputController,
                            builder: (_, v, __) {
                              if (v.text.trim().isNotEmpty) {
                                return const SizedBox.shrink();
                              }
                              return const Padding(
                                padding: EdgeInsets.only(left: 4, right: 4),
                                child: Icon(Iconsax.camera,
                                    color: ChatTheme.mutedText, size: 22),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _inputController,
                    builder: (_, value, __) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: hasText ? _sendMessage : null,
                        child: Container(
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
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedBar(Color accent) {
    final msg = _messages.firstWhere(
          (m) => m['id'] == _pinnedMessageId,
          orElse: () => <String, dynamic>{},
        );
    final text = msg['text'] as String? ?? 'Pinned Message';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: ChatTheme.barBackground,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pinned Message', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: ChatTheme.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              OfflineCacheService.remove('pinned_${widget.chatId}');
              setState(() => _pinnedMessageId = null);
            },
            child: const Icon(Icons.close, color: ChatTheme.mutedText, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Product Context Card ─────────────────────────────────────────────────────
class _ProductContextCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String price;
  final bool iAmSeller;

  const _ProductContextCard({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.iAmSeller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLine(context)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.primaryBackground(context),
                  child: Icon(Iconsax.image,
                      color: AppColors.buttonColor(context), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: TextStyle(
                      color: AppColors.buttonColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "View",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Replies ────────────────────────────────────────────────────────────
class _QuickReplies extends StatelessWidget {
  final void Function(String) onTap;

  const _QuickReplies({required this.onTap});

  static const replies = [
    'Is this available?',
    'What\'s your best price?',
    'Can I see more photos?',
    'Where are you located?',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => onTap(replies[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLine(context)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                replies[i],
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Offer Bubble ─────────────────────────────────────────────────────────────
class _OfferBubble extends StatelessWidget {
  final bool isMine;
  final String offerAmount;
  final String offerStatus; // pending / accepted / rejected
  final String time;
  final String productTitle;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _OfferBubble({
    required this.isMine,
    required this.offerAmount,
    required this.offerStatus,
    required this.time,
    required this.productTitle,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (offerStatus) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Offer Accepted';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Offer Declined';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Offer Pending';
        statusIcon = Icons.pending_outlined;
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isMine ? 'You sent an offer' : '${productTitle.split(' ')[0]} received an offer',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Text(
                offerAmount,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // Status
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Accept/Reject buttons (only for receiver when pending)
            if (!isMine && offerStatus == 'pending')
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onReject,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: onAccept,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Time
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                time,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;
  final String? status;
  final String? avatarUrl;
  final VoidCallback? onPin;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMine,
    this.status,
    this.avatarUrl,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onLongPress: () => showMessageActionSheet(
        context,
        messageText: text,
        isMine: isMine,
        onReply: () {},
        onPin: onPin,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? ChatTheme.outgoingBubble : ChatTheme.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: ChatTheme.mutedText,
                    fontSize: 10,
                  ),
                ),
                if (isMine && status != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    status == 'read' ? Icons.done_all : Icons.done,
                    size: 14,
                    color: status == 'read'
                        ? ChatTheme.readTick
                        : ChatTheme.mutedText,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (isMine) {
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
          if (avatarUrl != null)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(avatarUrl!),
            ),
          if (avatarUrl != null) const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

// ─── Make Offer Sheet ─────────────────────────────────────────────────────────
class _MakeOfferSheet extends StatefulWidget {
  final String currentPrice;
  final void Function(String amount) onSend;

  const _MakeOfferSheet({required this.currentPrice, required this.onSend});

  @override
  State<_MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<_MakeOfferSheet> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make an Offer',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Listed price: ${widget.currentPrice}',
            style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.secondaryText(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLine(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.buttonColor(context), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final val = _ctrl.text.trim();
                if (val.isNotEmpty) {
                  widget.onSend('₹$val');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Offer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}