import 'package:flutter/material.dart';
import '../../api_services/chat_service.dart';
import 'chat_theme.dart';
import 'message_action_sheet.dart';
import 'voice_message_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;
  final MessageReceiptStatus? receiptStatus;
  final String? avatarUrl;
  final Color? avatarColor;
  final VoidCallback? onReply;
  final void Function(String emoji)? onReaction;
  final VoidCallback? onEdit;
  final VoidCallback? onForward;
  final VoidCallback? onPin;
  final VoidCallback? onUnsend;
  final VoidCallback? onSilent;
  final void Function(String effect)? onEffect;
  final VoidCallback? onRetry;

  // Voice message fields
  final bool? _isVoice;
  bool get isVoice => _isVoice ?? false;
  final String? voiceAudioUrl;
  final Duration? _voiceDuration;
  Duration get voiceDuration => _voiceDuration ?? Duration.zero;
  final String? conversationId;
  final String? messageId;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMine,
    this.receiptStatus,
    this.avatarUrl,
    this.avatarColor,
    this.onReply,
    this.onReaction,
    this.onEdit,
    this.onForward,
    this.onPin,
    this.onUnsend,
    this.onSilent,
    this.onEffect,
    this.onRetry,
    bool? isVoice,
    this.voiceAudioUrl,
    Duration? voiceDuration,
    this.conversationId,
    this.messageId,
  })  : _isVoice = isVoice,
        _voiceDuration = voiceDuration;

  void _showActions(BuildContext context) {
    showMessageActionSheet(
      context,
      messageText: text,
      isMine: isMine,
      onReaction: onReaction,
      onReply: onReply,
      onEdit: onEdit,
      onForward: onForward,
      onPin: onPin,
      onUnsend: onUnsend,
      onSilent: onSilent,
      onEffect: onEffect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget bubble = isVoice
        ? GestureDetector(
            onLongPress: () => _showActions(context),
            child: VoiceMessageBubble(
              messageId: messageId,
              audioUrl: voiceAudioUrl,
              isMine: isMine,
              time: time,
              totalDuration: voiceDuration,
              receiptStatus: receiptStatus,
              conversationId: conversationId,
            ),
          )
        : GestureDetector(
            onLongPress: () => _showActions(context),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMine ? ChatTheme.outgoingBubble : ChatTheme.incomingBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: ChatTheme.mutedText,
                          fontSize: 10,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _tickIcon(receiptStatus),
                          size: 14,
                          color: _tickColor(receiptStatus),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );

    if (isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: bubble,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (avatarUrl != null || avatarColor != null)
            CircleAvatar(
              radius: 16,
              backgroundColor: avatarColor ?? ChatTheme.incomingBubble,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            ),
          if (avatarUrl != null || avatarColor != null) const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  IconData _tickIcon(MessageReceiptStatus? status) {
    switch (status) {
      case MessageReceiptStatus.delivered:
      case MessageReceiptStatus.read:
        return Icons.done_all;
      case MessageReceiptStatus.sent:
      default:
        return Icons.done;
    }
  }

  Color _tickColor(MessageReceiptStatus? status) {
    if (status == MessageReceiptStatus.read) return ChatTheme.readTick;
    return ChatTheme.mutedText;
  }
}
