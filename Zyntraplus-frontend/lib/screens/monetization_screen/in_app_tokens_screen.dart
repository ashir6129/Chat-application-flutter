import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

const int _balance = 340;

const List<Map<String, dynamic>> _packs = [
  {'tokens': 50,   'price': 0.99,  'badge': 'Starter', 'popular': false},
  {'tokens': 150,  'price': 2.49,  'badge': 'Popular',  'popular': true},
  {'tokens': 350,  'price': 4.99,  'badge': 'Value',    'popular': false},
  {'tokens': 800,  'price': 9.99,  'badge': 'Pro',      'popular': false},
  {'tokens': 2000, 'price': 19.99, 'badge': 'Elite',    'popular': false},
  {'tokens': 5000, 'price': 39.99, 'badge': 'Ultra',    'popular': false},
];

const List<Map<String, dynamic>> _gifts = [
  {'label': 'Rose',    'icon': Iconsax.heart,    'tokens': 10},
  {'label': 'Fire',    'icon': Iconsax.flash,    'tokens': 15},
  {'label': 'Crown',   'icon': Iconsax.crown,    'tokens': 25},
  {'label': 'Bouquet', 'icon': Iconsax.heart_add,'tokens': 30},
  {'label': 'Diamond', 'icon': Iconsax.diamonds, 'tokens': 50},
  {'label': 'Rocket',  'icon': Iconsax.send_2,   'tokens': 80},
];

final List<Map<String, dynamic>> _txs = [
  {'type': 'purchase', 'title': 'Purchased 350 tokens',  'sub': 'Via Razorpay · UPI',           'amount':  350, 'date': '20 Jun'},
  {'type': 'call',     'title': 'Video call · @priya_k', 'sub': '12 min · 6 tokens/min',        'amount': -72,  'date': '19 Jun'},
  {'type': 'gift',     'title': 'Gift sent · @rohan.dev','sub': 'Rose bouquet',                 'amount': -30,  'date': '18 Jun'},
  {'type': 'bonus',    'title': 'Bonus tokens',           'sub': 'First post reward',            'amount':  10,  'date': '17 Jun'},
  {'type': 'call',     'title': 'Voice call · @sneha_m', 'sub': '8 min · 4 tokens/min',         'amount': -32,  'date': '16 Jun'},
  {'type': 'gift',     'title': 'Gift sent · @arjun.x',  'sub': 'Fire emoji',                   'amount': -15,  'date': '15 Jun'},
  {'type': 'purchase', 'title': 'Purchased 150 tokens',  'sub': 'Via Razorpay · Card',          'amount':  150, 'date': '14 Jun'},
  {'type': 'bonus',    'title': 'Referral bonus',         'sub': 'Friend joined via your link',  'amount':  8,   'date': '13 Jun'},
];

class InAppTokensScreen extends StatefulWidget {
  const InAppTokensScreen({super.key});
  @override
  State<InAppTokensScreen> createState() => _InAppTokensScreenState();
}

