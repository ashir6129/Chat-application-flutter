import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class MessageRequestsScreen extends StatelessWidget {
  const MessageRequestsScreen({super.key});

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
          'Message requests',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.direct_inbox, size: 56, color: AppColors.mutedText(context)),
            const SizedBox(height: 16),
            Text(
              'No message requests',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When someone you don\'t follow messages you, it will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
