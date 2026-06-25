import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketplaceProductDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class MarketplaceProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const MarketplaceProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<MarketplaceProductDetailScreen> createState() =>
      _MarketplaceProductDetailScreenState();
}

class _MarketplaceProductDetailScreenState
    extends State<MarketplaceProductDetailScreen> {
  int _currentImage = 0;
  bool _isSaved = false;
  bool _descExpanded = false;

  // Mock multi-image support — use product image + fallbacks
  late final List<String> _images;

  // Mock "You Might Be Interested In" listings
  final List<Map<String, dynamic>> _suggested = [
    {
      "name": "55\" Samsung 4K TV",
      "price": "\$400",
      "distance": "1.8 miles away",
      "image":
      "https://i.pinimg.com/1200x/71/1b/00/711b00dc657c11b15eb894f07eae276f.jpg",
    },
    {
      "name": "Apple Watch Series 7",
      "price": "\$320",
      "distance": "2 miles away",
      "image":
      "https://i.pinimg.com/1200x/12/51/6c/12516c664cd5de304da876b8703e0dab.jpg",
    },
    {
      "name": "Sony Headphones",
      "price": "\$150",
      "distance": "3 miles away",
      "image":
      "https://techcrunch.com/wp-content/uploads/2024/11/CMC_8144.jpg?resize=1280,853",
    },
    {
      "name": "iPad Pro 11\"",
      "price": "\$650",
      "distance": "0.5 miles away",
      "image":
      "https://i.guim.co.uk/img/media/57daf7ac13cd25f41f3eda61abb8dfdd0c446962/216_402_5108_3066/master/5108.jpg?width=1900&dpr=2&s=none&crop=none",
    },
  ];

  @override
  void initState() {
    super.initState();
    final img = widget.product["image"] as String? ?? '';
    _images = [img, img, img, img]; // replace with real multi-image list
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    HapticFeedback.lightImpact();
  }

  void _showMessageSheet(BuildContext ctx) {
    final ctrl = TextEditingController(
        text: 'Hi! Is this still available?');
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBackground(ctx),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderLine(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Message Seller',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText(ctx),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              style: TextStyle(color: AppColors.primaryText(ctx)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryBackground(ctx),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle:
                TextStyle(color: AppColors.secondaryText(ctx)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor(ctx),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Send Message',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _conditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'like new':
        return Colors.green.shade600;
      case 'good':
        return Colors.orange.shade600;
      case 'used':
        return Colors.grey.shade500;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final condition = p["condition"] as String? ?? 'Used';
    final condColor = _conditionColor(condition);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Gallery ─────────────────────────────────────────
                _ImageGallery(
                  images: _images,
                  current: _currentImage,
                  onPageChanged: (i) => setState(() => _currentImage = i),
                  totalCount: _images.length,
                  condition: condition,
                  condColor: condColor,
                ),

                // ── Price + Title ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p["price"] ?? '',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.buttonColor(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p["name"] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Iconsax.location,
                              size: 13,
                              color: AppColors.secondaryText(context)),
                          const SizedBox(width: 4),
                          Text(
                            p["distance"] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                _Divider(),

                // ── Seller Info ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: const NetworkImage(
                            'https://i.pravatar.cc/80?img=12'),
                        backgroundColor:
                        AppColors.secondaryBackground(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p["sellerName"] ?? 'Henry Thompson',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Listed ${p["time"] ?? "2 hours ago"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showMessageSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Iconsax.message, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Rating + badges ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      Text(
                        ' (25)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryText(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF1976D2), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        'Verified Seller',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),

                _Divider(),

                // ── Description ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p["description"] ??
                            '• ${p["name"] ?? "Item"}, ${p["condition"] ?? "Good"} condition.\n• Original box and charger included.\n• No scratches or dents.\n• Open to reasonable offers.',
                        maxLines: _descExpanded ? null : 3,
                        overflow: _descExpanded
                            ? null
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.secondaryText(context),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _descExpanded = !_descExpanded),
                        child: Text(
                          _descExpanded ? 'Show less' : 'Read more >',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                _Divider(),

                // ── Sponsored Ad ──────────────────────────────────────────
                _SponsoredAd(),

                _Divider(),

                // ── You Might Be Interested In ────────────────────────────
                _SuggestedSection(listings: _suggested),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Gallery with dots
// ─────────────────────────────────────────────────────────────────────────────
class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final int current;
  final ValueChanged<int> onPageChanged;
  final int totalCount;
  final String condition;
  final Color condColor;

  const _ImageGallery({
    required this.images,
    required this.current,
    required this.onPageChanged,
    required this.totalCount,
    required this.condition,
    required this.condColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (ctx, i) => Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
              images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.secondaryBackground(ctx),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.secondaryBackground(context),
                child: Center(
                  child: Icon(Iconsax.image,
                      size: 36,
                      color: AppColors.mutedText(context)),
                ),
              ),
            ),
          ),

          // Image counter top-right
          Positioned(
            top: 10,
            right: 14,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${current + 1}/$totalCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Condition badge bottom-left
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: condColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Dot indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == current ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == current
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsored Ad Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SponsoredAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsored',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                    'https://i.pinimg.com/736x/99/58/39/9958394ff4d9b24871996ba317e613fd.jpg',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.borderLine(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remodel Your Kitchen!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Check out our renovation services. Transform your kitchen today.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText(context),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// You Might Be Interested In
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestedSection extends StatelessWidget {
  final List<Map<String, dynamic>> listings;

  const _SuggestedSection({required this.listings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You Might Be Interested In',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText(context),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.buttonColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final item = listings[i];
              return GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                          item["image"],
                          height: 100,
                          width: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: AppColors.secondaryBackground(ctx),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item["price"],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.buttonColor(ctx),
                        ),
                      ),
                      Text(
                        item["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryText(ctx),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item["distance"],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryText(ctx),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.borderLine(context),
    );
  }
}