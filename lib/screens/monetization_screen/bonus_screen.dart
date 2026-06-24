import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

// ── Data ───────────────────────────────────────────────────────────────────

const double _totalEarned = 43.30;
const double _pendingBonus = 20.00;

const List<Map<String, dynamic>> _tasks = [
  {'icon': Iconsax.edit,         'title': 'First post',              'sub': 'Publish your very first post',       'reward': '10 tokens', 'done': true},
  {'icon': Iconsax.profile_tick, 'title': 'Complete your profile',   'sub': 'Add bio, photo & social links',      'reward': '5 tokens',  'done': true},
  {'icon': Iconsax.user_add,     'title': 'First referral',          'sub': 'Invite a friend who signs up',       'reward': '8 tokens',  'done': true},
  {'icon': Iconsax.image,        'title': 'Set profile picture',     'sub': 'Upload a profile photo',             'reward': '\$0.3',     'done': false},
  {'icon': Iconsax.notification, 'title': 'Enable notifications',    'sub': 'Turn on push notifications',         'reward': '3 tokens',  'done': false},
];

const List<Map<String, dynamic>> _milestones = [
  {'icon': Iconsax.eye,          'title': '10k views in a month',    'sub': 'Reach 10,000 post views in 30 days',                  'reward': '\$30', 'current': 6800,  'target': 10000, 'unlocked': false},
  {'icon': Iconsax.people,       'title': '20 active referrals',     'sub': '20 referred users who posted at least once',          'reward': '\$20', 'current': 14,    'target': 20,    'unlocked': false},
  {'icon': Iconsax.heart,        'title': '500 likes on a post',     'sub': 'A single post reaches 500 likes',                     'reward': '\$15', 'current': 500,   'target': 500,   'unlocked': true},
  {'icon': Iconsax.chart_2,      'title': '50 posts published',      'sub': 'Publish a total of 50 posts',                         'reward': '\$10', 'current': 50,    'target': 50,    'unlocked': true},
  {'icon': Iconsax.user_octagon, 'title': 'Follow 1,000 creators',   'sub': 'Follow a total of 1,000 creators on the platform',    'reward': '\$12', 'current': 430,   'target': 1000,  'unlocked': false},
  {'icon': Iconsax.share,        'title': 'Share app or post',       'sub': 'Share the app or a post with your friends',           'reward': '8 tokens', 'current': 0, 'target': 1,   'unlocked': false},
  {'icon': Iconsax.video_play,   'title': 'Engage with 500 reels',   'sub': 'Like, comment, or share 500 reels',                   'reward': '\$18', 'current': 214,   'target': 500,   'unlocked': false},
  {'icon': Iconsax.video_add,    'title': 'Create 20 reels',         'sub': 'Publish a total of 20 reels',                         'reward': '\$15', 'current': 20,    'target': 20,    'unlocked': true},
  {'icon': Iconsax.edit,         'title': 'Create 50 posts',         'sub': 'Publish a total of 50 posts on your profile',         'reward': '\$10', 'current': 38,    'target': 50,    'unlocked': false},
];

// ── Screen ─────────────────────────────────────────────────────────────────

class BonusScreen extends StatelessWidget {
  const BonusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doneTasks     = _tasks.where((t) => t['done'] as bool).length;
    final unlockedCount = _milestones.where((m) => m['unlocked'] as bool).length;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bonus & Rewards',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Summary cards ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _summaryCard(context,
                    icon: Iconsax.empty_wallet_tick,
                    label: 'Total earned',
                    value: '\$${_totalEarned.toStringAsFixed(2)}',
                    color: AppColors.buttonColor(context))),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard(context,
                    icon: Iconsax.clock,
                    label: 'Pending',
                    value: '\$${_pendingBonus.toStringAsFixed(2)}',
                    color: AppColors.verifiedBadge(context))),
              ],
            ),
            const SizedBox(height: 22),

            // ── Tasks ──────────────────────────────────────────────────────
            _sectionLabel(context, Iconsax.task_square, 'Bonus tasks',
                trailing: '$doneTasks/${_tasks.length} done'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.borderLine(context), width: 0.5),
              ),
              child: Column(
                children: List.generate(_tasks.length, (i) {
                  final t = _tasks[i];
                  final bool done = t['done'] as bool;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      border: Border(
                        top: i == 0
                            ? BorderSide.none
                            : BorderSide(
                            color: AppColors.borderLine(context),
                            width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.buttonColor(context).withOpacity(0.10)
                                : AppColors.primaryBackground(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: done
                                  ? AppColors.buttonColor(context).withOpacity(0.3)
                                  : AppColors.borderLine(context),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            done ? Icons.check_rounded : t['icon'] as IconData,
                            color: done
                                ? AppColors.buttonColor(context)
                                : AppColors.secondaryText(context),
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['title'] as String,
                                  style: TextStyle(
                                    color: done
                                        ? AppColors.secondaryText(context)
                                        : AppColors.primaryText(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  )),
                              const SizedBox(height: 2),
                              Text(t['sub'] as String,
                                  style: TextStyle(
                                      color: AppColors.secondaryText(context),
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.buttonColor(context).withOpacity(0.10)
                                : AppColors.buttonColor(context).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t['reward'] as String,
                              style: TextStyle(
                                color: done
                                    ? AppColors.buttonColor(context)
                                    : AppColors.buttonColor(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),

            // ── Milestones ─────────────────────────────────────────────────
            _sectionLabel(context, Iconsax.award, 'Milestone rewards',
                trailing: '$unlockedCount/${_milestones.length} unlocked'),
            const SizedBox(height: 10),
            Column(
              children: _milestones.map((m) {
                final bool unlocked = m['unlocked'] as bool;
                final int current   = m['current'] as int;
                final int target    = m['target'] as int;
                final double progress = (current / target).clamp(0.0, 1.0);
                final Color accent = unlocked
                    ? AppColors.buttonColor(context)
                    : AppColors.buttonColor(context);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: unlocked
                            ? AppColors.buttonColor(context).withOpacity(0.3)
                            : AppColors.borderLine(context),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            unlocked
                                ? Icons.check_rounded
                                : m['icon'] as IconData,
                            color: accent, size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(m['title'] as String,
                                        style: TextStyle(
                                            color: AppColors.primaryText(context),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(m['reward'] as String,
                                        style: TextStyle(
                                            color: accent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(m['sub'] as String,
                                  style: TextStyle(
                                      color: AppColors.secondaryText(context),
                                      fontSize: 11)),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: AppColors.borderLine(context),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    unlocked
                                        ? 'Unlocked'
                                        : _fmtProgress(current, target),
                                    style: TextStyle(
                                      color: unlocked
                                          ? AppColors.buttonColor(context)
                                          : AppColors.secondaryText(context),
                                      fontSize: 11,
                                      fontWeight: unlocked
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  Text('${(progress * 100).toInt()}%',
                                      style: TextStyle(
                                          color: accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _summaryCard(BuildContext context,
      {required IconData icon,
        required String label,
        required String value,
        required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 12)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, IconData icon, String label,
      {String? trailing}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondaryText(context), size: 14),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5)),
        const Spacer(),
        if (trailing != null)
          Text(trailing,
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 11)),
      ],
    );
  }

  String _fmtProgress(int current, int target) {
    String fmt(int n) =>
        n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k' : '$n';
    return '${fmt(current)} / ${fmt(target)}';
  }
}