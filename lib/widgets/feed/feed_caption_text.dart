import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Feed post caption.
/// - Text-only (no media), ≤20 chars → centered, bold, responsive size.
/// - Text-only (no media), >5 lines → "Read more" collapse.
/// - With media, >2 lines → "Read more" collapse.
/// - Otherwise → regular left-aligned style.
class FeedCaptionText extends StatefulWidget {
  final String caption;
  final EdgeInsetsGeometry padding;
  final bool hasMedia;

  const FeedCaptionText({
    super.key,
    required this.caption,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 10),
    this.hasMedia = false,
  });

  static const int shortMaxLength = 20;

  @override
  State<FeedCaptionText> createState() => _FeedCaptionTextState();
}

class _FeedCaptionTextState extends State<FeedCaptionText> {
  bool _expanded = false;

  bool get _isShortTextOnly =>
      !widget.hasMedia && widget.caption.trim().length <= FeedCaptionText.shortMaxLength;

  int get _collapsedMaxLines => widget.hasMedia ? 2 : 5;

  TextStyle _bodyStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText(context),
        height: 1.45,
        letterSpacing: -0.1,
      );

  @override
  Widget build(BuildContext context) {
    final text = widget.caption.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final accent = AppColors.buttonColor(context);

    // ── Short text-only: centered + bold ──────────────────────────────
    if (_isShortTextOnly) {
      final screenWidth = MediaQuery.of(context).size.width;
      final fontSize = (screenWidth * 0.072).clamp(22.0, 32.0);
      return Padding(
        padding: widget.padding,
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText(context),
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    // ── Long text: use LayoutBuilder to measure real lines ────────────
    final bodyStyle = _bodyStyle(context);
    final maxLines = _collapsedMaxLines;

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: bodyStyle),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          final overflows = painter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: bodyStyle,
                maxLines: (!_expanded && overflows) ? maxLines : null,
                overflow: (!_expanded && overflows) ? TextOverflow.ellipsis : null,
              ),
              if (overflows) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
