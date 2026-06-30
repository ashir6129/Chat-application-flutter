import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../api_services/post_services.dart';
import '../../core/app_colors.dart';
import '../../core/secure_storage_service.dart';
import 'comment_action_sheet.dart';

class CommentReaction {
  final String emoji;
  final int count;
  final bool mine;

  CommentReaction({required this.emoji, required this.count, this.mine = false});

  factory CommentReaction.fromApi(Map<String, dynamic> json) {
    return CommentReaction(
      emoji: json['emoji']?.toString() ?? '',
      count: json['count'] as int? ?? 0,
      mine: json['mine'] == true,
    );
  }
}

class CommentItem {
  final String id;
  final String userId;
  final String body;
  final String timeAgo;
  final String username;
  final String? parentId;
  final List<CommentItem> replies;
  final List<CommentReaction> reactions;

  CommentItem({
    required this.id,
    required this.userId,
    required this.body,
    required this.timeAgo,
    required this.username,
    this.parentId,
    this.replies = const [],
    this.reactions = const [],
  });

  factory CommentItem.fromApi(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final replies = (json['replies'] as List<dynamic>? ?? [])
        .map((r) => CommentItem.fromApi(Map<String, dynamic>.from(r as Map)))
        .toList();
    final reactions = (json['reactions'] as List<dynamic>? ?? [])
        .map((r) => CommentReaction.fromApi(Map<String, dynamic>.from(r as Map)))
        .toList();

    return CommentItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? author['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? 'now',
      username: (author['username']?.toString() ?? 'user').replaceAll('_', ' '),
      parentId: json['parent_id']?.toString(),
      replies: replies,
      reactions: reactions,
    );
  }

