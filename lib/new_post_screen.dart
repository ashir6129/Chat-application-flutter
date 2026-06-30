import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'api_services/media_service.dart';
import 'api_services/post_services.dart';
import 'core/app_colors.dart';
import 'core/feed_refresh.dart';
import 'core/image_filter_utils.dart';
import 'core/media_edit_settings.dart';
import 'core/profile_refresh.dart';
import 'core/secure_storage_service.dart';
import 'models/poll_data.dart';
import 'screens/home_screen/add_product_to_post_screen.dart';
import 'screens/home_screen/review_post_screen.dart';
import 'widgets/post/media_editor_screen.dart';
import 'widgets/post/post_attachment_sheets.dart';

enum PostCreateMode { text, image, video, reel }

class _AttachedMedia {
  final Uint8List bytes;
  final String filename;
  final bool isVideo;
  final MediaEditSettings editSettings;

  const _AttachedMedia({
    required this.bytes,
    required this.filename,
    required this.isVideo,
    this.editSettings = const MediaEditSettings(),
  });

  _AttachedMedia copyWith({
    Uint8List? bytes,
    String? filename,
    bool? isVideo,
    MediaEditSettings? editSettings,
  }) {
    return _AttachedMedia(
      bytes: bytes ?? this.bytes,
      filename: filename ?? this.filename,
      isVideo: isVideo ?? this.isVideo,
      editSettings: editSettings ?? this.editSettings,
    );
  }
}

class SimplePostScreen extends StatefulWidget {
  const SimplePostScreen({super.key, this.mode = PostCreateMode.text});

  final PostCreateMode mode;

  @override
  State<SimplePostScreen> createState() => _SimplePostScreenState();
}

