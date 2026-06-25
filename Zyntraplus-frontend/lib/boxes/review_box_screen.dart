import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ReviewBoxScreen extends StatelessWidget {
  final int coins;
  final String note;

  const ReviewBoxScreen({
    super.key,
    this.coins = 50,
    this.note =
    'Hey! I saw your profile and thought you seem really cool. Would love to get to know you better. 😊',
  });

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
                child: Column(
                  children: [
                    _buildGiftIllustration(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSendingAndNoteCard(context),
                          const SizedBox(height: 20),
                          _buildImportantToKnow(context),
                          const SizedBox(height: 28),
                          _buildSendButton(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
          const Spacer(),
          Text(
            'Review Box',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildGiftIllustration(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      color: AppColors.primaryBackground(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: 30, left: 70,
              child: _buildCoinParticle(size: 22)),
          Positioned(
              top: 20, right: 80,
              child: _buildCoinParticle(size: 18)),
          Positioned(
              bottom: 50, left: 60,
              child: _buildCoinParticle(size: 14)),
          Positioned(
              bottom: 40, right: 70,
              child: _buildCoinParticle(size: 20)),
          Positioned(
              top: 60, right: 50,
              child: _buildCoinParticle(size: 12)),
          Text('🎁', style: const TextStyle(fontSize: 100)),
        ],
      ),
    );
  }
  Widget _buildSendingAndNoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'You are sending',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '$coins Coins',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Your Note',
            style: TextStyle(
              color: const Color(0xFF9B59B6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryText(context).withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Text(
              note,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCoinParticle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildImportantToKnow(BuildContext context) {
    final items = [
      'They can accept or decline your box',
      'Coins will only be charged if accepted',
      'Be respectful and keep it friendly',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Important to know',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF00A884), width: 1.5),
                ),
                child: const Icon(Icons.check,
                    size: 12, color: Color(0xFF00A884)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item,
                    style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 13,
                        height: 1.4)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text('Send Box',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }
}