import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../core/app_colors.dart';
import '../../core/image_filter_utils.dart';
import '../../core/media_edit_settings.dart';
import '../../core/media_overlay.dart';
import '../../core/video_source_helper.dart';

enum _EditorTool { filter, crop, emoji, text, adjust }

class MediaEditorResult {
  final Uint8List bytes;
  final String filename;
  final bool removed;
  final MediaEditSettings editSettings;

  const MediaEditorResult({
    required this.bytes,
    required this.filename,
    this.removed = false,
    this.editSettings = const MediaEditSettings(),
  });

  factory MediaEditorResult.deleted() {
    return MediaEditorResult(bytes: Uint8List(0), filename: '', removed: true);
  }
}

class MediaEditorScreen extends StatefulWidget {
  final Uint8List initialBytes;
  final String filename;
  final bool isVideo;
  final MediaEditSettings initialSettings;

  const MediaEditorScreen({
    super.key,
    required this.initialBytes,
    required this.filename,
    this.isVideo = false,
    this.initialSettings = const MediaEditSettings(),
  });

  static Future<MediaEditorResult?> open(
    BuildContext context, {
    required Uint8List bytes,
    required String filename,
    bool isVideo = false,
    MediaEditSettings initialSettings = const MediaEditSettings(),
  }) {
    return Navigator.of(context).push<MediaEditorResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MediaEditorScreen(
          initialBytes: bytes,
          filename: filename,
          isVideo: isVideo,
          initialSettings: initialSettings,
        ),
      ),
    );
  }

  @override
  State<MediaEditorScreen> createState() => _MediaEditorScreenState();
}

class _MediaEditorScreenState extends State<MediaEditorScreen> {
  final _cropController = CropController();
  final _captureKey = GlobalKey();
  final _textInput = TextEditingController();
  final _overlays = <MediaOverlay>[];
  int _overlayCounter = 0;

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  Uint8List _fullBytes = Uint8List(0);
  MemoryImage? _previewMemoryImage;
  bool _previewOptimizing = false;

  late ImageFilterPreset _selectedFilter;
  late double _brightness;
  late double _contrast;
  late double _saturation;
  late ColorFilter _cachedPreviewFilter;
  late final ValueNotifier<ColorFilter> _previewFilterNotifier;
  late final ValueNotifier<_EditorTool> _toolNotifier;
  late final ValueNotifier<String> _selectedFilterNameNotifier;
  late final ValueNotifier<int> _adjustRevisionNotifier;

  bool _saving = false;
  String? _selectedOverlayId;
  String _textStyle = 'Classic';
  Color _textColor = Colors.white;

  // Overlay gesture (scale handles pan + pinch together).
  Offset? _overlayFocalStart;
  Offset? _overlayPositionStart;
  double? _overlayScaleStart;

  static const _emojiOptions = [
    '😀', '😍', '🔥', '✨', '💯', '🎉', '❤️', '😂', '🙌', '👏',
    '💚', '⭐', '🌟', '💪', '😎', '🥳', '💖', '😊', '🤩', '👍',
  ];

  static const _textStyles = ['Classic', 'Neon', 'Bold', 'Typewriter'];

  MediaEditSettings get _currentSettings => MediaEditSettings(
        filterName: _selectedFilter.name,
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
      );

  void _syncPreviewFilter() {
    _cachedPreviewFilter = ImageFilterUtils.previewColorFilter(
      preset: _selectedFilter,
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
    );
  }

