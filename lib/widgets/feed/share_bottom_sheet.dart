import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class ShareBottomSheet extends StatelessWidget {
  final String postUid;
  final String authorName;
  final Function(String platform) onShareSelected;

  const ShareBottomSheet({
    super.key,
    required this.postUid,
    required this.authorName,
    required this.onShareSelected,
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
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.mutedText(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Text(
              'Share Post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(context),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Share ${authorName}\'s post',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText(context),
              ),
            ),

            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ShareItem(
                  icon: Iconsax.link_1, // 🔗 copy link
                  label: 'Copy Link',
                  onTap: () {
                    Navigator.pop(context);
                    onShareSelected('copy');
                  },
                ),
                _ShareItem(
                  icon: Iconsax.message, // 💬 message
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    onShareSelected('message');
                  },
                ),
                _ShareItem(
                  icon: Iconsax.export_3, // 📤 share
                  label: 'More',
                  onTap: () {
                    Navigator.pop(context);
                    onShareSelected('more');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderLine(context)),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Share Item
// ─────────────────────────────────────────────

class _ShareItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}