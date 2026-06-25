import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _calls = [
    {
      'name': 'Aryan Sharma',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'time': '10:12 AM',
      'duration': '4m 32s',
      'type': 'incoming', // incoming | outgoing | missed
      'isVideo': false,
    },
    {
      'name': 'Priya Singh',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'time': 'Yesterday',
      'duration': '',
      'type': 'missed',
      'isVideo': true,
    },
    {
      'name': 'Rahul Dev',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'time': 'Yesterday',
      'duration': '12m 10s',
      'type': 'outgoing',
      'isVideo': false,
    },
    {
      'name': 'Sneha Patel',
      'avatar': 'https://i.pravatar.cc/150?img=9',
      'time': 'Mon',
      'duration': '1m 05s',
      'type': 'incoming',
      'isVideo': true,
    },
    {
      'name': 'Aryan Sharma',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'time': 'Mon',
      'duration': '',
      'type': 'missed',
      'isVideo': false,
    },
    {
      'name': 'Rahul Dev',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'time': 'Sun',
      'duration': '7m 48s',
      'type': 'outgoing',
      'isVideo': true,
    },
  ];

  List<Map<String, dynamic>> get allCalls => _calls;
  List<Map<String, dynamic>> get missedCalls =>
      _calls.where((c) => c['type'] == 'missed').toList();

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

  Color _callColor(String type) {
    switch (type) {
      case 'missed':
        return Colors.red;
      case 'outgoing':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _callIcon(String type) {
    switch (type) {
      case 'missed':
        return Iconsax.call_minus;
      case 'outgoing':
        return Iconsax.call_outgoing;
      default:
        return Iconsax.call_incoming;
    }
  }

  String _callLabel(String type) {
    switch (type) {
      case 'missed':
        return 'Missed';
      case 'outgoing':
        return 'Outgoing';
      default:
        return 'Incoming';
    }
  }

  Widget _buildCallTile(Map<String, dynamic> call) {
    final color = _callColor(call['type']);
    final isMissed = call['type'] == 'missed';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(call['avatar']),
          ),

          const SizedBox(width: 12),

          // Name + call info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call['name'],
                  style: TextStyle(
                    fontWeight:
                    isMissed ? FontWeight.w700 : FontWeight.w500,
                    color: isMissed
                        ? Colors.red
                        : AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      _callIcon(call['type']),
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _callLabel(call['type']),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if ((call['duration'] as String).isNotEmpty) ...[
                      Text(
                        "  ·  ${call['duration']}",
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    // Video badge
                    if (call['isVideo'] == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                          AppColors.secondaryBackground(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.video,
                              size: 10,
                              color: AppColors.secondaryText(context),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "Video",
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                AppColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Time + call back button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                call['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText(context),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  // TODO: initiate call
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    call['isVideo'] == true
                        ? Iconsax.video
                        : Iconsax.call,
                    size: 16,
                    color: AppColors.buttonColor(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> calls) {
    if (calls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.call_slash,
                size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              "No calls here",
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, i) => _buildCallTile(calls[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Iconsax.arrow_left,
                        size: 20,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Calls",
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: New call
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Iconsax.call_add,
                        size: 20,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.buttonColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.secondaryText(context),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: "All Calls"),
                    Tab(text: "Missed"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(allCalls),
                  _buildList(missedCalls),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}