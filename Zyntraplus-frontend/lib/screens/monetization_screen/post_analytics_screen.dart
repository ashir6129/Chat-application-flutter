import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';

class PostAnalyticsScreen extends StatelessWidget {
  const PostAnalyticsScreen({super.key});

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
          'Post Analytics',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _audienceQualityCard(context),
              const SizedBox(height: 12),
              _aiInsightCard(context),
              const SizedBox(height: 12),
              _topEarningContentCard(context),
              const SizedBox(height: 12),
              _earningOpportunitiesCard(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _audienceQualityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text('Audience Quality',
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 5),
                Icon(Icons.info_outline,
                    size: 13, color: AppColors.mutedText(context)),
              ]),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 7, color: Color(0xFF4ADE80)),
                    SizedBox(width: 4),
                    Text('Great',
                        style: TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arc meter + description row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _ArcMeterPainter(
                        value: 8.7,
                        max: 10,
                        trackColor: AppColors.borderLine(context),
                        fillColor: const Color(0xFF4ADE80),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('8.7',
                            style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text('/10',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText(context))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Excellent! Your audience\nis highly engaged.',
                  style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
              color: AppColors.borderLine(context),
              thickness: 0.5,
              height: 1),
          const SizedBox(height: 14),

          // Stats with progress bars
          _audienceStatWithBar(
            context,
            Iconsax.timer_1,
            'Average Watch Time',
            '38s',
            0.72,
            const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 14),
          _audienceStatWithBar(
            context,
            Iconsax.refresh_circle,
            '30s Retention Rate',
            '68%',
            0.68,
            const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 14),
          _audienceStatWithBar(
            context,
            Iconsax.share,
            'Shares',
            '54',
            0.54,
            const Color(0xFF4ADE80),
          ),
        ],
      ),
    );
  }

  Widget _audienceStatWithBar(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      double progress,
      Color barColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.mutedText(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText(context))),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.borderLine(context),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _aiInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Iconsax.star_1, size: 14, color: Color(0xFFA78BFA)),
            const SizedBox(width: 6),
            Text('AI Insight',
                style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text(
            'Your RPM increased by 25.29x due to high-quality content and strong audience appeal.',
            style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 12,
                height: 1.5),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child:
                const Icon(Iconsax.flash_1, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Keep posting content like your top performers to maintain this growth.',
                  style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 11,
                      height: 1.4),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _topEarningContentCard(BuildContext context) {
    final items = [
      _ContentItem(
          'How I built a \$10K/mo side hustle', 'Apr 1, 2026', '4.2K', '\$5.82'),
      _ContentItem('Morning routine that changed my life', 'Mar 28, 2026',
          '3.1K', '\$4.21'),
      _ContentItem('Top 5 productivity tools for creators', 'Mar 25, 2026',
          '2.7K', '\$3.44'),
      _ContentItem(
          'Why most creators quit too early', 'Mar 22, 2026', '1.8K', '\$0.99'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Earning Content',
                  style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {},
                child: Text('View all →',
                    style: TextStyle(
                        color: AppColors.buttonColor(context), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              Expanded(
                  child: Text('Content',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                          fontWeight: FontWeight.w600))),
              SizedBox(
                  width: 48,
                  child: Text('Views',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                          fontWeight: FontWeight.w600))),
              SizedBox(
                  width: 56,
                  child: Text('Earnings',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                          fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 8),

          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(children: [
              _contentRow(context, e.value),
              if (!isLast)
                Divider(
                    color: AppColors.borderLine(context),
                    height: 1,
                    thickness: 0.6),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _contentRow(BuildContext context, _ContentItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 52,
            height: 44,
            color: AppColors.primaryBackground(context),
            child: Icon(Iconsax.video,
                size: 20, color: AppColors.secondaryText(context)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(item.date,
                style: TextStyle(
                    fontSize: 10, color: AppColors.mutedText(context))),
          ]),
        ),
        const SizedBox(width: 6),
        SizedBox(
            width: 40,
            child: Text(item.views,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: AppColors.secondaryText(context)))),
        SizedBox(
            width: 52,
            child: Text(item.earnings,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText(context)))),
      ]),
    );
  }

  Widget _earningOpportunitiesCard(BuildContext context) {
    final opps = [
      _Opp('Boost Your\nContent', 'Increase reach and earnings', Iconsax.graph,
          const [Color(0xFF2563EB), Color(0xFF60A5FA)]),
      _Opp('Brand\nCampaigns', 'Collaborate with top brands', Iconsax.briefcase,
          const [Color(0xFFD97706), Color(0xFFFBBF24)]),
      _Opp('Earn TURQ\nRewards', 'Unlock exclusive creator rewards',
          Iconsax.coin, const [Color(0xFF7C3AED), Color(0xFFA855F7)]),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earning Opportunities',
              style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: opps
                .map((o) => Expanded(
              child: Padding(
                padding:
                EdgeInsets.only(right: o == opps.last ? 0 : 8),
                child: _oppCard(context, o),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _oppCard(BuildContext context, _Opp opp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: opp.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(opp.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(opp.title,
              style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3)),
          const SizedBox(height: 4),
          Text(opp.subtitle,
              style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 10,
                  height: 1.4)),
          const SizedBox(height: 10),
          Icon(Icons.arrow_forward,
              size: 14, color: AppColors.buttonColor(context)),
        ],
      ),
    );
  }
}

class _ArcMeterPainter extends CustomPainter {
  final double value, max;
  final Color trackColor, fillColor;
  _ArcMeterPainter(
      {required this.value,
        required this.max,
        required this.trackColor,
        required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final radius = size.width / 2 - 8;
    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle * (value / max),
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcMeterPainter old) => false;
}

class _ContentItem {
  final String title, date, views, earnings;
  const _ContentItem(this.title, this.date, this.views, this.earnings);
}

class _Opp {
  final String title, subtitle;
  final IconData icon;
  final List<Color> gradient;
  const _Opp(this.title, this.subtitle, this.icon, this.gradient);
}