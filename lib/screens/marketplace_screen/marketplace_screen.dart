import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_search_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_map_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_see_all_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/create_product_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/marketplace_details_screen.dart';
import 'package:zyntraplus/screens/message_screen/messages_hub_screen.dart';
import 'package:zyntraplus/screens/message_screen/switch_chat_sheet.dart';
import '../../core/app_colors.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = const [
    {"name": "All", "icon": Iconsax.grid_2},
    {"name": "Electronics", "icon": Iconsax.monitor},
    {"name": "Vehicles", "icon": Iconsax.car},
    {"name": "Home & Garden", "icon": Iconsax.home},
    {"name": "More", "icon": Iconsax.more},
  ];

  final List<Map<String, dynamic>> nearbyPopular = [
    {
      "name": "iPhone 13",
      "price": "\$799",
      "distance": "2 km away",
      "condition": "Like New",
      "time": "1h ago",
      "image": "https://i.guim.co.uk/img/media/57daf7ac13cd25f41f3eda61abb8dfdd0c446962/216_402_5108_3066/master/5108.jpg?width=1900&dpr=2&s=none&crop=none"
    },
    {
      "name": "Honda Civic",
      "price": "\$12,000",
      "distance": "5 km away",
      "condition": "Good",
      "time": "3h ago",
      "image": "https://di-uploads-pod1.dealerinspire.com/hondaoflincoln/uploads/2018/08/01___2019_Honda_Civic_Coupe-768x531.jpg"
    },
    {
      "name": "Sofa Set",
      "price": "\$300",
      "distance": "1.5 km away",
      "condition": "Used",
      "time": "2h ago",
      "image": "https://dukaan.b-cdn.net/700x700/webp/upload_file_service/26b19304-17df-456c-b463-094938619439/whatsapp-image-2023-02-20-at-12-53-22-am.jpeg"
    },
  ];

  final List<Map<String, dynamic>> nearbyListings = [
    {
      "name": "MacBook Pro M2",
      "price": "\$1200",
      "distance": "3 km away",
      "image": "https://techcrunch.com/wp-content/uploads/2024/11/CMC_8144.jpg?resize=1280,853",
      "condition": "Like New",
      "time": "2h ago",
      "category": "Electronics"
    },
    {
      "name": "Mountain Bike",
      "price": "\$450",
      "distance": "6 km away",
      "image": "https://i.pinimg.com/1200x/12/51/6c/12516c664cd5de304da876b8703e0dab.jpg",
      "condition": "Used",
      "time": "5h ago",
      "category": "Sports"
    },
    {
      "name": "AirPods Pro",
      "price": "\$180",
      "distance": "2.5 km away",
      "image": "https://i.pinimg.com/1200x/71/1b/00/711b00dc657c11b15eb894f07eae276f.jpg",
      "condition": "Like New",
      "time": "1h ago",
      "category": "Electronics"
    },
    {
      "name": "Dining Table",
      "price": "\$250",
      "distance": "4 km away",
      "image": "https://i.pinimg.com/736x/99/58/39/9958394ff4d9b24871996ba317e613fd.jpg",
      "condition": "Good",
      "time": "1 day ago",
      "category": "Home"
    },
  ];

  final Map<String, dynamic> sponsoredAd = {
    "title": "Renovate Your Home!",
    "description": "Upgrade your space with our renovation deals. Get started today!",
    "buttonText": "Shop Now",
    "image": "https://i.pinimg.com/736x/99/58/39/9958394ff4d9b24871996ba317e613fd.jpg",
  };

  // ── Navigation helper ─────────────────────────────────────────────────────
  void _goToDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketplaceProductDetailScreen(product: item),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredListings {
    if (selectedIndex == 0) return nearbyListings;
    final cat = categories[selectedIndex]['name'] as String;
    if (cat == 'More') return nearbyListings;
    return nearbyListings.where((item) {
      final c = (item['category'] as String?) ?? '';
      if (cat == 'Electronics') return c == 'Electronics';
      if (cat == 'Vehicles') return c.contains('Vehicle') || c == 'Sports';
      if (cat == 'Home & Garden') return c == 'Home';
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPopular {
    if (selectedIndex == 0) return nearbyPopular;
    return nearbyPopular;
  }

  List<Map<String, dynamic>> get _allListings {
    return [
      ...nearbyPopular,
      ...nearbyListings,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      // Replace the existing AppBar and _buildSearchBar with the following:

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBackground(context),
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        title: GestureDetector(
          onTap: () {}, // hook up location picker
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your Location",
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.location,
                      color: AppColors.buttonColor(context), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    "Los Angeles, CA",
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryText(context), size: 18),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateListingScreen(),
                ),
              );
            },
            icon: Icon(Iconsax.add_square,
                color: AppColors.primaryText(context), size: 22),
          ),
          const SizedBox(width: 4),
          // ✅ Chat icon replaces bell
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MessagesHubScreen(
                    initialSpace: ChatSpace.marketplace,
                  ),
                ),
              );
            },
            icon: Icon(Iconsax.message,
                color: AppColors.primaryText(context), size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context, "Los Angeles, CA"),
              const SizedBox(height: 4),
              _buildCategories(),
              const SizedBox(height: 10),
              _buildNearbyPopular(),
              const SizedBox(height: 10),
              _buildSponsoredAd(),
              const SizedBox(height: 10),
              _buildNearbyListings(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

// Replace _buildSearchBar with this:
  Widget _buildSearchBar(BuildContext context, String location) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MarketplaceSearchScreen(),
            ),
          );
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLine(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Iconsax.search_normal,
                  color: AppColors.secondaryText(context), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'What are you looking for?',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                  ),
                ),
              ),
              // Replace the two separate icon containers with this single container:
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(Iconsax.microphone,
                              color: AppColors.secondaryText(context), size: 17),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 16,
                          color: AppColors.borderLine(context),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => showMarketplaceFilterSheet(context),
                          child: Icon(Iconsax.setting_4,
                              color: AppColors.buttonColor(context), size: 17),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 75,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderLine(context),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'],
                    size: 28,
                    color: isSelected
                        ? AppColors.buttonColor(context)
                        : AppColors.buttonColor(context).withOpacity(0.75),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.buttonColor(context)
                          : AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyPopular() {
    return Container(
      color: AppColors.secondaryBackground(context).withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Nearby",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MarketplaceSeeAllScreen(
                          title: 'Popular Nearby',
                          items: _allListings,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "See All >",
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
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPopular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _filteredPopular[index];
                final cardWidth =
                    (MediaQuery.of(context).size.width - 16 * 2 - 12 * 2) / 3;

                return GestureDetector(
                  onTap: () => _goToDetail(item),
                  child: Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.borderLine(context), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          child: Stack(
                            children: [
                              Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                                item["image"],
                                height: 95,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 95,
                                    color: AppColors.secondaryBackground(context),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: 95,
                                  color: AppColors.secondaryBackground(context),
                                  child: Center(
                                    child: Icon(Iconsax.image,
                                        color: AppColors.buttonColor(context),
                                        size: 26),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.6],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 6,
                                child: Text(
                                  item["price"],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                          child: Row(
                            children: [
                              Icon(Iconsax.location,
                                  size: 10,
                                  color: AppColors.secondaryText(context)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  item["distance"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondaryText(context),
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
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNearbyListings() {
    return Container(
      color: AppColors.secondaryBackground(context).withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Listings Near You",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MarketplaceMapScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                    AppColors.secondaryBackground(context).withOpacity(0.1),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: AppColors.borderLine(context),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    "View Map >",
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
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: (_filteredListings.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              final firstIndex = rowIndex * 2;
              final secondIndex = firstIndex + 1;

              final item1 = _filteredListings[firstIndex];
              final item2 = secondIndex < _filteredListings.length
                  ? _filteredListings[secondIndex]
                  : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _goToDetail(item1),
                        child: _ListingCard(item: item1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: item2 != null
                          ? GestureDetector(
                        onTap: () => _goToDetail(item2),
                        child: _ListingCard(item: item2),
                      )
                          : const SizedBox(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredAd() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.buttonColor(context).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sponsored label ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
              child: Text(
                "Sponsored",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.buttonColor(context),
                ),
              ),
            ),
            Divider(color: AppColors.borderLine(context)),

            // ── Image + Content row ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Thumbnail ─────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                      sponsoredAd["image"],
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 100,
                          height: 100,
                          color: AppColors.primaryBackground(context),
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
                        width: 100,
                        height: 100,
                        color: AppColors.primaryBackground(context),
                        child: Icon(Iconsax.image,
                            color: AppColors.buttonColor(context)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Title + Description + Button ──────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sponsoredAd["title"],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sponsoredAd["description"],
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Shop Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ListingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLine(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with price overlay ──────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Stack(
              children: [
                Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                  item["image"],
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 130,
                      color: AppColors.secondaryBackground(context),
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
                    height: 130,
                    color: AppColors.secondaryBackground(context),
                    child: Center(
                      child: Icon(Iconsax.image,
                          color: AppColors.buttonColor(context)),
                    ),
                  ),
                ),
                // ── Gradient ─────────────────────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
                // ── Price inside image bottom-left ────────────────
                Positioned(
                  left: 10,
                  bottom: 8,
                  child: Text(
                    item["price"],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Name + Distance below image ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryText(context),
                  ),
                ),
                Text(
                  item["distance"],
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText(context),
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