import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

enum ChatSpace { general, creators, marketplace }

extension ChatSpaceMeta on ChatSpace {
  String get title => switch (this) {
        ChatSpace.general => 'Chat',
        ChatSpace.creators => 'Creators',
        ChatSpace.marketplace => 'Marketplace',
      };

  String get subtitle => switch (this) {
        ChatSpace.general => 'General conversations',
        ChatSpace.creators => 'Creator-focused chats',
        ChatSpace.marketplace => 'Buy & sell conversations',
      };

  IconData get icon => switch (this) {
        ChatSpace.general => Iconsax.message,
        ChatSpace.creators => Iconsax.star1,
        ChatSpace.marketplace => Iconsax.shopping_bag,
      };
}

void showSwitchChatSheet(
  BuildContext context, {
  required ChatSpace current,
  required ValueChanged<ChatSpace> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _SwitchChatSheet(
      current: current,
      onSelected: (space) {
        Navigator.pop(context);
        onSelected(space);
      },
    ),
  );
}

class _SwitchChatSheet extends StatelessWidget {
  final ChatSpace current;
  final ValueChanged<ChatSpace> onSelected;

  const _SwitchChatSheet({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Switch chat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            ...ChatSpace.values.map(
              (space) => _SpaceTile(
                space: space,
                selected: space == current,
                onTap: () => onSelected(space),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceTile extends StatelessWidget {
  final ChatSpace space;
  final bool selected;
  final VoidCallback onTap;

  const _SpaceTile({
    required this.space,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                space.icon,
                color: AppColors.buttonColor(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                  Text(
                    space.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Iconsax.tick_circle5,
                color: AppColors.buttonColor(context),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
