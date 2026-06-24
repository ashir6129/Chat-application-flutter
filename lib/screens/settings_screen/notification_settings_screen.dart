import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // ── Push Notifications ────────────────────────────────────────────────────
  bool _pushEnabled = true;

  // ── Activity ──────────────────────────────────────────────────────────────
  bool _likes = true;
  bool _comments = true;
  bool _commentLikes = false;
  bool _mentions = true;
  bool _newFollowers = true;
  bool _followRequests = true;

  // ── Messages ──────────────────────────────────────────────────────────────
  bool _directMessages = true;
  bool _messageRequests = true;

  // ── Posts & Creator ───────────────────────────────────────────────────────
  bool _postShares = false;
  bool _tips = true;
  bool _newPostFromFollowing = false;

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
          'Notification Settings',
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
          // ── Master toggle ─────────────────────────────────────────────────
          _MasterToggle(
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
          ),

          const SizedBox(height: 20),

          // ── Activity ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Activity'),
          _ToggleTile(
            icon: Iconsax.heart,
            label: 'Likes',
            subtitle: 'When someone likes your post',
            value: _likes && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _likes = v),
          ),
          _ToggleTile(
            icon: Iconsax.message,
            label: 'Comments',
            subtitle: 'When someone comments on your post',
            value: _comments && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _comments = v),
          ),
          _ToggleTile(
            icon: Iconsax.heart_circle,
            label: 'Comment Likes',
            subtitle: 'When someone likes your comment',
            value: _commentLikes && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _commentLikes = v),
          ),
          _ToggleTile(
            icon: Iconsax.tag,
            label: 'Mentions',
            subtitle: 'When someone mentions you',
            value: _mentions && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _mentions = v),
          ),
          _ToggleTile(
            icon: Iconsax.user_add,
            label: 'New Followers',
            subtitle: 'When someone follows you',
            value: _newFollowers && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _newFollowers = v),
          ),
          _ToggleTile(
            icon: Iconsax.people,
            label: 'Follow Requests',
            subtitle: 'When someone requests to follow you',
            value: _followRequests && _pushEnabled,
            enabled: _pushEnabled,
            onChanged: (v) => setState(() => _followRequests = v),
          ),

          // const SizedBox(height: 24),

          // // ── Messages ──────────────────────────────────────────────────────
          // _SectionHeader(label: 'Messages'),
          // _ToggleTile(
          //   icon: Iconsax.message_text,
          //   label: 'Direct Messages',
          //   subtitle: 'When you receive a new message',
          //   value: _directMessages && _pushEnabled,
          //   enabled: _pushEnabled,
          //   onChanged: (v) => setState(() => _directMessages = v),
          // ),
          // _ToggleTile(
          //   icon: Iconsax.message_add,
          //   label: 'Message Requests',
          //   subtitle: 'When someone new messages you',
          //   value: _messageRequests && _pushEnabled,
          //   enabled: _pushEnabled,
          //   onChanged: (v) => setState(() => _messageRequests = v),
          // ),
          //
          // const SizedBox(height: 24),
          //
          // // ── Creator & Posts ───────────────────────────────────────────────
          // _SectionHeader(label: 'Creator & Posts'),
          // _ToggleTile(
          //   icon: Icons.monetization_on_outlined,
          //   label: 'Tips Received',
          //   subtitle: 'When someone tips you',
          //   value: _tips && _pushEnabled,
          //   enabled: _pushEnabled,
          //   onChanged: (v) => setState(() => _tips = v),
          // ),
          // _ToggleTile(
          //   icon: Iconsax.notification,
          //   label: 'New Posts from Following',
          //   subtitle: 'When someone you follow posts',
          //   value: _newPostFromFollowing && _pushEnabled,
          //   enabled: _pushEnabled,
          //   onChanged: (v) => setState(() => _newPostFromFollowing = v),
          // ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Master toggle card
// ─────────────────────────────────────────────────────────────────────────────
class _MasterToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MasterToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: value
            ? AppColors.buttonColor(context).withOpacity(0.08)
            : AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppColors.buttonColor(context).withOpacity(0.3)
              : AppColors.borderLine(context),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.buttonColor(context).withOpacity(0.12)
                  : AppColors.borderLine(context).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              value ? Iconsax.notification : Iconsax.notification_15,
              size: 20,
              color: value
                  ? AppColors.buttonColor(context)
                  : AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? 'Notifications are enabled' : 'All notifications are muted',
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

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.buttonColor(context),
            ),
          ],
        ),
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