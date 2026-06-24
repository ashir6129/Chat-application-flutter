import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import 'search_location_screen.dart';
import 'location_helper.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  String _selectedLocation = 'Current Location';
  String _displayedLocation = 'Lekki Phase 1, Lagos, Nigeria';
  String _displayedDistance = 'within 3 km';

  final List<String> _quickLocations = ['Current Location', 'Lagos', 'Lekki', 'Ikeja'];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final name = _displayedLocation;
        final coords = LocationHelper.locationCoords[name] ?? LocationHelper.locationCoords[_selectedLocation] ?? [6.4281, 3.4219];
        Navigator.pop(context, {
          'location': name,
          'latitude': coords[0],
          'longitude': coords[1],
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground(context),
          elevation: 0,
          toolbarHeight: 56,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
            onPressed: () {
              final name = _displayedLocation;
              final coords = LocationHelper.locationCoords[name] ?? LocationHelper.locationCoords[_selectedLocation] ?? [6.4281, 3.4219];
              Navigator.pop(context, {
                'location': name,
                'latitude': coords[0],
                'longitude': coords[1],
              });
            },
          ),
          title: Text(
            'Explore Map',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.location,
                color: AppColors.buttonColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.mutedText(context).withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.search_normal_1,
                            color: AppColors.mutedText(context),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search location',
                                hintStyle: TextStyle(
                                  color: AppColors.mutedText(context),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Location Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: _quickLocations.asMap().entries.map((entry) {
                      final location = entry.value;
                      final isSelected = _selectedLocation == location;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = location;
                              if (location == 'Current Location') {
                                _displayedLocation = 'Lekki Phase 1, Lagos, Nigeria';
                              } else {
                                _displayedLocation = location;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.buttonColor(context)
                                  : AppColors.secondaryBackground(context),
                              borderRadius: BorderRadius.circular(18),
                              border: !isSelected
                                  ? Border.all(
                                      color: AppColors.mutedText(context).withOpacity(0.25),
                                    )
                                  : null,
                            ),
                            child: Text(
                              location,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.primaryText(context),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Map area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Grid pattern background
                        CustomPaint(
                          painter: GridPatternPainter(),
                          size: Size.infinite,
                        ),

                        // Center marker
                        Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.location,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),

                        // Map controls (right side)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _mapControlButton(Iconsax.location),
                              const SizedBox(height: 10),
                              _mapControlButton(Iconsax.add),
                              const SizedBox(height: 10),
                              _mapControlButton(Iconsax.minus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),

            // Bottom location info card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBackground(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.location,
                        color: AppColors.buttonColor(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your Location',
                            style: TextStyle(
                              color: AppColors.mutedText(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _displayedLocation,
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _displayedDistance,
                            style: TextStyle(
                              color: AppColors.buttonColor(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selected = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchLocationScreen(),
                          ),
                        );
                        if (selected != null) {
                          setState(() {
                            _displayedLocation = selected;
                            _selectedLocation = 'Custom';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor(context),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Change Location',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapControlButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mutedText(context).withOpacity(0.2),
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.primaryText(context),
        size: 18,
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A3A4A).withOpacity(0.4)
      ..strokeWidth = 1;

    const spacing = 35.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) => false;
}
