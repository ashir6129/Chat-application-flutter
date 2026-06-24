import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import 'add_money_screen.dart';
import 'withdraw_send_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context), size: 18),
          ),
        ),
        title: Text(
          'Wallet',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(context),
            const SizedBox(height: 20),
            _actionRow(context),
            const SizedBox(height: 28),
            _transactionHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Iconsax.wallet, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Your Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Zyntra Wallet',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '₦245,600.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Zyntra Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₦200,000', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Zyntra Bonus', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₦45,600', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Add Money',
            icon: Icons.add,
            textColor: const Color(0xFF4ADE80),
            borderColor: const Color(0xFF4ADE80),
            bgColor: const Color(0xFF0D2B1A),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMoneyScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Send',
            icon: Icons.send_outlined,
            textColor: const Color(0xFF38BDF8),
            borderColor: const Color(0xFF38BDF8),
            bgColor: const Color(0xFF0A1F2E),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WithdrawSendScreen(initialTab: 1),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Withdraw',
            icon: Icons.arrow_circle_up_outlined,
            textColor: const Color(0xFFB980F8),
            borderColor: const Color(0xFFB980F8),
            bgColor: const Color(0xFF1A0D2E),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WithdrawSendScreen(initialTab: 0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _transactionHistory(BuildContext context) {
    final transactions = [
      _Transaction('Product Sale', 'Air Zoom Pegasus 40', '+₦65,000', 'Today, 10 May', true, Icons.shopping_bag_outlined, const Color(0xFF22C55E), const Color(0xFF052E16)),
      _Transaction('Affiliate Commission', 'iPhone 15 Pro Max sale', '+₦7,500', 'Today, 10 May', true, Icons.link, const Color(0xFFA855F7), const Color(0xFF1A0938)),
      _Transaction('Withdraw to Bank', 'Opay · GTB', '-₦80,000', 'Yesterday, 09 May', false, Icons.account_balance_outlined, const Color(0xFF3B82F6), const Color(0xFF0A1528)),
      _Transaction('Add Money', 'Bank Transfer', '+₦400,000', 'Fri, 08 May', true, Icons.add_circle_outline, const Color(0xFF22C55E), const Color(0xFF052E16)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: TextStyle(color: AppColors.primaryText(context), fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'See all',
              style: TextStyle(color: const Color(0xFF00A884), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLine(context), width: 0.5),
          ),
          child: Column(
            children: transactions.asMap().entries.map((e) {
              final isLast = e.key == transactions.length - 1;
              final t = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(t.icon, color: t.iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: TextStyle(
                                  color: AppColors.primaryText(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.subtitle,
                                style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              t.amount,
                              style: TextStyle(
                                color: t.isCredit ? const Color(0xFF4ADE80) : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(t.date, style: TextStyle(color: AppColors.mutedText(context), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(color: AppColors.borderLine(context), height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color borderColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.borderColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Icon(icon, color: textColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Transaction {
  final String title, subtitle, amount, date;
  final bool isCredit;
  final IconData icon;
  final Color iconColor, bgColor;

  const _Transaction(this.title, this.subtitle, this.amount, this.date, this.isCredit, this.icon, this.iconColor, this.bgColor);
}
