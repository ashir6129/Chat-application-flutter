import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../api_services/box_service.dart';
import 'receive_box.dart';

class BoxRequestsScreen extends StatefulWidget {
  final int initialTab;
  const BoxRequestsScreen({super.key, this.initialTab = 0});

  @override
  State<BoxRequestsScreen> createState() => _BoxRequestsScreenState();
}

class _BoxRequestsScreenState extends State<BoxRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _receivedRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final rec = await BoxService.getReceivedBoxRequests();
      final sent = await BoxService.getSentBoxRequests();
      if (mounted) {
        setState(() {
          _receivedRequests = rec;
          _sentRequests = sent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
        ),
      );
    }

    if (_receivedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text('No received boxes yet',
                style: TextStyle(
                    color: AppColors.secondaryText(context), fontSize: 15)),
            const SizedBox(height: 6),
            Text('Received boxes will appear here',
                style: TextStyle(
                    color: AppColors.mutedText(context), fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final req = _receivedRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMysteryBoxCard(context, req),
        );
      },
    );
  }

  Widget _buildMysteryBoxCard(BuildContext context, Map<String, dynamic> request) {
    return GestureDetector(
      onTap: () async {
        final processed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiveBoxScreen(request: request),
          ),
        );
        if (processed == true) {
          _loadRequests();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.borderLine(context).withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Box from ${request['sender_username'] ?? 'Someone'}',
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to open and view note',
                    style: TextStyle(
                        color: AppColors.secondaryText(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2218),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '${request['coins'] ?? 50}',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
        ),
      );
    }

    if (_sentRequests.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final req = _sentRequests[index];
        Color statusColor = const Color(0xFFFF9F0A); // pending
        if (req['status'] == 'accepted') {
          statusColor = const Color(0xFF30D158);
        } else if (req['status'] == 'declined') {
          statusColor = const Color(0xFFFF453A);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.borderLine(context).withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sent to ${req['receiver_username'] ?? 'Someone'}',
                      style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coins: ${req['coins'] ?? 50}',
                      style: TextStyle(
                          color: AppColors.secondaryText(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  req['status']?.toString().toUpperCase() ?? 'PENDING',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}