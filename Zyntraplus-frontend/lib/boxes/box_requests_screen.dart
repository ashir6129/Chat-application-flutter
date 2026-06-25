import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class BoxRequestsScreen extends StatefulWidget {
  const BoxRequestsScreen({super.key});

  @override
  State<BoxRequestsScreen> createState() => _BoxRequestsScreenState();
}

class _BoxRequestsScreenState extends State<BoxRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReceivedTab(context),
                  _buildSentTab(context),
                ],
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
            child: Icon(Icons.chevron_left,
                color: AppColors.primaryText(context), size: 28),
          ),
          const Spacer(),
          Text(
            'Box Requests',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Icon(Icons.tune,
              color: AppColors.secondaryText(context), size: 22),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF9B59B6),
        indicatorWeight: 2,
        labelColor: const Color(0xFF9B59B6),
        unselectedLabelColor: AppColors.secondaryText(context),
        labelStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        tabs: const [
          Tab(text: 'Received'),
          Tab(text: 'Sent'),
        ],
      ),
    );
  }

  Widget _buildReceivedTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildMysteryBoxCard(context),
        ],
      ),
    );
  }

  Widget _buildMysteryBoxCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.borderLine(context).withOpacity(0.5), width: 1),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9B59B6).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 8, left: 20,
                    child: _buildSparkle(color: const Color(0xFF9B59B6))),
                Positioned(
                    top: 15, right: 25,
                    child: _buildSparkle(color: const Color(0xFFFFD700))),
                Positioned(
                    bottom: 10, left: 30,
                    child: _buildSparkle(color: const Color(0xFF9B59B6), size: 5)),
                Positioned(
                    bottom: 5, right: 20,
                    child: _buildSparkle(color: const Color(0xFFFFD700), size: 5)),
                const Text('🎁', style: TextStyle(fontSize: 90)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Someone sent you a Box!',
              style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the box to see what\'s inside',
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkle({required Color color, double size = 7}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSentTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.outbox_outlined,
              size: 48, color: AppColors.mutedText(context)),
          const SizedBox(height: 12),
          Text('No sent boxes yet',
              style: TextStyle(
                  color: AppColors.secondaryText(context), fontSize: 15)),
          const SizedBox(height: 6),
          Text('Boxes you send will appear here',
              style: TextStyle(
                  color: AppColors.mutedText(context), fontSize: 13)),
        ],
      ),
    );
  }
}