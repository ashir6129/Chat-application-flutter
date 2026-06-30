import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/creators_messages_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_message_screen.dart';
import '../../core/app_colors.dart';
import 'chat/create_group_page_screen.dart';
import 'main_message_screen/main_message_screen.dart';
import 'switch_chat_sheet.dart';

/// All message spaces with Switch chat — Chat, Creators, Marketplace.
class MessagesHubScreen extends StatefulWidget {
  final ChatSpace initialSpace;

  const MessagesHubScreen({
    super.key,
    this.initialSpace = ChatSpace.general,
  });

  @override
  State<MessagesHubScreen> createState() => _MessagesHubScreenState();
}

class _MessagesHubScreenState extends State<MessagesHubScreen> {
  late ChatSpace _space;
  late final Set<ChatSpace> _visited;

  @override
  void initState() {
    super.initState();
    _space = widget.initialSpace;
    _visited = {_space};
  }

  void _openSwitchChat() {
    showSwitchChatSheet(
      context,
      current: _space,
      onSelected: (s) => setState(() {
        _space = s;
        _visited.add(s);
      }),
    );
  }

  void _onCompose(BuildContext context) {
    if (_space == ChatSpace.general) {
      showCreateChatSheet(context);
    }
  }

  Widget _tabFor(ChatSpace space) {
    switch (space) {
      case ChatSpace.general:
        return MainMessageScreen(
          key: const PageStorageKey('chat_general'),
          embedded: true,
        );
      case ChatSpace.creators:
        return CreatorsMainMessageScreen(
          key: const PageStorageKey('chat_creators'),
          embedded: true,
        );
      case ChatSpace.marketplace:
        return MarketplaceMessagesScreen(
          key: const PageStorageKey('chat_marketplace'),
          embedded: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HubHeader(
              space: _space,
              onBack: () => Navigator.pop(context),
              onSwitchChat: _openSwitchChat,
              onCompose: () => _onCompose(context),
            ),
            Expanded(
              child: IndexedStack(
                index: _space.index,
                children: ChatSpace.values.map((space) {
                  if (!_visited.contains(space)) {
                    return const SizedBox.shrink();
                  }
                  return _tabFor(space);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  final ChatSpace space;
  final VoidCallback onBack;
  final VoidCallback onSwitchChat;
  final VoidCallback onCompose;

  const _HubHeader({
    required this.space,
    required this.onBack,
    required this.onSwitchChat,
    required this.onCompose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Iconsax.arrow_left,
                  color: AppColors.primaryText(context),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.title,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: onSwitchChat,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Switch chat',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.buttonColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_down_1,
                            size: 14,
                            color: AppColors.buttonColor(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIconBtn(
                icon: Iconsax.filter,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _HeaderIconBtn(
                icon: Iconsax.edit,
                onTap: onCompose,
              ),
              const SizedBox(width: 8),
              _HeaderIconBtn(
                icon: Icons.more_vert_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryText(context)),
      ),
    );
  }
}
