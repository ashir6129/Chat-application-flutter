import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

class MarketplaceSearchScreen extends StatefulWidget {
  const MarketplaceSearchScreen({super.key});

  @override
  State<MarketplaceSearchScreen> createState() =>
      _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState extends State<MarketplaceSearchScreen> {
  final TextEditingController _query = TextEditingController();

  static const _recent = ['iPhone', 'MacBook', 'Sofa', 'Mountain Bike'];
  static const _trending = ['Electronics', 'Vehicles', 'Furniture', 'Fashion'];

  @override
  void dispose() {
    _query.dispose();
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
          icon: Icon(Iconsax.arrow_left,
              color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _searchField(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Recent',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText(context))),
          const SizedBox(height: 8),
          ..._recent.map(
            (q) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Iconsax.clock,
                  size: 18, color: AppColors.mutedText(context)),
              title: Text(q,
                  style: TextStyle(color: AppColors.primaryText(context))),
              onTap: () => _query.text = q,
            ),
          ),
          const SizedBox(height: 16),
          Text('Trending',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText(context))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending
                .map(
                  (t) => ActionChip(
                    label: Text(t),
                    onPressed: () => _query.text = t,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLine(context), width: 0.8),
      ),
      child: TextField(
        controller: _query,
        autofocus: true,
        style: TextStyle(color: AppColors.primaryText(context), fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search marketplace…',
          hintStyle: TextStyle(color: AppColors.mutedText(context)),
          prefixIcon: Icon(Iconsax.search_normal,
              size: 20, color: AppColors.mutedText(context)),
          suffixIcon: IconButton(
            icon: Icon(Iconsax.filter,
                size: 20, color: AppColors.buttonColor(context)),
            onPressed: () => showMarketplaceFilterSheet(context),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

void showMarketplaceFilterSheet(
  BuildContext context, {
  RangeValues priceRange = const RangeValues(0, 2000),
  double maxDistance = 25,
  String sortBy = 'Recent',
  String condition = 'All',
  void Function(RangeValues priceRange, double maxDistance, String sortBy, String condition)? onApply,
}) {
  RangeValues selectedPriceRange = priceRange;
  double selectedMaxDistance = maxDistance;
  String selectedSortBy = sortBy;
  String selectedCondition = condition;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final accent = AppColors.buttonColor(context);
        final chipBg = AppColors.secondaryBackground(context);
        final border = AppColors.borderLine(context);

        Widget filterChip({
          required String label,
          required bool selected,
          required VoidCallback onTap,
        }) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? accent : chipBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? accent : border.withOpacity(0.7),
                  width: 0.8,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.mutedText(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setSheet(() {
                        selectedSortBy = 'Recent';
                        selectedCondition = 'All';
                        selectedMaxDistance = 25;
                        selectedPriceRange = const RangeValues(0, 2000);
                      }),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: border.withOpacity(0.5),
                ),
                const SizedBox(height: 20),

                Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in [
                      'Recent',
                      'Nearest',
                      'Price: Low to High',
                      'Price: High to Low',
                    ])
                      filterChip(
                        label: option,
                        selected: selectedSortBy == option,
                        onTap: () => setSheet(() => selectedSortBy = option),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Condition',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in ['All', 'Like New', 'Good', 'Used'])
                      filterChip(
                        label: option,
                        selected: selectedCondition == option,
                        onTap: () => setSheet(() => selectedCondition = option),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Max Distance: ${selectedMaxDistance.round()} km',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent,
                    inactiveTrackColor: chipBg,
                    thumbColor: accent,
                    overlayColor: accent.withOpacity(0.15),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: selectedMaxDistance,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (v) => setSheet(() => selectedMaxDistance = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 km',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedText(context))),
                    Text('50 km',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedText(context))),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'Price Range: \$${selectedPriceRange.start.round()} – \$${selectedPriceRange.end.round()}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent,
                    inactiveTrackColor: chipBg,
                    thumbColor: accent,
                    overlayColor: accent.withOpacity(0.15),
                    trackHeight: 3,
                    rangeThumbShape:
                        const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: RangeSlider(
                    values: selectedPriceRange,
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    onChanged: (v) => setSheet(() => selectedPriceRange = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$0',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedText(context))),
                    Text('\$2000+',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.mutedText(context))),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (onApply != null) {
                        onApply(selectedPriceRange, selectedMaxDistance, selectedSortBy, selectedCondition);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
