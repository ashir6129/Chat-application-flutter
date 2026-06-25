import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/app_colors.dart';

class ShareProfileBottomSheet extends StatelessWidget {
  final String username;
  final String? imageUrl;

  const ShareProfileBottomSheet({
    super.key,
    required this.username,
    this.imageUrl,
  });

  String get profileUrl => "https://zyntra.app/$username";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),

          Text(
            "Share Profile",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Anyone with this link can view your profile",
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.secondaryText(context),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLine(context),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
                  backgroundColor:
                  AppColors.secondaryBackground(context),
                  child: imageUrl == null
                      ? Icon(Icons.person,
                      color: AppColors.secondaryText(context))
                      : null,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@$username",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "zyntra.app/$username",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Iconsax.link_1,
                  size: 18,
                  color: AppColors.secondaryText(context),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _copyLink(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderLine(context),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor(context)
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.copy,
                      size: 18,
                      color: AppColors.buttonColor(context),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Copy profile link",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tap to copy instantly",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: AppColors.secondaryText(context),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: profileUrl));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile link copied"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}