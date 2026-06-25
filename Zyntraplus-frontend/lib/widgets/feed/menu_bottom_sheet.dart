import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/app_colors.dart';
import '../../screens/home_screen/rejected_home_screen.dart';

void showPostMenuBottomSheet(
  BuildContext context, {
  required String authorName,
  required bool isOwnPost,
  PostData? post,
  VoidCallback? onDelete,
  VoidCallback? onEdit,
  VoidCallback? onArchive,
  bool isArchived = false,
}) {
  final parentContext = context;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.primaryBackground(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => isOwnPost
        ? _OwnPostMenu(
            parentContext: parentContext,
            post: post,
            onDelete: onDelete,
            onEdit: onEdit,
            onArchive: onArchive,
            isArchived: isArchived,
          )
        : _OtherPostMenu(authorName: authorName),
  );
}

class _OwnPostMenu extends StatelessWidget {
  final BuildContext parentContext;
  final PostData? post;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final bool isArchived;

  const _OwnPostMenu({
    required this.parentContext,
    this.post,
    this.onDelete,
    this.onEdit,
    this.onArchive,
    this.isArchived = false,
  });

  void _confirmDelete() {
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground(parentContext),
        title: Text('Delete post?', style: TextStyle(color: AppColors.primaryText(parentContext))),
        content: Text(
          'This action cannot be undone. The post will be permanently removed.',
          style: TextStyle(color: AppColors.secondaryText(parentContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          _MenuTile(
            icon: Iconsax.edit,
            label: 'Edit post',
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
          ),
          _MenuTile(
            icon: Iconsax.copy,
            label: 'Copy link',
            onTap: () => Navigator.pop(context),
          ),
          if (onArchive != null)
            _MenuTile(
              icon: isArchived ? Iconsax.refresh : Iconsax.archive,
              label: isArchived ? 'Restore post' : 'Archive post',
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _MenuTile(
            icon: Iconsax.trash,
            label: 'Delete post',
            color: const Color(0xFFE24B4A),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) => _confirmDelete());
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OtherPostMenu extends StatelessWidget {
  final String authorName;

  const _OtherPostMenu({required this.authorName});

  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Block $authorName?'),
        content: Text("They won't be able to see your posts or interact with you."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Block', style: TextStyle(color: Color(0xFFE24B4A)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          _MenuTile(icon: Iconsax.flag, label: 'Report post', color: const Color(0xFFE24B4A), onTap: () => Navigator.pop(context)),
          _MenuTile(
            icon: Iconsax.slash,
            label: 'Block $authorName',
            color: const Color(0xFFE24B4A),
            onTap: () {
              Navigator.pop(context);
              _confirmBlock(context);
            },
          ),
          _MenuTile(icon: Iconsax.copy, label: 'Copy link', onTap: () => Navigator.pop(context)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.borderLine(context), borderRadius: BorderRadius.circular(2)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryText(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c, size: 20),
      title: Text(label, style: TextStyle(fontSize: 14, color: c)),
    );
  }
}
