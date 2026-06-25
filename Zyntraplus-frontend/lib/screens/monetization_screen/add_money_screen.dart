import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class _PaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  String _selectedMethodId = 'bank';
  final TextEditingController _amountController = TextEditingController();

  static const _methods = [
    _PaymentMethod(
      id: 'bank',
      title: 'Bank Transfer',
      subtitle: 'Transfer from your bank',
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFF60A5FA),
      bgColor: Color(0xFF0A1A2E),
    ),
    _PaymentMethod(
      id: 'card',
      title: 'Debit / Credit Card',
      subtitle: 'Visa, Mastercard, Verve',
      icon: Icons.credit_card_outlined,
      iconColor: Color(0xFFF472B6),
      bgColor: Color(0xFF1E0A1A),
    ),
    _PaymentMethod(
      id: 'mobile',
      title: 'Mobile Money',
      subtitle: 'Opay, Moniepoint, PalmPay',
      icon: Icons.phone_android_outlined,
      iconColor: Color(0xFF4ADE80),
      bgColor: Color(0xFF062012),
    ),
    _PaymentMethod(
      id: 'crypto',
      title: 'Crypto',
      subtitle: 'USDT, BTC, ETH and more',
      icon: Icons.currency_bitcoin,
      iconColor: Color(0xFFFB923C),
      bgColor: Color(0xFF1E1208),
    ),
  ];

  final _quickLabels = ['₦10K', '₦20K', '₦50K', '₦100K'];
  final _quickValues = [10000.0, 20000.0, 50000.0, 100000.0];

  void _selectQuick(double value) {
    setState(() => _amountController.text = value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
          'Add Money',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Payment Method',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            ..._methods.map((m) => _MethodTile(
              method: m,
              isSelected: _selectedMethodId == m.id,
              onTap: () => setState(() => _selectedMethodId = m.id),
            )),
            const SizedBox(height: 24),
            Text(
              'Enter Amount',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _buildAmountField(context),
            const SizedBox(height: 12),
            _buildQuickRow(context),
            const SizedBox(height: 28),
            _buildContinueButton(context),
            const SizedBox(height: 16),
            _buildSecurityNote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLine(context), width: 1),
      ),
      child: Row(
        children: [
          const Text(
            '₦',
            style: TextStyle(color: Color(0xFF00C48C), fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '50,000',
                hintStyle: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRow(BuildContext context) {
    return Row(
      children: List.generate(_quickLabels.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _quickLabels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _selectQuick(_quickValues[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLine(context), width: 1),
                ),
                child: Center(
                  child: Text(
                    _quickLabels[i],
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C48C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildSecurityNote(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 13, color: AppColors.mutedText(context)),
        const SizedBox(width: 6),
        Text(
          'Your money is secure with 256-bit SSL encryption',
          style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
        ),
      ],
    );
  }
}

// ─── Method Tile ──────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : AppColors.borderLine(context),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: method.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, color: method.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle,
                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 13),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : AppColors.borderLine(context),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
