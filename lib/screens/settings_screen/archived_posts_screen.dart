import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/post_services.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/profile_refresh.dart';
import '../../models/feed_post.dart';
import '../../widgets/feed/feed_image_grid.dart';
import '../../widgets/feed/feed_poll_card.dart';
import '../../widgets/feed/feed_sheets.dart';
import '../../widgets/feed/feed_video_preview.dart';
import '../../widgets/feed/menu_bottom_sheet.dart';
import '../../widgets/feed/post_widget.dart';
import '../../widgets/app_header.dart';

class ArchivedPostsScreen extends StatefulWidget {
  const ArchivedPostsScreen({super.key});

  @override
  State<ArchivedPostsScreen> createState() => _ArchivedPostsScreenState();
}

class _ArchivedPostsScreenState extends State<ArchivedPostsScreen> {
  List<PostModel> _posts = [];
  bool _loading = true;
  String? _error;
  late final ProfileRefreshListener _profileRefreshListener;

  @override
  void initState() {
    super.initState();
    _profileRefreshListener = ({bool silent = false}) => _load(silent: silent);
    ProfileRefresh.register(_profileRefreshListener);
    _load();
  }

  @override
  void dispose() {
    ProfileRefresh.unregister(_profileRefreshListener);
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (_posts.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final posts = await UserService.getMyPosts(type: 'archived', limit: 50);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = UserService.errorMessage(e);
      });
    }
  }

  Future<void> _restore(int index) async {
    final post = _posts[index];
    try {
      await PostsService.archivePost(post.id, archived: false);
      ProfileRefresh.trigger();
      if (!mounted) return;
      setState(() => _posts.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post restored to profile')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  Future<void> _delete(int index) async {
    final post = _posts[index];
    try {
      await PostsService.deletePost(post.id);
      ProfileRefresh.trigger();
      if (!mounted) return;
      setState(() => _posts.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted permanently')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Archived Posts'),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: AppColors.buttonColor(context)))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, style: TextStyle(color: AppColors.secondaryText(context))),
                              TextButton(onPressed: _load, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : _posts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.archive, size: 48, color: AppColors.mutedText(context)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No archived posts',
                                    style: TextStyle(color: AppColors.secondaryText(context), fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Archive posts from the ⋯ menu on your posts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              color: AppColors.buttonColor(context),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: _posts.length,
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  return _ArchivedPostCard(
                                    post: post,
                                    onRestore: () => _restore(index),
                                    onDelete: () => _delete(index),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedPostCard({
    required this.post,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Archived · ${post.time}', style: TextStyle(color: AppColors.mutedText(context), fontSize: 11)),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: AppColors.secondaryText(context), size: 20),
                  onPressed: () => showPostMenuBottomSheet(
                    context,
                    authorName: post.user,
                    isOwnPost: true,
                    isArchived: true,
                    onDelete: onDelete,
                    onArchive: onRestore,
                  ),
                ),
              ],
            ),
          ),
          if (post.poll != null)
            FeedPollCard(poll: post.poll!, isOwner: true, showResults: true),
          if (post.displayCaption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: Text(post.displayCaption, style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13.5)),
            ),
          if (post.images.isNotEmpty)
            if (post.isVideo)
              FeedVideoPreview(videoUrl: post.images.first)
            else
              FeedImageGrid(images: post.images, mediaMeta: post.mediaMeta),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onRestore,
                  icon: Icon(Iconsax.refresh, size: 16, color: AppColors.buttonColor(context)),
                  label: Text('Restore', style: TextStyle(color: AppColors.buttonColor(context))),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Iconsax.trash, size: 16, color: Color(0xFFE24B4A)),
                  label: const Text('Delete', style: TextStyle(color: Color(0xFFE24B4A))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
