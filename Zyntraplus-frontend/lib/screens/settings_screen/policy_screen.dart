import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/app_colors.dart';
import '../../widgets/app_header.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  const PolicyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primaryBackground(context),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: title,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Last updated: January 2024',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This Privacy Policy explains how we collect, use, and protect your information when you use our application.\n\n'

                          '1. Information We Collect\n'
                          'We may collect personal information such as your name, email address, profile details, and any content you choose to share. We also collect usage data like app interactions, device type, and log information to improve performance.\n\n'

                          '2. How We Use Your Information\n'
                          'Your information is used to provide and improve our services, personalize your experience, enable communication features, and ensure platform safety. We do not sell your personal data to third parties.\n\n'

                          '3. Sharing of Information\n'
                          'We may share limited data with trusted service providers to operate the app (such as hosting or analytics). Information may also be disclosed if required by law or to protect user safety.\n\n'

                          '4. Data Security\n'
                          'We implement reasonable security measures to protect your data. However, no system is completely secure, and we cannot guarantee absolute protection.\n\n'

                          '5. Your Choices\n'
                          'You can control your privacy settings within the app, including profile visibility and communication permissions. You may also request account deletion at any time.\n\n'

                          '6. Cookies and Tracking\n'
                          'We may use cookies or similar technologies to enhance user experience, analyze usage, and improve features.\n\n'

                          '7. Changes to This Policy\n'
                          'We may update this Privacy Policy from time to time. Any changes will be reflected with a revised "Last updated" date.\n\n'

                          '8. Contact Us\n'
                          'If you have any questions about this policy, please contact us through the app support section.',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
