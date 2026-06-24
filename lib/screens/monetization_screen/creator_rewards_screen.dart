import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/screens/monetization_screen/post_analytics_screen.dart';
import 'package:zyntraplus/screens/monetization_screen/wallet_screen.dart';

import '../../core/app_colors.dart';

class CreatorRewardsScreen extends StatelessWidget {
  const CreatorRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _totalEarningsCard(context),
            const SizedBox(height: 16),
            _earningsBreakdownCard(context),
            const SizedBox(height: 16),
            _performanceOverviewCard(context),
            const SizedBox(height: 16),
            _quickStatsCard(context),
            const SizedBox(height: 16),
            _audienceQualityCard(context),
            const SizedBox(height: 16),
            _aiInsightCard(context),
            const SizedBox(height: 16),
            _topEarningContentCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _totalEarningsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16203D), Color(0xFF2A3668)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '\$14.46',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Iconsax.trend_up, size: 14, color: Color(0xFF4ADE80)),
                  SizedBox(width: 6),
                  Text(
                    '12.4% this week',
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Wallet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostAnalyticsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.monetization_on_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningsBreakdownCard(BuildContext context) {
    const segments = [
      _Segment('Standard Reward', '\$0.55', '3.8%', Color(0xFF4ADE80)),
      _Segment('Additional\nReward', '\$13.91', '48.1%', Color(0xFF818CF8)),
      _Segment('Sales Earnings', '\$42.00', '48.1%', Color(0xFFFFC107)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Earnings Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Last updated: Apr 1, 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutPainter(segments),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '\$14.46',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedText(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  children: segments
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryText(context),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    s.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    s.pct,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: AppColors.borderLine(context),
            height: 20,
            thickness: 0.5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 14,
                  color: AppColors.mutedText(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sales Earnings reflect your net revenue from Marketplace orders after platform fees.',
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceOverviewCard(BuildContext context) {
    final cells = [
      _PerfCell('RPM', '\$7.44', '+25.29x', const [
        Color(0xFF2563EB),
        Color(0xFF3B82F6),
      ], Icons.bar_chart_outlined),
      _PerfCell('Total Views', '12.3K', '+18.7%', const [
        Color(0xFF7C3AED),
        Color(0xFFA855F7),
      ], Icons.visibility_outlined),
      _PerfCell('Qualified Views', '1.9K', '+15.3%', const [
        Color(0xFF059669),
        Color(0xFF34D399),
      ], Icons.people_outline),
      _PerfCell('Total Earnings', '\$14.46', '+12.4%', const [
        Color(0xFFD97706),
        Color(0xFFFFC107),
      ], Icons.shopping_bag_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: cells.map((c) => _buildPerfCell(context, c)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfCell(BuildContext context, _PerfCell cell) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161C24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cell.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cell.icon, size: 20, color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cell.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cell.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Iconsax.trend_up, size: 12, color: Color(0xFF4ADE80)),
              const SizedBox(width: 4),
              Text(
                cell.growth,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStatsCard(BuildContext context) {
    final stats = [
      _QuickStat('38s', 'Avg. Watch\nTime', Icons.timer_outlined),
      _QuickStat('68%', '30s\nRetention', Icons.sync_outlined),
      _QuickStat('23', 'Gifts\nReceived', Icons.card_giftcard_outlined),
      _QuickStat('7', 'Marketplace\nOrders', Icons.storefront_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats
                .map(
                  (s) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00A884),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            s.icon,
                            size: 24,
                            color: const Color(0xFF00A884),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _audienceQualityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Audience Quality',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.mutedText(context),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A884).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Great',
                      style: TextStyle(
                        color: Color(0xFF00A884),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Improved layout: larger circular score and stronger visual balance
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    value: 0.87,
                    colors: const [Color(0xFF00E5A8), Color(0xFF00A884)],
                    backgroundColor: const Color(0xFF16222A),
                    strokeWidth: 10,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '8.7',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/10',
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Excellent! Your audience is highly engaged.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _buildProgressRow(
            context,
            Icons.timer_outlined,
            'Average Watch Time',
            '38s',
            0.8,
            progressColor: const Color(0xFF00A884),
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            context,
            Icons.sync_outlined,
            '30s Retention Rate',
            '68%',
            0.68,
            progressColor: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            context,
            Icons.share_outlined,
            'Shares',
            '54',
            0.5,
            progressColor: const Color(0xFF4ADE80),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double progress, {
    Color progressColor = const Color(0xFF00A884),
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.mutedText(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF3B4A54),
            color: progressColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _aiInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF310A6B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Insight',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your RPM increased by 25.29x due to high-quality content and strong audience appeal.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Keep posting content like your top performers to maintain this growth.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topEarningContentCard(BuildContext context) {
    final contents = [
      {
        'title': 'How I built a \$10K/\nmo side hustle',
        'date': 'Apr 1, 2026',
        'views': '4.2K',
        'earn': '\$5.82',
      },
      {
        'title': 'Morning routine that\nchanged my life',
        'date': 'Mar 28, 2026',
        'views': '3.1K',
        'earn': '\$4.21',
      },
      {
        'title': 'Top 5 productivity\ntools for creators',
        'date': 'Mar 25, 2026',
        'views': '2.7K',
        'earn': '\$3.44',
      },
      {
        'title': 'Why most creators\nquit too early',
        'date': 'Mar 22, 2026',
        'views': '1.8K',
        'earn': '\$0.99',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF232D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Earning Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFF00A884),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Color(0xFF00A884),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contents.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == contents.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161C24),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLine(context),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.videocam_outlined,
                          color: AppColors.mutedText(context),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                color: AppColors.mutedText(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['views']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Views',
                            style: TextStyle(
                              color: AppColors.mutedText(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Text(
                        item['earn']!,
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    color: AppColors.borderLine(context),
                    height: 1,
                    thickness: 0.5,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.038, 0.481, 0.481];
    final cx = size.width / 2, cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.65;
    const gap = 0.05;
    double start = -pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final sweep = values[i] * pi * 2 - gap;
      final paint = Paint()
        ..color = segments[i].color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
          start,
          sweep,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
          start + sweep,
          -sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

class _Segment {
  final String label, value, pct;
  final Color color;
  const _Segment(this.label, this.value, this.pct, this.color);
}

class _PerfCell {
  final String label, value, growth;
  final List<Color> gradient;
  final IconData icon;
  const _PerfCell(
    this.label,
    this.value,
    this.growth,
    this.gradient,
    this.icon,
  );
}

class _QuickStat {
  final String value, label;
  final IconData icon;
  const _QuickStat(this.value, this.label, this.icon);
}

class _ScoreRingPainter extends CustomPainter {
  final double value;
  final List<Color> colors;
  final Color backgroundColor;
  final double strokeWidth;

  _ScoreRingPainter({
    required this.value,
    required this.colors,
    required this.backgroundColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi * value,
      colors: colors,
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * value;
    canvas.drawArc(rect, -pi / 2, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.colors != colors;
  }
}