class _InAppTokensScreenState extends State<InAppTokensScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
        title: Text('In-App Tokens',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Wallet Card ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.borderLine(context), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor(context).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Iconsax.wallet_2,
                            color: AppColors.buttonColor(context), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Token balance',
                              style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 12)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$_balance',
                                  style: TextStyle(
                                      color: AppColors.primaryText(context),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1)),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('tokens',
                                    style: TextStyle(
                                        color: AppColors.secondaryText(context),
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.borderLine(context), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        _usagePill(context, Iconsax.video,
                            '~${(_balance / 6).floor()} min video'),
                        Container(
                            width: 0.5,
                            height: 14,
                            color: AppColors.borderLine(context)),
                        _usagePill(context, Iconsax.call,
                            '~${(_balance / 4).floor()} min voice'),
                        Container(
                            width: 0.5,
                            height: 14,
                            color: AppColors.borderLine(context)),
                        _usagePill(context, Iconsax.gift,
                            '${(_balance / 10).floor()} gifts'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Tab Bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.borderLine(context), width: 0.5),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: AppColors.buttonColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.buttonTextColor(context),
                unselectedLabelColor: AppColors.secondaryText(context),
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
                unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                padding: const EdgeInsets.all(3),
                tabs: const [Tab(text: 'Buy tokens'), Tab(text: 'History')],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Tab Views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_buyTab(context), _historyTab(context)],
            ),
          ),
        ],
      ),
    );
  }

  // ── Usage Pill ───────────────────────────────────────────────────────────

  Widget _usagePill(BuildContext context, IconData icon, String label) =>
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondaryText(context), size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );

  // ── Buy Tab ──────────────────────────────────────────────────────────────

  Widget _buyTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Token packs
          _sectionLabel(context, Iconsax.bag_2, 'Token packs'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _packs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, i) {
              final p = _packs[i];
              final bool popular = p['popular'] as bool;
              return GestureDetector(
                onTap: () => _showBuySheet(context, p),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: popular
                          ? AppColors.buttonColor(context).withOpacity(0.5)
                          : AppColors.borderLine(context),
                      width: popular ? 1 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: popular
                                  ? AppColors.buttonColor(context)
                                  .withOpacity(0.12)
                                  : AppColors.primaryBackground(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.borderLine(context),
                                  width: 0.5),
                            ),
                            child: Icon(Iconsax.coin,
                                color: popular
                                    ? AppColors.buttonColor(context)
                                    : AppColors.secondaryText(context),
                                size: 15),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: popular
                                  ? AppColors.buttonColor(context)
                                  : AppColors.primaryBackground(context),
                              borderRadius: BorderRadius.circular(6),
                              border: popular
                                  ? null
                                  : Border.all(
                                  color: AppColors.borderLine(context),
                                  width: 0.5),
                            ),
                            child: Text(p['badge'] as String,
                                style: TextStyle(
                                  color: popular
                                      ? AppColors.buttonTextColor(context)
                                      : AppColors.secondaryText(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${p['tokens']} tokens',
                        style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text('₹${(p['price'] as double).toStringAsFixed(2)}',
                          style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // Section: Call rates
          _sectionLabel(context, Iconsax.call, 'Use tokens for calls'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Column(
              children: [
                _callRateRow(context, Iconsax.video, 'Video call',
                    'HD quality, up to 60 min', '6 tokens / min',
                    first: true),
                _callRateRow(context, Iconsax.call, 'Voice call',
                    'Crystal clear audio', '4 tokens / min'),
                _callRateRow(context, Iconsax.message_text, 'Chat unlock',
                    'Unlock DMs with a creator', '20 tokens'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Section: Gifts
          _sectionLabel(context, Iconsax.gift, 'Use tokens for gifts'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _gifts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, i) {
                final g = _gifts[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.borderLine(context), width: 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(g['icon'] as IconData,
                          color: AppColors.heartColor(context), size: 22),
                      const SizedBox(height: 5),
                      Text(g['label'] as String,
                          style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('${g['tokens']} tkn',
                          style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // Section: Payment methods
          _sectionLabel(context, Iconsax.card, 'Payment methods'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Column(
              children: [
                _paymentRow(context, Iconsax.mobile, 'UPI',
                    'GPay, PhonePe, Paytm', first: true),
                _paymentRow(context, Iconsax.card, 'Card',
                    'Visa, Mastercard, RuPay'),
                _paymentRow(context, Iconsax.building_4, 'Net banking',
                    'All major banks'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── History Tab ──────────────────────────────────────────────────────────

  Widget _historyTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats
          Row(
            children: [
              _statCard(context, Iconsax.arrow_circle_down,
                  'Total bought', '500', isPositive: true),
              const SizedBox(width: 10),
              _statCard(context, Iconsax.arrow_circle_up,
                  'Total spent', '178', isPositive: false),
              const SizedBox(width: 10),
              _statCard(context, Iconsax.gift,
                  'Gifts sent', '45', isHeart: true),
            ],
          ),
          const SizedBox(height: 20),

          _sectionLabel(context, Iconsax.receipt_2, 'Transactions'),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.borderLine(context), width: 0.5),
            ),
            child: Column(
              children: List.generate(_txs.length, (i) {
                final t = _txs[i];
                final bool credit = (t['amount'] as int) > 0;

                IconData icon;
                Color iconColor;
                switch (t['type'] as String) {
                  case 'purchase':
                    icon = Iconsax.bag_2;
                    iconColor = AppColors.buttonColor(context);
                    break;
                  case 'call':
                    icon = Iconsax.call;
                    iconColor = AppColors.buttonColor(context);
                    break;
                  case 'gift':
                    icon = Iconsax.gift;
                    iconColor = AppColors.heartColor(context);
                    break;
                  default:
                    icon = Iconsax.star;
                    iconColor = AppColors.verifiedBadge(context);
                }

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
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: iconColor, size: 17),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title'] as String,
                                style: TextStyle(
                                    color: AppColors.primaryText(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(t['sub'] as String,
                                style: TextStyle(
                                    color: AppColors.secondaryText(context),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${credit ? '+' : ''}${t['amount']}',
                            style: TextStyle(
                              color: credit
                                  ? AppColors.buttonColor(context)
                                  : AppColors.liveBadge(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(t['date'] as String,
                              style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, IconData icon, String label) =>
      Row(
        children: [
          Icon(icon, color: AppColors.secondaryText(context), size: 14),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5),
          ),
        ],
      );

  Widget _callRateRow(BuildContext context, IconData icon, String label,
      String sub, String rate,
      {bool first = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: first
                ? BorderSide.none
                : BorderSide(
                color: AppColors.borderLine(context), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: AppColors.buttonColor(context), size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(rate,
                  style: TextStyle(
                      color: AppColors.buttonColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Widget _paymentRow(BuildContext context, IconData icon, String label,
      String sub,
      {bool first = false}) =>
      Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: first
                ? BorderSide.none
                : BorderSide(
                color: AppColors.borderLine(context), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: AppColors.secondaryText(context), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text(sub,
                      style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Iconsax.tick_circle,
                color: AppColors.buttonColor(context), size: 16),
          ],
        ),
      );

  Widget _statCard(BuildContext context, IconData icon, String label,
      String value,
      {bool isPositive = false, bool isHeart = false}) {
    final color = isHeart
        ? AppColors.heartColor(context)
        : isPositive
        ? AppColors.buttonColor(context)
        : AppColors.liveBadge(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.borderLine(context), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Buy Bottom Sheet ──────────────────────────────────────────────────────

  void _showBuySheet(BuildContext context, Map<String, dynamic> p) {
    final tokens = p['tokens'] as int;
    final price = p['price'] as double;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLine(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.coin,
                      color: AppColors.buttonColor(context), size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tokens tokens',
                        style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    Text('₹${price.toStringAsFixed(2)} via Razorpay',
                        style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.borderLine(context), width: 0.5),
              ),
              child: Column(
                children: [
                  _sheetRow(context, Iconsax.video,
                      '~${(tokens / 6).floor()} min video calls'),
                  const SizedBox(height: 10),
                  _sheetRow(context, Iconsax.call,
                      '~${(tokens / 4).floor()} min voice calls'),
                  const SizedBox(height: 10),
                  _sheetRow(context, Iconsax.gift,
                      '~${(tokens / 10).floor()} gifts'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.card,
                        color: AppColors.buttonTextColor(context), size: 17),
                    const SizedBox(width: 8),
                    Text('Pay ₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: AppColors.buttonTextColor(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.shield_tick,
                      color: AppColors.secondaryText(context), size: 13),
                  const SizedBox(width: 5),
                  Text('Secured by Razorpay · 256-bit SSL',
                      style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(BuildContext context, IconData icon, String label) =>
      Row(
        children: [
          Icon(icon, color: AppColors.secondaryText(context), size: 15),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: AppColors.primaryText(context), fontSize: 13)),
        ],
      );
}