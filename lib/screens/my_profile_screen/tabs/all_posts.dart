import 'package:flutter/material.dart';
import 'package:zyntraplus/widgets/profile/profile_posts_list.dart';

class AllPostsTab extends StatelessWidget {
  const AllPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePostsList(type: 'all');
  }
}
