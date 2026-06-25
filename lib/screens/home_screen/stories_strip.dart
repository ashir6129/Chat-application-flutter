import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../create_post/create_story_screen.dart';

class StoriesStrip extends StatelessWidget {
  const StoriesStrip({super.key});

  static const double _avatarSize = 64;
  static const double _stripHeight = 108;

  static const _storyUsers = [
    _StoryUser(name: 'Rahul', initial: 'R', color: Color(0xFF9B59FF)),
    _StoryUser(name: 'Priya', initial: 'P', color: Color(0xFF00A884)),
    _StoryUser(name: 'Arjun', initial: 'A', color: Color(0xFFEF5350)),
    _StoryUser(name: 'Sara', initial: 'S', color: Color(0xFF3D9BFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _stripHeight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        scrollDirection: Axis.horizontal,
        children: [
          _AddStoryBubble(
            avatarSize: _avatarSize,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
            ),
          ),
          const SizedBox(width: 14),
          ..._storyUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _UserStoryBubble(
                user: user,
                avatarSize: _avatarSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryUser {
  final String name;
  final String initial;
  final Color color;

  const _StoryUser({
    required this.name,
    required this.initial,
    required this.color,
  });
}

class _StoryCell extends StatelessWidget {
  final Widget avatar;
  final String label;

  const _StoryCell({
    required this.avatar,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Center(child: avatar),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              color: AppColors.secondaryText(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStoryBubble extends StatelessWidget {
  final double avatarSize;
  final VoidCallback onTap;

  const _AddStoryBubble({
    required this.avatarSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return GestureDetector(
      onTap: onTap,
      child: _StoryCell(
        label: 'Your story',
        avatar: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLine(context),
                  width: 1.5,
                ),
                color: AppColors.composerBackground(context),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.secondaryText(context),
                size: 30,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBackground(context),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStoryBubble extends StatelessWidget {
  final _StoryUser user;
  final double avatarSize;

  const _UserStoryBubble({
    required this.user,
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final ring = AppColors.buttonColor(context);

    return _StoryCell(
      label: user.name,
      avatar: Container(
        width: avatarSize,
        height: avatarSize,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: 2.5),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.composerBackground(context),
          ),
          alignment: Alignment.center,
          child: Text(
            user.initial,
            style: TextStyle(
              color: user.color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
