import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Feed post caption — short text centered/uppercase; long text with read more.
class FeedCaptionText extends StatefulWidget {
  final String caption;
  final EdgeInsetsGeometry padding;

  const FeedCaptionText({
    super.key,
    required this.caption,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 10),
  });

  static const int shortMaxLength = 20;
  static const int collapsedMaxLines = 3;
  static const int readMoreMinLength = 100;
  static const int readMoreMinWords = 18;

  @override
  State<FeedCaptionText> createState() => _FeedCaptionTextState();
}

class _FeedCaptionTextState extends State<FeedCaptionText> {
  bool _expanded = false;

  TextStyle _bodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryText(context),
      height: 1.4,
      letterSpacing: -0.1,
    );
  }

  bool _needsReadMore(String text) {
    if (text.length < FeedCaptionText.shortMaxLength) return false;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return text.length > FeedCaptionText.readMoreMinLength ||
        words >= FeedCaptionText.readMoreMinWords;
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.caption.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final accent = AppColors.buttonColor(context);
    final needsReadMore = _needsReadMore(text);

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: _bodyStyle(context),
            maxLines: (!_expanded && needsReadMore)
                ? FeedCaptionText.collapsedMaxLines
                : null,
            overflow: (!_expanded && needsReadMore)
                ? TextOverflow.ellipsis
                : null,
          ),
          if (needsReadMore) ...[
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
      ),
    );
  }
}
