import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class TipBottomSheet extends StatelessWidget {
  final Function(String type, int amount) onTipSelected;
  final int balanceCredits;

  const TipBottomSheet({
    super.key,
    required this.onTipSelected,
    this.balanceCredits = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tips = [
      {"icon": Iconsax.heart5, "label": "Rose", "amount": 5},
      {"icon": Iconsax.star1, "label": "Star", "amount": 10},
      {"icon": Iconsax.flash_1, "label": "Spark", "amount": 15},
      {"icon": Iconsax.emoji_happy, "label": "Smile", "amount": 20},
      {"icon": Iconsax.like_1, "label": "Like", "amount": 25},

      {"icon": Iconsax.gift, "label": "Gift", "amount": 40},
      {"icon": Iconsax.cake, "label": "Cake", "amount": 50},
      {"icon": Iconsax.musicnote, "label": "Vibe", "amount": 60},
      {"icon": Iconsax.crown, "label": "King", "amount": 80},
      {"icon": Iconsax.flash, "label": "Boost", "amount": 100},

      {"icon": Iconsax.medal, "label": "Hero", "amount": 150},
      {"icon": Iconsax.heart_add, "label": "Love+", "amount": 200},
      {"icon": Iconsax.star, "label": "Super Star", "amount": 250},
      {"icon": Iconsax.gift1, "label": "Mega Gift", "amount": 300},
      {"icon": Iconsax.diamonds, "label": "Diamond", "amount": 400},

      {"icon": Iconsax.crown_1, "label": "Royal", "amount": 500},
      {"icon": Iconsax.flash_circle, "label": "Ultra", "amount": 700},
      {"icon": Iconsax.global, "label": "Global", "amount": 1000},
      {"icon": Iconsax.medal_star, "label": "Legend", "amount": 1500},
      {"icon": Iconsax.cup, "label": "Champion", "amount": 2000},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Send a Tip",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Balance: $balanceCredits credits',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context)),
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            itemCount: tips.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = tips[index];

              return _tipItem(
                context,
                item["icon"] as IconData,
                item["label"] as String,
                item["amount"] as int,
              );
            },
          ),
        ],
      ),
    );
  }

  // 🎨 Dynamic color based on amount
  Color _getColor(int amount) {
    if (amount <= 20) return Colors.grey;
    if (amount <= 50) return Colors.green;
    if (amount <= 100) return Colors.blue;
    if (amount <= 300) return Colors.purple;
    if (amount <= 700) return Colors.orange;
    if (amount <= 1500) return Colors.red;
    return Colors.amber; // premium
  }

  Widget _tipItem(
      BuildContext context, IconData icon, String label, int amount) {
    final color = _getColor(amount);

    return GestureDetector(
      onTap: () => onTipSelected(label, amount),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            "$amount",
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}