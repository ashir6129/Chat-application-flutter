import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class UserAllProductsTab extends StatelessWidget {
  const UserAllProductsTab({super.key});

  static const List<_ProductData> _products = [
    _ProductData(uid: 'pr1', name: 'Handcrafted Bamboo Lamp',       price: 1299.00, imageUrl: 'https://picsum.photos/seed/p1/400/400'),
    _ProductData(uid: 'pr2', name: 'Limited Edition Zyntra Hoodie', price: 2499.00, imageUrl: 'https://picsum.photos/seed/p2/400/400'),
    _ProductData(uid: 'pr3', name: 'Minimalist Leather Wallet',     price: 799.00,  imageUrl: 'https://picsum.photos/seed/p3/400/400'),
    _ProductData(uid: 'pr4', name: 'Ceramic Coffee Mug Set',        price: 549.00,  imageUrl: 'https://picsum.photos/seed/p4/400/400'),
    _ProductData(uid: 'pr5', name: 'Wooden Phone Stand',            price: 349.00,  imageUrl: 'https://picsum.photos/seed/p5/400/400'),
    _ProductData(uid: 'pr6', name: 'Scented Soy Candle Bundle',     price: 699.00,  imageUrl: 'https://picsum.photos/seed/p6/400/400'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.bag, size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              'No products yet',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return GestureDetector(
          onTap: () {}, // TODO: navigate to product detail
          child: Stack(
            fit: StackFit.expand,
            children: [

              Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.secondaryBackground(context),
                  child: Icon(Iconsax.bag,
                      color: AppColors.mutedText(context), size: 32),
                ),
              ),

              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Iconsax.bag,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.currency}${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class _ProductData {
  final String uid;
  final String name;
  final double price;
  final String imageUrl;
  final String currency;

  const _ProductData({
    required this.uid,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.currency = '₹',
  });
}