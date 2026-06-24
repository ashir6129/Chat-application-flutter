import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

Future<void> showCommentActionSheet(
  BuildContext context, {
  required String commentBody,
  required bool isOwn,
  void Function(String emoji)? onReaction,
  VoidCallback? onReply,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onReport,
}) {
  const reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '👏'];

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(ctx),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mutedText(ctx),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
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
            Divider(height: 1, color: AppColors.borderLine(ctx)),
            if (onReply != null)
              _tile(
                ctx,
                icon: Iconsax.arrow_left_2,
                label: 'Reply',
                onTap: () {
                  Navigator.pop(ctx);
                  onReply();
                },
              ),
            _tile(
              ctx,
              icon: Iconsax.copy,
              label: 'Copy',
              onTap: () {
                Clipboard.setData(ClipboardData(text: commentBody));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                );
              },
            ),
            if (isOwn)
              _tile(
                ctx,
                icon: Iconsax.edit_2,
                label: 'Edit',
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call();
                },
              ),
            if (isOwn)
              _tile(
                ctx,
                icon: Iconsax.trash,
                label: 'Delete',
                destructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete?.call();
                },
              ),
            if (!isOwn)
              _tile(
                ctx,
                icon: Iconsax.flag,
                label: 'Report',
                destructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  onReport?.call();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

Widget _tile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool destructive = false,
}) {
  final color = destructive ? Colors.redAccent : AppColors.primaryText(context);

  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 20),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
