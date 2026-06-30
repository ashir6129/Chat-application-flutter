import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/api_methods.dart';
import '../../core/app_colors.dart';

/// A marketplace product as returned by the API.
class MarketplaceProductItem {
  final String id;
  final String title;
  final double price;
  final String currency;
  final int stock;
  final String? imageUrl;
  final int resellMarginPct;
  final bool allowResell;

  const MarketplaceProductItem({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.stock,
    this.imageUrl,
    this.resellMarginPct = 0,
    this.allowResell = false,
  });

  factory MarketplaceProductItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceProductItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? '₦',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString(),
      resellMarginPct: (json['resell_margin_pct'] as num?)?.toInt() ?? 0,
      allowResell: json['allow_resell'] == true,
    );
  }

  double get commission => price * resellMarginPct / 100;

  String get formattedPrice =>
      '$currency${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  String get formattedCommission =>
      '+$currency${commission.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
}

/// Returned to the caller when user selects a product.
class AttachedProduct {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String? imageUrl;
  final bool isResell;

  const AttachedProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.isResell = false,
  });

  String get formattedPrice =>
      '$currency${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
}

class AddProductToPostScreen extends StatefulWidget {
  const AddProductToPostScreen({super.key});

  @override
  State<AddProductToPostScreen> createState() => _AddProductToPostScreenState();
}

class _AddProductToPostScreenState extends State<AddProductToPostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  List<MarketplaceProductItem> _myProducts = [];
  List<MarketplaceProductItem> _resellProducts = [];
  bool _loadingMine = true;
  bool _loadingResell = false; // don't load until tab is opened
  bool _resellLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    _loadMyProducts(); // only load first tab eagerly
  }

  void _onTabChanged() {
    if (_tabCtrl.index == 1 && !_resellLoaded) {
      _resellLoaded = true;
      _loadResellProducts();
    }
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyProducts() async {
    try {
      final data = await ApiMethods.authorizedGet('products/my');
      final list = (data['data']?['products'] as List<dynamic>? ?? [])
          .map((e) => MarketplaceProductItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (mounted) setState(() { _myProducts = list; _loadingMine = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMine = false);
    }
  }

  Future<void> _loadResellProducts() async {
    try {
      final data = await ApiMethods.authorizedGet('products/resellable');
      final list = (data['data']?['products'] as List<dynamic>? ?? [])
          .map((e) => MarketplaceProductItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (mounted) setState(() { _resellProducts = list; _loadingResell = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingResell = false);
    }
  }

  void _attach(MarketplaceProductItem item, {bool isResell = false}) {
    Navigator.pop(
      context,
      AttachedProduct(
        id: item.id,
        title: item.title,
        price: item.price,
        currency: item.currency,
        imageUrl: item.imageUrl,
        isResell: isResell,
      ),
    );
  }

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
          'Add Product to Post',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: accent,
          indicatorWeight: 2.5,
          labelColor: accent,
          unselectedLabelColor: AppColors.secondaryText(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'My Products'),
            Tab(text: 'Resellable Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildProductList(
            loading: _loadingMine,
            items: _myProducts,
            emptyMessage: 'You have no listed products yet.\nCreate a listing in the Marketplace.',
            buttonLabel: 'Attach',
            onTap: (item) => _attach(item),
          ),
          _buildProductList(
            loading: _loadingResell,
            items: _resellProducts,
            emptyMessage: 'No resellable products available right now.',
            buttonLabel: 'Resell',
            showCommission: true,
            onTap: (item) => _attach(item, isResell: true),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList({
    required bool loading,
    required List<MarketplaceProductItem> items,
    required String emptyMessage,
    required String buttonLabel,
    required void Function(MarketplaceProductItem) onTap,
    bool showCommission = false,
  }) {
    final accent = AppColors.buttonColor(context);

    if (loading) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText(context), fontSize: 14, height: 1.5),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ProductCard(
        item: items[i],
        buttonLabel: buttonLabel,
        showCommission: showCommission,
        onTap: () => onTap(items[i]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceProductItem item;
  final String buttonLabel;
  final bool showCommission;
  final VoidCallback onTap;

  const _ProductCard({
    required this.item,
    required this.buttonLabel,
    required this.showCommission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Thumbnail ─────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      headers: const {'ngrok-skip-browser-warning': 'true'},
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            const SizedBox(width: 12),
            // ── Info ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.formattedPrice,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Stock: ${item.stock}',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                      if (showCommission && item.resellMarginPct > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.formattedCommission} commission',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ── Attach / Resell Button ────────────────────────────
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withOpacity(0.5)),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.primaryBackground(context),
      child: Icon(Iconsax.bag, color: AppColors.mutedText(context), size: 28),
    );
  }
}
