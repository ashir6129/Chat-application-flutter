import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allLocations = [
    'Lekki Phase 1, Lagos, Nigeria',
    'Lekki Phase 2, Lagos, Nigeria',
    'Lekki Phase 3, Lagos, Nigeria',
    'Lekki Phase 4, Lagos, Nigeria',
    'Lekki Conservation Centre, Lagos, Nigeria',
    'Victoria Island, Lagos, Nigeria',
    'Ikoyi, Lagos, Nigeria',
    'Yaba, Lagos, Nigeria',
    'Surulere, Lagos, Nigeria',
    'Mushin, Lagos, Nigeria',
    'Ikeja, Lagos, Nigeria',
    'Ojodu, Lagos, Nigeria',
  ];

  late List<String> _filteredLocations;

  @override
  void initState() {
    super.initState();
    _filteredLocations = _allLocations;
    _searchController.addListener(_filterLocations);
  }

  void _filterLocations() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredLocations = _allLocations
          .where((location) => location.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Search Location',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mutedText(context).withOpacity(0.3),
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(color: AppColors.primaryText(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Locations list
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Text(
                      'No locations found',
                      style: TextStyle(color: AppColors.mutedText(context)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, location);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.mutedText(context).withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBackground(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.location,
                                  color: AppColors.mutedText(context),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.split(',').first,
                                      style: TextStyle(
                                        color: AppColors.primaryText(context),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location.substring(
                                        location.indexOf(',') + 1,
                                      ),
                                      style: TextStyle(
                                        color: AppColors.mutedText(context),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}
