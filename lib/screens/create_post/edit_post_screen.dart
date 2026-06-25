import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/app_colors.dart';
import '../../screens/home_screen/rejected_home_screen.dart';

class EditPostScreen extends StatefulWidget {
  final PostData post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _captionCtrl;
  bool _isSaving = false;

  bool get _isDirty => _captionCtrl.text != widget.post.caption;

  @override
  void initState() {
    super.initState();
    _captionCtrl = TextEditingController(text: widget.post.caption);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground(context),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.primaryText(context),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Post',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            _isSaving
                ? const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
                : TextButton(
              onPressed: null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.buttonColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MediaPreview(post: widget.post),

            const SizedBox(height: 16),

            _SectionLabel(label: 'Caption'),
            const SizedBox(height: 8),
            _CaptionField(controller: _captionCtrl),

            const SizedBox(height: 16),

            // ── Post-type badge info (read-only) ───────────────────────────
            _PostTypeBadgeTile(post: widget.post),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MediaPreview — shows the existing image / video thumbnail (non-editable)
// ─────────────────────────────────────────────────────────────────────────────
class _MediaPreview extends StatelessWidget {
  final PostData post;
  const _MediaPreview({required this.post});

  String? get _imageUrl =>
      post.imagePath ?? post.thumbnailPath ?? post.productImagePath;

  bool get _isVideo => post.thumbnailPath != null && post.imagePath == null;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          _imageUrl != null
              ? Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
            _imageUrl!,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _Placeholder(
              icon: _isVideo ? Iconsax.video : Iconsax.image,
            ),
          )
              : _Placeholder(icon: Iconsax.image),

          // "Can't change media" label overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black.withOpacity(0.45),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.white70, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Media cannot be changed after posting',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          if (_isVideo)
            const Center(
              child: _PlayIcon(),
            ),
        ],
      ),
    );
  }
}

class _PlayIcon extends StatelessWidget {
  const _PlayIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  const _Placeholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      color: AppColors.secondaryBackground(context),
      child: Center(
        child: Icon(icon, size: 36, color: AppColors.mutedText(context)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CaptionField
// ─────────────────────────────────────────────────────────────────────────────
class _CaptionField extends StatelessWidget {
  final TextEditingController controller;
  const _CaptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        maxLength: 2200,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.primaryText(context),
        ),
        decoration: InputDecoration(
          hintText: 'Write a caption…',
          hintStyle: TextStyle(color: AppColors.secondaryText(context)),
          border: InputBorder.none,
          counterStyle:
          TextStyle(fontSize: 11, color: AppColors.secondaryText(context)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PostTypeBadgeTile — info-only row showing the post type
// ─────────────────────────────────────────────────────────────────────────────
class _PostTypeBadgeTile extends StatelessWidget {
  final PostData post;
  const _PostTypeBadgeTile({required this.post});

  // Mirror the badge colours from the post widgets.
  _BadgeStyle get _style {
    if (post.thumbnailPath != null && post.imagePath == null) {
      return _BadgeStyle(
        label: 'Video',
        bg: const Color(0xFFFBEAF0),
        fg: const Color(0xFF993556),
        icon: Iconsax.video,
      );
    }
    if (post.productName != null) {
      return _BadgeStyle(
        label: 'Product',
        bg: const Color(0xFFEAF3DE),
        fg: const Color(0xFF3B6D11),
        icon: Iconsax.bag,
      );
    }
    return _BadgeStyle(
      label: 'Photo',
      bg: const Color(0xFFE6F1FB),
      fg: const Color(0xFF185FA5),
      icon: Iconsax.image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Iconsax.tag, size: 18, color: AppColors.secondaryText(context)),
          const SizedBox(width: 10),
          Text(
            'Post type',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryText(context),
            ),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 12, color: s.fg),
                const SizedBox(width: 4),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: s.fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;
  const _BadgeStyle({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryText(context),
        letterSpacing: 0.3,
      ),
    );
  }
}