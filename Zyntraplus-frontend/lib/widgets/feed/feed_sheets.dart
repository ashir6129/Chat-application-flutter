import 'package:flutter/material.dart';

import '../../api_services/tip_service.dart';
import '../../core/app_colors.dart';
import 'comment_bottom_sheet.dart';
import 'share_bottom_sheet.dart';
import 'tip_bottom_sheet.dart';

void showFeedCommentsSheet(
  BuildContext context, {
  required String postUid,
  required String authorName,
  ValueChanged<int>? onCommentCountChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommentsBottomSheet(
      postUid: postUid,
      authorName: authorName,
      onCommentCountChanged: onCommentCountChanged,
    ),
  );
}

void showFeedShareSheet(
  BuildContext context, {
  required String postUid,
  required String authorName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ShareBottomSheet(
      postUid: postUid,
      authorName: authorName,
      onShareSelected: (_) {},
    ),
  );
}

Future<void> showFeedTipSheet(
  BuildContext context, {
  required String recipientId,
  required String authorName,
  String? postId,
}) async {
  if (recipientId.isEmpty) return;

  final messenger = ScaffoldMessenger.of(context);
  final accent = AppColors.buttonColor(context);
  int balance = 0;
  try {
    balance = await TipService.getBalance();
  } catch (_) {}

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => TipBottomSheet(
      balanceCredits: balance,
      onTipSelected: (type, amount) async {
        Navigator.of(sheetContext).pop();
        try {
          final result = await TipService.sendTip(
            recipientId: recipientId,
            postId: postId,
            tipType: type,
            amount: amount,
          );
          final newBalance = result['data']?['balance_credits'] as int? ?? balance - amount;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Sent $type tip to $authorName! Balance: $newBalance credits'),
              backgroundColor: accent,
            ),
          );
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(TipService.errorMessage(e)),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
    ),
  );
}
