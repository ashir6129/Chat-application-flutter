import 'package:flutter/material.dart';
import 'package:zyntraplus/screens/home_screen/stories_strip.dart';
import 'package:zyntraplus/screens/home_screen/whats_on_your_mind.dart';

import '../../core/app_colors.dart';
import 'feed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _feedKey = GlobalKey<FeedState>();

  Future<void> _onRefresh() async {
    await _feedKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.buttonColor(context),
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const StoriesStrip(),
          Divider(color: AppColors.borderLine(context), height: 1, thickness: 0.5),
          const WhatsOnYourMind(),
          Divider(color: AppColors.borderLine(context), height: 1, thickness: 0.5),
          Feed(key: _feedKey),
        ],
      ),
    );
  }
}
