import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import '../../core/profile_memory_cache.dart';
import '../../new_post_screen.dart';
import '../my_profile_screen/profile_screen.dart';

class WhatsOnYourMind extends StatelessWidget {
  const WhatsOnYourMind({super.key});

  static const double _avatarSize = 40;

  Widget _composerAvatar(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    final me = ProfileMemoryCache.me;

    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.55),
          width: 1.5,
        ),
        color: AppColors.composerBackground(context),
      ),
      child: ClipOval(
        child: me?.avatarUrl != null && me!.avatarUrl!.isNotEmpty
            ? Image.network(
                me.avatarUrl!,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person_rounded,
                    color: accent,
                    size: 22,
                  );
                },
              )
            : Icon(
                Icons.person_rounded,
                color: accent,
                size: 22,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Container(
      color: AppColors.primaryBackground(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: _composerAvatar(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SimplePostScreen()),
              ),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.composerBackground(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.borderLine(context).withValues(alpha: 0.45),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimplePostScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF132821),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              child: Icon(
                Iconsax.gallery,
                color: accent,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
