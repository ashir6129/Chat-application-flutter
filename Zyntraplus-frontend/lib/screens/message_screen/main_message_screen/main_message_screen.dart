import 'package:flutter/material.dart';
import 'package:zyntraplus/widgets/message/conversations_list_view.dart';

class MainMessageScreen extends StatelessWidget {
  final bool embedded;

  const MainMessageScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ConversationsListView(embedded: embedded);
  }
}
