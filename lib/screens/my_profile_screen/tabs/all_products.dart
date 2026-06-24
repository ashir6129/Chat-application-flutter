import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class AllProductsTab extends StatelessWidget {
  const AllProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 6),
          Text(
            'List items from Marketplace to show them here',
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
