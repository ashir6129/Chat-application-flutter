import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../core/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 16, 8),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: AppColors.primaryText(context),
                  ),
                )
              else
                const SizedBox(width: 48),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (actions != null) ...actions!,
            ],
          ),
        ),
        Divider(
          color: AppColors.borderLine(context),
          height: 1,
          thickness: 0.5,
        ),
      ],
    );
  }
}