import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../api_services/box_service.dart';
import 'review_box_screen.dart';

class SendBoxScreen extends StatefulWidget {
  final String targetUserId;
  final String username;
  final String avatarUrl;
  final String distance;

  const SendBoxScreen({
    super.key,
    required this.targetUserId,
    required this.username,
    required this.avatarUrl,
    required this.distance,
  });

  @override
  State<SendBoxScreen> createState() => _SendBoxScreenState();
}

class _SendBoxScreenState extends State<SendBoxScreen> {
  int _selectedCoins = 50;
  final TextEditingController _noteController = TextEditingController();
  final List<int> _coinOptions = [10, 25, 50, 100];
  int _walletBalance = 0;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final balanceData = await BoxService.getWalletBalance();
      debugPrint("DEBUG: balanceData fetched: $balanceData");
      if (mounted) {
        setState(() {
          final balanceVal = balanceData['balance_credits'] ?? balanceData['balance'];
          debugPrint("DEBUG: balanceVal: $balanceVal");
          _walletBalance = balanceVal != null
              ? int.tryParse(balanceVal.toString()) ?? 0
              : 0;
          debugPrint("DEBUG: parsed _walletBalance: $_walletBalance");
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      debugPrint("DEBUG: Error loading wallet: $e");
      if (mounted) {
        setState(() {
          _isLoadingWallet = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildLockIcon(context),
                    const SizedBox(height: 20),
                    _buildNotConnectedText(context),
                    const SizedBox(height: 24),
                    _buildSendBoxCard(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                color: AppColors.primaryText(context), size: 24),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.avatarUrl.isNotEmpty
                    ? NetworkImage(widget.avatarUrl)
                    : null,
                backgroundColor: AppColors.secondaryBackground(context),
                child: widget.avatarUrl.isEmpty
                    ? Icon(Icons.person, color: AppColors.secondaryText(context))
                    : null,
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A884),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primaryBackground(context), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.username,
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(widget.distance,
                    style: TextStyle(
                        color: AppColors.secondaryText(context), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.more_horiz,
              color: AppColors.secondaryText(context), size: 22),
        ],
      ),
    );
  }

  Widget _buildLockIcon(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryBackground(context),
        border: Border.all(
            color: const Color(0xFF3B4A54).withOpacity(0.6), width: 1.5),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withOpacity(0.15),
              ),
            ),
            Icon(Icons.lock_outline,
                size: 36, color: const Color(0xFF7C3AED).withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotConnectedText(BuildContext context) {
    return Column(
      children: [
        Text(
          'You haven\'t connected yet',
          style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Send a Box to introduce yourself\nand start the conversation.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
              height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSendBoxCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLine(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Send a Box ',
                  style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const Text('🎁', style: TextStyle(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Add coins and a note to stand out!',
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 12)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Coins',
                  style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text('Balance: $_walletBalance 🪙',
                  style: TextStyle(
                      color: const Color(0xFFFF9F0A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ..._coinOptions.map((coin) => _buildCoinChip(context, coin)),
              const SizedBox(width: 6),
              _buildCustomChip(context),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.add, color: AppColors.secondaryText(context), size: 12),
              const SizedBox(width: 4),
              Text('Higher coins increase acceptance chances',
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add a Note',
                  style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text('(optional)',
                  style: TextStyle(
                      color: AppColors.secondaryText(context), fontSize: 12)),
              const Spacer(),
              Text(
                '${_noteController.text.length}/120',
                style: TextStyle(
                    color: AppColors.mutedText(context), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: TextField(
              controller: _noteController,
              maxLength: 120,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                  color: AppColors.primaryText(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Say something nice...',
                hintStyle:
                TextStyle(color: AppColors.mutedText(context), fontSize: 14),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 30),
                  child: Icon(Icons.favorite,
                      color: AppColors.heartColor(context), size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_walletBalance < _selectedCoins) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient wallet balance. You have $_walletBalance coins.')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewBoxScreen(
                      targetUserId: widget.targetUserId,
                      username: widget.username,
                      avatarUrl: widget.avatarUrl,
                      distance: widget.distance,
                      coins: _selectedCoins,
                      note: _noteController.text,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Box',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 12, color: AppColors.mutedText(context)),
              const SizedBox(width: 4),
              Text('Coins will only be charged if accepted',
                  style: TextStyle(
                      color: AppColors.mutedText(context), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinChip(BuildContext context, int coin) {
    final isSelected = _selectedCoins == coin;
    return GestureDetector(
      onTap: () => setState(() => _selectedCoins = coin),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED).withOpacity(0.2)
              : AppColors.primaryBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : AppColors.borderLine(context),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 3),
            Text(
              '$coin',
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF7C3AED)
                    : AppColors.primaryText(context),
                fontSize: 13,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLine(context), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined,
              size: 12, color: AppColors.secondaryText(context)),
          const SizedBox(width: 3),
          Text('Custom',
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 12)),
        ],
      ),
    );
  }
}