import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'chat_theme.dart';

Future<void> showMessageActionSheet(
  BuildContext context, {
  required String messageText,
  required bool isMine,
  void Function(String emoji)? onReaction,
  VoidCallback? onReply,
  VoidCallback? onEdit,
  VoidCallback? onForward,
  VoidCallback? onPin,
  VoidCallback? onUnsend,
  VoidCallback? onSilent,
  void Function(String effect)? onEffect,
}) {
  const reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  const effects = ['confetti', 'fireworks', 'hearts', 'sparkles'];

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: ChatTheme.sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: reactions
                    .map(
                      (emoji) => GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          onReaction?.call(emoji);
                        },
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(height: 1, color: ChatTheme.divider),
            _actionTile(
              ctx,
              icon: Iconsax.arrow_left_2,
              label: 'Reply',
              onTap: () {
                Navigator.pop(ctx);
                onReply?.call();
              },
            ),
            _actionTile(
              ctx,
              icon: Iconsax.copy,
              label: 'Copy Text',
              onTap: () {
                Clipboard.setData(ClipboardData(text: messageText));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            if (isMine)
              _actionTile(
                ctx,
                icon: Iconsax.edit_2,
                label: 'Edit Message',
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call();
                },
              ),
            _actionTile(
              ctx,
              icon: Iconsax.arrow_right_3,
              label: 'Forward',
              onTap: () {
                Navigator.pop(ctx);
                onForward?.call();
              },
            ),
            _actionTile(
              ctx,
              icon: Icons.push_pin_outlined,
              label: 'Pin Message',
              onTap: () {
                Navigator.pop(ctx);
                onPin?.call();
              },
            ),
            if (isMine)
              _actionTile(
                ctx,
                icon: Iconsax.trash,
                label: 'Unsend',
                onTap: () {
                  Navigator.pop(ctx);
                  onUnsend?.call();
                },
              ),
            _actionTile(
              ctx,
              icon: Iconsax.notification,
              label: '@silent',
              onTap: () {
                Navigator.pop(ctx);
                onSilent?.call();
              },
            ),
            if (onEffect != null) ...[
              const Divider(height: 1, color: ChatTheme.divider),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Send with effect',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  children: effects.map((effect) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        onEffect.call(effect);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          effect,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Widget _actionTile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 20),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
