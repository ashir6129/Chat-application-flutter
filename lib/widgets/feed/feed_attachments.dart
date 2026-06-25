import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

/// Product card shown below post actions when user attached a product.
class FeedProductAttachmentCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final String currency;
  final int? stock;
  final VoidCallback? onBuyNow;

  const FeedProductAttachmentCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.currency = '₹',
    this.stock,
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = stock != null && stock == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLine(context), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.secondaryBackground(context),
                  child: Icon(Iconsax.bag,
                      size: 36, color: AppColors.mutedText(context)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: outOfStock ? null : onBuyNow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: outOfStock
                            ? AppColors.mutedText(context)
                            : AppColors.buttonColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        outOfStock ? 'Sold Out' : 'Buy Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sponsored / banner strip below post actions.
class FeedBannerAdCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String ctaLabel;

  const FeedBannerAdCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.ctaLabel = 'Learn more',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.buttonColor(context).withOpacity(0.15),
              AppColors.buttonColor(context).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.buttonColor(context).withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
                child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                  imageUrl!,
                  width: 88,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 88,
                    height: 72,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsored',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                ctaLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
