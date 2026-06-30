import 'package:flutter/material.dart';
import 'package:zyntraplus/widgets/message/conversations_list_view.dart';

class MarketplaceMessagesScreen extends StatelessWidget {
  final bool embedded;

  const MarketplaceMessagesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ConversationsListView(embedded: embedded, directOnly: true, spaceType: 'marketplace');
  }
}
