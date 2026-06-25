import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import 'marketplace_details_screen.dart';
import 'marketplace_search_screen.dart';

class MarketplaceMapScreen extends StatefulWidget {
  const MarketplaceMapScreen({super.key});

  @override
  State<MarketplaceMapScreen> createState() => _MarketplaceMapScreenState();
}

class _MarketplaceMapScreenState extends State<MarketplaceMapScreen> {
  // Filter states
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _maxDistance = 50.0;
  String _sortBy = 'Recent';
  String _condition = 'All';

  // Selected item overlay state
  Map<String, dynamic>? _selectedProduct;

  static const List<Map<String, dynamic>> _allListings = [
    {
      "name": "iPhone 13",
      "price": "\$799",
      "distance": "2 km away",
      "condition": "Like New",
      "time": "1h ago",
      "image": "https://i.guim.co.uk/img/media/57daf7ac13cd25f41f3eda61abb8dfdd0c446962/216_402_5108_3066/master/5108.jpg?width=1900&dpr=2&s=none&crop=none",
      "x": 0.32,
      "y": 0.27
    },
    {
      "name": "Honda Civic",
      "price": "\$12,000",
      "distance": "5 km away",
      "condition": "Good",
      "time": "3h ago",
      "image": "https://di-uploads-pod1.dealerinspire.com/hondaoflincoln/uploads/2018/08/01___2019_Honda_Civic_Coupe-768x531.jpg",
      "x": 0.58,
      "y": 0.20
    },
    {
      "name": "Sofa Set",
      "price": "\$300",
      "distance": "1.5 km away",
      "condition": "Used",
      "time": "2h ago",
      "image": "https://dukaan.b-cdn.net/700x700/webp/upload_file_service/26b19304-17df-456c-b463-094938619439/whatsapp-image-2023-02-20-at-12-53-22-am.jpeg",
      "x": 0.20,
      "y": 0.48
    },
    {
      "name": "MacBook Pro M2",
      "price": "\$1200",
      "distance": "3 km away",
      "condition": "Like New",
      "image": "https://techcrunch.com/wp-content/uploads/2024/11/CMC_8144.jpg?resize=1280,853",
      "x": 0.52,
      "y": 0.34
    },
    {
      "name": "Mountain Bike",
      "price": "\$450",
      "distance": "6 km away",
      "condition": "Used",
      "image": "https://i.pinimg.com/1200x/12/51/6c/12516c664cd5de304da876b8703e0dab.jpg",
      "x": 0.41,
      "y": 0.56
    },
    {
      "name": "AirPods Pro",
      "price": "\$180",
      "distance": "2.5 km away",
      "condition": "Like New",
      "image": "https://i.pinimg.com/1200x/71/1b/00/711b00dc657c11b15eb894f07eae276f.jpg",
      "x": 0.26,
      "y": 0.38
    },
    {
      "name": "Dining Table",
      "price": "\$250",
      "distance": "4 km away",
      "condition": "Good",
      "image": "https://i.pinimg.com/736x/99/58/39/9958394ff4d9b24871996ba317e613fd.jpg",
      "x": 0.45,
      "y": 0.25
    },
  ];

