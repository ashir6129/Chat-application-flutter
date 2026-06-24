import 'package:flutter/material.dart';
import 'package:zyntraplus/widgets/profile/profile_posts_list.dart';

class AllReelsTab extends StatelessWidget {
  const AllReelsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePostsList(type: 'reels');
  }
}
