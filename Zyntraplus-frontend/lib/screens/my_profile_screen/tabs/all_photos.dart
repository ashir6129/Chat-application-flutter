import 'package:flutter/material.dart';
import 'package:zyntraplus/widgets/profile/profile_posts_list.dart';

class AllPhotosTab extends StatelessWidget {
  const AllPhotosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePostsList(type: 'photos');
  }
}
