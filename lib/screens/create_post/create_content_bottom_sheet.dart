import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/new_post_screen.dart';
import 'package:zyntraplus/screens/marketplace_screen/create_product_screen.dart';
import '../../../core/app_colors.dart';
import 'create_story_screen.dart';

class CreateContentBottomSheet extends StatelessWidget {
  const CreateContentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),

          Text(
            "Create",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 18),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _item(
                context,
                icon: Iconsax.story,
                label: "Story",
                color: Colors.orange,
                onTap: () {
                  _go(context, const CreateStoryScreen());
                },
              ),
              _item(
                context,
                icon: Iconsax.gallery,
                label: "Post",
                color: Colors.blue,
                onTap: () {
                  _go(context, const SimplePostScreen());
                },
              ),
              _item(
                context,
                icon: Iconsax.video_play,
                label: "Reel",
                color: Colors.purple,
                onTap: () {
                  _go(context, const SimplePostScreen(mode: PostCreateMode.reel));
                },
              ),
              _item(
                context,
                icon: Iconsax.shopping_bag,
                label: "Product",
                color: Colors.green,
                onTap: () {
                  _go(context, const CreateListingScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderLine(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),

            const Spacer(),

            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(context),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Create $label",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 150), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    });
  }
}