import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';

/// Reference feed toolbar colors — muted actions + dark green Tip pill.
class FeedActionBarStyle {
  FeedActionBarStyle._();

  static const double iconSize = 18;
  static const double labelSize = 13;
  static const FontWeight labelWeight = FontWeight.w500;
  static const double tipIconSize = 14;
  static const double tipLabelSize = 12;
  static const FontWeight tipLabelWeight = FontWeight.w700;

  static Color inactive(BuildContext context) => AppColors.secondaryText(context);

  static Color tipBackground(BuildContext context) => const Color(0xFF132821);

  static Color tipBorder(BuildContext context) =>
      AppColors.buttonColor(context).withValues(alpha: 0.42);

  static Color tipIcon(BuildContext context) => AppColors.buttonColor(context);
}

class FeedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const FeedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: FeedActionBarStyle.iconSize, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: FeedActionBarStyle.labelSize,
                fontWeight: FeedActionBarStyle.labelWeight,
                color: color,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedTipButton extends StatelessWidget {
  final VoidCallback onTap;

  const FeedTipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = FeedActionBarStyle.tipIcon(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: FeedActionBarStyle.tipBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FeedActionBarStyle.tipBorder(context),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.send_2, color: accent, size: FeedActionBarStyle.tipIconSize),
            const SizedBox(width: 6),
            const Text(
              'Tip',
              style: TextStyle(
                color: Colors.white,
                fontSize: FeedActionBarStyle.tipLabelSize,
                fontWeight: FeedActionBarStyle.tipLabelWeight,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedPostActionBar extends StatelessWidget {
  final Widget likeButton;
  final String commentLabel;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onTip;

  const FeedPostActionBar({
    super.key,
    required this.likeButton,
    required this.commentLabel,
    required this.onComment,
    required this.onShare,
    this.onTip,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = FeedActionBarStyle.inactive(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
          child: Row(
            children: [
              likeButton,
              FeedActionButton(
                icon: Iconsax.message,
                label: commentLabel,
                color: inactive,
                onTap: onComment,
              ),
              FeedActionButton(
                icon: Iconsax.export_3,
                label: 'Share',
                color: inactive,
                onTap: onShare,
              ),
              const Spacer(),
              if (onTip != null) FeedTipButton(onTap: onTip!),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.borderLine(context).withValues(alpha: 0.55),
        ),
      ],
    );
  }
}