  // Helper getters to parse and filter listings
  List<Map<String, dynamic>> get _filteredListings {
    List<Map<String, dynamic>> list = List.from(_allListings);

    // 1. Price Filter
    list = list.where((item) {
      final priceStr = item['price'] as String;
      final price = double.tryParse(priceStr.replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
      // Handle bounds for items larger than max slider value ($2000)
      if (_priceRange.end >= 2000) {
        return price >= _priceRange.start;
      }
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // 2. Distance Filter
    list = list.where((item) {
      final distStr = item['distance'] as String;
      final dist = double.tryParse(distStr.split(' ')[0]) ?? 0.0;
      return dist <= _maxDistance;
    }).toList();

    // 3. Condition Filter
    if (_condition != 'All') {
      list = list.where((item) {
        return item['condition'] == _condition;
      }).toList();
    }

    // 4. Sorting logic
    if (_sortBy == 'Nearest') {
      list.sort((a, b) {
        final distA = double.tryParse((a['distance'] as String).split(' ')[0]) ?? 0.0;
        final distB = double.tryParse((b['distance'] as String).split(' ')[0]) ?? 0.0;
        return distA.compareTo(distB);
      });
    } else if (_sortBy == 'Price: Low to High') {
      list.sort((a, b) {
        final priceA = double.tryParse((a['price'] as String).replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
        final priceB = double.tryParse((b['price'] as String).replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (_sortBy == 'Price: High to Low') {
      list.sort((a, b) {
        final priceA = double.tryParse((a['price'] as String).replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
        final priceB = double.tryParse((b['price'] as String).replaceAll('\$', '').replaceAll(',', '')) ?? 0.0;
        return priceB.compareTo(priceA);
      });
    }

    return list;
  }

  void _openFilters() {
    showMarketplaceFilterSheet(
      context,
      priceRange: _priceRange,
      maxDistance: _maxDistance,
      sortBy: _sortBy,
      condition: _condition,
      onApply: (newPrice, newDist, newSort, newCond) {
        setState(() {
          _priceRange = newPrice;
          _maxDistance = newDist;
          _sortBy = newSort;
          _condition = newCond;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredListings;

    // Reset selection if the selected product gets filtered out
    if (_selectedProduct != null && !filtered.contains(_selectedProduct)) {
      _selectedProduct = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF132233),
      body: Stack(
        children: [
          // Map Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(context),
            ),
          ),

          // Pulsing User Location dot
          Positioned(
            left: MediaQuery.of(context).size.width * 0.46,
            top: MediaQuery.of(context).size.height * 0.41,
            child: const _LocationDot(),
          ),

          // Price badges/pins
          ...filtered.map((item) {
            final double x = item['x'] as double;
            final double y = item['y'] as double;
            final isSelected = _selectedProduct == item;
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: _MapPin(
                price: item['price'] as String,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedProduct = item;
                  });
                },
              ),
            );
          }),

          // Top Floating Navigation & Search Controls
          _buildTopFloatingBar(context),

          // Floating Preview Card when an item is selected
          if (_selectedProduct != null)
            _buildProductPreviewCard(_selectedProduct!),

          // Draggable Bottom sheet overlay showing listings
          _buildBottomListSheet(context, filtered),
        ],
      ),
    );
  }

  Widget _buildTopFloatingBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2D3A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Search bar
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2D3A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Iconsax.search_normal,
                    color: AppColors.secondaryText(context),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search on map',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: _openFilters,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2D3A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.setting_4,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreviewCard(Map<String, dynamic> item) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 64,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarketplaceProductDetailScreen(product: item),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2D3A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                  item['image'] as String,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 58,
                    height: 58,
                    color: const Color(0xFF15222E),
                    child: Icon(
                      Iconsax.image,
                      color: AppColors.buttonColor(context),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['price'] as String,
                      style: const TextStyle(
                        color: Color(0xFF00A884),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 11,
                          color: AppColors.secondaryText(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['distance'] as String,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProduct = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF00A884),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomListSheet(BuildContext context, List<Map<String, dynamic>> filteredList) {
    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.22,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15222E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredList.length} Listings Nearby',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    InkWell(
                      onTap: _openFilters,
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 16,
                            color: AppColors.secondaryText(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sort',
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withOpacity(0.06),
                height: 1,
                thickness: 1,
              ),
              // List View
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildBottomSheetCard(context, item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetCard(BuildContext context, Map<String, dynamic> item) {
    final isSelected = _selectedProduct == item;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = item;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2D3A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A884) : Colors.white.withOpacity(0.05),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                item['image'] as String,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 76,
                    height: 76,
                    color: const Color(0xFF15222E),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 76,
                  height: 76,
                  color: const Color(0xFF15222E),
                  child: Icon(
                    Iconsax.image,
                    color: AppColors.buttonColor(context),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['price'] as String,
                    style: const TextStyle(
                      color: Color(0xFF00A884),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 11,
                        color: AppColors.secondaryText(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['distance'] as String,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121C26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['condition'] as String,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _MapPin extends StatelessWidget {
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapPin({
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00A884) : const Color(0xFF1C2D3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          price,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LocationDot extends StatefulWidget {
  const _LocationDot();

  @override
  State<_LocationDot> createState() => _LocationDotState();
}

class _LocationDotState extends State<_LocationDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2196F3).withOpacity(0.15),
          ),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2196F3),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.5),
                  blurRadius: _animation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final BuildContext context;
  _MapGridPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F354D).withOpacity(0.2)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 45) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += 45) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
