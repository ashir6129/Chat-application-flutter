import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import 'wallet_screen.dart';

class ExtraRewardsScreen extends StatelessWidget {
  const ExtraRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalTurqBalanceCard(context),
            const SizedBox(height: 20),
            _buildTurqBreakdownCard(context),
            const SizedBox(height: 20),
            _buildTurqPerformanceCard(context),
            const SizedBox(height: 20),
            _buildTurqInsightCard(context),
            const SizedBox(height: 20),
            _buildTopEarningContentCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Total TURQ Balance Card ──────────────────────────────────────────────

  Widget _buildTotalTurqBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLine(context),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Row(
                  children: [
                    Text(
                      'Total TURQ Rewards',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Iconsax.info_circle,
                      size: 14,
                      color: AppColors.mutedText(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Amount row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.coin,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '1,280',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Growth badge
                Row(
                  children: const [
                    Icon(Iconsax.trend_up, size: 14, color: Color(0xFF4ADE80)),
                    SizedBox(width: 4),
                    Text(
                      '18.7% this week',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor(context),
                        foregroundColor: AppColors.buttonTextColor(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Redeem',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const WalletScreen(),
                        ));
                      },
                      icon: Icon(Iconsax.wallet,
                          size: 15, color: AppColors.secondaryText(context)),
                      label: Text('Wallet',
                          style:
                          TextStyle(color: AppColors.secondaryText(context))),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderLine(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildTurqBreakdownCard(BuildContext context) {
    final items = [
      _BreakdownItem('Engagement Rewards', 620, 48.4, const Color(0xFFA855F7)),
      _BreakdownItem('Campaign Rewards', 340, 26.6, const Color(0xFFEC4899)),
      _BreakdownItem('Referral Rewards', 200, 15.6, const Color(0xFFF97316)),
      _BreakdownItem('Bonus Rewards', 120, 9.4, const Color(0xFF3B82F6)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'TURQ Breakdown',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Iconsax.info_circle,
                      size: 14, color: AppColors.mutedText(context)),
                ],
              ),
              Text(
                'Last updated: Apr 1, 2026',
                style: TextStyle(
                    fontSize: 11, color: AppColors.mutedText(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutPainter(items),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '1,280',
                          style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Legend
              Expanded(
                child: Column(
                  children: items
                      .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.label,
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                  AppColors.secondaryText(context))),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${item.value}',
                                style: TextStyle(
                                    color:
                                    AppColors.primaryText(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            Text('${item.pct}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                    AppColors.mutedText(context))),
                          ],
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),

          // Footer
          Divider(
              color: AppColors.borderLine(context),
              thickness: 0.8,
              height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.award,
                    size: 17, color: AppColors.secondaryText(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'TURQ rewards can be redeemed for exclusive benefits and special offers.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText(context),
                      height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurqPerformanceCard(BuildContext context) {
    final cells = [
      _PerfCell(
        'TURQ Earned',
        '1,280',
        '18.7%',
        true,
        null,
        const [Color(0xFF7C3AED), Color(0xFFA855F7)],
        Iconsax.coin,
      ),
      _PerfCell(
        'TURQ Redeemed',
        '850',
        '25.1%',
        true,
        null,
        const [Color(0xFFDB2777), Color(0xFFEC4899)],
        Iconsax.gift,
      ),
      _PerfCell(
        'TURQ Balance',
        '430',
        null,
        false,
        'Available',
        const [Color(0xFFEA580C), Color(0xFFF97316)],
        Iconsax.flash_1,
      ),
      _PerfCell(
        'TURQ Value',
        '\$25.60',
        null,
        false,
        'Est. Value',
        const [Color(0xFF2563EB), Color(0xFF3B82F6)],
        Iconsax.clock,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLine(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TURQ Performance',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // FIRST ROW
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPerfCell(context, cells[0]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPerfCell(context, cells[1]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // SECOND ROW
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPerfCell(context, cells[2]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPerfCell(context, cells[3]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfCell(BuildContext context, _PerfCell cell) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cell.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              cell.icon,
              size: 16,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cell.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.mutedText(context),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  cell.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context),
                  ),
                ),

                const SizedBox(height: 2),

                if (cell.growth != null)
                  Row(
                    children: [
                      const Icon(
                        Iconsax.trend_up,
                        size: 10,
                        color: Color(0xFF4ADE80),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        cell.growth!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4ADE80),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    cell.subtitle!,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedText(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurqInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Iconsax.star_1,
                    size: 16, color: AppColors.buttonColor(context)),
                const SizedBox(width: 7),
                Text('TURQ Insight',
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 7),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                        AppColors.buttonColor(context).withOpacity(0.35)),
                  ),
                  child: Text('New',
                      style: TextStyle(
                          color: AppColors.buttonColor(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              Icon(Icons.chevron_right,
                  size: 18, color: AppColors.mutedText(context)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "You're earning more TURQ this week! Keep engaging your audience and join more campaigns.",
            style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText(context),
                height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: const Icon(Iconsax.flash_1,
                    size: 15, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                    'Complete campaigns and invite friends to earn more TURQ.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText(context),
                        height: 1.45),
                  )),
              Icon(Icons.arrow_forward,
                  size: 15, color: AppColors.mutedText(context)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Top TURQ Earning Content Card ────────────────────────────────────────

  Widget _buildTopEarningContentCard(BuildContext context) {
    final items = [
      _ContentItem(
          'How I built a \$10K/mo side hustle', 'Apr 1, 2026', '4.2K', 320),
      _ContentItem(
          'Morning routine that changed my life', 'Mar 28, 2026', '3.1K', 240),
      _ContentItem('Top 5 productivity tools for creators', 'Mar 25, 2026',
          '2.7K', 180),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top TURQ Earning Content',
                  style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {},
                child: Row(children: [
                  Text('View all',
                      style: TextStyle(
                          color: AppColors.buttonColor(context), fontSize: 12)),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward,
                      size: 13, color: AppColors.buttonColor(context)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                _buildContentRow(context, e.value),
                if (!isLast)
                  Divider(
                      color: AppColors.borderLine(context),
                      height: 1,
                      thickness: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContentRow(BuildContext context, _ContentItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 52,
            height: 52,
            color: AppColors.primaryBackground(context),
            child: Icon(Iconsax.video,
                size: 22, color: AppColors.secondaryText(context)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3)),
                const SizedBox(height: 2),
                Text(item.date,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.mutedText(context))),
              ],
            )),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.views,
              style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Text('Views',
              style:
              TextStyle(fontSize: 10, color: AppColors.mutedText(context))),
        ]),
        const SizedBox(width: 8),
        Row(children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.coin, size: 10, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text('${item.reward}',
              style: const TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class _BreakdownItem {
  final String label;
  final int value;
  final double pct;
  final Color color;
  const _BreakdownItem(this.label, this.value, this.pct, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_BreakdownItem> items;
  _DonutPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<int>(0, (s, i) => s + i.value);
    final cx = size.width / 2, cy = size.height / 2;
    final outerR = size.width / 2 - 4;
    final innerR = outerR * 0.64;
    const gap = 0.04;
    double start = -pi / 2;

    for (final item in items) {
      final sweep = (item.value / total) * pi * 2 - gap;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
            start, sweep, false)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
            start + sweep, -sweep, false)
        ..close();

      canvas.drawPath(path, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

class _PerfCell {
  final String label, value;
  final String? growth, subtitle;
  final bool isGrowth;
  final List<Color> gradient;
  final IconData icon;
  const _PerfCell(this.label, this.value, this.growth, this.isGrowth,
      this.subtitle, this.gradient, this.icon);
}

class _ContentItem {
  final String title, date, views;
  final int reward;
  const _ContentItem(this.title, this.date, this.views, this.reward);
}