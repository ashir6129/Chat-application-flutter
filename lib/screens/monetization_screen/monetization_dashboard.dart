import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../widgets/app_header.dart';
import 'creator_rewards_screen.dart';
import 'extra_rewards_screen.dart';

class MonetizationScreen extends StatefulWidget {
  const MonetizationScreen({super.key});

  @override
  State<MonetizationScreen> createState() => _MonetizationScreenState();
}

class _MonetizationScreenState extends State<MonetizationScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Professional Dashboard'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLine(context),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      context,
                      title: 'Creator Rewards',
                      icon: Icons.play_circle_outline,
                      index: 0,
                    ),
                    _buildTabButton(
                      context,
                      title: 'Extra Rewards',
                      icon: Icons.diamond_outlined,
                      index: 1,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: selectedIndex == 0
                    ? const CreatorRewardsScreen()
                    : const ExtraRewardsScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.buttonColor(context),
              AppColors.buttonColor(context).withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.wallet_3, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Wallet Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '\$1,240.50',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _walletChip('USD \$14.46'),
                const SizedBox(width: 8),
                _walletChip('TURQ 2,450'),
                const SizedBox(width: 8),
                _walletChip('Tokens 890'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool isActive = selectedIndex == index;
    final bool isCompact = MediaQuery.of(context).size.width < 380;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.buttonColor(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isCompact ? 14 : 16,
                color: isActive
                    ? Colors.white
                    : AppColors.secondaryText(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppColors.secondaryText(context),
                    fontSize: isCompact ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
