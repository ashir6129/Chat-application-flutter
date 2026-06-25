import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

class WithdrawalMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  const WithdrawalMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class LeaderboardEntry {
  final String name;
  final String avatar;
  final double amount;
  final String timeAgo;
  final String method;

  const LeaderboardEntry({
    required this.name,
    required this.avatar,
    required this.amount,
    required this.timeAgo,
    required this.method,
  });
}

class HistoryEntry {
  final double amount;
  final String method;
  final String date;
  final String status; // 'completed' | 'pending' | 'failed'

  const HistoryEntry({
    required this.amount,
    required this.method,
    required this.date,
    required this.status,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMethodId;
  final TextEditingController _amountController = TextEditingController();

  // ── Data ──────────────────────────────────────────────────────────────────

  final List<WithdrawalMethod> _methods = const [
    WithdrawalMethod(
      id: 'paypal',
      name: 'PayPal',
      subtitle: 'Instant transfer',
      icon: Iconsax.wallet_money,
      color: Color(0xFF003087),
    ),
    WithdrawalMethod(
      id: 'bank',
      name: 'Bank Transfer',
      subtitle: '1–3 business days',
      icon: Iconsax.bank,
      color: Color(0xFF2E7D32),
    ),
    WithdrawalMethod(
      id: 'crypto',
      name: 'Crypto (USDT)',
      subtitle: 'TRC-20 / ERC-20',
      icon: Iconsax.bitcoin_convert,
      color: Color(0xFFF7931A),
    ),
    WithdrawalMethod(
      id: 'skrill',
      name: 'Skrill',
      subtitle: 'Same-day transfer',
      icon: Iconsax.card,
      color: Color(0xFF862165),
    ),
  ];

  final List<LeaderboardEntry> _leaderboard = const [
    LeaderboardEntry(name: 'Alex_Pro', avatar: 'A', amount: 580.00, timeAgo: '2m ago', method: 'PayPal'),
    LeaderboardEntry(name: 'MariaCurator', avatar: 'M', amount: 420.50, timeAgo: '8m ago', method: 'Bank'),
    LeaderboardEntry(name: 'KingJay98', avatar: 'K', amount: 310.00, timeAgo: '15m ago', method: 'Crypto'),
    LeaderboardEntry(name: 'SunnyDev', avatar: 'S', amount: 220.75, timeAgo: '31m ago', method: 'Skrill'),
    LeaderboardEntry(name: 'Zheng_Li', avatar: 'Z', amount: 175.00, timeAgo: '1h ago', method: 'PayPal'),
  ];

  final List<HistoryEntry> _history = const [
    HistoryEntry(amount: 120.00, method: 'PayPal', date: 'Apr 22, 2026', status: 'completed'),
    HistoryEntry(amount: 75.50, method: 'PayPal', date: 'Apr 15, 2026', status: 'completed'),
    HistoryEntry(amount: 200.00, method: 'PayPal', date: 'Apr 08, 2026', status: 'completed'),
    HistoryEntry(amount: 50.00, method: 'Bank Transfer', date: 'Mar 30, 2026', status: 'failed'),
    HistoryEntry(amount: 300.00, method: 'Crypto', date: 'Mar 22, 2026', status: 'pending'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedMethodId = 'paypal';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  WithdrawalMethod? get _selected =>
      _methods.where((m) => m.id == _selectedMethodId).firstOrNull;

  void _showWithdrawConfirm(BuildContext context) {
    final amt = double.tryParse(_amountController.text) ?? 0;
    if (amt <= 0 || _selected == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        amount: amt,
        method: _selected!,
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistorySheet(history: _history),
    );
  }

  void _showMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MethodPickerSheet(
        methods: _methods,
        selectedId: _selectedMethodId,
        onSelected: (id) => setState(() => _selectedMethodId = id),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
            child: Icon(
              Iconsax.arrow_left,
              color: AppColors.primaryText(context),
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Withdraw',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showHistorySheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLine(context)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.dollar_circle, color: AppColors.buttonColor(context), size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'History',
                    style: TextStyle(
                      color: AppColors.buttonColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            _buildWithdrawToDropdown(context),
            const SizedBox(height: 20),
            _buildAmountSection(context),
            const SizedBox(height: 24),
            _buildWithdrawButton(context),
            const SizedBox(height: 28),
            _buildLeaderboardSection(context),
          ],
        ),
      ),
    );
  }

  // ── Balance Card ──────────────────────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.wallet_2, color: AppColors.mutedText(context), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Available to Withdraw',
                        style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$1,150.00',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Iconsax.dollar_square, color: AppColors.buttonColor(context), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'USD',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Withdraw To Dropdown ──────────────────────────────────────────────────

  Widget _buildWithdrawToDropdown(BuildContext context) {
    final method = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdraw To',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showMethodPicker(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: method != null
                    ? method.color.withOpacity(0.5)
                    : AppColors.borderLine(context),
                width: method != null ? 1.5 : 1,
              ),
            ),
            child: method == null
            // ── Placeholder ──
                ? Row(
              children: [
                Icon(Iconsax.wallet_add, color: AppColors.mutedText(context), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select withdrawal method',
                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 14),
                  ),
                ),
                Icon(Iconsax.arrow_down, color: AppColors.mutedText(context), size: 18),
              ],
            )
            // ── Selected method ──
                : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: method.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(method.icon, color: method.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        method.subtitle,
                        style: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right, color: AppColors.secondaryText(context), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Amount ────────────────────────────────────────────────────────────────

  Widget _buildAmountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdrawal Amount',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLine(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    color: AppColors.buttonColor(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _amountController.text = '1150.00'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MAX',
                          style: TextStyle(
                            color: AppColors.buttonColor(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min: \$10.00',
                      style: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Withdraw Button ───────────────────────────────────────────────────────

  Widget _buildWithdrawButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showWithdrawConfirm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.send_2, size: 18),
            SizedBox(width: 10),
            Text(
              'Withdraw Now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  Widget _buildLeaderboardSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Withdrawals',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLine(context)),
          ),
          child: Column(
            children: _leaderboard.asMap().entries.map((e) {
              return _buildLeaderboardRow(context, e.key, e.value);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(BuildContext context, int idx, LeaderboardEntry entry) {
    final medals = ['🥇', '🥈', '🥉'];
    final rankLabel = idx < 3 ? medals[idx] : '#${idx + 1}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: idx < _leaderboard.length - 1
            ? Border(bottom: BorderSide(color: AppColors.borderLine(context), width: 0.8))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(rankLabel, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.buttonColor(context).withOpacity(0.15),
            child: Text(
              entry.avatar,
              style: TextStyle(
                color: AppColors.buttonColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 10, color: AppColors.mutedText(context)),
                    const SizedBox(width: 4),
                    Text(entry.timeAgo, style: TextStyle(color: AppColors.mutedText(context), fontSize: 11)),
                    const SizedBox(width: 6),
                    Text('•', style: TextStyle(color: AppColors.mutedText(context), fontSize: 10)),
                    const SizedBox(width: 6),
                    Text(entry.method, style: TextStyle(color: AppColors.mutedText(context), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(color: AppColors.buttonColor(context), fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── Method Picker Sheet (custom dropdown) ─────────────────────────────────────

class _MethodPickerSheet extends StatelessWidget {
  final List<WithdrawalMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _MethodPickerSheet({
    required this.methods,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLine(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Method',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose where to send your earnings',
            style: TextStyle(color: AppColors.secondaryText(context), fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          ...methods.map((m) {
            final isSelected = m.id == selectedId;
            return GestureDetector(
              onTap: () {
                onSelected(m.id);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? m.color.withOpacity(0.08)
                      : AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? m.color : AppColors.borderLine(context),
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                m.subtitle,
                                style: TextStyle(color: AppColors.secondaryText(context), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? m.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? m.color : AppColors.borderLine(context),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 12)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── History Sheet ─────────────────────────────────────────────────────────────

class _HistorySheet extends StatelessWidget {
  final List<HistoryEntry> history;
  const _HistorySheet({required this.history});

  Color _statusColor(String s) {
    if (s == 'completed') return Colors.green;
    if (s == 'pending') return Colors.red;
    return Colors.red;
  }

  IconData _statusIcon(String s) {
    if (s == 'completed') return Iconsax.tick_circle;
    if (s == 'pending') return Iconsax.clock;
    return Iconsax.close_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.dollar_circle, color: AppColors.buttonColor(context), size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                'Withdrawal History',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${history.length} records',
                style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...history.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _statusColor(h.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon(h.status), color: _statusColor(h.status), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.method,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        h.date,
                        style: TextStyle(color: AppColors.mutedText(context), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-\$${h.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(h.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        h.status[0].toUpperCase() + h.status.substring(1),
                        style: TextStyle(
                          color: _statusColor(h.status),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Confirm Sheet ─────────────────────────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final double amount;
  final WithdrawalMethod method;
  const _ConfirmSheet({required this.amount, required this.method});

  @override
  Widget build(BuildContext context) {
    const fee = 0.50;
    final net = amount - fee;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLine(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.buttonColor(context).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.send_2, color: AppColors.buttonColor(context), size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Confirm Withdrawal',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _buildRow(context, 'Amount', '\$${amount.toStringAsFixed(2)}'),
          _buildRow(context, 'Platform Fee', '-\$${fee.toStringAsFixed(2)}'),
          _buildRow(context, 'You Receive', '\$${net.toStringAsFixed(2)}', highlight: true),
          _buildRow(context, 'Method', method.name),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.borderLine(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.secondaryText(context), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor(context),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13.5)),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.green : AppColors.primaryText(context),
              fontSize: 13.5,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}