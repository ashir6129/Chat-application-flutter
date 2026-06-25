import 'package:flutter/material.dart';
import '../../../../../core/app_colors.dart';

class StoryModel {
  final String uid;
  final String name;
  final String? avatarUrl;
  final bool seen;
  final bool isOwn;

  const StoryModel({
    required this.uid,
    required this.name,
    this.avatarUrl,
    this.seen = false,
    this.isOwn = false,
  });
}

class StoryWidget extends StatelessWidget {
  final List<StoryModel> stories;

  const StoryWidget({
    super.key,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLine(context),
            width: 0.5,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          const _AddStoryItem(),
          const SizedBox(width: 10),
          ...stories.map(
                (s) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _StoryItem(story: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final StoryModel story;

  const _StoryItem({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: open story viewer
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: story.seen
                    ? AppColors.borderLine(context)
                    : AppColors.buttonColor(context),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBackground(context),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: story.avatarUrl != null
                    ? NetworkImage(story.avatarUrl!)
                    : null,
                backgroundColor: AppColors.secondaryBackground(context),
                child: story.avatarUrl == null
                    ? Text(
                  _initials(story.name),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText(context),
                  ),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 56,
            child: Text(
              story.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

class _AddStoryItem extends StatelessWidget {
  const _AddStoryItem();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: open story creator
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLine(context),
                width: 0.5,
              ),
              color: AppColors.secondaryBackground(context),
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.buttonColor(context),
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 56,
            child: Text(
              'Your story',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}