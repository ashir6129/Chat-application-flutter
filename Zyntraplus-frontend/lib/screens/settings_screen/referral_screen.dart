import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReferralScreen
// ─────────────────────────────────────────────────────────────────────────────
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  static const _referralCode = 'KSHITIZ2024';
  static const _referralLink = 'https://app.link/ref/KSHITIZ2024';

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final List<_ReferralEntry> _referrals = [
    _ReferralEntry(
      name: 'Ananya Singh',
      username: 'ananya.s',
      avatarUrl: 'https://i.pravatar.cc/80?img=9',
      joinedAt: '2 days ago',
      reward: 150,
    ),
    _ReferralEntry(
      name: 'Rohan Das',
      username: 'rohan.das',
      avatarUrl: 'https://i.pravatar.cc/80?img=11',
      joinedAt: '1 week ago',
      reward: 150,
    ),
    _ReferralEntry(
      name: 'Meera Joshi',
      username: 'meera.j',
      avatarUrl: null,
      joinedAt: '2 weeks ago',
      reward: 150,
    ),
    _ReferralEntry(
      name: 'Kabir Malhotra',
      username: 'kabir.m',
      avatarUrl: 'https://i.pravatar.cc/80?img=7',
      joinedAt: '1 month ago',
      reward: 150,
    ),
  ];

  int get _totalEarned =>
      _referrals.fold(0, (sum, r) => sum + r.reward);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _copyCode(BuildContext ctx) {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyLink(BuildContext ctx) {
    Clipboard.setData(const ClipboardData(text: _referralLink));
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _share() {
    // Replace with: Share.share(_referralLink) from share_plus
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Refer & Earn',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Hero Banner ─────────────────────────────────────────────────
          _HeroBanner(pulseAnim: _pulseAnim),

          const SizedBox(height: 20),

          // ── Stats Row ───────────────────────────────────────────────────
          _StatsRow(
            totalReferred: _referrals.length,
            totalEarned: _totalEarned,
          ),

          const SizedBox(height: 24),

          // ── Referral Code ───────────────────────────────────────────────
          _SectionHeader(label: 'Your Referral Code'),
          _ReferralCodeCard(
            code: _referralCode,
            onCopy: () => _copyCode(context),
          ),

          const SizedBox(height: 20),

          // ── Share Link ──────────────────────────────────────────────────
          _SectionHeader(label: 'Share Your Link'),
          _ShareLinkCard(
            link: _referralLink,
            onCopyLink: () => _copyLink(context),
            onShare: _share,
          ),

          const SizedBox(height: 24),

          // ── How it works ────────────────────────────────────────────────
          _SectionHeader(label: 'How It Works'),
          const _HowItWorksCard(),

          const SizedBox(height: 24),

          // ── Referral History ────────────────────────────────────────────
          if (_referrals.isNotEmpty) ...[
            _SectionHeader(label: 'Referral History'),
            ..._referrals.map((r) => _ReferralTile(
              entry: r,
              initials: _initials(r.name),
            )),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _HeroBanner({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.buttonColor(context),
            AppColors.buttonColor(context).withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invite friends, earn rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get ₹150 in coins for every friend\nwho joins using your referral code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int totalReferred;
  final int totalEarned;

  const _StatsRow({
    required this.totalReferred,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Invited',
            value: '$totalReferred',
            icon: Iconsax.people,
          ),
          _VertDivider(),
          _StatCell(
            label: 'Joined',
            value: '$totalReferred',
            icon: Iconsax.tick_circle,
          ),
          _VertDivider(),
          _StatCell(
            label: 'Earned',
            value: '₹$totalEarned',
            icon: Icons.monetization_on_outlined,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: highlight
                  ? AppColors.buttonColor(context)
                  : AppColors.secondaryText(context),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: highlight
                    ? AppColors.buttonColor(context)
                    : AppColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 0.5, height: 48, color: AppColors.borderLine(context));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Referral Code Card
// ─────────────────────────────────────────────────────────────────────────────
class _ReferralCodeCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const _ReferralCodeCard({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your code',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: AppColors.buttonColor(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.copy, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Copy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Link Card
// ─────────────────────────────────────────────────────────────────────────────
class _ShareLinkCard extends StatelessWidget {
  final String link;
  final VoidCallback onCopyLink;
  final VoidCallback onShare;

  const _ShareLinkCard({
    required this.link,
    required this.onCopyLink,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Text(
              link,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCopyLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.borderLine(context), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.copy,
                            size: 15, color: AppColors.primaryText(context)),
                        const SizedBox(width: 6),
                        Text(
                          'Copy Link',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.export_3, size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How It Works Card
// ─────────────────────────────────────────────────────────────────────────────
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
      icon: Iconsax.export_3,
      title: 'Share your code',
      desc: 'Send your referral code or link to a friend.',
      ),
      (
      icon: Iconsax.user_add,
      title: 'Friend signs up',
      desc: 'They create an account using your code.',
      ),
      (
      icon: Icons.monetization_on_outlined,
      title: 'You both earn',
      desc: 'You get ₹150 in coins. They get ₹50 as a welcome bonus.',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                      AppColors.buttonColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.icon,
                        size: 17,
                        color: AppColors.buttonColor(context)),
                  ),
                  if (!isLast)
                    Container(
                      width: 1.5,
                      height: 36,
                      color: AppColors.borderLine(context),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Referral Tile — always Joined + reward shown
// ─────────────────────────────────────────────────────────────────────────────
class _ReferralTile extends StatelessWidget {
  final _ReferralEntry entry;
  final String initials;

  const _ReferralTile({required this.entry, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!)
                : null,
            backgroundColor: AppColors.borderLine(context),
            child: entry.avatarUrl == null
                ? Text(
              initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText(context),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${entry.username} · ${entry.joinedAt}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Joined',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B6D11),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+₹${entry.reward}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.buttonColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class _ReferralEntry {
  final String name;
  final String username;
  final String? avatarUrl;
  final String joinedAt;
  final int reward;

  const _ReferralEntry({
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.joinedAt,
    required this.reward,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.secondaryText(context),
        ),
      ),
    );
  }
}