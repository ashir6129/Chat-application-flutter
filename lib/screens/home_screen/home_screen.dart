import 'package:flutter/material.dart';
import 'package:zyntraplus/screens/home_screen/stories_strip.dart';
import 'package:zyntraplus/screens/home_screen/whats_on_your_mind.dart';

import '../../core/app_colors.dart';
import '../../core/home_scroll_notifier.dart';
import 'feed.dart';

import '../../core/tab_scroll_to_top.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _feedKey = GlobalKey<FeedState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    TabScrollToTop.register(0, _scrollToTop);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    HomeScrollNotifier.instance.scrollOffset.value =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
  }

  @override
  void dispose() {
    TabScrollToTop.unregister(0);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    HomeScrollNotifier.instance.scrollOffset.value = 0.0;
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onRefresh() async {
    await _feedKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.buttonColor(context),
      onRefresh: _onRefresh,
      child: ListView(
        controller: _scrollController,
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
