import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import '../../models/poll_data.dart';

class FeedPollCard extends StatelessWidget {
  final PollData poll;
  final ValueChanged<int>? onVote;
  final bool showResults;
  final bool isOwner;

  const FeedPollCard({
    super.key,
    required this.poll,
    this.onVote,
    this.showResults = false,
    this.isOwner = false,
  });

  bool get _revealed => showResults || poll.hasVoted || (isOwner && poll.isActive);

  bool get _canVote => poll.isActive && onVote != null;

  int get _totalVotes {
    if (poll.votes.isEmpty) return 0;
    return poll.votes.fold(0, (sum, v) => sum + v);
  }

  String _timeLeftLabel() {
    if (poll.expiresAt == null) return '';
    if (poll.isExpired) return 'Poll ended';
    final diff = poll.expiresAt!.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes.clamp(1, 59)}m left';
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    final timeLabel = _timeLeftLabel();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_2, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  poll.question,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (timeLabel.isNotEmpty)
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: poll.isExpired ? Colors.redAccent : AppColors.mutedText(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(poll.options.length, (i) {
            final label = poll.options[i];
            final votes = i < poll.votes.length ? poll.votes[i] : 0;
            final pct = _totalVotes > 0 ? votes / _totalVotes : 0.0;
            final selected = poll.myVote == i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _canVote ? () => onVote!(i) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? accent
                            : AppColors.borderLine(context).withValues(alpha: 0.45),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (_revealed)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic,
                                widthFactor: pct.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: selected ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: AppColors.primaryText(context),
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_revealed)
                              Text(
                                '${(pct * 100).round()}%',
                                style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else if (selected)
                              Icon(Icons.check_circle, size: 16, color: accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_revealed)
            Text(
              '$_totalVotes ${_totalVotes == 1 ? 'vote' : 'votes'}',
              style: TextStyle(color: AppColors.mutedText(context), fontSize: 11),
            )
          else if (poll.isExpired)
            Text(
              'This poll has ended',
              style: TextStyle(color: AppColors.mutedText(context), fontSize: 11),
            )
          else if (!poll.hasVoted)
            Text(
              'Tap an option to vote · tap again to change vote',
              style: TextStyle(color: AppColors.mutedText(context), fontSize: 11),
            ),
        ],
      ),
    );
  }
}
