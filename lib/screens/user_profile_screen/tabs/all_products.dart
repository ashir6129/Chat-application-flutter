import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/api_methods.dart';

class UserAllProductsTab extends StatefulWidget {
  final String? userId;
  final bool isOwnProfile;

  const UserAllProductsTab({
    super.key,
    this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<UserAllProductsTab> createState() => _UserAllProductsTabState();
}

class _UserAllProductsTabState extends State<UserAllProductsTab> {
  List<_ProductData> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = widget.userId;
      if (userId == null) {
        setState(() {
          _loading = false;
          _products = [];
        });
        return;
      }

      final data = await ApiMethods.authorizedGet('products/user/$userId');
      final products = data['data']?['products'] as List<dynamic>? ?? [];

      if (!mounted) return;
      setState(() {
        _products = products.map((p) => _ProductData.fromApi(p as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load products';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.mutedText(context))),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadProducts, child: const Text('Retry')),
          ],
        ),
      );
    }

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

              Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
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

  factory _ProductData.fromApi(Map<String, dynamic> json) {
    return _ProductData(
      uid: json['id'] as String? ?? '',
      name: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      currency: json['currency'] as String? ?? '₹',
    );
  }
}