class _SimplePostScreenState extends State<SimplePostScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final List<_AttachedMedia> _media = [];
  bool _loading = false;
  String _displayName = 'You';
  String _visibility = 'Public';
  String? _location;
  String? _attachedProduct;
  AttachedProduct? _attachedProductData;
  String? _attachedPoll;
  List<String> _pollOptions = [];
  int _pollDurationDays = 7;
  final Set<String> _activeChips = {};
  static const _maxMedia = 10;

  String _resolvePostType() {
    final hasVideo = _media.any((m) => m.isVideo);
    final hasImage = _media.any((m) => !m.isVideo);
    if (hasVideo && hasImage) return 'mixed';
    if (hasVideo) return widget.mode == PostCreateMode.reel ? 'reel' : 'video';
    if (hasImage) return 'image';
    return 'text';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await SecureStorageService.getUserUid();
    if (!mounted) return;
    setState(() => _displayName = uid != null ? 'You' : 'Guest');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _imageFilename(String raw, int index) {
    final name = raw.trim();
    if (name.isEmpty || name == 'blob' || !name.contains('.')) {
      return 'photo_$index.jpg';
    }
    return name;
  }

  String _videoFilename(String raw) {
    final name = raw.trim();
    if (name.isEmpty || name == 'blob' || !name.contains('.')) {
      return 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    }
    return name;
  }

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files.isEmpty) return;

      final additions = <_AttachedMedia>[];
      for (var i = 0; i < files.length; i++) {
        if (_media.length + additions.length >= _maxMedia) break;
        final bytes = await files[i].readAsBytes();
        additions.add(
          _AttachedMedia(
            bytes: bytes,
            filename: _imageFilename(files[i].name, _media.length + i),
            isVideo: false,
          ),
        );
      }

      setState(() => _media.addAll(additions));
    } catch (_) {}
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;

      if (_media.length >= _maxMedia) {
        _showMessage('Maximum $_maxMedia files allowed');
        return;
      }

      final bytes = await file.readAsBytes();
      setState(() {
        _media.add(
          _AttachedMedia(
            bytes: bytes,
            filename: _videoFilename(file.name),
            isVideo: true,
          ),
        );
      });
    } catch (_) {}
  }

  void _removeMedia(int index) {
    setState(() => _media.removeAt(index));
  }

  void _openMediaEditor(int index) async {
    final item = _media[index];
    final result = await MediaEditorScreen.open(
      context,
      bytes: item.bytes,
      filename: item.filename,
      isVideo: item.isVideo,
      initialSettings: item.editSettings,
    );

    if (!mounted || result == null) return;

    if (result.removed) {
      _removeMedia(index);
      return;
    }

    setState(() {
      _media[index] = item.copyWith(
        bytes: result.bytes,
        filename: result.filename,
        editSettings: result.editSettings,
      );
    });
  }

  Future<void> _goToReview() async {
    final caption = _controller.text.trim();
    if (caption.isEmpty && _media.isEmpty && _attachedPoll == null) {
      _showMessage('Add a caption, photo, video, or poll');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPostScreen(
          caption: caption,
          visibility: _visibility,
          location: _location,
          mediaCount: _media.length,
          product: _attachedProductData,
          isPublishing: _loading,
          onPublish: _submitPost,
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final caption = _controller.text.trim();
    if (caption.isEmpty && _media.isEmpty && _attachedPoll == null) {
      _showMessage('Add a caption, photo, video, or poll');
      return;
    }

    setState(() => _loading = true);

    try {
      final mediaUrls = _media.isEmpty
          ? <String>[]
          : await MediaService.uploadFiles(
              bytesList: _media.map((m) => m.bytes).toList(),
              filenames: _media.map((m) => m.filename).toList(),
            );

      final postType = _resolvePostType();
      Map<String, dynamic>? postMeta;
      if (_attachedPoll != null && _pollOptions.length >= 2) {
        postMeta = {
          'poll': PollData(
            question: _attachedPoll!,
            options: _pollOptions,
          ).toCreateJson(durationDays: _pollDurationDays),
        };
      }
      if (_attachedProductData != null) {
        postMeta = {
          ...?postMeta,
          'product': {
            'id': _attachedProductData!.id,
            'title': _attachedProductData!.title,
            'price': _attachedProductData!.price,
            'currency': _attachedProductData!.currency,
            'image_url': _attachedProductData!.imageUrl,
            'is_resell': _attachedProductData!.isResell,
          },
        };
      }

      final created = await PostsService.createPost(
        caption: caption,
        postType: postType,
        mediaUrls: mediaUrls,
        location: _location,
        mediaMeta: _media.map((m) => m.editSettings.toJson()).toList(),
        postMeta: postMeta,
      );

      FeedRefresh.prepend(created);
      ProfileRefresh.trigger(silent: true);
      if (!mounted) return;
      // Pop both ReviewPostScreen and SimplePostScreen
      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name != null);
    } catch (e) {
      _showMessage(PostsService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _insertAtCursor(String value) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final updated = text.replaceRange(start, end, value);
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  Future<void> _pickLocation() async {
    final input = TextEditingController(text: _location ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final accent = AppColors.buttonColor(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(ctx),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Icon(Iconsax.location, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add location', style: TextStyle(color: AppColors.primaryText(ctx), fontWeight: FontWeight.w700, fontSize: 17)),
                          Text('Where was this taken?', style: TextStyle(color: AppColors.secondaryText(ctx), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: input,
                  autofocus: true,
                  style: TextStyle(color: AppColors.primaryText(ctx)),
                  decoration: postSheetInputDecoration(ctx, hint: 'City, place or address'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final value = input.text.trim();
                      if (value.isEmpty) return;
                      Navigator.pop(ctx);
                      setState(() {
                        _location = value;
                        _activeChips.add('Location');
                      });
                    },
                    style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Add location', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickHashtag() async {
    final input = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final accent = AppColors.buttonColor(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(ctx),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add hashtag', style: TextStyle(color: AppColors.primaryText(ctx), fontWeight: FontWeight.w700, fontSize: 17)),
                const SizedBox(height: 12),
                TextField(
                  controller: input,
                  autofocus: true,
                  style: TextStyle(color: AppColors.primaryText(ctx)),
                  decoration: postSheetInputDecoration(ctx, hint: 'travel, fitness, music'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final raw = input.text.trim().replaceAll('#', '');
                      if (raw.isEmpty) return;
                      Navigator.pop(ctx);
                      setState(() => _activeChips.add('Hashtag'));
                      _insertAtCursor('#$raw ');
                    },
                    style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Add hashtag'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProduct() async {
    final result = await Navigator.push<AttachedProduct>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductToPostScreen()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _attachedProductData = result;
      _attachedProduct = '${result.title} — ${result.formattedPrice}';
      _activeChips.add('Product');
    });
  }

  Future<void> _pickPoll() async {
    final qCtrl = TextEditingController(text: _attachedPoll ?? '');
    final optionCtrls = List.generate(
      4,
      (i) => TextEditingController(text: i < _pollOptions.length ? _pollOptions[i] : ''),
    );
    var durationDays = _pollDurationDays;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final accent = AppColors.buttonColor(ctx);
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(ctx),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: Icon(Iconsax.chart_2, color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Create poll', style: TextStyle(color: AppColors.primaryText(ctx), fontWeight: FontWeight.w700, fontSize: 17)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: qCtrl, style: TextStyle(color: AppColors.primaryText(ctx)), decoration: postSheetInputDecoration(ctx, hint: 'Ask a question')),
                    const SizedBox(height: 10),
                    ...List.generate(4, (i) => Padding(
                          padding: EdgeInsets.only(bottom: i == 3 ? 0 : 10),
                          child: TextField(
                            controller: optionCtrls[i],
                            style: TextStyle(color: AppColors.primaryText(ctx)),
                            decoration: postSheetInputDecoration(ctx, hint: 'Option ${i + 1}${i < 2 ? ' (required)' : ''}'),
                          ),
                        )),
                    const SizedBox(height: 14),
                    Text('Poll duration', style: TextStyle(color: AppColors.secondaryText(ctx), fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final d in [1, 3, 7, 14])
                          ChoiceChip(
                            label: Text('${d}d'),
                            selected: durationDays == d,
                            onSelected: (_) => setSheetState(() => durationDays = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final options = optionCtrls.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
                          if (qCtrl.text.trim().isEmpty || options.length < 2) return;
                          Navigator.pop(ctx);
                          setState(() {
                            _attachedPoll = qCtrl.text.trim();
                            _pollOptions = options;
                            _pollDurationDays = durationDays;
                            _activeChips.add('Poll');
                          });
                        },
                        style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Add poll'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickVisibility() async {
    const options = ['Public', 'Friends', 'Private'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.secondaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (o) => ListTile(
                  title: Text(o, style: TextStyle(color: AppColors.primaryText(ctx))),
                  trailing: _visibility == o ? Icon(Icons.check, color: AppColors.buttonColor(ctx)) : null,
                  onTap: () => Navigator.pop(ctx, o),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) setState(() => _visibility = picked);
  }

  void _showEmojiPicker() {
    const emojis = ['😀', '😍', '🔥', '✨', '❤️', '😂', '👏', '🎉', '💯', '🙌'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBackground(context),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: emojis
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _insertAtCursor('$e ');
                  },
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, accent),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileRow(context, accent),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 3,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 16,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                    if (_media.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _mediaPreviewGrid(context, accent),
                    ],
                    const SizedBox(height: 20),
                    _actionChips(context, accent),
                    if (_location != null || _attachedPoll != null || _attachedProduct != null) ...[
                      const SizedBox(height: 14),
                      _attachmentCards(context, accent),
                    ],
                    const SizedBox(height: 16),
                    _visibilityCard(context, accent),
                  ],
                ),
              ),
            ),
            _bottomToolbar(context),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.primaryText(context), size: 24),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loading ? null : _goToReview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(BuildContext context, Color accent) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: accent.withOpacity(0.15),
          child: Icon(Iconsax.user, color: accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _pickVisibility,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.global, size: 12, color: AppColors.secondaryText(context)),
                      const SizedBox(width: 4),
                      Text(
                        _visibility,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.secondaryText(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mediaPreviewGrid(BuildContext context, Color accent) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _media[index];
          return GestureDetector(
            onTap: () => _openMediaEditor(index),
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
                color: AppColors.secondaryBackground(context),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.isVideo)
                      ColoredBox(
                        color: Colors.black87,
                        child: Icon(Iconsax.video_play, color: accent, size: 36),
                      )
                    else
                      ColorFiltered(
                        colorFilter: item.editSettings.hasEffect
                            ? ImageFilterUtils.settingsToColorFilter(item.editSettings)
                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: Image.memory(item.bytes, fit: BoxFit.cover),
                      ),
                    if (item.isVideo)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.isVideo ? 'Video' : 'Photo',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionChips(BuildContext context, Color accent) {
    final chips = <(IconData, String, VoidCallback)>[
      (Iconsax.location, 'Location', _pickLocation),
      (Iconsax.hashtag, 'Hashtag', _pickHashtag),
      (Iconsax.shopping_bag, 'Product', _pickProduct),
      (Iconsax.chart_2, 'Poll', _pickPoll),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (c) {
                final active = _activeChips.contains(c.$2);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: c.$3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                            ? accent.withValues(alpha: 0.15)
                            : AppColors.secondaryBackground(context),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: active ? accent : AppColors.borderLine(context).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.$1, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text(
                            c.$2,
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
            .toList(),
      ),
    );
  }

  Widget _attachmentCards(BuildContext context, Color accent) {
    return Column(
      children: [
        if (_location != null)
          PostAttachmentCard(
            icon: Iconsax.location,
            title: 'Location',
            subtitle: _location!,
            onTap: _pickLocation,
            onRemove: () => setState(() {
              _location = null;
              _activeChips.remove('Location');
            }),
          ),
        if (_attachedProduct != null)
          PostAttachmentCard(
            icon: Iconsax.shopping_bag,
            title: 'Product',
            subtitle: _attachedProduct!,
            onTap: _pickProduct,
            onRemove: () => setState(() {
              _attachedProduct = null;
              _activeChips.remove('Product');
            }),
          ),
        if (_attachedPoll != null)
          PollPreviewCard(
            question: _attachedPoll!,
            options: _pollOptions.isEmpty ? const ['Option 1', 'Option 2'] : _pollOptions,
            onRemove: () => setState(() {
              _attachedPoll = null;
              _pollOptions = [];
              _activeChips.remove('Poll');
            }),
          ),
      ],
    );
  }

  Widget _visibilityCard(BuildContext context, Color accent) {
    final subtitle = switch (_visibility) {
      'Friends' => 'Only friends can see this post',
      'Private' => 'Only you can see this post',
      _ => 'Anyone can see this post',
    };

    return GestureDetector(
      onTap: _pickVisibility,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLine(context).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.global, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _visibility,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.mutedText(context)),
          ],
        ),
      ),
    );
  }

  Widget _bottomToolbar(BuildContext context) {
    final color = AppColors.secondaryText(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLine(context).withOpacity(0.4))),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: _pickImages, icon: Icon(Iconsax.gallery, color: color)),
          IconButton(onPressed: _pickVideo, icon: Icon(Iconsax.video, color: color)),
          IconButton(
            onPressed: () => _showMessage('Voice posts coming soon'),
            icon: Icon(Iconsax.microphone_2, color: color),
          ),
          IconButton(onPressed: _showEmojiPicker, icon: Icon(Iconsax.emoji_happy, color: color)),
          IconButton(onPressed: _pickPoll, icon: Icon(Iconsax.chart_2, color: color)),
        ],
      ),
    );
  }
}

