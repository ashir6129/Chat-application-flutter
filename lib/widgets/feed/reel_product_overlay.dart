import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Product card or banner ad overlay at bottom of reel feed.
class ReelProductOverlay extends StatelessWidget {
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final String? earnAmount;
  final String? bannerTitle;
  final String? bannerSubtitle;
  final String? bannerImage;
  final VoidCallback? onBuyNow;
  final VoidCallback? onBannerTap;

  const ReelProductOverlay.product({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    this.earnAmount,
    this.onBuyNow,
  })  : bannerTitle = null,
        bannerSubtitle = null,
        bannerImage = null,
        onBannerTap = null;

  const ReelProductOverlay.banner({
    super.key,
    required this.bannerTitle,
    required this.bannerSubtitle,
    this.bannerImage,
    this.onBannerTap,
  })  : productName = null,
        productPrice = null,
        productImage = null,
        earnAmount = null,
        onBuyNow = null;

  bool get hasProduct => productName != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasProduct ? onBuyNow : onBannerTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: hasProduct ? _productRow() : _bannerRow(),
      ),
    );
  }

  Widget _productRow() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            productImage!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              color: Colors.white12,
              child: const Icon(Iconsax.bag, color: Colors.white54, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                productPrice!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (earnAmount != null)
                Text(
                  'Earn $earnAmount',
                  style: const TextStyle(
                    color: Color(0xFF43A047),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Buy Now',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerRow() {
    return Row(
      children: [
        if (bannerImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              bannerImage!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        if (bannerImage != null) const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sponsored',
                style: TextStyle(
                  color: Color(0xFF43A047),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                bannerTitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                bannerSubtitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Iconsax.arrow_right_3, color: Colors.white54, size: 18),
      ],
    );
  }
}