  MediaOverlay? get _selectedOverlay {
    if (_selectedOverlayId == null) return null;
    for (final o in _overlays) {
      if (o.id == _selectedOverlayId) return o;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fullBytes = widget.initialBytes;
    _previewMemoryImage = MemoryImage(_fullBytes);
    _selectedFilter = ImageFilterUtils.byName(widget.initialSettings.filterName);
    _brightness = widget.initialSettings.brightness;
    _contrast = widget.initialSettings.contrast;
    _saturation = widget.initialSettings.saturation;
    _syncPreviewFilter();
    _previewFilterNotifier = ValueNotifier(_cachedPreviewFilter);
    _toolNotifier = ValueNotifier(_EditorTool.filter);
    _selectedFilterNameNotifier = ValueNotifier(_selectedFilter.name);
    _adjustRevisionNotifier = ValueNotifier(0);

    if (widget.isVideo) {
      _initVideo();
    } else {
      _optimizePreviewAsync();
    }
  }

  Future<void> _optimizePreviewAsync() async {
    if (_previewOptimizing) return;
    _previewOptimizing = true;
    try {
      final optimized = await ImageFilterUtils.createPreviewBytesAsync(_fullBytes);
      if (!mounted) return;
      _previewMemoryImage?.evict();
      setState(() => _previewMemoryImage = MemoryImage(optimized));
    } finally {
      _previewOptimizing = false;
    }
  }

  void _refreshPreviewCache(Uint8List fullBytes) {
    _previewMemoryImage?.evict();
    _fullBytes = fullBytes;
    _previewMemoryImage = MemoryImage(fullBytes);
    _previewOptimizing = false;
    _optimizePreviewAsync();
  }

  void _selectFilter(ImageFilterPreset preset) {
    if (preset.name == _selectedFilter.name) return;
    _selectedFilter = preset;
    _syncPreviewFilter();
    _previewFilterNotifier.value = _cachedPreviewFilter;
    _selectedFilterNameNotifier.value = preset.name;
  }

  void _setTool(_EditorTool tool) {
    if (_toolNotifier.value == tool) return;
    _toolNotifier.value = tool;
  }

  void _updateAdjust({
    double? brightness,
    double? contrast,
    double? saturation,
  }) {
    var changed = false;
    if (brightness != null && _brightness != brightness) {
      _brightness = brightness;
      changed = true;
    }
    if (contrast != null && _contrast != contrast) {
      _contrast = contrast;
      changed = true;
    }
    if (saturation != null && _saturation != saturation) {
      _saturation = saturation;
      changed = true;
    }
    if (!changed) return;
    _syncPreviewFilter();
    _previewFilterNotifier.value = _cachedPreviewFilter;
    _adjustRevisionNotifier.value++;
  }

  Future<void> _initVideo() async {
    try {
      final controller = await VideoSourceHelper.createController(
        widget.initialBytes,
        widget.filename,
      );
      if (!mounted || controller == null) return;
      await controller.play();
      setState(() {
        _videoController = controller;
        _videoReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _videoReady = false);
    }
  }

  @override
  void dispose() {
    _textInput.dispose();
    _videoController?.dispose();
    _previewFilterNotifier.dispose();
    _toolNotifier.dispose();
    _selectedFilterNameNotifier.dispose();
    _adjustRevisionNotifier.dispose();
    super.dispose();
  }

  Future<Uint8List> _captureEditedImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return _fullBytes;

    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return _fullBytes;
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _renderFinalBytes() async {
    if (_overlays.isNotEmpty) {
      return _captureEditedImage();
    }
    if (!_currentSettings.hasEffect) {
      return _fullBytes;
    }
    return ImageCompositor.renderFinal(
      sourceBytes: _fullBytes,
      filter: _selectedFilter,
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.isVideo) {
        if (!mounted) return;
        Navigator.pop(
          context,
          MediaEditorResult(
            bytes: widget.initialBytes,
            filename: widget.filename,
            editSettings: _currentSettings,
          ),
        );
        return;
      }

      final bytes = await _renderFinalBytes();

      if (!mounted) return;
      Navigator.pop(
        context,
        MediaEditorResult(
          bytes: bytes,
          filename: widget.filename,
          editSettings: _currentSettings,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onCropDone(Uint8List cropped) {
    _refreshPreviewCache(cropped);
    _toolNotifier.value = _EditorTool.filter;
  }

  void _addEmoji(String emoji) {
    setState(() {
      final overlay = MediaOverlay.emoji(
        id: 'o_${_overlayCounter++}',
        emoji: emoji,
        position: const Offset(110, 110),
      );
      _overlays.add(overlay);
      _selectedOverlayId = overlay.id;
    });
  }

  void _addText() {
    final value = _textInput.text.trim();
    if (value.isEmpty) return;
    setState(() {
      final overlay = MediaOverlay.text(
        id: 'o_${_overlayCounter++}',
        text: value,
        textColor: _textColor,
        textStyle: _textStyle,
        position: const Offset(70, 150),
      );
      _overlays.add(overlay);
      _selectedOverlayId = overlay.id;
      _textInput.clear();
    });
  }

  void _removeSelectedOverlay() {
    final id = _selectedOverlayId;
    if (id == null) return;
    setState(() {
      _overlays.removeWhere((o) => o.id == id);
      _selectedOverlayId = null;
    });
  }

  Widget _filteredPreview({required Widget child}) {
    return ValueListenableBuilder<ColorFilter>(
      valueListenable: _previewFilterNotifier,
      builder: (context, filter, _) => ColorFiltered(colorFilter: filter, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(accent),
            Expanded(
              child: ValueListenableBuilder<_EditorTool>(
                valueListenable: _toolNotifier,
                builder: (context, tool, _) => _previewArea(accent, tool),
              ),
            ),
            ValueListenableBuilder<_EditorTool>(
              valueListenable: _toolNotifier,
              builder: (context, tool, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedOverlay != null && (tool == _EditorTool.emoji || tool == _EditorTool.text))
                      _sizeSlider(accent),
                    if (tool == _EditorTool.filter) _filterStrip(accent),
                    if (tool == _EditorTool.emoji) _emojiStrip(),
                    if (tool == _EditorTool.text) _textPanel(accent),
                    if (tool == _EditorTool.adjust) _adjustPanel(),
                    if (tool == _EditorTool.crop && !widget.isVideo) _cropRatioBar(accent),
                  ],
                );
              },
            ),
            _toolBar(accent),
          ],
        ),
      ),
    );
  }

