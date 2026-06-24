import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class LocationPrivacyScreen extends StatefulWidget {
  const LocationPrivacyScreen({super.key});

  @override
  State<LocationPrivacyScreen> createState() => _LocationPrivacyScreenState();
}

class _LocationPrivacyScreenState extends State<LocationPrivacyScreen> {
  bool _locationEnabled = false;
  bool _preciseLocation = false;
  bool _showOnProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Location Privacy',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [

          _SectionHeader(label: 'Location Access'),

          // ── Enable Location Toggle ────────────────────────────────────────
          _ToggleTile(
            icon: Iconsax.location,
            label: 'Enable Location',
            subtitle: _locationEnabled
                ? 'Location is active on your account'
                : 'Turn on to use location features',
            value: _locationEnabled,
            onChanged: (v) {
              if (v) {
                _showEnableConfirmSheet(context);
              } else {
                setState(() {
                  _locationEnabled = false;
                  _preciseLocation = false;
                  _showOnProfile = false;
                });
              }
            },
          ),

          // ── Billing Banner (shown when enabled) ───────────────────────────
          if (_locationEnabled) ...[
            const SizedBox(height: 6),
            _InfoBanner(
              icon: Iconsax.wallet,
              color: const Color(0xFF4CAF50),
              message:
              '\$1.00 will be deducted from your earnings every 30 days. You will not be charged upfront.',
            ),
          ],

          const SizedBox(height: 20),

          // // ── Sub-settings (only visible when enabled) ──────────────────────
          // if (_locationEnabled) ...[
          //   _SectionHeader(label: 'Location Settings'),
          //   _ToggleTile(
          //     icon: Iconsax.gps,
          //     label: 'Precise Location',
          //     subtitle: _preciseLocation
          //         ? 'Sharing your exact location'
          //         : 'Only approximate location is shared',
          //     value: _preciseLocation,
          //     onChanged: (v) => setState(() => _preciseLocation = v),
          //   ),
          //   _ToggleTile(
          //     icon: Iconsax.profile_2user,
          //     label: 'Show on Profile',
          //     subtitle: _showOnProfile
          //         ? 'Your city is visible on your profile'
          //         : 'Location hidden from your profile',
          //     value: _showOnProfile,
          //     onChanged: (v) => setState(() => _showOnProfile = v),
          //   ),
          //   const SizedBox(height: 20),
          // ],

          // ── What This Means ───────────────────────────────────────────────
          _SectionHeader(label: 'What This Means'),
          _BulletTile(
            icon: Iconsax.location_tick,
            label: 'Location-based content discovery',
            subtitle: 'See posts and creators near you',
          ),
          _BulletTile(
            icon: Iconsax.shield_tick,
            label: 'Your exact coordinates are never shared',
            subtitle: 'Only city-level data is used publicly',
          ),
          _BulletTile(
            icon: Iconsax.dollar_circle,
            label: '\$1 deducted from earnings every 30 days',
            subtitle: 'No upfront charge — billed from your balance',
          ),
          _BulletTile(
            icon: Iconsax.close_circle,
            label: 'Cancel anytime by toggling off',
            subtitle: 'Billing stops at the end of your current cycle',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEnableConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedText(context),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(Iconsax.location,
                  color: Color(0xFF4CAF50), size: 30),
            ),
            const SizedBox(height: 14),

            Text(
              'Enable Location?',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // Billing notice card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.25),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.wallet,
                          size: 16, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '\$1.00 / 30 days from your earnings',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You will not be charged upfront. The \$1.00 fee is automatically deducted from your in-app earnings every 30 days as long as location is enabled.',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.borderLine(context), width: 0.8),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Enable
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _locationEnabled = true);
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Enable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets (scoped to this file) ────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.secondaryText(context),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.primaryText(context))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText(context))),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.buttonColor(context),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _InfoBanner({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _BulletTile({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.primaryText(context))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}