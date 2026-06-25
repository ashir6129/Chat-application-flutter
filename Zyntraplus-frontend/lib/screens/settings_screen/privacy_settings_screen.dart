import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _privateAccount = false;
  bool _showOnlineStatus = true;
  bool _showReadReceipts = true;
  bool _allowTagging = true;
  bool _allowMentions = true;
  bool _showFollowers = true;
  bool _showFollowing = true;

  String _whoCanMessage = 'Everyone';
  String _whoCanComment = 'Everyone';
  String _whoCanSeeActivity = 'Followers';

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
          'Privacy Settings',
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
          _SectionHeader(label: 'Account'),
          _ToggleTile(
            icon: Iconsax.lock,
            label: 'Private Account',
            subtitle: _privateAccount
                ? 'Only your followers can see your posts'
                : 'Anyone can see your posts',
            value: _privateAccount,
            onChanged: (v) => setState(() => _privateAccount = v),
          ),
          // _ToggleTile(
          //   icon: Iconsax.activity,
          //   label: 'Online Status',
          //   subtitle: _showOnlineStatus
          //       ? 'Others can see when you\'re active'
          //       : 'Your activity is hidden',
          //   value: _showOnlineStatus,
          //   onChanged: (v) => setState(() => _showOnlineStatus = v),
          // ),
          // _ToggleTile(
          //   icon: Iconsax.tick_circle,
          //   label: 'Read Receipts',
          //   subtitle: _showReadReceipts
          //       ? 'Others can see when you\'ve read messages'
          //       : 'Read receipts are off',
          //   value: _showReadReceipts,
          //   onChanged: (v) => setState(() => _showReadReceipts = v),
          // ),

          const SizedBox(height: 24),

          // ── Interactions ──────────────────────────────────────────────────
          _SectionHeader(label: 'Interactions'),
          _DropdownTile(
            icon: Iconsax.message_edit,
            label: 'Who can message you',
            value: _whoCanMessage,
            options: const ['Everyone', 'Followers', 'No one'],
            onChanged: (v) => setState(() => _whoCanMessage = v),
          ),
          _DropdownTile(
            icon: Iconsax.message_text,
            label: 'Who can comment',
            value: _whoCanComment,
            options: const ['Everyone', 'Followers', 'No one'],
            onChanged: (v) => setState(() => _whoCanComment = v),
          ),
          _ToggleTile(
            icon: Iconsax.tag_user,
            label: 'Allow Tagging',
            subtitle: _allowTagging
                ? 'Anyone can tag you in posts'
                : 'Nobody can tag you',
            value: _allowTagging,
            onChanged: (v) => setState(() => _allowTagging = v),
          ),
          _ToggleTile(
            icon: Iconsax.tag,
            label: 'Allow Mentions',
            subtitle: _allowMentions
                ? 'Anyone can mention you'
                : 'Nobody can mention you',
            value: _allowMentions,
            onChanged: (v) => setState(() => _allowMentions = v),
          ),

          const SizedBox(height: 24),

          // ── Visibility ────────────────────────────────────────────────────
          _SectionHeader(label: 'Visibility'),
          _ToggleTile(
            icon: Iconsax.people,
            label: 'Show Followers',
            subtitle: _showFollowers
                ? 'Your followers list is visible'
                : 'Followers list is hidden',
            value: _showFollowers,
            onChanged: (v) => setState(() => _showFollowers = v),
          ),
          _ToggleTile(
            icon: Iconsax.user_add,
            label: 'Show Following',
            subtitle: _showFollowing
                ? 'Your following list is visible'
                : 'Following list is hidden',
            value: _showFollowing,
            onChanged: (v) => setState(() => _showFollowing = v),
          ),
          _DropdownTile(
            icon: Iconsax.eye,
            label: 'Who can see your activity',
            value: _whoCanSeeActivity,
            options: const ['Everyone', 'Followers', 'Only me'],
            onChanged: (v) => setState(() => _whoCanSeeActivity = v),
          ),

          const SizedBox(height: 24),

          // ── Data ──────────────────────────────────────────────────────────
          _SectionHeader(label: 'Data & Permissions'),
          _ActionTile(
            icon: Iconsax.document_download,
            label: 'Download my data',
            onTap: () => _showDownloadDialog(context),
          ),
          _ActionTile(
            icon: Iconsax.trash,
            label: 'Clear search history',
            color: const Color(0xFFE24B4A),
            onTap: () => _showClearHistoryDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Download your data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send a download link to your registered email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Request',
                style:
                TextStyle(color: AppColors.buttonColor(ctx))),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear search history?'),
        content: const Text('This will permanently erase your search history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
  }
}

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
        border:
        Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText(context),
                  ),
                ),
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

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  void _showSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.primaryBackground(ctx),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderLine(ctx),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(ctx),
                  ),
                ),
              ),
            ),
            ...options.map((o) => ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                o,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText(ctx),
                  fontWeight: o == value
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              trailing: o == value
                  ? Icon(Icons.check_rounded,
                  color: AppColors.buttonColor(ctx), size: 18)
                  : null,
              onTap: () {
                onChanged(o);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.borderLine(context), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryText(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText(context),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.buttonColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.secondaryText(context)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryText(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color != null
                ? color!.withOpacity(0.2)
                : AppColors.borderLine(context),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: c,
                fontWeight:
                color != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: color ?? AppColors.secondaryText(context)),
          ],
        ),
      ),
    );
  }
}