  Widget _topBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _saving ? null : () => Navigator.pop(context, MediaEditorResult.deleted()),
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
          ),
          IconButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, color: Colors.white, size: 18),
            label: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _previewArea(Color accent, _EditorTool tool) {
    if (tool == _EditorTool.crop && !widget.isVideo) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Crop(
          controller: _cropController,
          image: _fullBytes,
          withCircleUi: false,
          baseColor: Colors.black,
          maskColor: Colors.black.withValues(alpha: 0.55),
          onCropped: (result) {
            if (result is CropSuccess) _onCropDone(result.croppedImage);
          },
          radius: 12,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: RepaintBoundary(
            key: _captureKey,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.isVideo)
                    ColoredBox(
                      color: Colors.black,
                      child: _videoReady && _videoController != null
                          ? _filteredPreview(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            )
                          : Center(child: Icon(Iconsax.video_play, size: 56, color: accent)),
                    )
                  else if (_previewMemoryImage != null)
                    RepaintBoundary(
                      child: _filteredPreview(
                        child: Image(
                          key: ValueKey(_previewMemoryImage),
                          image: _previewMemoryImage!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                          isAntiAlias: false,
                        ),
                      ),
                    ),
                  ..._overlays.map((o) => _buildOverlay(o, accent)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlay(MediaOverlay overlay, Color accent) {
    final selected = overlay.id == _selectedOverlayId;
    final display = overlay.kind == OverlayKind.emoji ? overlay.emoji : overlay.text;

    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onTap: () => setState(() => _selectedOverlayId = overlay.id),
        onLongPress: () => setState(() {
          _overlays.remove(overlay);
          if (_selectedOverlayId == overlay.id) _selectedOverlayId = null;
        }),
        onScaleStart: (d) {
          _overlayFocalStart = d.focalPoint;
          _overlayPositionStart = overlay.position;
          _overlayScaleStart = overlay.scale;
          setState(() => _selectedOverlayId = overlay.id);
        },
        onScaleUpdate: (d) {
          if (_overlayFocalStart == null || _overlayPositionStart == null || _overlayScaleStart == null) {
            return;
          }
          setState(() {
            overlay.position = _overlayPositionStart! + (d.focalPoint - _overlayFocalStart!);
            overlay.scale = (_overlayScaleStart! * d.scale).clamp(0.4, 3.5);
          });
        },
        onScaleEnd: (_) {
          _overlayFocalStart = null;
          _overlayPositionStart = null;
          _overlayScaleStart = null;
        },
        child: Container(
          padding: selected ? const EdgeInsets.all(4) : EdgeInsets.zero,
          decoration: selected
              ? BoxDecoration(
                  border: Border.all(color: accent, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(display, style: overlay.resolveTextStyle()),
        ),
      ),
    );
  }

  Widget _sizeSlider(Color accent) {
    final overlay = _selectedOverlay!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          const Icon(Iconsax.size, color: Colors.white70, size: 16),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accent,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: overlay.scale,
                min: 0.4,
                max: 3.5,
                onChanged: (v) => setState(() => overlay.scale = v),
              ),
            ),
          ),
          Text('${(overlay.scale * 100).round()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          IconButton(
            onPressed: _removeSelectedOverlay,
            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _filterStrip(Color accent) {
    final preview = _previewMemoryImage;
    if (preview == null) return const SizedBox(height: 96);

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: ImageFilterUtils.presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final preset = ImageFilterUtils.presets[i];
          return ValueListenableBuilder<String>(
            valueListenable: _selectedFilterNameNotifier,
            builder: (context, selectedName, _) => _FilterChip(
              key: ValueKey(preset.name),
              preset: preset,
              selected: preset.name == selectedName,
              accent: accent,
              previewImage: preview,
              isVideo: widget.isVideo,
              onTap: () => _selectFilter(preset),
            ),
          );
        },
      ),
    );
  }

  Widget _emojiStrip() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _emojiOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _addEmoji(_emojiOptions[i]),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Text(_emojiOptions[i], style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textPanel(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textInput,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add text...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _addText(),
                ),
              ),
              IconButton(onPressed: _addText, icon: Icon(Iconsax.add_circle, color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _textStyles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final style = _textStyles[i];
                final selected = _textStyle == style;
                return GestureDetector(
                  onTap: () => setState(() => _textStyle = style),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? accent.withValues(alpha: 0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? accent : Colors.white24),
                    ),
                    child: Text(style, style: TextStyle(color: selected ? accent : Colors.white70, fontSize: 11)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _adjustPanel() {
    return ValueListenableBuilder<int>(
      valueListenable: _adjustRevisionNotifier,
      builder: (context, revision, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              _sliderRow('Brightness', _brightness, -0.4, 0.4, (v) => _updateAdjust(brightness: v)),
              _sliderRow('Contrast', _contrast, 0.5, 1.8, (v) => _updateAdjust(contrast: v)),
              _sliderRow('Saturation', _saturation, 0, 2, (v) => _updateAdjust(saturation: v)),
            ],
          ),
        );
      },
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 82, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.buttonColor(context),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Widget _cropRatioBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: OutlinedButton(
        onPressed: () => _cropController.crop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: accent.withValues(alpha: 0.6)),
        ),
        child: const Text('Apply crop'),
      ),
    );
  }

  Widget _toolBar(Color accent) {
    final tools = widget.isVideo
        ? [_EditorTool.filter, _EditorTool.emoji, _EditorTool.text, _EditorTool.adjust]
        : _EditorTool.values;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
      child: ValueListenableBuilder<_EditorTool>(
        valueListenable: _toolNotifier,
        builder: (context, activeTool, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tools.map((tool) {
              final selected = activeTool == tool;
              final (icon, label) = switch (tool) {
                _EditorTool.filter => (Iconsax.colorfilter, 'Filters'),
                _EditorTool.crop => (Iconsax.crop, 'Crop'),
                _EditorTool.emoji => (Iconsax.emoji_happy, 'Emoji'),
                _EditorTool.text => (Iconsax.text, 'Text'),
                _EditorTool.adjust => (Iconsax.setting_4, 'Adjust'),
              };
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _setTool(tool),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: selected ? accent : Colors.white54, size: 22),
                        const SizedBox(height: 4),
                        Text(label, style: TextStyle(color: selected ? accent : Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final ImageFilterPreset preset;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final MemoryImage? previewImage;
  final bool isVideo;

  const _FilterChip({
    super.key,
    required this.preset,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.previewImage,
    this.isVideo = false,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  late final ColorFilter _filter;
  Widget? _thumb;

  @override
  void initState() {
    super.initState();
    _filter = ImageFilterUtils.cachedPresetFilter(widget.preset);
    _thumb = _buildThumb();
  }

  @override
  void didUpdateWidget(covariant _FilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewImage != widget.previewImage || oldWidget.isVideo != widget.isVideo) {
      _thumb = _buildThumb();
    }
  }

  Widget _buildThumb() {
    if (widget.isVideo) {
      return ColoredBox(
        color: const Color(0xFF2A2A2A),
        child: Center(
          child: Icon(Iconsax.video, color: widget.accent.withValues(alpha: 0.8), size: 18),
        ),
      );
    }
    if (widget.previewImage != null) {
      return Image(
        image: ResizeImage(widget.previewImage!, width: 56, height: 56),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.none,
      );
    }
    return const ColoredBox(color: Color(0xFF2A2A2A));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.selected ? widget.accent : Colors.white24,
                  width: widget.selected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: RepaintBoundary(
                  child: ColorFiltered(
                    colorFilter: _filter,
                    child: _thumb ?? const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.preset.name,
              style: TextStyle(
                color: widget.selected ? widget.accent : Colors.white70,
                fontSize: 10,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