  CommentItem copyWith({
    String? body,
    List<CommentReaction>? reactions,
    List<CommentItem>? replies,
  }) {
    return CommentItem(
      id: id,
      userId: userId,
      body: body ?? this.body,
      timeAgo: timeAgo,
      username: username,
      parentId: parentId,
      replies: replies ?? this.replies,
      reactions: reactions ?? this.reactions,
    );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final String postUid;
  final String authorName;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentsBottomSheet({
    super.key,
    required this.postUid,
    required this.authorName,
    this.onCommentCountChanged,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<CommentItem> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  String? _replyParentId;
  String? _replyingToUser;
  String? _currentUserId;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await SecureStorageService.getUserUid();
    await _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await PostsService.getComments(widget.postUid);
      setState(() {
        _comments = raw.map(CommentItem.fromApi).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = PostsService.errorMessage(e);
      });
    }
  }

  void _updateCommentInTree(String id, CommentItem updated) {
    setState(() {
      _comments = _comments.map((c) => _patchComment(c, id, updated)).toList();
    });
  }

  CommentItem _patchComment(CommentItem node, String id, CommentItem updated) {
    if (node.id == id) return updated;
    if (node.replies.isEmpty) return node;
    return node.copyWith(
      replies: node.replies.map((r) => _patchComment(r, id, updated)).toList(),
    );
  }

  CommentItem _removeFromTree(CommentItem node, String id) {
    return node.copyWith(
      replies: node.replies
          .where((r) => r.id != id)
          .map((r) => _removeFromTree(r, id))
          .toList(),
    );
  }

  void _removeCommentFromTree(String id) {
    setState(() {
      _comments = _comments
          .where((c) => c.id != id)
          .map((c) => _removeFromTree(c, id))
          .toList();
    });
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final count = await PostsService.addComment(
        widget.postUid,
        body: text,
        parentId: _replyParentId,
      );

      widget.onCommentCountChanged?.call(count);
      _controller.clear();
      _cancelReply();
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostsService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reactToComment(CommentItem comment, String emoji) async {
    try {
      final reactions = await PostsService.reactComment(widget.postUid, comment.id, emoji);
      _updateCommentInTree(
        comment.id,
        comment.copyWith(
          reactions: reactions.map(CommentReaction.fromApi).toList(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostsService.errorMessage(e))),
        );
      }
    }
  }

  Future<void> _deleteComment(CommentItem comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final count = await PostsService.deleteComment(widget.postUid, comment.id);
      widget.onCommentCountChanged?.call(count);
      _removeCommentFromTree(comment.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostsService.errorMessage(e))),
        );
      }
    }
  }

  Future<void> _editComment(CommentItem comment) async {
    final editController = TextEditingController(text: comment.body);
    final newBody = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit comment'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update your comment'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newBody == null || newBody.isEmpty || newBody == comment.body) return;

    try {
      await PostsService.updateComment(widget.postUid, comment.id, body: newBody);
      _updateCommentInTree(comment.id, comment.copyWith(body: newBody));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostsService.errorMessage(e))),
        );
      }
    }
  }

  Future<void> _reportComment(CommentItem comment) async {
    try {
      await PostsService.reportComment(widget.postUid, comment.id, reason: 'Inappropriate');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment reported. Thank you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostsService.errorMessage(e))),
        );
      }
    }
  }

  void _openActions(CommentItem comment, {required bool isReply}) {
    showCommentActionSheet(
      context,
      commentBody: comment.body,
      isOwn: comment.userId == _currentUserId,
      onReaction: (emoji) => _reactToComment(comment, emoji),
      onReply: isReply ? null : () => _startReply(comment),
      onEdit: () => _editComment(comment),
      onDelete: () => _deleteComment(comment),
      onReport: () => _reportComment(comment),
    );
  }

  void _startReply(CommentItem comment) {
    setState(() {
      _replyParentId = comment.id;
      _replyingToUser = comment.username;
      _controller.text = '@${comment.username.split(' ').first} ';
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyingToUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _dragHandle(),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildBody(scrollController)),
                if (_replyingToUser != null) _replyBanner(),
                _inputField(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.secondaryText(context))),
            TextButton(onPressed: _loadComments, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet. Be the first!',
          style: TextStyle(color: AppColors.secondaryText(context)),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _comments.length,
      itemBuilder: (_, i) => _commentThread(_comments[i]),
    );
  }

  Widget _commentThread(CommentItem comment) {
    final expanded = _expanded.contains(comment.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _commentTile(comment: comment, isReply: false),
        if (comment.replies.isNotEmpty && !expanded)
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 2, bottom: 4),
            child: GestureDetector(
              onTap: () => setState(() => _expanded.add(comment.id)),
              child: Text(
                'View ${comment.replies.length} repl${comment.replies.length > 1 ? 'ies' : 'y'}',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context)),
              ),
            ),
          ),
        if (expanded) ...[
          ...comment.replies.map((r) => _commentTile(comment: r, isReply: true)),
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 2, bottom: 6),
            child: GestureDetector(
              onTap: () => setState(() => _expanded.remove(comment.id)),
              child: Text(
                'Hide replies',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mutedText(context),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _replyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: AppColors.primaryBackground(context).withValues(alpha: 0.6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to $_replyingToUser',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText(context)),
            ),
          ),
          GestureDetector(onTap: _cancelReply, child: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }

  Widget _inputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _sending
                ? null
                : () {
                    showCommentActionSheet(
                      context,
                      commentBody: '',
                      isOwn: false,
                      onReaction: (emoji) {
                        if (_controller.text.isEmpty) {
                          _controller.text = emoji;
                        } else {
                          _controller.text = '${_controller.text} $emoji';
                        }
                      },
                    );
                  },
            icon: Icon(Iconsax.emoji_happy, color: AppColors.buttonColor(context)),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_sending,
              style: TextStyle(fontSize: 14, color: AppColors.primaryText(context)),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: AppColors.mutedText(context), fontSize: 14),
                filled: true,
                fillColor: AppColors.primaryBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _sending ? null : _sendComment,
            icon: _sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.buttonColor(context),
                    ),
                  )
                : Icon(Iconsax.send_1, color: AppColors.buttonColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    final words = text.split(' ');
    return RichText(
      text: TextSpan(
        children: words.map((word) {
          final isMention = word.startsWith('@');
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isMention ? FontWeight.w600 : FontWeight.normal,
              color: isMention
                  ? AppColors.buttonColor(context)
                  : AppColors.primaryText(context),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _reactionsRow(CommentItem comment) {
    if (comment.reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: comment.reactions.map((r) {
          return GestureDetector(
            onTap: () => _reactToComment(comment, r.emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: r.mine
                    ? AppColors.buttonColor(context).withValues(alpha: 0.15)
                    : AppColors.primaryBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: r.mine
                      ? AppColors.buttonColor(context).withValues(alpha: 0.4)
                      : AppColors.borderLine(context).withValues(alpha: 0.4),
                ),
              ),
              child: Text('${r.emoji} ${r.count}', style: const TextStyle(fontSize: 11)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _commentTile({required CommentItem comment, required bool isReply}) {
    return GestureDetector(
      onLongPress: () => _openActions(comment, isReply: isReply),
      child: Padding(
        padding: EdgeInsets.only(left: isReply ? 40 : 12, right: 8, top: 6, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 12 : 16,
              backgroundColor: AppColors.buttonColor(context).withValues(alpha: 0.15),
              child: Text(
                comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: isReply ? 10 : 12,
                  color: AppColors.buttonColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                  _buildText(comment.body),
                  _reactionsRow(comment),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        comment.timeAgo,
                        style: TextStyle(fontSize: 11, color: AppColors.secondaryText(context)),
                      ),
                      const SizedBox(width: 12),
                      if (!isReply)
                        GestureDetector(
                          onTap: () => _startReply(comment),
                          child: Text(
                            'Reply',
                            style: TextStyle(fontSize: 11, color: AppColors.secondaryText(context)),
                          ),
                        ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _reactToComment(comment, '❤️'),
                        child: Text(
                          'Like',
                          style: TextStyle(fontSize: 11, color: AppColors.secondaryText(context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => _openActions(comment, isReply: isReply),
              icon: Icon(Icons.more_horiz, size: 18, color: AppColors.mutedText(context)),
            ),
          ],
        ),
      ),
    );
  }
}
