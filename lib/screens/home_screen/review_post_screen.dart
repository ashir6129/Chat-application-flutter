import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import 'add_product_to_post_screen.dart';

class ReviewPostScreen extends StatelessWidget {
  final String caption;
  final String visibility;
  final String? location;
  final int mediaCount;
  final AttachedProduct? product;
  final VoidCallback onPublish;
  final bool isPublishing;

  const ReviewPostScreen({
    super.key,
    required this.caption,
    required this.visibility,
    this.location,
    required this.mediaCount,
    this.product,
    required this.onPublish,
    required this.isPublishing,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review Post',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: isPublishing ? null : onPublish,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isPublishing ? accent.withOpacity(0.5) : accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isPublishing
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Publish',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Subtitle ────────────────────────────────────────────
            Text(
              "Here's how your post will look to others.",
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
            ),
            const SizedBox(height: 16),

            // ── Post Preview Card ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLine(context), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Author Row ─────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.15),
                        ),
                        child: Icon(Iconsax.user, color: accent, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You',
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBackground(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.global, size: 10, color: accent),
                                      const SizedBox(width: 3),
                                      Text(
                                        visibility,
                                        style: TextStyle(
                                          color: AppColors.secondaryText(context),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Just now',
                                  style: TextStyle(
                                    color: AppColors.mutedText(context),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_horiz, color: AppColors.mutedText(context)),
                    ],
                  ),

                  // ── Caption ────────────────────────────────────────
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      caption,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],

                  // ── Product Banner Strip ───────────────────────────
                  if (product != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBackground(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLine(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.shopping_bag, color: accent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product!.title,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product!.formattedPrice,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Post Details Card ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLine(context), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post details',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailRow(context, Iconsax.global, 'Audience', visibility),
                  const SizedBox(height: 12),
                  _detailRow(
                    context,
                    Iconsax.image,
                    'Media',
                    mediaCount == 0 ? 'None' : '$mediaCount file${mediaCount == 1 ? '' : 's'}',
                  ),
                  if (product != null) ...[
                    const SizedBox(height: 12),
                    _detailRow(context, Iconsax.shopping_bag, 'Tagged product', product!.title),
                  ],
                  if (location != null) ...[
                    const SizedBox(height: 12),
                    _detailRow(context, Iconsax.location, 'Location', location!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Bottom Buttons ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLine(context)),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Post',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: isPublishing ? null : onPublish,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isPublishing ? accent.withOpacity(0.5) : accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isPublishing
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Publish Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryText(context)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
