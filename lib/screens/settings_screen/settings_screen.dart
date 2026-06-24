import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyntraplus/screens/monetization_screen/in_app_tokens_screen.dart';
import 'package:zyntraplus/screens/settings_screen/account_information_screen.dart';
import 'package:zyntraplus/screens/settings_screen/account_privacy_screen.dart';
import 'package:zyntraplus/screens/settings_screen/referral_screen.dart';
import '../../../core/app_colors.dart';
import '../../api_services/user_service.dart';
import '../../core/secure_storage_service.dart';
import '../../login_screen/auth_screen.dart';
import '../../main.dart';
import '../../widgets/app_header.dart';
import '../monetization_screen/bonus_screen.dart';
import '../monetization_screen/monetization_dashboard.dart';
import 'blocked_users_screen.dart';
import 'change_password_screen.dart';
import 'privacy_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'policy_screen.dart';
import 'location_privacy_screen.dart';
import 'archived_posts_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [

                  _SectionHeader(label: 'Account'),
                  _SettingsTile(
                    icon: Iconsax.user,
                    label: 'Account Information',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AccountInformationScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.lock,
                    label: 'Change Password',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Content & Privacy'),
                  _SettingsTile(
                    icon: Iconsax.eye,
                    label: 'Account Privacy',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AccountPrivacyScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.location,
                    label: 'Location Privacy',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LocationPrivacyScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.user_remove,
                    label: 'Blocked Users',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BlockedUsersScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.archive,
                    label: 'Archived Posts',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ArchivedPostsScreen())),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Notifications'),
                  _SettingsTile(
                    icon: Iconsax.notification,
                    label: 'Notifications',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Monetization'),
                  _SettingsTile(
                    icon: Iconsax.chart,
                    label: 'Monetization Dashboard',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MonetizationScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.coin,
                    label: 'In-App Tokens',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const InAppTokensScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.user_add,
                    label: 'Referral System',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ReferralScreen())),
                  ),
                  _SettingsTile(
                    icon: Iconsax.star1,
                    label: 'Bonus Page',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BonusScreen())),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Appearance'),
                  _ThemeToggleTile(),
                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Support'),
                  _SettingsTile(
                    icon: Iconsax.star,
                    label: 'Rate Us',
                    onTap: () => _showRateUs(context),
                  ),
                  _SettingsTile(
                    icon: Iconsax.document_text,
                    label: 'Privacy Policy',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PolicyScreen(title: 'Privacy Policy'))),
                  ),
                  _SettingsTile(
                    icon: Iconsax.document,
                    label: 'Terms & Conditions',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PolicyScreen(title: 'Terms & Conditions'))),
                  ),

                  const SizedBox(height: 8),

                  _SectionHeader(label: 'Danger Zone'),
                  const SizedBox(height: 10),

                  // Log Out — ghost style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _showLogout(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Delete Account — solid filled style with icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _showDeleteAccount(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Iconsax.trash, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Version $_appVersion',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        icon: Iconsax.logout,
        iconColor: Colors.redAccent,
        title: 'Log Out',
        subtitle: 'Are you sure you want to log out?',
        confirmLabel: 'Log Out',
        confirmColor: Colors.redAccent,
        onConfirm: () async {
          Navigator.pop(context);
          await SecureStorageService.logout();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (_) => false,
          );
        },
      ),
    );
  }

  Future<void> _completeAccountDeletion(BuildContext context) async {
    await UserService.deleteMe();
    await SecureStorageService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteAccountSheet(
        onDelete: () => _completeAccountDeletion(context),
      ),
    );
  }

  void _showRateUs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        int selected = 0;
        return StatefulBuilder(
          builder: (context, setModal) => Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Icon(Iconsax.star5, size: 40, color: AppColors.buttonColor(context)),
                const SizedBox(height: 12),
                Text(
                  'Rate Our App',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your feedback helps us improve',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModal(() => selected = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          i < selected ? Iconsax.star5 : Iconsax.star,
                          size: 36,
                          color: i < selected ? Colors.amber : AppColors.secondaryText(context),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor(context),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: selected == 0
                        ? null
                        : () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Submit Rating',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Delete Account Sheet (custom, distinct from _ConfirmSheet) ───────────────
class _DeleteAccountSheet extends StatefulWidget {
  final Future<void> Function() onDelete;

  const _DeleteAccountSheet({required this.onDelete});

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  bool _confirmed = false;
  bool _deleting = false;

  Future<void> _handleDelete() async {
    if (!_confirmed || _deleting) return;
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserService.errorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Icon with pulsing red ring feel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFB71C1C).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(Iconsax.trash, color: Color(0xFFB71C1C), size: 30),
          ),
          const SizedBox(height: 14),

          Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will permanently erase your profile,\ncontent, and all associated data.\nThis action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          // Checkbox confirmation
          GestureDetector(
            onTap: () => setState(() => _confirmed = !_confirmed),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _confirmed
                        ? const Color(0xFFB71C1C)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _confirmed
                          ? const Color(0xFFB71C1C)
                          : AppColors.secondaryText(context),
                      width: 1.5,
                    ),
                  ),
                  child: _confirmed
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I understand this action is permanent',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
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
              Expanded(
                child: GestureDetector(
                  onTap: _confirmed && !_deleting ? () async {
                    Navigator.pop(context);
                    await _handleDelete();
                  } : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      color: _confirmed && !_deleting
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFFB71C1C).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Delete',
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
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.secondaryText(context),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20,
                color: iconColor ?? AppColors.primaryText(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3,
                size: 16, color: AppColors.secondaryText(context)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
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
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: confirmColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: confirmColor.withOpacity(0.4), width: 0.8),
                    ),
                    child: Center(
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          color: confirmColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(
                isDark ? Iconsax.moon : Iconsax.sun_1,
                size: 20,
                color: AppColors.primaryText(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isDark,
                onChanged: (val) async {
                  themeModeNotifier.value =
                  val ? ThemeMode.dark : ThemeMode.light;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('theme', val ? 'dark' : 'light');
                },
                activeColor: AppColors.buttonColor(context),
              ),
            ],
          ),
        );
      },
    );
  }
}